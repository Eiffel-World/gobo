indexing

	description:

		"XSLT union patterns"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_UNION_PATTERN

inherit

	XM_XSLT_PATTERN
		redefine
			simplified_pattern, type_check
		end

creation

	make

feature {NONE} -- Initialization

	make (a_static_context: XM_XPATH_STATIC_CONTEXT; a_pattern_one, a_pattern_two: XM_XSLT_PATTERN) is
			-- Establish invariant.
		require
				pattern_one_not_void: a_pattern_one /= Void
				pattern_two_not_void: a_pattern_two /= Void
				static_context_not_void: a_static_context /= Void
		do
			left_hand_side := a_pattern_one
			right_hand_side := a_pattern_two
			if a_pattern_one.node_kind = a_pattern_two.node_kind then
				node_type := a_pattern_one.node_kind
			else
				node_type := Any_node
			end
			original_text := STRING_.concat (a_pattern_one.original_text, "|")
			original_text := STRING_.appended_string (original_text, a_pattern_two.original_text)
			static_context := a_static_context
			system_id := a_static_context.system_id
			line_number := a_static_context.line_number
		ensure
			pattern_one_set: left_hand_side = a_pattern_one
			pattern_two_set: right_hand_side = a_pattern_two
			system_id_set: STRING_.same_string (system_id, a_static_context.system_id)
			line_number_set: line_number = a_static_context.line_number
			static_context_stored: static_context = a_static_context
		end
	
feature -- Access

	left_hand_side, right_hand_side: XM_XSLT_PATTERN
			-- Patterns forming union

	original_text: STRING
			-- Original text

	node_test: XM_XSLT_NODE_TEST is
			-- Retrieve an `XM_XSLT_NODE_TEST' that all nodes matching this pattern must satisfy
		do
			if node_type = Any_node then
				create {XM_XSLT_ANY_NODE_TEST} Result.make
			else
				create {XM_XSLT_NODE_KIND_TEST} Result.make (static_context, node_type)
			end
		end

feature -- Analysis

	simplified_pattern: XM_XSLT_PATTERN is
			-- Simplify a pattern by applying any context-independent optimizations;
			-- Default implementation does nothing
		do
			create {XM_XSLT_UNION_PATTERN} Result.make (static_context, left_hand_side.simplified_pattern, right_hand_side.simplified_pattern)
		end

	type_check (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Type-check the pattern;
			-- Default implementation does nothing. This is only needed for patterns that contain
			-- variable references or function calls.
		do
			left_hand_side.type_check (a_context)
			if left_hand_side.is_error then
				set_error_value (left_hand_side.error_value)
			else
				right_hand_side.type_check (a_context)
				if right_hand_side.is_error then
					set_error_value (right_hand_side.error_value)
				end
			end
		end

feature -- Matching

	matches (a_node: XM_XPATH_NODE; a_context: XM_XSLT_EVALUATION_CONTEXT): BOOLEAN is
			-- Determine whether this Pattern matches the given Node;
		do
			Result := left_hand_side.matches (a_node, a_context) or else right_hand_side.matches (a_node, a_context)
		end

feature {NONE} -- Implementation

	node_type: INTEGER
			-- Type of nodes in this pattern

	static_context: XM_XPATH_STATIC_CONTEXT
			-- Static context stored for simplification

invariant

	pattern_one_not_void: left_hand_side /= Void
	pattern_two_not_void: right_hand_side /= Void
	static_context_not_void: static_context /= Void
	
end
	
