indexing

	description:

		"Test features of class DS_HASH_TABLE"

	library: "Gobo Eiffel Structure Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class DS_TEST_HASH_TABLE

inherit

	TS_TEST_CASE

feature -- Test

	test_hash_table1 is
			-- Test features of DS_HASH_TABLE.
		local
			a_table: DS_HASH_TABLE [INTEGER, INTEGER]
		do
			!! a_table.make (10)
			assert ("empty1", a_table.is_empty)
			assert_equal ("capacity", 10, a_table.capacity)
			a_table.put (1, 1)
			a_table.force (2, 2)
			a_table.put_new (3, 3)
			a_table.force_new (4, 4)
			assert_iarrays_same ("items1", <<1, 2, 3, 4>>, a_table.to_array)
			assert ("has_1", a_table.has (1))
			assert ("has_2", a_table.has (2))
			assert ("has_3", a_table.has (3))
			assert ("has_4", a_table.has (4))
			assert ("not_has_5", not a_table.has (5))
			a_table.remove (3)
			assert ("not_has_3", not a_table.has (3))
			assert_iarrays_same ("items2", <<1, 2, 4>>, a_table.to_array)
			a_table.force_last (10, 10)
			assert_iarrays_same ("items3", <<1, 2, 4, 10>>, a_table.to_array)
			a_table.put (5, 5)
			assert_iarrays_same ("items4", <<1, 2, 5, 4, 10>>, a_table.to_array)
			a_table.remove (10)
			a_table.put (6, 6)
			assert_iarrays_same ("items5", <<1, 2, 5, 4, 6>>, a_table.to_array)
			a_table.remove (6)
			assert_iarrays_same ("items6", <<1, 2, 5, 4>>, a_table.to_array)
			a_table.put (7, 7)
			assert_iarrays_same ("items7", <<1, 2, 5, 4, 7>>, a_table.to_array)
			a_table.wipe_out
			assert ("empty2", a_table.is_empty)
			a_table.put (8, 8)
			assert_iarrays_same ("items8", <<8>>, a_table.to_array)
			a_table.put (8, 8)
			assert_iarrays_same ("items9", <<8>>, a_table.to_array)
		end

end
