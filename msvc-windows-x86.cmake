set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_TARGET_IS_WINDOWS ON)
set(VCPKG_CRT_LINKAGE static)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_CMAKE_SYSTEM_NAME Windows)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/msvc-windows.cmake)
set(TARGET_CMAKE_GENERATOR "Visual Studio 16 2019")
set(TARGET_CMAKE_OPTIONS "-A" "Win32")
