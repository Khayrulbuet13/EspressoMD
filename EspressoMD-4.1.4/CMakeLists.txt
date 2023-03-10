# Copyright (C) 2009-2019 The ESPResSo project
# Copyright (C) 2009,2010
#   Max-Planck-Institute for Polymer Research, Theory Group
#
# This file is part of ESPResSo.
#
# ESPResSo is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# ESPResSo is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

cmake_minimum_required(VERSION 3.4)
message(STATUS "CMake version: ${CMAKE_VERSION}")

# C++ standard
enable_language(CXX)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

include(FeatureSummary)
include(GNUInstallDirs)
project(ESPResSo)
if(NOT ${CMAKE_VERSION} VERSION_LESS "3.12")
  cmake_policy(SET CMP0074 NEW)
endif()

set(PROJECT_VERSION "4.1.4")

#
# CMake internal vars
#

# CMake modules/macros are in a subdirectory to keep this file cleaner
set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

# Select the build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif(NOT CMAKE_BUILD_TYPE)

# On Mac OS X, first look for other packages, then frameworks
set(CMAKE_FIND_FRAMEWORK LAST)

######################################################################
# User input options
######################################################################

option(WITH_PYTHON "Build with Python bindings"  ON)
option(WITH_GSL    "Build with GSL support"  ON)
option(WITH_CUDA   "Build with GPU support"  ON)
option(WITH_HDF5   "Build with HDF5 support" ON)
option(WITH_TESTS  "Enable tests"            ON)
option(WITH_SCAFACOS "Build with Scafacos support" OFF)
option(WITH_BENCHMARKS "Enable benchmarks"   OFF)
option(WITH_VALGRIND_INSTRUMENTATION "Build with valgrind instrumentation markers" OFF)
if(CMAKE_VERSION VERSION_GREATER 3.5.2 AND CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  option(WITH_CLANG_TIDY "Run Clang-Tidy during compilation" OFF)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang"
   OR CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  option(WITH_COVERAGE "Generate code coverage report" OFF)
  option(WITH_ASAN "Build with address sanitizer" OFF)
  option(WITH_UBSAN "Build with undefined behavior sanitizer" OFF)
endif()
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang" AND NOT APPLE)
  option(
    WITH_MSAN
    "Build with memory sanitizer (experimental; requires a memory-sanitized Python interpreter)"
    OFF)
endif()
option(WARNINGS_ARE_ERRORS "Treat warnings as errors during compilation" OFF)
option(WITH_CCACHE "Use ccache compiler invocation." OFF)
option(WITH_PROFILER "Enable profiler annotations." OFF)
set(TEST_TIMEOUT "300" CACHE STRING "Timeout in seconds for each testsuite test")

if(WITH_CCACHE)
  find_program(CCACHE ccache)
  if(CCACHE)
    message(STATUS "Found ccache ${CCACHE}")
    set(CMAKE_CXX_COMPILER_LAUNCHER ${CCACHE} CACHE STRING "ccache executable")
  else()
    message(FATAL_ERROR "ccache not found.")
  endif(CCACHE)
endif(WITH_CCACHE)


# Write compile commands to file, for various tools...
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# choose the name of the config file
set(MYCONFIG_NAME "myconfig.hpp"
    CACHE STRING "Default name of the local config file")

# Check which config file to use
include(MyConfig)

#
# Pretty function
#

include(CheckCXXSourceCompiles)

set(__PRETTYFUNC__ __func__)
foreach(func_name __PRETTY_FUNCTION__ __FUNCTION__)
  check_cxx_source_compiles("
     #include <string>
     int main() { std::string(${func_name}); }
     " result${func_name})
  if(result${func_name})
    set(__PRETTYFUNC__ ${func_name})
    break()
  endif(result${func_name})
endforeach(func_name __PRETTY_FUNCTION__ __FUNCTION__)

#
# Libraries
#

# CUDA compiler
if(WITH_CUDA)
  find_package(CUDACompiler REQUIRED)
endif(WITH_CUDA)

find_package(PythonInterp 3.3 REQUIRED)

if(WITH_PYTHON)
  find_package(Cython 0.23 REQUIRED)
  find_package(PythonHeaders REQUIRED)
  find_package(NumPy REQUIRED)
  find_program(IPYTHON_EXECUTABLE NAMES jupyter ipython3 ipython)
endif(WITH_PYTHON)

find_package(FFTW3)
if(FFTW3_FOUND)
  set(FFTW 3)
endif(FFTW3_FOUND)

# If we build Python bindings, turn on script interface
if(WITH_PYTHON)
  set(WITH_SCRIPT_INTERFACE ON)
endif()

# We need the parallel hdf5 version!
if (WITH_HDF5)
  set(HDF5_PREFER_PARALLEL 1)
  find_package(HDF5 "1.8" COMPONENTS C)
  if(HDF5_IS_PARALLEL)
    set(H5MD 1)
    add_feature_info(HDF5 ON "parallel")
  else()
    unset(H5MD)
    unset(HDF5_FOUND)
  endif(HDF5_IS_PARALLEL)
endif(WITH_HDF5)

# Check for the h5xx submodule and try to check it out if not found or update it
# if found.
if(WITH_HDF5 AND EXISTS "${CMAKE_SOURCE_DIR}/.git")
  # Try to find git
  find_package(Git)
  if(GIT_FOUND)
    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/libs/h5xx/.git")
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule update --init --
                              libs/h5xx
                      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    else()
      execute_process(COMMAND ${GIT_EXECUTABLE} submodule update -- libs/h5xx
                      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR})
    endif()
  endif()
endif()

if(WITH_SCAFACOS)
  find_package(PkgConfig)
  pkg_check_modules(SCAFACOS scafacos)
  if(SCAFACOS_FOUND)
    set(SCAFACOS 1)
  endif(SCAFACOS_FOUND)
endif(WITH_SCAFACOS)

if(WITH_GSL)
  find_package(GSL)
  if(GSL_FOUND)
    set(GSL 1)
  endif(GSL_FOUND)
endif(WITH_GSL)

if(WITH_VALGRIND_INSTRUMENTATION)
  find_package(PkgConfig)
  pkg_check_modules(VALGRIND valgrind)
  if(VALGRIND_FOUND)
    set(VALGRIND_INSTRUMENTATION 1)
    message(STATUS ${VALGRIND_INCLUDE_DIRS})
    include_directories(SYSTEM ${VALGRIND_INCLUDE_DIRS})
  endif(VALGRIND_FOUND)
endif(WITH_VALGRIND_INSTRUMENTATION)

#
# MPI
#

find_package(MPI 3.0 REQUIRED)

# CMake < 3.9
if(NOT TARGET MPI::MPI_CXX)
  add_library(MPI::MPI_CXX IMPORTED INTERFACE)

  # Workaround for https://gitlab.kitware.com/cmake/cmake/issues/18349
  foreach(_MPI_FLAG ${MPI_CXX_COMPILE_FLAGS})
     set_property(TARGET MPI::MPI_CXX
            PROPERTY INTERFACE_COMPILE_OPTIONS ${_MPI_FLAG})
  endforeach()

  set_property(TARGET MPI::MPI_CXX
          PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${MPI_CXX_INCLUDE_PATH}")

  # Workaround for https://gitlab.kitware.com/cmake/cmake/issues/18349
  foreach(_MPI_FLAG ${MPI_CXX_LINK_FLAGS})
  set_property(TARGET MPI::MPI_CXX
          PROPERTY INTERFACE_LINK_LIBRARIES ${_MPI_FLAG})
  endforeach()

  set_property(TARGET MPI::MPI_CXX
          PROPERTY INTERFACE_LINK_LIBRARIES ${MPI_CXX_LIBRARIES})
endif()

#######################################################################
# Boost
#######################################################################

list(APPEND BOOST_COMPONENTS
            mpi
            serialization
            filesystem
            system)

if(WITH_TESTS)
  list(APPEND BOOST_COMPONENTS unit_test_framework)
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  set(BOOST_MINIMUM_VERSION "1.65.0")
  if (CUDA_FOUND AND NOT CUDA_VERSION VERSION_LESS "9.0")
    set(BOOST_MINIMUM_VERSION "1.66.0")
  endif()
else()
  set(BOOST_MINIMUM_VERSION "1.55.0")
endif()

# old Boost.MPI versions contain a use-after-free bug that seems to only cause crashes on 32-bit architectures
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
  set(BOOST_MINIMUM_VERSION "1.67.0")
endif()

find_package(Boost ${BOOST_MINIMUM_VERSION} REQUIRED ${BOOST_COMPONENTS})

if(Boost_VERSION VERSION_GREATER 106399 AND Boost_VERSION VERSION_LESS 106500)
  # Boost 1.64 has incompatible Serialization and MPI modules, see
  # https://svn.boost.org/trac10/ticket/12723 . Some distributions, like Fedora,
  # have backported the patch.
  file(READ "${Boost_INCLUDE_DIR}/boost/mpi/detail/mpi_datatype_primitive.hpp"
            boost_mpi_datatype_file)
  if(boost_mpi_datatype_file MATCHES "boost::serialization::detail::get_data")
    message(FATAL_ERROR "Boost 1.64 is unsupported")
  endif()
endif()

#
# Paths
#

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${PYTHON_INSTDIR}/espressomd")

#
# Flags
#

# drop 'lib' prefix from all libraries
set(CMAKE_SHARED_LIBRARY_PREFIX "")

if(WARNINGS_ARE_ERRORS)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror")
endif(WARNINGS_ARE_ERRORS)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wno-sign-compare -Wno-unused-function -Wno-unused-variable -Wno-unused-parameter -Wno-missing-braces")
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_SYSTEM_PROCESSOR MATCHES "arm")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-psabi")
endif()
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Intel" AND NOT (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "7.0.0"))
  # disable warnings from -Wextra
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-implicit-fallthrough")
endif()
if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  # disable warnings from -Wextra
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-clobbered")
  if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL "8.1.0")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-cast-function-type")
  endif()
