indexing

	description:

		"Test XPath reverse() function."

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_TEST_REVERSE

inherit

	TS_TEST_CASE
		redefine
			set_up
		end

	XM_XPATH_TYPE
	
	XM_XPATH_ERROR_TYPES

	XM_XPATH_SHARED_CONFORMANCE

	KL_IMPORTED_STRING_ROUTINES

	KL_SHARED_STANDARD_FILES

feature -- Tests

	test_reverse_one is
			-- Test fn:reverse (('a', 'b', 'c')) returns ('c', 'b', 'a')
		local
			an_evaluator: XM_XPATH_EVALUATOR
			evaluated_items: DS_LINKED_LIST [XM_XPATH_ITEM]
			a_string_value: XM_XPATH_STRING_VALUE
		do
			create an_evaluator.make (18, False)
			an_evaluator.set_string_mode_ascii
			an_evaluator.build_static_context ("./data/languages.xml", False, False, False, True)
			assert ("Build successfull", not an_evaluator.was_build_error)
			an_evaluator.evaluate ("reverse (('a', 'b', 'c'))")
			assert ("No evaluation error", not an_evaluator.is_error)
			evaluated_items := an_evaluator.evaluated_items
			assert ("Three values", evaluated_items /= Void and then evaluated_items.count = 3)
			a_string_value ?= evaluated_items.item (1)
			assert ("First value is string", a_string_value /= Void)
			assert ("First value is c", STRING_.same_string (a_string_value.string_value, "c"))
			a_string_value ?= evaluated_items.item (2)
			assert ("Second value is string", a_string_value /= Void)
			assert ("Second value is b", STRING_.same_string (a_string_value.string_value, "b"))
			a_string_value ?= evaluated_items.item (3)
			assert ("Third value is string", a_string_value /= Void)
			assert ("Third value is a", STRING_.same_string (a_string_value.string_value, "a"))
		end

	set_up is
		do
			conformance.set_basic_xslt_processor
		end

end

			
