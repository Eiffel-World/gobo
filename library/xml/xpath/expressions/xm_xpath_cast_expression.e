indexing

	description:

		"XPath cast as Expressions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_CAST_EXPRESSION

inherit

	XM_XPATH_UNARY_EXPRESSION
		redefine
			item_type, analyze, evaluate_item, compute_cardinality, same_expression
		end

	XM_XPATH_ROLE

creation

	make

feature {NONE} -- Initialization

	make (a_source: XM_XPATH_EXPRESSION; a_target_type: XM_XPATH_ATOMIC_TYPE; empty_ok: BOOLEAN) is
			-- Establish invariant.
		do
			make_unary (a_source)
			target_type := a_target_type
			is_empty_allowed := empty_ok
			compute_static_properties
			initialize
		ensure
			base_expression_set: base_expression = a_source
			target_type_set: target_type = a_target_type
			is_empty_allowed_set: is_empty_allowed = empty_ok
			static_properties_computed: are_static_properties_computed
		end

feature -- Access

	target_type: XM_XPATH_ATOMIC_TYPE
			-- Target type 

	is_empty_allowed: BOOLEAN
			-- Is empty sequence allowed?
	
	item_type: XM_XPATH_ITEM_TYPE is
			--Determine the data type of the expression, if possible
		do
			Result := target_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

feature -- Comparison

	same_expression (other: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Are `Current' and `other' the same expression?
		local
			other_cast: XM_XPATH_CAST_EXPRESSION
		do
			other_cast ?= other
			if other_cast /= Void then
				Result := base_expression.same_expression (other_cast.base_expression) 
					and then other_cast.is_empty_allowed = is_empty_allowed
					and then other_cast.target_type = target_type
			end
		end

feature -- Optimization	

	analyze (a_context: XM_XPATH_STATIC_CONTEXT) is
			-- Perform static analysis of an expression and its subexpressions
		local
			a_role: XM_XPATH_ROLE_LOCATOR
			a_sequence_type: XM_XPATH_SEQUENCE_TYPE
			a_type_checker: XM_XPATH_TYPE_CHECKER
			an_expression: XM_XPATH_EXPRESSION
			a_qname_cast: XM_XPATH_CAST_AS_QNAME_EXPRESSION
			an_atomic_value: XM_XPATH_ATOMIC_VALUE
		do
			mark_unreplaced
			base_expression.analyze (a_context)
			if base_expression.was_expression_replaced then
				set_base_expression (base_expression.replacement_expression)
			end
			if base_expression.is_error then
				set_last_error (base_expression.error_value)
			else
				create a_sequence_type.make (type_factory.any_atomic_type, cardinality)
				create a_role.make (Type_operation_role, "cast as", 1)
				create a_type_checker
				a_type_checker.static_type_check (a_context, base_expression, a_sequence_type, False, a_role)
				if a_type_checker.is_static_type_check_error then
					set_last_error_from_string (a_type_checker.static_type_check_error_message, Xpath_errors_uri, "XP0004", Type_error)
				else
					an_expression := a_type_checker.checked_expression
					if is_sub_type (an_expression.item_type, target_type) then
						set_replacement (an_expression)

						-- It's not entirely clear that the spec permits this. Perhaps we should change the type label?
						-- On the other hand, it's generally true that any expression defined to return an X
						--  is allowed to return a subtype of X:

					elseif is_sub_type (target_type, type_factory.qname_type) then --or else (type_factory.notation_type /= Void and then is_sub_type (target_type, type_factory.notation_type)) then
						create a_qname_cast.make (an_expression)
						a_qname_cast.analyze (a_context)
						if a_qname_cast.is_error then
							set_last_error (a_qname_cast.error_value)
						else
							set_replacement (a_qname_cast)
						end
					else
						an_atomic_value ?= an_expression
						if an_atomic_value /= Void then
							evaluate_item (Void)
							an_atomic_value ?= last_evaluated_item
							if an_atomic_value /= Void then
								set_replacement (an_atomic_value)
							end
						else
							set_base_expression (an_expression)
						end
					end
				end
			end
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		local
			an_atomic_value: XM_XPATH_ATOMIC_VALUE
		do
			base_expression.evaluate_item (a_context)
			if base_expression.last_evaluated_item = Void or else base_expression.last_evaluated_item.is_error then
				last_evaluated_item := base_expression.last_evaluated_item
			else
				an_atomic_value ?= base_expression.last_evaluated_item
				if an_atomic_value = Void then
					if is_empty_allowed then
						last_evaluated_item := Void
					else
						create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string (STRING_.appended_string ("Target typr for cast as does not allow empty sequence",
																																					 target_type.conventional_name), Xpath_errors_uri, "XP0006", Type_error)
					end
				elseif an_atomic_value.is_convertible (target_type) then
					last_evaluated_item := an_atomic_value.convert_to_type (target_type)
				else
					create {XM_XPATH_INVALID_ITEM} last_evaluated_item.make_from_string (STRING_.appended_string ("Could not cast expression to type ",
																																				 target_type.conventional_name), Xpath_errors_uri, "XP0021", Dynamic_error)
				end
			end
		end


feature {XM_XPATH_UNARY_EXPRESSION} -- Restricted
	
	display_operator: STRING is
			-- Format `operator' for display
		do
			Result := "cast as " + target_type.conventional_name
		end

	
feature {NONE} -- Implementation
	
	compute_cardinality is
			-- Compute cardinality.
		do
			if is_empty_allowed then
				set_cardinality_optional
			else
				set_cardinality_exactly_one
			end
		end

invariant

	target_type_not_void: target_type /= Void

end
