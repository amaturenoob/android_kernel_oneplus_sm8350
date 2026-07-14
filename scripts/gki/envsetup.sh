#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Copyright (c) 2019, The Linux Foundation. All rights reserved.

SCRIPT_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
KERN_SRC="$(readlink -f "${SCRIPT_DIR}/../../")"

# Ensure we are in the kernel source root
cd "${KERN_SRC}" || return 1 2>/dev/null || exit 1

if [ -z "$1" ]; then
    echo "Error: PLATFORM_NAME not provided." >&2
    echo "Usage: source scripts/gki/envsetup.sh <platform_name> [base_defconfig]" >&2
    return 1 2>/dev/null || exit 1
fi

: ${ARCH:=arm64}
: ${CROSS_COMPILE:=aarch64-linux-gnu-}
: ${CLANG_TRIPLE:=aarch64-linux-gnu-}
: ${REAL_CC:=clang}
: ${HOSTCC:=gcc}
: ${HOSTLD:=ld}
: ${HOSTAR:=ar}
: ${KERN_OUT:=}

CONFIGS_DIR="${KERN_SRC}/arch/${ARCH}/configs/vendor"

PLATFORM_NAME="$1"

BASE_DEFCONFIG="${KERN_SRC}/arch/${ARCH}/configs/${2:-gki_defconfig}"

# Fragments that are available for the platform
OPLUS_GKI_FRAG="${CONFIGS_DIR}/oplus_GKI.config"
OPLUS_QGKI_FRAG="${CONFIGS_DIR}/oplus_QGKI.config"
QCOM_GKI_FRAG="${CONFIGS_DIR}/${PLATFORM_NAME}_GKI.config"
QCOM_QGKI_FRAG="${CONFIGS_DIR}/${PLATFORM_NAME}_QGKI.config"
QCOM_DEBUG_FRAG="${CONFIGS_DIR}/${PLATFORM_NAME}_debug.config"

# For user variant build merge debugfs.config fragment.
if [ "${TARGET_BUILD_VARIANT}" == "user" ]; then
    if [ -f "${CONFIGS_DIR}/debugfs.config" ]; then
        QCOM_DEBUG_FS_FRAG="${CONFIGS_DIR}/debugfs.config"
    else
        QCOM_DEBUG_FS_FRAG=" "
    fi
else
    QCOM_DEBUG_FS_FRAG=" "
fi

# Consolidate fragment may not be present for all platforms.
CONSOLIDATE_PATH="${CONFIGS_DIR}/${PLATFORM_NAME}_consolidate.config"
if [ -f "$CONSOLIDATE_PATH" ]; then
    QCOM_CONSOLIDATE_FRAG="$CONSOLIDATE_PATH"
else
    QCOM_CONSOLIDATE_FRAG=" "
fi

QCOM_GENERIC_PERF_FRAG="${CONFIGS_DIR}/${PLATFORM_NAME}.config"
QCOM_GENERIC_DEBUG_FRAG="${CONFIGS_DIR}/${PLATFORM_NAME}-debug.config"

export ARCH CROSS_COMPILE REAL_CC HOSTCC HOSTLD HOSTAR KERN_SRC KERN_OUT \
    CONFIGS_DIR BASE_DEFCONFIG OPLUS_GKI_FRAG OPLUS_QGKI_FRAG QCOM_GKI_FRAG \
    QCOM_QGKI_FRAG QCOM_DEBUG_FRAG QCOM_DEBUG_FS_FRAG QCOM_CONSOLIDATE_FRAG \
    QCOM_GENERIC_PERF_FRAG QCOM_GENERIC_DEBUG_FRAG PLATFORM_NAME

graddle init /home/skep/StudioProjects/android_kernel_oneplus_sm8350/gradle/wrapper