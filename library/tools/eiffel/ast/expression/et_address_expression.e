indexing

	description:

		"Eiffel address expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_ADDRESS_EXPRESSION

inherit

	ET_EXPRESSION

feature -- Access

	dollar: ET_SYMBOL
			-- '$' symbol

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := dollar.position
		end

	first_leaf: ET_AST_LEAF is
			-- First leaf node in current node
		do
			Result := dollar
		end

feature -- Setting

	set_dollar (a_dollar: like dollar) is
			-- Set `dollar' to `a_dollar'.
		require
			a_dollar_not_void: a_dollar /= Void
		do
			dollar := a_dollar
		ensure
			dollar_set: dollar = a_dollar
		end

invariant

	dollar_not_void: dollar /= Void

end
