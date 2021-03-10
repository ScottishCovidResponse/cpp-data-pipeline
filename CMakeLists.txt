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

SET( CMAKE_CXX_FLAGS "-fvisibility=hidden -DROOTDIR=\\\"${CMAKE_SOURCE_DIR}\\\" -DGIT_URL=\\\"${GIT_REMOTE_URL}\\\" -DVERSION=\\\"${SOFT_VERSION}\\\"" )

FIND_PACKAGE(PythonLibs 3 REQUIRED)
FIND_LIBRARY(LIBDL NAMES dl)

option(CODE_COVERAGE "Enable code coverage with LCov" OFF)

if(CODE_COVERAGE)
	message(STATUS "Including Code Coverage")
	set(COVERAGE_COMPILER_FLAGS "-g -fprofile-arcs -ftest-coverage")
	set (CMAKE_CXX_FLAGS "-std=gnu++17 -Wall -Wextra ${COVERAGE_COMPILER_FLAGS} ${CMAKE_CXX_FLAGS}")
endif()

MESSAGE(STATUS "----- SCRC API C++ Bindings -----")
MESSAGE(STATUS "[Setup]:")
MESSAGE(STATUS "\tVERSION: ${SOFT_VERSION}")
MESSAGE(STATUS "\tPYTHON EXE: ${PYTHON_EXECUTABLE}")
MESSAGE(STATUS "\tGIT_REMOTE_URL: ${GIT_REMOTE_URL}")
MESSAGE(STATUS "\tCOVERAGE: ${CODE_COVERAGE}")
INCLUDE(external/pybind11.cmake)
MESSAGE(STATUS "[Flags]:")
MESSAGE(STATUS "\t${CMAKE_CXX_FLAGS}")
MESSAGE(STATUS "\tPYTHON INCLUDE: ${PYTHON_INCLUDE_DIRS}")
MESSAGE(STATUS "---------------------------------")
set( CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin )

add_subdirectory(src)
add_subdirectory(tests)

if(CODE_COVERAGE)
	find_program( LCOV_PATH  NAMES lcov lcov.bat lcov.exe lcov.perl)
	find_program( GENHTML_PATH NAMES genhtml genhtml.perl genhtml.bat )
	find_program( GCOV_PATH gcov )
	
	set(LCOV_EXCLUDES "build/*" "/usr*")
	
	add_custom_target(coverage
	
        # Cleanup lcov
        COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -directory . -b ${PROJECT_SOURCE_DIR} --zerocounters

        # Create baseline to make sure untouched files show up in the report
        COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -c -i -d . -b ${PROJECT_SOURCE_DIR} -o ${PROJECT_NAME}.base

        # Run executables
        COMMAND ${CMAKE_SOURCE_DIR}/build/bin/Covid19EERAModel ${COV_TEST_FLAGS} -s original  -m inference
        COMMAND ${CMAKE_SOURCE_DIR}/build/bin/Covid19EERAModel-unit_tests

        # Capturing lcov counters and generating report
        COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} --directory . -b ${PROJECT_SOURCE_DIR} --capture --output-file ${PROJECT_NAME}.capture

        # add baseline counters
        COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} -a ${PROJECT_NAME}.base -a ${PROJECT_NAME}.capture --output-file ${PROJECT_NAME}.total

        # filter collected data to final coverage report and merge outputs
        COMMAND ${LCOV_PATH} --gcov-tool ${GCOV_PATH} --remove ${PROJECT_NAME}.total ${LCOV_EXCLUDES} --output-file ${PROJECT_NAME}.info

        # Generate HTML output
    
        COMMAND ${GENHTML_PATH} -o ${PROJECT_NAME}_coverage ${PROJECT_NAME}.info

        # Set output files as GENERATED (will be removed on 'make clean')
        BYPRODUCTS
        ${PROJECT_NAME}.base
        ${PROJECT_NAME}.capture
        ${PROJECT_NAME}.total
        ${PROJECT_NAME}.info
        ${PROJECT_NAME}  # report directory

        WORKING_DIRECTORY ${PROJECT_BINARY_DIR}
        VERBATIM # Protect arguments to commands
        COMMENT "Resetting code coverage counters to zero.\nProcessing code coverage counters and generating report."
    )
endif()