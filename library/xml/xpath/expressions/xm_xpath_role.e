indexing

	description:

		"Expression roles"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_ROLE

feature -- Access

	Function_role: INTEGER is 1
	Binary_expression_role: INTEGER is 2
	Type_operation_role: INTEGER is 3
	Variable_role: INTEGER is 4
	Instruction_role: INTEGER is 5
	Function_result_role: INTEGER is 6
	Order_by_role: INTEGER is 7
	
end

