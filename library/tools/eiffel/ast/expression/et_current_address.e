indexing

	description:

		"Eiffel addresses of Current"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 199-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CURRENT_ADDRESS

inherit

	ET_ADDRESS_EXPRESSION

creation

	make

feature {NONE} -- Initialization

	make is
			-- Create a new address of 'Current'.
		do
			dollar := tokens.dollar_symbol
			current_keyword := tokens.current_keyword
		end

feature -- Access

	current_keyword: ET_CURRENT
			-- 'Current' keyword

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := current_keyword.break
		end

feature -- Setting

	set_current_keyword (a_current: like current_keyword) is
			-- Set `current_keyword' to `a_current'.
		require
			a_current_not_void: a_current /= Void
		do
			current_keyword := a_current
		ensure
			current_keyword_set: current_keyword = a_current
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_current_address (Current)
		end

invariant

	current_keyword_not_void: current_keyword /= Void

end
