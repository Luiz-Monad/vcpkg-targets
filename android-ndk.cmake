message(STATUS "Custom Android NDK Toolchain")

set (ANDROID_SDK_ROOT "C:/Microsoft/AndroidSDK/25")
set (ANDROID_NDK_ROOT "C:/Microsoft/AndroidSDK/25/ndk")
set (ANDROID_NDK_VERSION "22.1.7171670")
set (ANDROID_NDK_SYSTEM_VERSION 29)
set (ANDROID_NDK_NINJA "C:/Microsoft/AndroidSDK/25/cmake/3.10.2.4988404/bin/ninja.exe")

message(STATUS "root:    ${ANDROID_SDK_ROOT}")
message(STATUS "ndk:     ${ANDROID_NDK_ROOT}")
message(STATUS "ndk_ver: ${ANDROID_NDK_VERSION}")
message(STATUS "sys_ver: ${ANDROID_NDK_SYSTEM_VERSION}")
message(STATUS "ninja:   ${ANDROID_NDK_NINJA}")

# 3. Set VCPKG_TARGET_TRIPLET according to ANDROID_ABI
# 
# There are four different Android ABI, each of which maps to 
# a vcpkg triplet. The following table outlines the mapping from vcpkg architectures to android architectures
#
# |VCPKG_TARGET_TRIPLET       | ANDROID_ABI          |
# |---------------------------|----------------------|
# |arm64-android              | arm64-v8a            |
# |arm-android                | armeabi-v7a          |
# |x64-android                | x86_64               |
# |x86-android                | x86                  |
#

if (VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(ANDROID_ABI arm64-v8a CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "armv6")
    set(ANDROID_ABI armeabi CACHE STRING "")
    set(ANDROID_ARM_MODE arm CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    set(ANDROID_ABI armeabi-v7a CACHE STRING "")
    set(ANDROID_ARM_NEON ON CACHE BOOL "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "armv7")
    set(ANDROID_ABI armeabi-v7a CACHE STRING "")
    set(ANDROID_ARM_NEON OFF CACHE BOOL "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(ANDROID_ABI x86_64 CACHE STRING "")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(ANDROID_ABI x86 CACHE STRING "")
else()
    message(FATAL_ERROR "Unknown ABI for target triplet ${VCPKG_TARGET_TRIPLET}")
endif()
if (VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(ANDROID_STL_TYPE c++_shared CACHE STRING "")
else()
    set(ANDROID_STL_TYPE c++_static CACHE STRING "")
endif()
set(ANDROID_SDK ${ANDROID_SDK_ROOT} CACHE STRING "")
set(ANDROID_NDK ${ANDROID_NDK_ROOT}/${ANDROID_NDK_VERSION} CACHE STRING "")
set(ANDROID_NATIVE_API_LEVEL ${ANDROID_NDK_SYSTEM_VERSION} CACHE STRING "")
set(ANDROID_PLATFORM=android-${ANDROID_NATIVE_API_LEVEL} CACHE STRING "")

set(CMAKE_SYSTEM_NAME "Android" CACHE STRING "")
set(CMAKE_SYSTEM_VERSION ${ANDROID_NATIVE_API_LEVEL} CACHE STRING "")
set(CMAKE_MAKE_PROGRAM $ENV{ANDROID_NDK_NINJA} CACHE STRING "")
set(CMAKE_ANDROID_ARCH_ABI ${ANDROID_ABI} CACHE STRING "")
set(CMAKE_ANDROID_NDK ${ANDROID_NDK} CACHE STRING "")
set(CMAKE_ANDROID_STL_TYPE ${ANDROID_STL_TYPE} CACHE STRING "")

if(NOT _VCPKG_ANDROID_TOOLCHAIN)
    set(_VCPKG_ANDROID_TOOLCHAIN 1)
    get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
    if(NOT _CMAKE_IN_TRY_COMPILE)
        string(APPEND CMAKE_C_FLAGS " -fPIC ${VCPKG_C_FLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS " -fPIC ${VCPKG_CXX_FLAGS} ")
        string(APPEND CMAKE_C_FLAGS_DEBUG " ${VCPKG_C_FLAGS_DEBUG} ")
        string(APPEND CMAKE_CXX_FLAGS_DEBUG " ${VCPKG_CXX_FLAGS_DEBUG} ")
        string(APPEND CMAKE_C_FLAGS_RELEASE " ${VCPKG_C_FLAGS_RELEASE} ")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE " ${VCPKG_CXX_FLAGS_RELEASE} ")

        string(APPEND CMAKE_SHARED_LINKER_FLAGS " ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS " ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG " ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG " ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE " ${VCPKG_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE " ${VCPKG_LINKER_FLAGS_RELEASE} ")
    endif()
endif()
