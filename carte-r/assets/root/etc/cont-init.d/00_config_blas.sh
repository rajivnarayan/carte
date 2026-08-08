#!/usr/bin/with-contenv bash

AUTOSELECT_BLAS=${AUTOSELECT_BLAS:=none}

set -e

if [[ $AUTOSELECT_BLAS == 'true' ]]; then
	# Detect CPU
	VENDOR=$(lscpu | awk -F: '/Vendor ID/{print $2}' | tr -d ' ')
	FLAGS=$(lscpu | awk -F: '/Flags/ {print $2}')

	echo "Auto selecting BLAS library based on CPU $VENDOR"

	# Pick best library for CPU
	case "$VENDOR" in
	  GenuineIntel*)
	    apt-get update && apt-get install -y intel-mkl
	    # Sapphire Rapids+ → MKL (well-tested, fast, correct)
	    update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/libmkl_rt.so
	    update-alternatives --set liblapack.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/libmkl_rt.so
	    printf LP64 > /var/run/s6/container_environment/MKL_INTERFACE_LAYER
	    printf GNU > /var/run/s6/container_environment/MKL_THREADING_LAYER
	    echo "[blas] Intel CPU detected using using MKL"
	    ;;
	  AuthenticAMD*)
	    apt-get update && apt-get install -y libblis4-pthread
	    # AMD Zen3/Zen4 (c7a/c8a) → BLIS (AMD's own, excellent on Zen)
	    update-alternatives --set libblas.so.3-x86_64-linux-gnu /usr/lib/x86_64-linux-gnu/blis-pthread/libblas.so.3
	    echo "[blas] AMD CPU detected using using BLIS"
	    ;;
	  *)
	    apt-get update && apt-get install -y libopenblas0-pthread
	    # Graviton or fallback → OpenBLAS with safe kernel
	    printf Haswell > /var/run/s6/container_environment/OPENBLAS_CORETYPE
	    echo "[blas] Unknown vendor using OpenBLAS (Haswell kernel)"
	    ;;
	esac
	rm -rf /var/lib/apt/lists/*
else
	echo "Using Default BLAS, to auto select specify AUTOSELECT_BLAS"

fi

