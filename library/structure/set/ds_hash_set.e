indexing

	description:

		"Sets implemented with single arrays. Items are hashed %
		%using `hash_code' from HASHABLE."

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 1999-2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class DS_HASH_SET [G -> HASHABLE]

inherit

	DS_ARRAYED_SPARSE_SET [G]
		redefine
			new_cursor
		end

creation

	make, make_equal, make_default

feature -- Access

	new_cursor: DS_HASH_SET_CURSOR [G] is
			-- New external cursor for traversal
		do
			!! Result.make (Current)
		end

feature {NONE} -- Implementation

	hash_position (v: G): INTEGER is
			-- Hash position of `v' in `slots';
			-- Use `v.hash_code' as hashing function.
		do
			if v /= Void then
				Result := v.hash_code \\ modulus
			else
				Result := modulus
			end
		end

end -- class DS_HASH_SET
