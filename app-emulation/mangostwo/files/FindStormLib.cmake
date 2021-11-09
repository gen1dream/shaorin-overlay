find_library(StormLib_LIBRARIES NAMES storm PATHS /usr/lib /usr/lib64)
find_path(StormLib_INCLUDE_DIRS NAMES Stormlib.h StormPort.h PATHS /usr/include)
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(StormLib DEFAULT_MSG StormLib_LIBRARIES StormLib_INCLUDE_DIRS)
