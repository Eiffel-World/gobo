note
	description: "Stacks implemented by resizable arrays"
	library: "Free implementation of ELKS library"
	legal: "See notice at end of class."
	status: "See notice at end of class."
	names: dispenser, array;
	representation: array;
	access: fixed, lifo, membership;
	size: fixed;
	contents: generic;
	date: "$Date: 2012-07-23 23:02:19 +0200 (Mon, 23 Jul 2012) $"
	revision: "$Revision: 567 $"

class ARRAYED_STACK [G] inherit

	STACK [G]
		undefine
			copy, is_equal, prune_all, replace, is_inserted
		redefine
			linear_representation
		select
			remove, extend, put
		end

	ARRAYED_LIST [G]
		rename
			put as al_put,
			extend as al_extend,
			force as al_force,
			remove as al_remove,
			start as finish,
			finish as start,
			forth as back,
			back as forth,
			after as before,
			before as after
		export
			{NONE} all
			{ANY}
				count, readable, writable, extendible,
			 	make, wipe_out, valid_index, index, off
			{STACK} before, after, start, finish, forth, back
			{ARRAYED_STACK} valid_cursor, cursor, go_to, area, area_v2,
				i_th, upper, lower
		undefine
			readable, writable,
			append, fill
		redefine
			linear_representation
		end

create
	make

create {ARRAYED_STACK}
	make_filled

feature -- Element change

	extend, put, force (v: like item)
			-- Push `v' on top.
		do
			al_extend (v)
			start
		end

feature -- Removal

	remove
			-- Remove top item.
		require else
			not_empty: count /= 0
		do
			al_remove
			start
		end

feature -- Conversion

	linear_representation: ARRAYED_LIST [G]
			-- Representation as a linear structure
			-- (in the reverse order of original insertion)
		local
			i: INTEGER
		do
			from
				create Result.make (count)
				i := count
			until
				i < 1
			loop
				Result.extend (i_th (i))
				i := i - 1
			end
		end

note
	copyright: "Copyright (c) 1984-2012, Eiffel Software and others"
	license:   "Eiffel Forum License v2 (see http://www.eiffel.com/licensing/forum.txt)"
	source: "[
			Eiffel Software
			5949 Hollister Ave., Goleta, CA 93117 USA
			Telephone 805-685-1006, Fax 805-685-6869
			Website http://www.eiffel.com
			Customer support http://support.eiffel.com
		]"

end
