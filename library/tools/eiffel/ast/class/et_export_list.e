indexing

	description:

		"Eiffel export clauses"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_EXPORT_LIST

inherit

	ET_AST_NODE

	ET_AST_LIST [ET_EXPORT]
		redefine
			make, make_with_capacity
		end

creation

	make, make_with_capacity

feature {NONE} -- Initialization

	make is
			-- Create a new export clause
		do
			export_keyword := tokens.export_keyword
			precursor
		end

	make_with_capacity (nb: INTEGER) is
			-- Create a new export clause with capacity `nb'.
		do
			export_keyword := tokens.export_keyword
			precursor (nb)
		end

feature -- Access

	export_keyword: ET_KEYWORD
			-- 'export' keyword

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := export_keyword.position
			if Result.is_null and not is_empty then
				Result := first.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if is_empty then
				Result := export_keyword.break
			else
				Result := last.break
			end
		end

feature -- Setting

	set_export_keyword (an_export: like export_keyword) is
			-- Set `export_keyword' to `an_export'.
		require
			an_export_not_void: an_export /= Void
		do
			export_keyword := an_export
		ensure
			export_keyword_set: export_keyword = an_export
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_export_list (Current)
		end

feature {NONE} -- Implementation

	fixed_array: KL_FIXED_ARRAY_ROUTINES [ET_EXPORT] is
			-- Fixed array routines
		once
			create Result
		end

invariant

	export_keyword_not_void: export_keyword /= Void

end
