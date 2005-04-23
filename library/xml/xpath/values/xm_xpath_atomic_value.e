indexing

	description:

		"Objects that are XPath values that are not a sequence (strictly, a sequence of one item)"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class XM_XPATH_ATOMIC_VALUE

inherit

	XM_XPATH_VALUE
		undefine
			is_integer_value, as_integer_value, is_string_value, as_string_value, is_decimal_value, as_decimal_value,
			is_qname_value, as_qname_value, is_boolean_value, as_boolean_value, is_numeric_value, as_numeric_value,
			is_atomic_value, as_atomic_value, is_untyped_atomic, as_untyped_atomic, is_object_value
		redefine
			process
		end

	XM_XPATH_ITEM
		redefine
			as_item_value, is_atomic_value, as_atomic_value
		end

	HASHABLE

feature {NONE} -- Initialization

	make_atomic_value is
			-- Establish static properties
		do
			make_value
			set_cardinality_exactly_one
		end

feature -- Access

	typed_value: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ATOMIC_VALUE] is
			-- Typed value
		do
			create {XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_ATOMIC_VALUE]} Result.make (Current)
		end

	type_name: STRING is
			-- Type name for diagnostic purposes
		do
			Result := item_type.conventional_name
		end

	primitive_value: XM_XPATH_ATOMIC_VALUE is
			-- Primitive value;
			-- For built-in types, this is the type itself.
			-- For user-defined types, this is the type minus it's type annotation.
		do
			Result := Current
		ensure
			primitive_value_not_void: Result /= Void
		end
	
	is_atomic_value: BOOLEAN is
			-- Is `Current' an atomic value?
		do
			Result := True
		end

	as_atomic_value: XM_XPATH_ATOMIC_VALUE is
			-- `Current' seen as an atomic_value
		do
			Result := Current
		end

feature -- Comparison

	three_way_comparison (other: XM_XPATH_ATOMIC_VALUE): INTEGER is
			-- Compare `Current' to `other'
		require
			comparable_other: other /= Void and then is_comparable (other)
		deferred
		ensure
			three_way_comparison: Result >= -1 and Result <= 1
		end

feature -- Status report

	is_convertible_to_item (a_context: XM_XPATH_CONTEXT): BOOLEAN is
			-- Can `Current' be converted to an `XM_XPATH_ITEM'?
		do
			Result := True
		end

	is_comparable (other: XM_XPATH_ATOMIC_VALUE): BOOLEAN is
			-- Is `other' comparable to `Current'?
		require
			other_not_void: other /= Void
		deferred
		end

	is_convertible (a_required_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- Is `Current' convertible to `a_required_type'?
		require
			required_type_not_void: a_required_type /= Void
		deferred
		end

feature -- Evaluation

	calculate_effective_boolean_value (a_context: XM_XPATH_CONTEXT) is
			-- Effective boolean value
		local
			a_message: STRING
		do
			create last_boolean_value.make (False)
			a_message := STRING_.concat ("Effective boolean value is not defined for an atomic value of type ", item_type.conventional_name)
			last_boolean_value.set_last_error_from_string (a_message, "", "XPTY0004", Type_error)
		end

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a single item
		do
			last_evaluated_item := Current
		end

	
	evaluate_as_string (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate `Current' as a String
		do
			create last_evaluated_string.make (string_value)
		end

	create_iterator (a_context: XM_XPATH_CONTEXT) is
			-- Iterator over the values of a sequence
		do
			create {XM_XPATH_SINGLETON_ITERATOR [XM_XPATH_ATOMIC_VALUE]} last_iterator.make (Current)
		end
	
	process (a_context: XM_XPATH_CONTEXT) is
			-- Execute `Current' completely, writing results to the current `XM_XPATH_RECEIVER'.
		do
			evaluate_item (a_context)
			if last_evaluated_item /= Void then
				a_context.current_receiver.append_item (last_evaluated_item)
			end
		end

feature -- Conversion
	
	convert_to_type (a_required_type: XM_XPATH_ITEM_TYPE): XM_XPATH_ATOMIC_VALUE is
			-- Convert `Current' to `required_type'
		require
			required_type_not_void: a_required_type /= Void
			convertiable: is_convertible (a_required_type)
		deferred
		end

	as_item (a_context: XM_XPATH_CONTEXT): XM_XPATH_ITEM is
			-- `Current' seen as an item
		do
			Result := Current
		end
	
	as_item_value: XM_XPATH_VALUE is
			-- `Current' seen as a value
		do
				Result := Current
		end

feature {XM_XPATH_EXPRESSION} -- Restricted

	native_implementations: INTEGER is
			-- Natively-supported evaluation routines
		do
			Result := Supports_evaluate_item
		end

end
