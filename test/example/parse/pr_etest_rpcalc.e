indexing

	description:

		"Test 'rpcalc' example"

	library: "Gobo Eiffel Parse Library"
	copyright: "Copyright (c) 2001, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class PR_ETEST_RPCALC

inherit

	EXAMPLE_TEST_CASE

feature -- Access

	program_name: STRING is "rpcalc"
			-- Program name

	library_name: STRING is "parse"
			-- Library name of example

feature -- Test

	test_rpcalc is
			-- Test 'rpcalc' example.
		do
			compile_program
		end

end
