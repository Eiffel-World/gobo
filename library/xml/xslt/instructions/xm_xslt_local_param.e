indexing

	description:

		"Objects that represent the compiled form of a local xsl:param"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_LOCAL_PARAM

inherit

	XM_XSLT_LOCAL_VARIABLE
		redefine
			make, process_leaving_tail, sub_expressions, display
		end

creation

	make

feature {NONE} -- Initialization

	make (an_executable: XM_XSLT_EXECUTABLE; a_name: STRING; a_slot_number: INTEGER) is
			-- Establish invariant.
		do
			Precursor (an_executable, a_name, a_slot_number)
			instruction_name := "xsl:param"
		end

feature -- Access
	
	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do
			create Result.make (2)
			Result.set_equality_tester (expression_tester)
			if select_expression /= Void then Result.put_last (select_expression) end
			if conversion /= Void then Result.put_last (conversion) end
		end

feature -- Status report

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "local parameter: ")
			std.error.put_string (a_string);
			std.error.put_string (variable_name);
			std.error.put_new_line
			if select_expression /= Void then select_expression.display (a_level + 1) end
		end

feature -- Element change

	set_conversion (a_conversion: like conversion) is
			-- Set type conversion.
		do
			conversion := a_conversion
			if conversion /= Void then adopt_child_expression (conversion) end
		end

feature -- Evaluation

	process_leaving_tail (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Execute `Current', writing results to the current `XM_XPATH_RECEIVER'.
		local
			was_supplied: BOOLEAN
			an_invalid_item : XM_XPATH_INVALID_ITEM
		do
			was_supplied := a_context.is_local_parameter_supplied (variable_fingerprint, is_tunnel_parameter)
			if was_supplied then
				if conversion /= Void then

					-- We do an eager evaluation here for safety, because the result of the
               --  type conversion overwrites the slot where the actual supplied parameter
               --   is contained.

					conversion.eagerly_evaluate (a_context)
					a_context.set_local_variable (conversion.last_evaluation, slot_number)
				else
					a_context.ensure_local_parameter_set (variable_fingerprint, is_tunnel_parameter, slot_number)
				end
			else
				if is_required_parameter then
					create an_invalid_item.make_from_string (STRING_.concat ("Circular definition of global variable: ", variable_name), "", "XT0640", Dynamic_error)
					a_context.current_receiver.append_item (an_invalid_item)
				else
					a_context.set_local_variable (select_value (a_context), slot_number)
				end
			end
			last_tail_call := Void
		end

feature {NONE} -- Implementation

	conversion: XM_XPATH_EXPRESSION
			-- Type conversion to be applied

end
	
