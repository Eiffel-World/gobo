indexing

	description:

		"Test features of class CONCAT2"

	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class TEST_CONCAT2

inherit

	TS_TEST_CASE

feature -- Test

	test_concat is
			-- Test feature `concat'.
		local
			c: CONCAT2
		do
			create c.make
			assert_equal ("toto", "toto", c.concat ("to", "to"))
			assert_equal ("foobar", "foobar", c.concat ("foo", "bar"))
		end

end
