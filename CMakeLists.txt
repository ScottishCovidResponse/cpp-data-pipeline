CMAKE_MINIMUM_REQUIRED( VERSION 3.16 )

SET(Python3_FIND_VIRTUALENV FIRST)
FIND_PACKAGE(PythonInterp 3 REQUIRED)
FIND_PACKAGE(Python3)

execute_process(
    COMMAND bash -c "echo \"$(git describe --dirty --always | cut -d '-' -f 1)\"| tr -d '[:space:]'"
    OUTPUT_VARIABLE SOFT_VERSION
)

execute_process(
    COMMAND bash -c "echo \"$(git remote show origin | grep Fetch | cut -d ' ' -f 5)\"| tr -d '[:space:]'"
    OUTPUT_VARIABLE GIT_REMOTE_URL
)

project( datapipeline VERSION 0.7.3 LANGUAGES CXX )

SET( CMAKE_CXX_STANDARD 17 )
SET( CMAKE_CXX_STANDARD_REQUIRED ON )
SET( CMAKE_THREAD_LIBS_INIT "-lpthread" )

INCLUDE(external/data_pipeline_api.cmake)
INCLUDE(CTest)

SET( CMAKE_CXX_FLAGS "-fvisibility=hidden -DROOTDIR=\\\"${CMAKE_SOURCE_DIR}\\\" -DGIT_URL=\\\"${GIT_REMOTE_URL}\\\" -DVERSION=\\\"${SOFT_VERSION}\\\"" )

FIND_PACKAGE(PythonLibs 3 REQUIRED)
FIND_LIBRARY(LIBDL NAMES dl)

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	message(STATUS "Including Code Coverage")
	set(COVERAGE_COMPILER_FLAGS "-g -fprofile-arcs -ftest-coverage")
	set (CMAKE_CXX_FLAGS "-std=gnu++17 -O0 -Wall -Wextra ${COVERAGE_COMPILER_FLAGS} ${CMAKE_CXX_FLAGS}")
    SET(BUILD_TESTING ON)
endif()

MESSAGE(STATUS "----- SCRC API C++ Bindings -----")
MESSAGE(STATUS "[Setup]:")
MESSAGE(STATUS "\tVERSION: ${SOFT_VERSION}")
MESSAGE(STATUS "\tPYTHON EXE: ${PYTHON_EXECUTABLE}")
MESSAGE(STATUS "\tGIT_REMOTE_URL: ${GIT_REMOTE_URL}")
MESSAGE(STATUS "\tBUILD TESTS: ${BUILD_TESTING}")
MESSAGE(STATUS "\tCOVERAGE: ${CODE_COVERAGE}")
INCLUDE(external/pybind11.cmake)
MESSAGE(STATUS "[Flags]:")
MESSAGE(STATUS "\t${CMAKE_CXX_FLAGS}")
MESSAGE(STATUS "\tPYTHON INCLUDE: ${PYTHON_INCLUDE_DIRS}")
MESSAGE(STATUS "---------------------------------")
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

add_subdirectory(src)

IF(BUILD_TESTING)
    add_subdirectory(tests)
ENDIF()

if(CMAKE_BUILD_TYPE STREQUAL "Debug")
	include(external/coverage.cmake)
    setup_target_for_coverage_lcov(
        NAME coverage
        EXECUTABLE ${PROJECT_NAME}-tests
        DEPENDENCIES ${PROJECT_NAME}-tests
        EXCLUDE ${CMAKE_BINARY_DIR}
        )
endif()