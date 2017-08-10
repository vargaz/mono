project (mini)

include_directories("${PROJECT_BINARY_DIR}/../.." "${PROJECT_SOURCE_DIR}/../eglib")

add_library(monosgen "main-sgen.c" "${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h")

# FIXME: Use the previous format
string(TIMESTAMP BUILD_DATE)

add_custom_command (
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  COMMAND echo "const char *build_date = \"${BUILD_DATE}\";" > ${CMAKE_CURRENT_BINARY_DIR}/buildver-sgen.h
  VERBATIM
)
