# detect-arch.cmake -- Detect compiler architecture and set ARCH and BASEARCH
# Copyright (C) 2019 Hans Kristian Rosbach
# Licensed under the Zlib license, see LICENSE.md for details
set(ARCHDETECT_FOUND TRUE)

if(CMAKE_OSX_ARCHITECTURES)
    # If multiple architectures are requested (universal build), pick only the first
    list(GET CMAKE_OSX_ARCHITECTURES 0 ARCH)
elseif(MSVC)
    if("${MSVC_C_ARCHITECTURE_ID}" STREQUAL "X86")
        set(ARCH "i686")
    elseif("${MSVC_C_ARCHITECTURE_ID}" STREQUAL "x64")
        set(ARCH "x86_64")
    elseif("${MSVC_C_ARCHITECTURE_ID}" STREQUAL "ARM" OR "${MSVC_C_ARCHITECTURE_ID}" STREQUAL "ARMV7")
        set(ARCH "arm")
    elseif ("${MSVC_C_ARCHITECTURE_ID}" STREQUAL "ARM64")
        set(ARCH "aarch64")
    endif()
elseif(CMAKE_CROSSCOMPILING)
    set(ARCH ${CMAKE_C_COMPILER_TARGET})
else()
    # Let preprocessor parse archdetect.c and raise an error containing the arch identifier
    enable_language(C)
    try_run(
        run_result_unused
        compile_result_unused
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/cmake/detect-arch.c
        COMPILE_OUTPUT_VARIABLE RAWOUTPUT
        CMAKE_FLAGS CMAKE_OSX_ARCHITECTURES=${CMAKE_OSX_ARCHITECTURES}
    )

    # Find basearch tag, and extract the arch word into BASEARCH variable
    string(REGEX REPLACE ".*archfound ([a-zA-Z0-9_]+).*" "\\1" ARCH "${RAWOUTPUT}")
    if (NOT ARCH)
        set(ARCH unknown)
    endif()
endif()

# Make sure we have ARCH set
if(NOT ARCH OR ARCH STREQUAL "unknown")
    set(ARCH ${CMAKE_SYSTEM_PROCESSOR})
    message(STATUS "Arch not recognized, falling back to cmake arch: '${ARCH}'")
else()
    message(STATUS "Arch detected: '${ARCH}'")
endif()

# Base arch detection
if("${ARCH}" MATCHES "(x86_64|AMD64|i[3-6]86)")
    set(BASEARCH "x86")
    set(BASEARCH_X86_FOUND TRUE)
elseif("${ARCH}" MATCHES "(arm(v[0-9])?|aarch64)")
    set(BASEARCH "arm")
    set(BASEARCH_ARM_FOUND TRUE)
elseif("${ARCH}" MATCHES "ppc(64(le)?)?|powerpc(64(le)?)?")
    set(BASEARCH "ppc")
    set(BASEARCH_PPC_FOUND TRUE)
elseif("${ARCH}" MATCHES "alpha")
    set(BASEARCH "alpha")
    set(BASEARCH_ALPHA_FOUND TRUE)
elseif("${ARCH}" MATCHES "blackfin")
    set(BASEARCH "blackfin")
    set(BASEARCH_BLACKFIN_FOUND TRUE)
elseif("${ARCH}" MATCHES "ia64")
    set(BASEARCH "ia64")
    set(BASEARCH_IA64_FOUND TRUE)
elseif("${ARCH}" MATCHES "mips")
    set(BASEARCH "mips")
    set(BASEARCH_MIPS_FOUND TRUE)
elseif("${ARCH}" MATCHES "m68k")
    set(BASEARCH "m68k")
    set(BASEARCH_M68K_FOUND TRUE)
elseif("${ARCH}" MATCHES "sh")
    set(BASEARCH "sh")
    set(BASEARCH_SH_FOUND TRUE)
elseif("${ARCH}" MATCHES "sparc[89]?")
    set(BASEARCH "sparc")
    set(BASEARCH_SPARC_FOUND TRUE)
elseif("${ARCH}" MATCHES "s3[679]0x?")
    set(BASEARCH "s360")
    set(BASEARCH_S360_FOUND TRUE)
elseif("${ARCH}" MATCHES "parisc")
    set(BASEARCH "parisc")
    set(BASEARCH_PARISC_FOUND TRUE)
elseif("${ARCH}" MATCHES "rs6000")
    set(BASEARCH "rs6000")
    set(BASEARCH_RS6000_FOUND TRUE)
else()
    set(BASEARCH "x86")
    set(BASEARCH_X86_FOUND TRUE)
    message(STATUS "Basearch '${ARCH}' not recognized, defaulting to 'x86'.")
endif()
message(STATUS "Basearch of '${ARCH}' has been detected as: '${BASEARCH}'")
