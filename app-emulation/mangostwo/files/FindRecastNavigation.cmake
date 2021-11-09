find_path(RecastNavigation_INCLUDE_DIR NAMES Recast.h PATHS /usr/include/recastnavigation)

find_library(RecastNavigation_DebugUtils_LIBRARY NAMES DebugUtils)
find_library(RecastNavigation_Detour_LIBRARY NAMES Detour)
find_library(RecastNavigation_DetourCrowd_LIBRARY NAMES DetourCrowd)
find_library(RecastNavigation_DetourTileCache_LIBRARY NAMES DetourTileCache)
find_library(RecastNavigation_Recast_LIBRARY NAMES Recast)

#set(RecastNavigation_LIBRARIES ${RecastNavigation_DebugUtils_LIBRARY} ${RecastNavigation_Detour_LIBRARY} ${RecastNavigation_DetourCrowd_LIBRARY} ${RecastNavigation_DetourTileCache_LIBRARY} ${RecastNavigation_Decast_LIBRARY})

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(RecastNavigation
	REQUIRED_VARS
		RecastNavigation_DebugUtils_LIBRARY 
		RecastNavigation_Detour_LIBRARY 	
		RecastNavigation_DetourCrowd_LIBRARY 	
		RecastNavigation_DetourTileCache_LIBRARY 	
		RecastNavigation_Recast_LIBRARY 	
		RecastNavigation_INCLUDE_DIR
	)

if(RecastNavigation_FOUND)
	#	if(NOT TARGET RecastNavigation::DebugUtils)
	#	add_library(RecastNavigation::DebugUtils SHARED IMPORTED)
	#	set_target_properties(RecastNavigation::DebugUtils PROPERTIES
	#		 "${RecastNavigation_DebugUtils_LIBRARY}"
	#		)
	#endif()
	if(NOT TARGET RecastNavigation::Detour)
		add_library(RecastNavigation::Detour INTERFACE IMPORTED)
		set_target_properties(RecastNavigation::Detour PROPERTIES
			INTERFACE_INCLUDE_DIRECTORIES "${RecastNavigation_INCLUDE_DIR}"
			INTERFACE_LINK_LIBRARIES "${RecastNavigation_Detour_LIBRARY}"
			)
	endif()
	if(NOT TARGET RecastNavigation::DetourCrowd)
		add_library(RecastNavigation::DetourCrowd INTERFACE IMPORTED)
		set_target_properties(RecastNavigation::DetourCrowd PROPERTIES
			INTERFACE_LINK_LIBRARIES "${RecastNavigation_DetourCrowd_LIBRARY}"
			INTERFACE_INCLUDE_DIRECTORIES "${RecastNavigation_INCLUDE_DIR}"
			)
	endif()
	if(NOT TARGET RecastNavigation::DetourTileCache)
		add_library(RecastNavigation::DetourTileCache INTERFACE IMPORTED)
		set_target_properties(RecastNavigation::DetourTileCache PROPERTIES
			INTERFACE_LINK_LIBRARIES "${RecastNavigation_DetourTileCache_LIBRARY}"
			INTERFACE_INCLUDE_DIRECTORIES "${RecastNavigation_INCLUDE_DIR}"
			)
	endif()
	if(NOT TARGET RecastNavigation::Recast)
		add_library(RecastNavigation::Recast INTERFACE IMPORTED)
		set_target_properties(RecastNavigation::Recast PROPERTIES
			INTERFACE_LINK_LIBRARIES "${RecastNavigation_Recast_LIBRARY}"
			INTERFACE_INCLUDE_DIRECTORIES "${RecastNavigation_INCLUDE_DIR}"
			)
	endif()
endif()



#add_library(RecastNavigation::Detour SHARED IMPORTED "${RecastNavigation_Detour_LIBRARY}")
#add_library(RecastNavigation::Recast SHARED IMPORTED "${RecastNavigation_Recast_LIBRARY}")
#if(NOT TARGET RecastNavigation::Detour)
	#add_library(RecastNavigation::Detour INTERFACE IMPORTED)
	#add_library(RecastNavigation::Recast INTERFACE IMPORTED)
	#
	#set_target_properties( RecastNavigation::Detour PROPERTIES
		#INTERFACE_LINK_LIBRARIES		"${RecastNavigation_Detour_LIBRARY}"
		#INTERFACE_INCLUDE_DIRECTORIES	"${RecastNavigation_INCLUDE_DIR}"
		#	)
	#set_target_properties( RecastNavigation::Recast PROPERTIES
		#INTERFACE_LINK_LIBRARIES		"${RecastNavigation_Recast_LIBRARY}"
		#INTERFACE_INCLUDE_DIRECTORIES	"${RecastNavigation_INCLUDE_DIR}"
		#	)
	#endif()

#set_target_properties(RecastNavigation::Detour PROPERTIES
#	)

#add_library(RecastNavigation::Recast ALIAS PkgConfig::RecastNavigation::Recast)
#if(RecastNavigation_FOUND AND NOT TARGET Detour AND NOT TARGET Recast)
	#add_library(Detour SHARED IMPORTED)
	#add_library(Recast SHARED IMPORTED)
	#endif()
	#if(RecastNavigation_FOUND AND TARGET Detour AND TARGET Recast AND NOT TARGET RecastNavigation::Detour AND NOT TARGET RecastNavigation::Recast)
	#add_library(RecastNavigation::Detour ALIAS Detour)
	#add_library(RecastNavigation::Recast ALIAS Recast)
	#endif()

