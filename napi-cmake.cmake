## NodeJS executable.
if (NOT NAPI_CMAKE_NODE_JS_EXE)
    set(NAPI_CMAKE_NODE_JS_EXE "node")
endif()

## Node modules path.
if (NOT NAPI_CMAKE_NODE_MODULES_PATH)
    set(NAPI_CMAKE_NODE_MODULES_PATH "${PROJECT_SOURCE_DIR}/node_modules")
endif()

## Make sure node_modules exists.
if (NOT EXISTS "${NAPI_CMAKE_NODE_MODULES_PATH}")
    message(FATAL_ERROR "NAPI-CMake: Could not find node_modules at ${NAPI_CMAKE_NODE_MODULES_PATH}. Set NAPI_CMAKE_NODE_MODULES_PATH to the path of your node_modules.")
endif ()

## Get NodeJS version.
execute_process(
    COMMAND "${NAPI_CMAKE_NODE_JS_EXE}" --version
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
    OUTPUT_VARIABLE _NAPI_CMAKE_NODE_VERSION
    COMMAND_ERROR_IS_FATAL ANY
    ECHO_ERROR_VARIABLE
)

## Trim string.
string(STRIP "${_NAPI_CMAKE_NODE_VERSION}" _NAPI_CMAKE_NODE_VERSION)
message(STATUS "NAPI-CMake: Using Node JS version ${_NAPI_CMAKE_NODE_VERSION}")

## Download Node API headers.
function(_napi_cmake_perform_download headers_url)
    ## Remove old tar.gz.
    if (EXISTS "${CMAKE_BINARY_DIR}/headers.tar.gz")
        file(REMOVE "${CMAKE_BINARY_DIR}/headers.tar.gz")
    endif ()

    ## Strip whitespace.
    string(STRIP "${headers_url}" url)

    ## Download headers.
    file(DOWNLOAD
        "${url}"
        "${CMAKE_BINARY_DIR}/headers.tar.gz"
        TIMEOUT 10
        STATUS status
    )

    ## Make sure it worked.
    list(GET status 0 code)
    if (NOT ${code} EQUAL 0)
        list(GET status 1 err)
        message(FATAL_ERROR "NAPI-CMake: Could not download Node API headers: ${err}")
    endif ()
endfunction()

## Extract tarball.
function(_napi_cmake_extract_headers)
    message("NAPI-CMake: Extracting Node API headers")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E tar "xvf" "${CMAKE_BINARY_DIR}/headers.tar.gz"
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        COMMAND_ERROR_IS_FATAL ANY
        ECHO_ERROR_VARIABLE
        ECHO_OUTPUT_VARIABLE
    )
endfunction()

## Download node api headers.
function(_napi_cmake_download_node_headers)
    ## Get headers URL from Node JS.
    execute_process(
        COMMAND "${NAPI_CMAKE_NODE_JS_EXE}" -p process.release.headersUrl
        WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
        OUTPUT_VARIABLE headers_url
        COMMAND_ERROR_IS_FATAL ANY
        ECHO_ERROR_VARIABLE
    )

    ## Check if we already have the headers.
    if (EXISTS "${CMAKE_BINARY_DIR}/node-version.txt")
        file(READ "${CMAKE_BINARY_DIR}/node-version.txt" current_version)
        if (current_version STREQUAL headers_url)
            message(STATUS "NAPI-CMake: Node API headers are up to date")
            return()
        endif ()
    endif ()

    ## Log.
    message(STATUS "NAPI-CMake: Downloading Node JS headers from ${headers_url}")

    ## Download and extract.
    _napi_cmake_perform_download("${headers_url}")
    _napi_cmake_extract_headers()
    file(WRITE "${CMAKE_BINARY_DIR}/node-version.txt" "${headers_url}")
endfunction()

## Download node api headers.
_napi_cmake_download_node_headers()

## Determine headers path.
set(_NAPI_CMAKE_NODE_HEADERS_PATH "${CMAKE_BINARY_DIR}/node-${_NAPI_CMAKE_NODE_VERSION}/include/node")
message(STATUS "NAPI-CMake: Using Node JS headers at ${_NAPI_CMAKE_NODE_HEADERS_PATH}")

## Add a native node module.
macro(add_node_module name)
    ## Enable C and C++ just in case they somehow aren't enabled.
    enable_language(C)
    enable_language(CXX)

    ## Add the module as a shared library.
    add_library("${name}" SHARED ${ARGN})

    ## Add NAPI and Node JS include directories.
    target_include_directories("${name}" SYSTEM PRIVATE "${_NAPI_CMAKE_NODE_HEADERS_PATH}")
    target_include_directories("${name}" SYSTEM PRIVATE "${NAPI_CMAKE_NODE_MODULES_PATH}/node-addon-api")

    ## Suffix is .node.
    set_target_properties("${name}" PROPERTIES PREFIX "" SUFFIX ".node" LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}")
endmacro()
