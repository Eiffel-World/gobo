indexing

	description:

		"Eiffel client lists"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CLIENTS

inherit

	ET_AST_NODE

	ET_CLASS_NAME_LIST
		redefine
			make, make_with_capacity
		end

creation

	make, make_with_capacity

feature {NONE} -- Initialization

	make is
			-- Create a new empty client list.
		do
			left_brace := tokens.left_brace_symbol
			right_brace := tokens.right_brace_symbol
			precursor
		end

	make_with_capacity (nb: INTEGER) is
			-- Create a new empty client list with capacity `nb'.
		do
			left_brace := tokens.left_brace_symbol
			right_brace := tokens.right_brace_symbol
			precursor (nb)
		end

feature -- Access

	left_brace: ET_SYMBOL
			-- '{' symbol

	right_brace: ET_SYMBOL
			-- '}' symbol

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := left_brace.position
			if Result.is_null and not is_empty then
				Result := first.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := right_brace.break
		end

feature -- Setting

	set_left_brace (l: like left_brace) is
			-- Set `left_brace' to `l'.
		require
			l_not_void: l /= Void
		do
			left_brace := l
		ensure
			left_brace_set: left_brace = l
		end

	set_right_brace (r: like right_brace) is
			-- Set `right_brace' to `r'.
		require
			r_not_void: r /= Void
		do
			right_brace := r
		ensure
			right_brace_set: right_brace = r
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_clients (Current)
		end

invariant

	left_brace_not_void: left_brace /= Void
	right_brace_not_void: right_brace /= Void

end
