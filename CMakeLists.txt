cmake_minimum_required (VERSION 3.0) 
project (the-lost-cow-hunter)

find_package(OpenGL)
if (OPENGL_FOUND)
  MESSAGE("OpenGL Correctly Found")
  include_directories(${OPENGL_INCLUDE_DIR})
else (OPENGL_FOUND)
  MESSAGE("OpenGL environment missing")
endif()

set(CMAKE_CXX_FLAGS "-std=c++17")

include_directories(include)
file(GLOB SOURCES "src/*.cpp")
add_executable (${PROJECT_NAME} ${SOURCES})

# GLFW
option(GLFW_BUILD_EXAMPLES "Build the GLFW example programs" OFF)
option(GLFW_BUILD_TESTS "Build the GLFW test programs" OFF)
option(GLFW_BUILD_DOCS "Build the GLFW documentation" OFF)

add_subdirectory(lib/glfw)
include_directories(lib/glfw/include)
target_link_libraries (${PROJECT_NAME} glfw ${GLFW_LIBRARIES})

# GLAD
add_library(glad src/glad.c)
target_include_directories(glad PRIVATE include/glad)
target_link_libraries(${CMAKE_PROJECT_NAME} glad)