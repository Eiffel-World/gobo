indexing

	description:

		"Eiffel create expressions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CREATE_EXPRESSION

inherit

	ET_EXPRESSION

creation

	make

feature {NONE} -- Initialization

	make (a_type: like creation_type; a_call: like creation_call) is
			-- Create a new create expression.
		require
			a_type_not_void: a_type /= Void
		do
			creation_type := a_type
			creation_call := a_call
			create_keyword := tokens.create_keyword
		ensure
			creation_type_set: creation_type = a_type
			creation_call_set: creation_call = a_call
		end

feature -- Access

	create_keyword: ET_KEYWORD
			-- 'create' keyword

	creation_type: ET_CREATION_TYPE
			-- Creation type surrounded by braces

	type: ET_TYPE is
			-- Creation type
		do
			Result := creation_type.type
		ensure
			type_not_void: Result /= Void
		end

	creation_call: ET_QUALIFIED_CALL
			-- Call to creation procedure

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if not create_keyword.position.is_null then
				Result := create_keyword.position
			else
				Result := creation_type.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if creation_call /= Void then
				Result := creation_call.break
			else
				Result := creation_type.break
			end
		end

feature -- Setting

	set_create_keyword (a_create: like create_keyword) is
			-- Set `create_keyword' to `a_create'.
		require
			a_create_not_void: a_create /= Void
		do
			create_keyword := a_create
		ensure
			create_keyword_set: create_keyword = a_create
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_create_expression (Current)
		end

invariant

	crete_keyword_not_void: create_keyword /= Void
	creation_type_not_void: creation_type /= Void

end
