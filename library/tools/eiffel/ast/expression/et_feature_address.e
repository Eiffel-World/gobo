indexing

	description:

		"Eiffel addresses of features"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_FEATURE_ADDRESS

inherit

	ET_ADDRESS_EXPRESSION

creation

	make

feature {NONE} -- Initialization

	make (a_name: like name) is
			-- Create a new feature address.
		require
			a_name_not_void: a_name /= Void
		do
			dollar := tokens.dollar_symbol
			name := a_name
		ensure
			name_set: name = a_name
		end

feature -- Access

	name: ET_FEATURE_NAME
			-- Feature name

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := name.break
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_feature_address (Current)
		end

invariant

	name_not_void: name /= Void

end
