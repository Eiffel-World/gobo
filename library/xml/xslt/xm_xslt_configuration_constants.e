indexing

	description:

		"Configuration constants"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_CONFIGURATION_CONSTANTS

feature -- Access

	Recover_silently: INTEGER is 1
	Recover_with_warnings: INTEGER is 2
	Do_not_recover: INTEGER is 3
			-- Recovery policies

end
	