endif()
if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  # disable warnings from -Wextra
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -wd592")
endif()
if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "Intel")
  # G++ and Intel don't know this flag
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-private-field")
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -Wno-gnu-zero-variadic-macro-arguments")
endif()
if(NOT
   CMAKE_CXX_COMPILER_ID
   STREQUAL
   "GNU"
   OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER "4.8.5")
  # older versions don't support -Wno-pedantic which we need in src/python
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pedantic")
endif()
if (CMAKE_CXX_COMPILER_ID STREQUAL "Intel" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS "16.0")
  # workaround for compiler crash related to decltype() and variadic template usage inside Boost
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_NO_CXX11_VARIADIC_TEMPLATES")
endif()

# prevent 80-bit arithmetic on old Intel processors
if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_SIZEOF_VOID_P EQUAL 4 AND CMAKE_SYSTEM_PROCESSOR MATCHES "[xX]86")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -ffloat-store")
endif()

set(CMAKE_MACOSX_RPATH TRUE)

if(WITH_ASAN AND WITH_MSAN)
  message(
    FATAL_ERROR
      "Address sanitizer and memory sanitizer cannot be enabled simultaneously")
endif()
if(WITH_ASAN)
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g -O1")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -fsanitize=address -fno-omit-frame-pointer")
endif()
if(WITH_MSAN)
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -g -O1")
  set(CMAKE_CXX_FLAGS
      "${CMAKE_CXX_FLAGS} -fsanitize=memory -fno-omit-frame-pointer")
endif()
if(WITH_UBSAN)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=undefined")
endif()

#
# Testing
#######################################################################

if(WITH_CLANG_TIDY)
  find_package(ClangTidy "${CMAKE_CXX_COMPILER_VERSION}" EXACT REQUIRED)
  set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_EXE}")
endif()

if(WITH_TESTS)
  enable_testing()
  if(Boost_UNIT_TEST_FRAMEWORK_FOUND)
    set(WITH_UNIT_TESTS ON)
  endif(Boost_UNIT_TEST_FRAMEWORK_FOUND)
  add_custom_target(check)
  if(WITH_PYTHON)
    add_subdirectory(testsuite)
  endif(WITH_PYTHON)
endif(WITH_TESTS)

if(WITH_BENCHMARKS)
  add_custom_target(benchmark)
  add_subdirectory(maintainer/benchmarks)
endif(WITH_BENCHMARKS)

#
# Subdirectories
#

add_subdirectory(doc)
add_subdirectory(src)
add_subdirectory(libs)
#
# Feature summary
#

include(FeatureSummary)
feature_summary(WHAT ALL)
