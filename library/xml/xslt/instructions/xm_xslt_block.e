indexing

	description:

		"Objects that represent a hypothetical xsl:block instruction"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_BLOCK

inherit

	XM_XSLT_INSTRUCTION
		redefine
			sub_expressions, item_type, compute_cardinality,
			promote_instruction,
			native_implementations, iterator, creates_new_nodes
		end

	XM_XPATH_SHARED_EXPRESSION_TESTER

		-- Implements an imaginary xsl:block instruction which simply evaluates
		--  it's contents. Used for top-level templates, xsl:otherwise, etc.

creation

	make

feature {NONE} -- Initialization

	make (an_executable: XM_XSLT_EXECUTABLE; a_head_expression, a_tail_expression: XM_XPATH_EXPRESSION) is
			-- Create a general-purpose block.
		require
			executable_not_void: an_executable /= Void
			head_not_replaced: a_head_expression /= Void and then not a_head_expression.was_expression_replaced
			tail_not_replaced: a_tail_expression /= Void and then not a_tail_expression.was_expression_replaced
		local
			a_block, another_block: XM_XSLT_BLOCK
			a_child_count: INTEGER
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			executable := an_executable			
			a_block ?= a_head_expression
			another_block ?= a_tail_expression
			if a_block = Void and then another_block = Void then
				create children.make (2)
				children.put (a_head_expression, 1)
				children.put (a_tail_expression, 2)				
			else
				if a_block = Void then
					a_child_count := 1
				else
					a_child_count := a_block.children.count
				end
				if another_block = Void then
					a_child_count := 1 + a_child_count
				else
					a_child_count := a_child_count + another_block.children.count
				end
				create children.make (a_child_count)
				if a_block = Void then
					children.put (a_head_expression, 1)
				else
					children.extend_last (a_block.children)
				end
				if another_block = Void then
					children.put_last (a_tail_expression)
				else
					children.extend_last (another_block.children)
				end
			end
			children.set_equality_tester (expression_tester)
			from
				a_cursor := children.new_cursor; a_cursor.start
			variant
				children.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				adopt_child_expression (a_cursor.item)
				a_cursor.forth
			end
			compute_static_properties
			initialize
		ensure
			executable_set: executable = an_executable
		end

feature -- Access

	instruction_name: STRING is
			-- Name of instruction, for diagnostics
		do
			Result := "[xsl:block]"
		end

	children: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION]
			-- Child expressions

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression, when known
		local
			a_type: XM_XPATH_ITEM_TYPE
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			if children.count = 0 then
				Result := empty_item
			else
				from
					a_cursor := children.new_cursor; a_cursor.start
				variant
					children.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					a_type := a_cursor.item.item_type
					if Result = Void then
						Result := a_type
						a_cursor.forth
					else
						Result := common_super_type (Result, a_type)
						if Result = any_item then
							a_cursor.go_after
						else
							a_cursor.forth
						end
					end
				end
			end
		end

	sub_expressions: DS_ARRAYED_LIST [XM_XPATH_EXPRESSION] is
			-- Immediate sub-expressions of `Current'
		do
			Result := children
		end

feature -- Status report

	creates_new_nodes: BOOLEAN is
			-- Can `Current' create new nodes?
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			if children.count > 0 then
				from
					a_cursor := children.new_cursor; a_cursor.start
				variant
					children.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					if not a_cursor.item.non_creating then
						Result := True
						a_cursor.go_after
					else
						a_cursor.forth
					end
				end
			end
		end

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			from
				a_cursor := children.new_cursor; a_cursor.start
			variant
				children.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				a_cursor.item.display (a_level)
				a_cursor.forth
			end
		end
	
