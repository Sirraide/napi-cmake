## Download Node API headers.
add_custom_target (
    napi_cmake_download_node_headers
    COMMAND ${CMAKE_COMMAND} -P "${PROJECT_SOURCE_DIR}/scripts/node_headers.cmake"
    COMMENT "NAPI-CMake: Downloading Node API headers"
)

## Determine nodejs version.
execute_process (
    COMMAND node --version
    OUTPUT_VARIABLE NODE_VERSION
    COMMAND_ERROR_IS_FATAL ANY
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ECHO_ERROR_VARIABLE
)

## Add include directories.
message(STATUS "NAPI-CMake: Using NodeJS headers at ${CMAKE_BINARY_DIR}/node-${NODE_VERSION}/include/node")

## Add a native node module.
macro(add_node_module name)
    ## Enable C and C++ just in case they somehow aren't enabled.
    enable_language(C)
    enable_language(CXX)

    ## Add the module as a shared library.
    add_library(name SHARED ${ARGN})

    ## Add NAPI and NodeJS include directories.
    target_include_directories(name SYSTEM PRIVATE "${CMAKE_BINARY_DIR}/node-${NODE_VERSION}/include/node")
    target_include_directories(name SYSTEM PRIVATE "${PROJECT_SOURCE_DIR}/node_modules/node-addon-api")

    ## Suffix is .node.
    set_target_properties(name PROPERTIES PREFIX "" SUFFIX ".node")

    ## Depends on node headers.
    add_dependencies(name napi_cmake_download_node_headers)
endmacro()
