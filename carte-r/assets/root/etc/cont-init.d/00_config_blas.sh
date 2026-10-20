#!/usr/bin/with-contenv bash

AUTOSELECT_BLAS=${AUTOSELECT_BLAS:=none}

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
	    ;;
	esac
	rm -rf /var/lib/apt/lists/*
else
	echo "Using Default BLAS, to auto select specify AUTOSELECT_BLAS"

fi

