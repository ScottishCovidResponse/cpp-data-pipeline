FILE(GLOB_RECURSE SRC_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.cc)

ADD_LIBRARY(${PROJECT_NAME} ${SRC_FILES})

TARGET_INCLUDE_DIRECTORIES(
    ${PROJECT_NAME} PRIVATE ${CMAKE_SOURCE_DIR}/include
    ${PROJECT_NAME} PUBLIC ${PYBIND11_INCLUDE_DIRS}
    ${PROJECT_NAME} PUBLIC ${PYTHON_INCLUDE_DIRS}
)

TARGET_LINK_LIBRARIES(${PROJECT_NAME} ${PYBIND11} ${SCRCPYTHON} ${PYTHON_LIBRARIES} ${LIBDL})