indexing

	description:

		"Eiffel once-functions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_ONCE_FUNCTION

inherit

	ET_INTERNAL_FUNCTION

creation

	make

feature -- Duplication

	new_synonym (a_name: like name_item): like Current is
			-- Synonym feature
		do
			create Result.make (a_name, arguments, declared_type, obsolete_message,
				preconditions, locals, compound, postconditions, rescue_clause,
				clients, implementation_class)
			Result.set_is_keyword (is_keyword)
			Result.set_end_keyword (end_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_synonym (Current)
		end

feature -- Conversion

	renamed_feature (a_name: like name): like Current is
			-- Renamed version of current feature
		do
			create Result.make (a_name, arguments, declared_type, obsolete_message,
				preconditions, locals, compound, postconditions, rescue_clause,
				clients, implementation_class)
			Result.set_is_keyword (is_keyword)
			Result.set_end_keyword (end_keyword)
			Result.set_version (version)
			Result.set_frozen_keyword (frozen_keyword)
			Result.set_semicolon (semicolon)
			Result.set_feature_clause (feature_clause)
			Result.set_first_seed (first_seed)
			Result.set_other_seeds (other_seeds)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_once_function (Current)
		end

end
