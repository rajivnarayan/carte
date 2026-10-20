#!/usr/bin/with-contenv bash

AUTOSELECT_BLAS=${AUTOSELECT_BLAS:=none}
# Opt-in: use Arm Performance Libraries instead of OpenBLAS on ARM CPUs
USE_ARMPL=${USE_ARMPL:=false}
ARMPL_VERSION=${ARMPL_VERSION:=26.07}

set -e

if [[ $AUTOSELECT_BLAS == 'true' ]]; then
	# Detect CPU
	VENDOR=$(lscpu | awk -F: '/Vendor ID/{print $2}' | tr -d ' ')
	FLAGS=$(lscpu | awk -F: '/Flags/ {print $2}')

	echo "Auto selecting BLAS library based on CPU $VENDOR"

	# R links libblas.so.3/liblapack.so.3 dynamically, so switching the Debian
	# alternatives is what reaches every R process. LD_PRELOAD in the s6
	# container environment does not: rserver scrubs it (along with MKL_*)
	# before spawning rsession, so R sessions fall back to the default OpenBLAS.
	# Multiarch triplet, e.g. x86_64-linux-gnu or aarch64-linux-gnu
	TRIPLET=$(uname -m)-linux-gnu
	ALT_BLAS=libblas.so.3-${TRIPLET}
	ALT_LAPACK=liblapack.so.3-${TRIPLET}

	# Pick best library for CPU
	case "$VENDOR" in
	  GenuineIntel*)
	    apt-get update && apt-get install -y intel-mkl
	    # Sapphire Rapids+ → MKL (well-tested, fast, correct)
	    update-alternatives --set $ALT_BLAS /usr/lib/${TRIPLET}/libmkl_rt.so
	    update-alternatives --set $ALT_LAPACK /usr/lib/${TRIPLET}/libmkl_rt.so
	    # MKL reads these on its first call, so Renviron.site is early enough
	    printf 'MKL_INTERFACE_LAYER=LP64\nMKL_THREADING_LAYER=GNU\n' >> /usr/lib/R/etc/Renviron.site
	    echo "[blas] Intel CPU detected using using MKL"
	    ;;
	  AuthenticAMD*)
	    apt-get update && apt-get install -y libblis4-pthread
	    # AMD Zen3/Zen4 (c7a/c8a) → BLIS (AMD's own, excellent on Zen)
	    # BLIS ships BLAS only, so LAPACK stays on OpenBLAS
	    update-alternatives --set $ALT_BLAS /usr/lib/${TRIPLET}/blis-pthread/libblas.so.3
	    echo "[blas] AMD CPU detected using using BLIS"
	    ;;
	  *)
	    if [[ $(uname -m) == 'aarch64' && $USE_ARMPL == 'true' ]]; then
	      # ARM (Graviton, Ampere) opt-in → Arm Performance Libraries (BLAS + LAPACK)
	      ARMPL_TMP=$(mktemp -d)
	      wget -q -O ${ARMPL_TMP}/armpl.tar \
	        "https://developer.arm.com/-/cdn-downloads/permalink/Arm-Performance-Libraries/Version_${ARMPL_VERSION}/arm-performance-libraries_${ARMPL_VERSION}_deb_gcc.tar"
	      tar -xf ${ARMPL_TMP}/armpl.tar -C ${ARMPL_TMP}
	      bash ${ARMPL_TMP}/arm-performance-libraries_${ARMPL_VERSION}_deb/arm-performance-libraries_${ARMPL_VERSION}_deb.sh --accept
	      rm -rf ${ARMPL_TMP}
	      # OpenMP build, so R gets multithreaded BLAS like OpenBLAS pthread
	      ARMPL_LIB=$(find /opt/arm -name libarmpl_lp64_mp.so -path '*_gcc/lib/*' | head -n 1)
	      if [[ -z $ARMPL_LIB ]]; then
	        echo "[blas] libarmpl_lp64_mp.so not found under /opt/arm, keeping default BLAS"
	        exit 1
	      fi
	      # libarmpl depends on other libraries (e.g. libamath) in the same directory
	      echo "$(dirname ${ARMPL_LIB})" > /etc/ld.so.conf.d/armpl.conf
	      ldconfig
	      # ArmPL does not register itself as an alternative, so add it first
	      update-alternatives --install /usr/lib/${TRIPLET}/libblas.so.3 $ALT_BLAS $ARMPL_LIB 100
	      update-alternatives --install /usr/lib/${TRIPLET}/liblapack.so.3 $ALT_LAPACK $ARMPL_LIB 100
	      update-alternatives --set $ALT_BLAS $ARMPL_LIB
	      update-alternatives --set $ALT_LAPACK $ARMPL_LIB
	      echo "[blas] $VENDOR CPU using Arm Performance Libraries ${ARMPL_VERSION}"
	    else
	      apt-get update && apt-get install -y libopenblas0-pthread
	      # Graviton or fallback → OpenBLAS with safe kernel
	      update-alternatives --set $ALT_BLAS /usr/lib/${TRIPLET}/openblas-pthread/libblas.so.3
	      update-alternatives --set $ALT_LAPACK /usr/lib/${TRIPLET}/openblas-pthread/liblapack.so.3
	      if [[ $(uname -m) == 'x86_64' ]]; then
	        # OpenBLAS reads this when the library loads, too early for Renviron.site,
	        # so it only reaches processes started with with-contenv
	        printf Haswell > /var/run/s6/container_environment/OPENBLAS_CORETYPE
	        echo "[blas] Unknown vendor using OpenBLAS (Haswell kernel)"
	      else
	        # ARM (Graviton, Ampere): Haswell is an x86 kernel, let OpenBLAS autodetect
	        echo "[blas] $VENDOR CPU using OpenBLAS (autodetected kernel)"
	      fi
	    fi
	    ;;
	esac
	rm -rf /var/lib/apt/lists/*
else
	echo "Using Default BLAS, to auto select specify AUTOSELECT_BLAS"

fi

