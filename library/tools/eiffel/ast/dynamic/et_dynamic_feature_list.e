indexing

	description:

		"Eiffel lists of features at run-time"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_DYNAMIC_FEATURE_LIST

inherit

	ET_TAIL_LIST [ET_DYNAMIC_FEATURE]

creation

	make, make_with_capacity

feature {NONE} -- Implementation

	fixed_array: KL_SPECIAL_ROUTINES [ET_DYNAMIC_FEATURE] is
			-- Fixed array routines
		once
			create Result
		end

end
