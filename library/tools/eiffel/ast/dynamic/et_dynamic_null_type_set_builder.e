indexing

	description:

		"Eiffel dynamic type set builders that do nothing"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_DYNAMIC_NULL_TYPE_SET_BUILDER

inherit

	ET_DYNAMIC_TYPE_SET_BUILDER

creation

	make

feature {NONE} -- Initialization

	make (a_system: like current_system) is
			-- Create a new dynamic type set builder.
		require
			a_system_not_void: a_system /= Void
		do
			current_system := a_system
		ensure
			current_system_set: current_system = a_system
		end

feature -- Factory

	new_dynamic_type_set (a_type: ET_DYNAMIC_TYPE): ET_DYNAMIC_TYPE_SET is
			-- New dynamic type set
		do
			Result := a_type
		end

feature -- Generation

	build_dynamic_type_sets is
			-- Build dynamic type sets for `current_system'.
			-- Set `has_fatal_error' if a fatal error occurred.
		do
			has_fatal_error := False
		end

feature {ET_DYNAMIC_TUPLE_TYPE} -- Generation

	build_tuple_item (a_tuple_type: ET_DYNAMIC_TUPLE_TYPE; an_item_feature: ET_DYNAMIC_FEATURE) is
			-- Build type set of result type of `an_item_feature' from `a_tuple_type'.
		do
		end

	build_tuple_put (a_tuple_type: ET_DYNAMIC_TUPLE_TYPE; a_put_feature: ET_DYNAMIC_FEATURE) is
			-- Build type set of argument type of `a_put_feature' from `a_tuple_type'.
		do
		end

end
