indexing

	description:

		"Eiffel Void entities"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_VOID

inherit

	ET_EXPRESSION

	ET_KEYWORD
		rename
			make_void as make
		redefine
			process
		end

creation

	make

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_void (Current)
		end

invariant

	is_void: is_void

end
