cmake_minimum_required(VERSION 3.4)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(BUILD_COVERAGE "Build coverage" OFF)

set(
  HUNTER_CACHE_SERVERS
  "https://github.com/bmstu-iu8-cpp-sem-3/hunter-cache"
  CACHE STRING "Default cache server"
)

include("tools/gate/cmake/HunterGate.cmake")

HunterGate(
  URL "https://github.com/cpp-pm/hunter/archive/v0.23.218.tar.gz"
  SHA1 "9a3594a61227967fb92159339ba326701b287b19"
)

foreach(policy
    CMP0074 # CMake 3.12
    )
  if(POLICY ${policy})
    cmake_policy(SET ${policy} NEW)
  endif()
endforeach()


# TODO: rename project and delete this comment
project(lab-06-multithreads)
#string(APPEND CMAKE_CXX_FLAGS " -pedantic -Werror -Wall -Wextra")
#string(APPEND CMAKE_CXX_FLAGS " -Wno-unused-command-line-argument")
#string(APPEND CMAKE_CXX_FLAGS " -Wshadow -Wnon-virtual-dtor")
hunter_add_package(Boost COMPONENTS filesystem log system thread)

set (Boost_NO_SYSTEM_PATHS true)
set (Boost_USE_STATIC_LIBS ON)
set (Boost_USE_MULTITHREADED ON)

find_package(Boost CONFIG REQUIRED filesystem log log_setup system thread)
find_package(Threads)

set(MAIN ${PROJECT_NAME}Main)
set(SOURCES ${PROJECT_NAME}Sources)

add_library(
${SOURCES}
STATIC
${CMAKE_CURRENT_SOURCE_DIR}/sources/HashSearcher.cpp
)

target_include_directories(
${SOURCES}
PUBLIC
${CMAKE_CURRENT_SOURCE_DIR}/include
${CMAKE_CURRENT_SOURCE_DIR}/third-party/PicoSHA2
${Boost_INCLUDE_DIR}
)

add_executable(${MAIN} ${CMAKE_CURRENT_SOURCE_DIR}/sources/main.cpp)

target_include_directories(
${MAIN}
PUBLIC
${SOURCES}
)

target_link_libraries(${MAIN} ${SOURCES})

if(BUILD_COVERAGE)
  set(ENABLE_COVERAGE ON CACHE BOOL "Enable coverage build." FORCE)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
  find_package(codecov)
  # TODO: change template word to project name and delete this comment
  add_coverage(template)
  add_coverage(tests)
  list(APPEND LCOV_REMOVE_PATTERNS "'${PROJECT_SOURCE_DIR}/tests/*'")
  coverage_evaluate()
endif()
