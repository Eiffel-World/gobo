indexing

	description:

		"Test 'bang2create' example"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2003, Eric Bezault and others"
	license: "Eiffel Forum License v1 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_ETEST_BANG2CREATE

inherit

	EXAMPLE_TEST_CASE

feature -- Access

	program_name: STRING is "bang2create"
			-- Program name

	library_name: STRING is "tools"
			-- Library name of example

feature -- Test

	test_bang2create is
			-- Test 'bang2create' example.
		do
			compile_program
		end

end
