note

	description:

		"Eiffel 'BIT feature' types"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2001-2014, Eric Bezault and others"
	license: "MIT License"
	date: "$Date$"
	revision: "$Revision$"

class ET_BIT_FEATURE

inherit

	ET_BIT_TYPE
		redefine
			reset
		end

create

	make

feature {NONE} -- Initialization

	make (a_name: like name; a_named_base_class: like named_base_class)
			-- Create a new 'BIT feature' type.
		require
			a_name_not_void: a_name /= Void
			a_named_base_class_not_void: a_named_base_class /= Void
		do
			bit_keyword := tokens.bit_keyword
			name := a_name
			size := No_size
			named_base_class := a_named_base_class
		ensure
			name_set: name = a_name
			named_base_class_set: named_base_class = a_named_base_class
		end

feature -- Initialization

	reset
			-- Reset type as it was just after it was last parsed.
		do
			name.reset
		end

feature -- Access

	name: ET_IDENTIFIER
			-- Name of the feature associated with
			-- current type and which is supposed
			-- to be an integer constant attribute

	seed: INTEGER
			-- Feature ID of one of the seeds of the
			-- feature associated with current type;
			-- 0 if not resolved yet
		do
			Result := name.seed
		ensure
			seed_positive: Result >= 0
		end

	position: ET_POSITION
			-- Position of first character of
			-- current node in source code
		do
			Result := bit_keyword.position
			if Result.is_null then
				Result := name.position
			end
		end

	first_leaf: ET_AST_LEAF
			-- First leaf node in current node
		do
			Result := bit_keyword
		end

	last_leaf: ET_AST_LEAF
			-- Last leaf node in current node
		do
			Result := name
		end

feature -- Resolving

	resolve_identifier_type (a_seed: INTEGER; a_constant: like constant)
			-- Resolve current type with `a_seed' and `a_constant'.
		require
			a_seed_positive: a_seed > 0
			a_constant_not_void: a_constant /= Void
		do
			name.set_seed (a_seed)
			constant := a_constant
		ensure
			seed_set: seed = a_seed
			constant_set: constant = a_constant
		end

feature -- Output

	append_to_string (a_string: STRING)
			-- Append textual representation of
			-- current type to `a_string'.
		do
			a_string.append_string (bit_space)
			a_string.append_string (name.lower_name)
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR)
			-- Process current node.
		do
			a_processor.process_bit_feature (Current)
		end

invariant

	name_not_void: name /= Void

end
