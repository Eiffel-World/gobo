indexing

	description:

		"Hash tables, implemented with single arrays. %
		%Keys are hashed using `hash_code' from HASHABLE."

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 2000-2001, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class DS_HASH_TABLE [G, K -> HASHABLE]

inherit

	DS_ARRAYED_SPARSE_TABLE [G, K]
		redefine
			new_cursor
		end

creation

	make, make_equal, make_default,
	make_map, make_map_equal, make_map_default

feature -- Access

	new_cursor: DS_HASH_TABLE_CURSOR [G, K] is
			-- New external cursor for traversal
		do
			create Result.make (Current)
		end

feature {NONE} -- Implementation

	hash_position (k: K): INTEGER is
			-- Hash position of `k' in `slots'
			-- Use `k.hash_code' as hashing function.
		do
			if k /= Void then
				Result := k.hash_code \\ modulus
			else
				Result := modulus
			end
		end

end
