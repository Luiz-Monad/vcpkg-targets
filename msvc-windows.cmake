message(STATUS "Custom Windows MSVC Toolchain")

if("" STREQUAL "$ENV{DevEnvDir}")
    message(STATUS "Running Enter-DevShell")
    find_program(PWSH_PATH pwsh)
    execute_process(
        COMMAND "${PWSH_PATH}" 
            "-nop"
            "-file"
            "${CMAKE_CURRENT_LIST_DIR}/enter_devshell.ps1"
        WORKING_DIRECTORY        
            "${CMAKE_CURRENT_BINARY_DIR}"
        RESULT_VARIABLE _result
    )
    if(NOT _result EQUAL 0)
      message(FATAL_ERROR "Enter-DevShell failed")
    endif()
    include("${CMAKE_CURRENT_BINARY_DIR}/env.cmake")
endif()

string(REGEX REPLACE "[\\/]" "" _sdk_version "$ENV{WindowsSDKVersion}")

set(CMAKE_SYSTEM_NAME "Windows" CACHE STRING "")
set(CMAKE_SYSTEM_VERSION ${_sdk_version} CACHE STRING "")
set(CMAKE_SYSTEM_PROCESSOR ${VCPKG_TARGET_ARCHITECTURE} CACHE STRING "")

message(STATUS "devenv:  $ENV{DevEnvDir}")
message(STATUS "sdk:     ${_sdk_version}")
message(STATUS "abi:     ${VCPKG_TARGET_ARCHITECTURE}")

if(NOT _VCPKG_WINDOWS_TOOLCHAIN)
    set(_VCPKG_WINDOWS_TOOLCHAIN 1)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>$<$<STREQUAL:${VCPKG_CRT_LINKAGE},dynamic>:DLL>" CACHE STRING "")

    get_property( _CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE )
    if(NOT _CMAKE_IN_TRY_COMPILE)

        if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
            set(VCPKG_CRT_LINK_FLAG_PREFIX "/MD")
        elseif(VCPKG_CRT_LINKAGE STREQUAL "static")
            set(VCPKG_CRT_LINK_FLAG_PREFIX "/MT")
        else()
            message(FATAL_ERROR "Invalid setting for VCPKG_CRT_LINKAGE: \"${VCPKG_CRT_LINKAGE}\". It must be \"static\" or \"dynamic\"")
        endif()

        set(CHARSET_FLAG "/utf-8")
        if (NOT VCPKG_SET_CHARSET_FLAG OR VCPKG_PLATFORM_TOOLSET MATCHES "v120")
            # VS 2013 does not support /utf-8
            set(CHARSET_FLAG)
        endif()

        set(CMAKE_CXX_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /GR /EHsc /MP ${VCPKG_CXX_FLAGS}" CACHE STRING "")
        set(CMAKE_C_FLAGS " /nologo /DWIN32 /D_WINDOWS /W3 ${CHARSET_FLAG} /MP ${VCPKG_C_FLAGS}" CACHE STRING "")
        set(CMAKE_RC_FLAGS "-c65001 /DWIN32" CACHE STRING "")

        unset(CHARSET_FLAG)

        set(CMAKE_CXX_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_CXX_FLAGS_DEBUG}" CACHE STRING "")
        set(CMAKE_C_FLAGS_DEBUG "/D_DEBUG ${VCPKG_CRT_LINK_FLAG_PREFIX}d /Z7 /Ob0 /Od /RTC1 ${VCPKG_C_FLAGS_DEBUG}" CACHE STRING "")
        set(CMAKE_CXX_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_CXX_FLAGS_RELEASE}" CACHE STRING "")
        set(CMAKE_C_FLAGS_RELEASE "${VCPKG_CRT_LINK_FLAG_PREFIX} /O2 /Oi /Gy /DNDEBUG /Z7 ${VCPKG_C_FLAGS_RELEASE}" CACHE STRING "")

        string(APPEND CMAKE_STATIC_LINKER_FLAGS_RELEASE_INIT " /nologo ")
        set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")
        set(CMAKE_EXE_LINKER_FLAGS_RELEASE "/nologo /DEBUG /INCREMENTAL:NO /OPT:REF /OPT:ICF ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_RELEASE}" CACHE STRING "")

        string(APPEND CMAKE_STATIC_LINKER_FLAGS_DEBUG_INIT " /nologo ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " /nologo ${VCPKG_LINKER_FLAGS} ${VCPKG_LINKER_FLAGS_DEBUG} ")
    endif()
endif()
