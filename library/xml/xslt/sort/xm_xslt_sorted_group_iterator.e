indexing

	description:

		"TBA"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class	XM_XSLT_SORTED_GROUP_ITERATOR

inherit

	XM_XSLT_GROUP_ITERATOR

	XM_XSLT_SORTED_ITERATOR
		rename
			make as make_sorted_iterator
		redefine
			build_array
		end

creation

	make, make_sorted_iterator

feature {NONE} -- Initialization

	make (a_context: XM_XSLT_EVALUATION_CONTEXT;
			a_base_iterator: XM_XSLT_GROUP_ITERATOR;
			some_sort_keys: DS_ARRAYED_LIST [XM_XSLT_FIXED_SORT_KEY_DEFINITION]) is
			-- Establish invariant
		require
			context_not_void: a_context /= Void
			base_iterator_not_void: a_base_iterator /= Void
			at_least_one_sort_key: some_sort_keys /= Void and then some_sort_keys.count > 0
		do
			make_sorted_iterator (a_context, a_base_iterator, some_sort_keys)
			group_iterator := a_base_iterator
		end

feature -- Access

	current_grouping_key: XM_XPATH_ATOMIC_VALUE is
			-- Grouping key for current group;
			-- (or `Void' for group-starting/ending-with)
		do
			todo ("current_grouping_key", False)
		end

feature -- Evaluation

	current_group_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM] is
			-- Iterator over the members of the current group, in population order.
		local
			a_sort_record: XM_XSLT_GROUP_SORT_RECORD
		do
			a_sort_record ?= node_keys.item (index)
			check
				group_sort_record: a_sort_record /= Void
				-- `build_array' assures this
			end
			Result := a_sort_record.current_group_iterator.another
		end

feature {NONE} -- Implementation

	group_iterator: XM_XSLT_GROUP_ITERATOR
			-- Sequence to be sorted

	build_array is
			-- Build `node_keys'.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XSLT_FIXED_SORT_KEY_DEFINITION]
			a_sort_record: XM_XSLT_GROUP_SORT_RECORD
			a_key_list: DS_ARRAYED_LIST [XM_XPATH_ATOMIC_VALUE]
			a_sort_key: XM_XPATH_ATOMIC_VALUE
			a_new_context: like context
		do
			create node_keys.make_default

			-- This provides the context for evaluating the sort key:
			-- Note that current() must return the node being sorted.

			a_new_context := context.new_context
			a_new_context.set_current_iterator (base_iterator)
			a_new_context.set_current_group_iterator (group_iterator)
			
			-- Initialize the array with data.

			from
				group_iterator.start
			until
				group_iterator.after
			loop
				if node_keys.is_full then
					node_keys.resize (node_keys.count * 2)
				end
				from
					create a_key_list.make (sort_keys.count)
					a_cursor := sort_keys.new_cursor; a_cursor.start
				until
					a_cursor.after
				loop
					a_cursor.item.sort_key.evaluate_item (context)
					if a_cursor.item.sort_key.last_evaluated_item /= Void then
						a_sort_key ?= a_cursor.item.sort_key.last_evaluated_item
					else
						a_sort_key := Void  -- = () - an empty sequence
					end
					a_key_list.put_last (a_sort_key)
					a_cursor.forth
				end

				-- Make the sort stable by adding the record number.

				count := count + 1

				-- next line is the only difference from the Precursor
				-- (apart from the type of `a_sort_record',
				--  the use of `group_iterator' for `base_iterator' throughout)
				--  and the setting and saving of the current group iterator).

				create a_sort_record.make (group_iterator.item, a_key_list, count,group_iterator.current_grouping_key, group_iterator.current_group_iterator)
				node_keys.put_last (a_sort_record)
				group_iterator.forth
			end
			count_determined := True
		end

invariant

	group_iterator: group_iterator = base_iterator

end
	
