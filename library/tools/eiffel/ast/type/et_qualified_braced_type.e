indexing

	description:

		"Eiffel qualified anchored types of the form 'like {A}.b'"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_QUALIFIED_BRACED_TYPE

inherit

	ET_QUALIFIED_TYPE

creation

	make

feature {NONE} -- Initialization

	make (a_type: like braced_type; a_name: like qualified_name) is
			-- Create a new 'like {A}.b' type.
		require
			a_type_not_void: a_type /= Void
			a_name_not_void: a_name /= Void
		do
			braced_type := a_type
			qualified_name := a_name
			like_keyword := tokens.like_keyword
		ensure
			braced_type_set: target_type = a_type
			qualified_name_set: qualified_name = a_name
		end

feature -- Access

	like_keyword: ET_KEYWORD
			-- 'like' keyword

	target_type: ET_TYPE is
			-- Target anchored type
		do
			Result := braced_type.type
		end

	braced_type: ET_TARGET_TYPE
			-- Target anchored type surrounded by braces

feature -- Setting

	set_like_keyword (a_like: like like_keyword) is
			-- Set `like_keyword' to `a_like'.
		require
			a_like_not_void: a_like /= Void
		do
			like_keyword := a_like
		ensure
			like_keyword_set: like_keyword = a_like
		end

feature -- Output

	append_to_string (a_string: STRING) is
			-- Append textual representation of
			-- current type to `a_string'.
		do
			a_string.append_string (like_space)
			a_string.append_character ('{')
			target_type.append_to_string (a_string)
			a_string.append_character ('}')
			a_string.append_character ('.')
			a_string.append_string (name.name)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_qualified_braced_type (Current)
		end

invariant

	braced_type_not_void: braced_type /= Void

end
