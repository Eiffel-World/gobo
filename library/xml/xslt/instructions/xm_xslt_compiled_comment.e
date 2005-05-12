indexing

	description:

		"Compiled instructions that produce comment output"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_COMPILED_COMMENT

inherit

	XM_XSLT_TEXT_CONSTRUCTOR
		redefine
			display, item_type, compute_cardinality
		end
		
	XM_XPATH_SHARED_NODE_KIND_TESTS

creation

	make

feature {NONE} -- Initialization

	make (an_executable: XM_XSLT_EXECUTABLE) is
			-- Establish invariant.
		require
			executable_not_void: an_executable /= Void
		do
			executable := an_executable
			compute_static_properties
			initialized := True
		ensure
			executable_set: executable = an_executable
		end

feature -- Access

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, when known
		do
			Result := comment_node_kind_test
		end

feature -- Status report

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "xsl:comment")
			std.error.put_string (a_string)
			std.error.put_new_line
			Precursor (a_level + 1)
		end

feature -- Optimization

	type_check (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static type checking
		do
			do_nothing
		end

feature -- Evaluation

	process_leaving_tail (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Execute `Current', writing results to the current `XM_XPATH_RECEIVER'.
		local
			a_transformer: XM_XSLT_TRANSFORMER
			a_comment, a_string: STRING
			a_comment_marker_index: INTEGER
		do
			a_transformer := a_context.transformer
			expand_children (a_context)
			if last_string_value = Void then
				a_transformer.report_fatal_error (select_expression.last_evaluated_item.error_value, Current)
			else
				a_comment := last_string_value
				from
				a_comment_marker_index := 1
				until
					a_comment_marker_index = 0
				loop
					a_comment_marker_index := a_comment.substring_index ("--", 1)
					if a_comment_marker_index /= 0 then
						a_string := STRING_.concat (a_comment.substring (1, a_comment_marker_index), " ")
						a_comment := STRING_.appended_string (a_string, a_comment.substring (a_comment_marker_index + 1, a_comment.count))
					end
				end
				if a_comment.count > 0 and then a_comment.item (a_comment.count).is_equal ('-') then
					a_comment := STRING_.appended_string (a_comment, " ")
				end
			end
			if not a_transformer.is_error then
				a_context.current_receiver.notify_comment (a_comment, 0)
			end
			last_tail_call := Void
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		do
			set_cardinality_exactly_one
		end

end
	
