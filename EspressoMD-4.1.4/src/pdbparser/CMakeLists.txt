add_library(pdbparser SHARED ${CMAKE_CURRENT_SOURCE_DIR}/src/PdbParser.cpp)
target_include_directories(pdbparser PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
install(TARGETS pdbparser LIBRARY DESTINATION ${PYTHON_INSTDIR}/espressomd)
if(WITH_UNIT_TESTS)
  add_subdirectory(unit_tests)
endif(WITH_UNIT_TESTS)
