indexing

	description:

		"Objects that select a tail sequence."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_TAIL_ITERATOR

inherit

	XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
		redefine
			before, start
		end

creation

	make

feature {NONE} -- Initialization

	make (a_base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]; a_start_position: INTEGER) is
			-- Establish invariant.
		require
			base_iterator_before: a_base_iterator /= Void and then a_base_iterator.before
			valid_start_position: a_start_position > 0
		do
			base_iterator := a_base_iterator
			start_position := a_start_position
		ensure
			base_iterator_set:base_iterator = a_base_iterator
			start_position_set: start_position = a_start_position
		end

feature -- Access

	item: XM_XPATH_ITEM is
			-- Value or node at the current position
		do
			Result := base_iterator.item
		end

feature -- Status report

	before: BOOLEAN is
			-- Are there any more items in the sequence?
		do
			Result := index < start_position
		end

	after: BOOLEAN is
			-- Are there any more items in the sequence?
		do
			Result := base_iterator.after
		end

feature -- Cursor movement

	start is
			-- Move to first position
		do
			from
				base_iterator.start
				index :=  1
			until
				index = start_position or else base_iterator.after
			loop
				index := index + 1
				if not base_iterator.after then base_iterator.forth end
			end
			if index < start_position then index := start_position end
		end

	forth is
			-- Move to next position
		do
			index := index + 1
			if not base_iterator.after then base_iterator.forth end
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original
		do
			create Result.make (base_iterator.another, start_position)
		end

feature {NONE} -- Implementation

	base_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			-- Underlying sequence

	start_position: INTEGER

invariant

	base_iterator_not_void: base_iterator /= Void
	valid_start_position: start_position > 0

end
