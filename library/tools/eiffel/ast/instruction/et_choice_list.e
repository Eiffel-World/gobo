indexing

	description:

		"Eiffel comma-separated lists of inspect choices"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CHOICE_LIST

inherit

	ET_AST_NODE

	ET_AST_LIST [ET_CHOICE_ITEM]
		redefine
			make, make_with_capacity
		end

creation

	make, make_with_capacity

feature {NONE} -- Initialization

	make is
			-- Create a new choice list.
		do
			when_keyword := tokens.when_keyword
			precursor
		end

	make_with_capacity (nb: INTEGER) is
			-- Create a new choice list with capacity `nb'.
		do
			when_keyword := tokens.when_keyword
			precursor (nb)
		end

feature -- Access

	choice (i: INTEGER): ET_CHOICE is
			-- Choice at index `i' in list
		require
			i_large_enough: i >= 1
			i_small_enough: i <= count
		do
			Result := item (i).choice
		ensure
			choice_not_void: Result /= Void
		end

	when_keyword: ET_KEYWORD
			-- 'when' keyword

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := when_keyword.position
			if Result.is_null and not is_empty then
				Result := item (1).position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if is_empty then
				Result := when_keyword.break
			else
				Result := item (count).break
			end
		end

feature -- Setting

	set_when_keyword (a_keyword: like when_keyword) is
			-- Set `when_keyword' to `a_keyword'.
		require
			a_keyword_not_void: a_keyword /= Void
		do
			when_keyword := a_keyword
		ensure
			when_keyword_set: when_keyword = a_keyword
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_choice_list (Current)
		end

feature {NONE} -- Implementation

	fixed_array: KL_SPECIAL_ROUTINES [ET_CHOICE_ITEM] is
			-- Fixed array routines
		once
			create Result
		end

invariant

	when_keyword_not_void: when_keyword /= Void

end
