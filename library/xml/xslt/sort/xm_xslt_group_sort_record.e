indexing

	description:

		"Sort records for XM_XSLT_SORTED_GROUP_ITERATOR"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class	XM_XSLT_GROUP_SORT_RECORD

inherit

	XM_XSLT_SORT_RECORD
		rename
			make as make_sort_record
		end

creation

	make

feature {NONE} -- Initialization

	make (an_item: XM_XPATH_ITEM; a_key_list: DS_ARRAYED_LIST [XM_XPATH_ATOMIC_VALUE]; a_count: INTEGER;
			a_current_grouping_key: XM_XPATH_ATOMIC_VALUE; a_current_group_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]) is
			-- Establish invariant.
		require
			item_not_void: an_item /= Void
			key_list_not_void: a_key_list /= Void
			strictly_positive_record_number: a_count > 0
			current_grouping_key_not_void: a_current_grouping_key /= Void
			current_group_iterator_not_void: a_current_group_iterator /= Void
		do
			make_sort_record (an_item, a_key_list, a_count)
			current_grouping_key := a_current_grouping_key
			current_group_iterator := a_current_group_iterator
		ensure
			item_set: item = an_item
			key_list_set: key_list = a_key_list
			record_number_set: record_number = a_count
			current_grouping_key_set: current_grouping_key = a_current_grouping_key
			current_group_iterator_set: current_group_iterator = a_current_group_iterator
		end

feature -- Access

	current_grouping_key: XM_XPATH_ATOMIC_VALUE
			-- Current grouping key

	current_group_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			-- Current group iterator

invariant

	current_grouping_key_not_void: current_grouping_key /= Void
	current_group_iterator_not_void: current_group_iterator /= Void

end
	
