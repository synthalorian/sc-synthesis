# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Project-level configuration.
set(PROJECT_NAME "rust_lib_sc_synthesis")
project(${PROJECT_NAME} LANGUAGES CXX)

# Point directly to the pre-built Rust library
set(RUST_LIB_PATH "${CMAKE_SOURCE_DIR}/../rust/target/debug/libsc_synthesis_bridge.so")
if(NOT EXISTS "${RUST_LIB_PATH}")
    message(FATAL_ERROR "Rust library not found at ${RUST_LIB_PATH}. Run: cd rust && cargo build")
endif()

add_library(${PROJECT_NAME} SHARED IMPORTED)
set_target_properties(${PROJECT_NAME} PROPERTIES
    IMPORTED_LOCATION "${RUST_LIB_PATH}"
)

# List of absolute paths to libraries that should be bundled with the plugin.
set(rust_lib_sc_synthesis_bundled_libraries
    "${RUST_LIB_PATH}"
    PARENT_SCOPE
)
