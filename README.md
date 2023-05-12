# NAPI-CMake
This is a CMake script to create native node modules using CMake and without node-gyp or cmake-js. You will, 
however, still need a NodeJS package manager such as `npm`.

## Usage
To install NAPI, run
```bash
npm install node-addon-api
```

Then, in your CMake file, add these lines:
```cmake
## Load script.
include(/path/to/napi-cmake.cmake)

## Add a native node module. This will also download the right NodeJS headers
## by running NAPI_CMAKE_NODE_JS_EXE (defaults to `node`) as well as add them
## to the include directories for this module. Under the hood, the module is 
## created as a SHARED libary using add_library().
##
## This ultimately creates "${CMAKE_BINARY_DIR}/my_module.node".
add_node_module(my_module ${sources})

## Set compile options or whatever.
target_compile_options(my_module -Wall -Wextra -O3)
```

