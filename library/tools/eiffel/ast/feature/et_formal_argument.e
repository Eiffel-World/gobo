indexing

	description:

		"Eiffel formal arguments"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_FORMAL_ARGUMENT

inherit

	ET_FORMAL_ARGUMENT_ITEM

creation

	make

feature {NONE} -- Initialization

	make (a_name: like name_item; a_type: like declared_type) is
			-- Create a new formal argument.
		require
			a_name_not_void: a_name /= Void
			a_type_not_void: a_type /= Void
		do
			name_item := a_name
			declared_type := a_type
		ensure
			name_item_set: name_item = a_name
			declared_type_set: declared_type = a_type
		end

feature -- Initialization

	reset is
			-- Reset formal argument as it was when it was first parsed.
		do
			name.reset
			type.reset
		end
			
feature -- Access

	name: ET_IDENTIFIER is
			-- Name
		do
			Result := name_item.identifier
		ensure
			name_not_void: Result /= Void
		end

	type: ET_TYPE is
			-- Type
		do
			Result := declared_type.type
		end

	name_item: ET_ARGUMENT_NAME
			-- Name (possibly followed by a comma)

	declared_type: ET_DECLARED_TYPE
			-- Declared type (type preceded by a colon)

	formal_argument: ET_FORMAL_ARGUMENT is
			-- Formal argument in semicolon-separated list
		do
			Result := Current
		end

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			Result := name_item.position
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := declared_type.break
		end

feature -- Status report

	is_used: BOOLEAN
			-- Is current formal argument used?

feature -- Setting

	set_declared_type (a_type: like declared_type) is
			-- Set `declared_type' to `a_type'.
		require
			a_type_not_void: a_type /= Void
		do
			declared_type := a_type
		ensure
			declared_type_set: declared_type = a_type
		end

feature -- Status setting

	set_used (b: BOOLEAN) is
			-- Set `is_used' to `b'.
		do
			is_used := b
		ensure
			used_set: is_used = b
		end

feature -- Duplication

	cloned_argument: like Current is
			-- Cloned formal argument;
			-- Do not recursively clone the type
		do
			create Result.make (name_item, declared_type)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_formal_argument (Current)
		end

invariant

	name_item_not_void: name_item /= Void
	declared_type_not_void: declared_type /= Void

end
