indexing

	description:

		"Eiffel anchored types"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_LIKE_TYPE

inherit

	ET_TYPE
		redefine
			has_anchored_type
		end

	HASHABLE

feature -- Access

	like_keyword: ET_KEYWORD is
			-- 'like' keyword
		deferred
		end

feature -- Status report

	has_anchored_type (a_context: ET_TYPE_CONTEXT): BOOLEAN is
			-- Does current type contain an anchored type
			-- when viewed from `a_context'?
		do
			Result := True
		end

feature {NONE} -- Constants

	like_space: STRING is "like "
			-- Eiffel keywords

invariant

	like_keyword_not_void: like_keyword /= Void

end
