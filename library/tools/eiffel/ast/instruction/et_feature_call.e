indexing

	description:

		"Eiffel feature calls"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_FEATURE_CALL

inherit

	ET_CALL_COMPONENT
		redefine
			target, arguments
		end

feature -- Access

	target: ET_EXPRESSION is
			-- Target
		deferred
		end

	arguments: ET_ACTUAL_ARGUMENTS is
			-- Arguments
		deferred
		end

end