feature -- Optimization

	simplify is
			-- Perform context-independent static optimizations.
		local
			all_atomic: BOOLEAN
			an_empty_sequence: XM_XPATH_EMPTY_SEQUENCE
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
			a_child: XM_XPATH_EXPRESSION
			a_value: XM_XPATH_ATOMIC_VALUE
			a_list: DS_ARRAYED_LIST [XM_XPATH_ITEM]
			an_extent: XM_XPATH_SEQUENCE_EXTENT
		do
			if children.count = 0 then
				create an_empty_sequence.make
				set_replacement (an_empty_sequence)
			elseif children.count = 1 then
				a_child := children.item (1)
				a_child.simplify
				if a_child.was_expression_replaced then
					set_replacement (a_child.replacement_expression)
				else
					set_replacement (a_child)
				end
			else
				from
					a_cursor := children.new_cursor; a_cursor.start
					all_atomic := True
				variant
					children.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					a_child := a_cursor.item
					a_child.simplify
					if a_child.was_expression_replaced then
						a_cursor.replace (a_child.replacement_expression)
						a_value ?= a_child.replacement_expression
					else
						a_value ?= a_child
					end
					if a_value = Void then all_atomic := False end
					a_cursor.forth
				end
				if all_atomic then
					create a_list.make (children.count)
					from
						a_cursor := children.new_cursor; a_cursor.start
					variant
						children.count + 1 - a_cursor.index
					until
						a_cursor.after
					loop
						a_value ?= a_cursor.item
						a_list.put_last (a_value)
						a_cursor.forth
					end
					create an_extent.make_from_list (a_list)
					set_replacement (an_extent)
				end
			end
		end

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of `Current' and its subexpressions.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
			a_child: XM_XPATH_EXPRESSION
		do
			from
				a_cursor := children.new_cursor; a_cursor.start
			variant
				children.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				a_child := a_cursor.item
				a_child.analyze (a_context)
				if a_child.is_error then
					set_last_error (a_child.error_value)
				elseif a_child.was_expression_replaced then
					a_cursor.replace (a_child.replacement_expression)
				end
				a_cursor.forth
			end	
		end

	
	promote_instruction (an_offer: XM_XPATH_PROMOTION_OFFER) is
			-- Promote this instruction.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
			a_child: XM_XPATH_EXPRESSION
		do
			from
				a_cursor := children.new_cursor; a_cursor.start
			variant
				children.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				a_child := a_cursor.item
				a_child.promote (an_offer)
				if a_child.was_expression_replaced then
					a_cursor.replace (a_child.replacement_expression)
				end
				a_cursor.forth
			end	
		end

feature -- Evaluation

	iterator (a_context: XM_XPATH_CONTEXT): XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM] is
			-- Iterate over the values of a sequence
		do
			if children.count = 0 then
				create {XM_XPATH_EMPTY_ITERATOR [XM_XPATH_ITEM]} Result.make
			elseif children.count = 1 then
				Result := children.item (1).iterator (a_context)
			else
				create {XM_XSLT_BLOCK_ITERATOR} Result.make (children, a_context)
			end
		end

	process_leaving_tail (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Execute `Current', writing results to the current `XM_XPATH_RECEIVER'.
		local
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
			a_child: XM_XPATH_EXPRESSION
			an_instruction: XM_XSLT_INSTRUCTION
		do
			last_tail_call := Void
			from
				a_cursor := children.new_cursor; a_cursor.start
			variant
				children.count + 1 - a_cursor.index
			until
				a_cursor.after
			loop
				a_child := a_cursor.item
				an_instruction ?= a_child
				if an_instruction /= Void then
					an_instruction.process_leaving_tail (a_context)
					last_tail_call := an_instruction.last_tail_call
				else
					a_child.process (a_context)
					last_tail_call := Void
				end
				a_cursor.forth
			end	
		end

feature {XM_XSLT_EXPRESSION} -- Restricted

	compute_cardinality is
			-- Compute cardinality.
		local
			a_cardinality: INTEGER
			a_cursor: DS_ARRAYED_LIST_CURSOR [XM_XPATH_EXPRESSION]
		do
			if children.count = 0 then
				set_cardinality_empty
			else
				from
					a_cursor := children.new_cursor; a_cursor.start
					a_cardinality := a_cursor.item.cardinality; a_cursor.forth
				variant
					children.count + 1 - a_cursor.index
				until
					a_cursor.after
				loop
					a_cardinality := add_cardinality (a_cardinality, a_cursor.item.cardinality)
					a_cursor.forth
				end
				set_cardinality (a_cardinality)
			end
		end

feature {NONE} -- Implementation
	
	native_implementations: INTEGER is
			-- Natively-supported evaluation routines
		do
				Result := Supports_process + Supports_iterator
		end

invariant

	children_not_void: children /= Void

end
	
