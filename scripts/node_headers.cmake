## Download Node API headers.
function(napi_cmake_perform_download expected_version)
    message("NAPI-CMake: Downloading Node API headers")

    if(EXISTS headers.tar.gz)
        file(REMOVE headers.tar.gz)
    endif()

    string(STRIP "${expected_version}" url)

    file (
        DOWNLOAD
        "${url}"
        headers.tar.gz
        TIMEOUT 10
        STATUS status
    )

    list(GET status 0 code)
    if(NOT ${code} EQUAL 0)
        list(GET status 1 err)
        message(FATAL_ERROR "NAPI-CMake: Could not download Node API headers: ${err}")
    endif()
endfunction()

## Extract tarball.
function(napi_cmake_extract_headers)
    message("NAPI-CMake: Extracting Node API headers")
    execute_process (
        COMMAND ${CMAKE_COMMAND} -E tar "xvf" headers.tar.gz
        COMMAND_ERROR_IS_FATAL ANY
        ECHO_ERROR_VARIABLE
    )
endfunction()

## Download node api headers.
function(napi_cmake_download_node_headers)
    execute_process (
        COMMAND node -p process.release.headersUrl
        OUTPUT_VARIABLE expected_version
        COMMAND_ERROR_IS_FATAL ANY
        ECHO_ERROR_VARIABLE
    )

    if(EXISTS node-version.txt)
        file(READ node-version.txt current_version)
        if(current_version STREQUAL expected_version)
            message("NAPI-CMake: Node API headers are up to date")
            return()
        endif()
    endif()

    napi_cmake_perform_download(${expected_version})
    napi_cmake_extract_headers()
    file(WRITE node-version.txt ${expected_version})
endfunction()

napi_cmake_download_node_headers()
