indexing

	description:

		"Eiffel local variables in semicolon-separated list of local variables"

	library:    "Gobo Eiffel Tools Library"
	author:     "Eric Bezault <ericb@gobosoft.com>"
	copyright:  "Copyright (c) 2002, Eric Bezault and others"
	license:    "Eiffel Forum Freeware License v1 (see forum.txt)"
	date:       "$Date$"
	revision:   "$Revision$"

deferred class ET_LOCAL_VARIABLE_ITEM

inherit

	ET_AST_NODE

feature -- Access

	local_variable_item: ET_LOCAL_VARIABLE is
			-- Local variable in semicolon-separated list
		deferred
		ensure
			local_variable_item_not_void: Result /= Void
		end

	type: ET_TYPE is
			-- Type
		deferred
		ensure
			type_not_void: Result /= Void
		end

end -- class ET_LOCAL_VARIABLE_ITEM
