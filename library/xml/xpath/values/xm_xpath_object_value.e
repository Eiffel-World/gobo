indexing

	description:

		"XPath values that represent arbitrary Eiffel objects, for creation by extension functions"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_OBJECT_VALUE

inherit

	XM_XPATH_ATOMIC_VALUE

creation

	make

feature {NONE} -- Initialization

	make (an_object: ANY) is
		do
			make_atomic_value
			value := an_object
		ensure
			set: value = an_object
		end

feature -- Access

	value: ANY
			-- Value of expression

	item_type: XM_XPATH_ITEM_TYPE is
			-- Data type of the expression
		do
			Result := type_factory.object_type
			if Result /= Void then
				-- Bug in SE 1.0 and 1.1: Make sure that
				-- that `Result' is not optimized away.
			end
		end

	string_value: STRING is
			--Value of the item as a string
		do
			if value = Void then
				Result := ""
			else
				Result := value.out
			end
		end

feature -- Comparison

	same_expression (other: XM_XPATH_EXPRESSION): BOOLEAN is
			-- Are `Current' and `other' the same expression?
		local
			other_object: XM_XPATH_OBJECT_VALUE
		do
			other_object ?= other
			if other_object /= Void then
				if value /= Void then
					Result := value.is_equal (other_object.value)
				else
					Result := other_object.value = Void
				end
			end
		end

feature -- Comparison

	three_way_comparison (other: XM_XPATH_ATOMIC_VALUE): INTEGER is
			-- Compare `Current' to `other'
		local
			other_object: XM_XPATH_OBJECT_VALUE
		do
			other_object ?= other
				check
					comparable: other_object /= Void
				end
			Result := STRING_.three_way_comparison (string_value, other_object.string_value)
		end

feature -- Status report


feature -- Status report

	is_comparable (other: XM_XPATH_ATOMIC_VALUE): BOOLEAN is
			-- Is `other' comparable to `Current'?
		local
			other_object: XM_XPATH_OBJECT_VALUE
		do
			other_object ?= other
			Result := other_object /= Void
		end

	is_convertible (a_required_type: XM_XPATH_ITEM_TYPE): BOOLEAN is
			-- Is `Current' convertible to `a_required_type'?
		local
			a_string_value: XM_XPATH_STRING_VALUE
		do
			if	a_required_type = any_item
				or else a_required_type = type_factory.any_atomic_type
				or else a_required_type = type_factory.object_type
				or else a_required_type = type_factory.boolean_type
				or else a_required_type = type_factory.string_type then
				Result := True
			else
				create {XM_XPATH_STRING_VALUE} a_string_value.make (string_value)
				Result := a_string_value.is_convertible (a_required_type)
			end	
		end

	display (a_level: INTEGER; a_pool: XM_XPATH_NAME_POOL) is
			-- Diagnostic print of expression structure to `std.error'
		local
			a_string: STRING
		do
			a_string := STRING_.appended_string (indentation (a_level), "** external object **")
			std.error.put_string (a_string)
			if is_error then
				std.error.put_string (" in error%N")
			else			
				std.error.put_new_line
			end
		end

feature -- Conversions
	
	convert_to_type (a_required_type: XM_XPATH_ITEM_TYPE): XM_XPATH_ATOMIC_VALUE is
			-- Convert `Current' to `a_required_type'
		do
			if	a_required_type = any_item
				or else a_required_type = type_factory.any_atomic_type
				or else a_required_type = type_factory.object_type then
				Result := Current
			elseif a_required_type = type_factory.boolean_type then
				if value = Void then
					create {XM_XPATH_BOOLEAN_VALUE} Result.make (False)
				elseif string_value.count > 0 then
					create {XM_XPATH_BOOLEAN_VALUE} Result.make (True)
				else
					create {XM_XPATH_BOOLEAN_VALUE} Result.make (False)
				end
			elseif a_required_type = type_factory.string_type then
				create {XM_XPATH_STRING_VALUE} Result.make (string_value)
			else
				create {XM_XPATH_STRING_VALUE} Result.make (string_value)
				Result := Result.convert_to_type (a_required_type)
			end
		end
end