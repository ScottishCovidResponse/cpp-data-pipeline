INCLUDE(ExternalProject)

ExternalProject_Add(datapipeline_python
    GIT_REPOSITORY https://github.com/ScottishCovidResponse/data_pipeline_api.git
    CONFIGURE_COMMAND ${PYTHON_EXECUTABLE} -m pip install pyyaml
    BUILD_COMMAND ""
    SOURCE_DIR ${CMAKE_BINARY_DIR}/external/data_pipeline_api
    INSTALL_COMMAND ${PYTHON_EXECUTABLE} -m pip install ${CMAKE_BINARY_DIR}/external/data_pipeline_api
    GIT_SUBMODULES ""
)

ExternalProject_Get_Property(datapipeline_python source_dir)
SET(SCRCPYTHON data_pipeline_api)
ADD_LIBRARY(${SCRCPYTHON} INTERFACE)