indexing

	description:

		"Scanner skeletons for Eiffel parsers"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2003, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_EIFFEL_SCANNER_SKELETON

inherit

	YY_COMPRESSED_SCANNER_SKELETON
		rename
			make as make_compressed_scanner_skeleton,
			text as skeleton_text,
			text_substring as skeleton_text_substring
		redefine
			reset
		end

	ET_EIFFEL_TOKENS
		export {NONE} all end

	UT_CHARACTER_CODES
		export {NONE} all end

	KL_IMPORTED_INTEGER_ROUTINES
	KL_IMPORTED_STRING_ROUTINES
	KL_SHARED_PLATFORM
	KL_SHARED_EIFFEL_COMPILER
	ET_SHARED_TOKEN_CONSTANTS
	KL_SHARED_STRING_EQUALITY_TESTER

feature {NONE} -- Initialization

	make (a_filename: STRING; an_error_handler: like error_handler) is
			-- Create a new Eiffel scanner.
		require
			a_filename_not_void: a_filename /= Void
			an_error_handler_not_void: an_error_handler /= Void
		local
			a_factory: ET_AST_FACTORY
		do
			create a_factory.make
			make_with_factory (a_filename, a_factory, an_error_handler)
		ensure
			filename_set: filename = a_filename
			error_handler_set: error_handler = an_error_handler
		end

	make_with_factory (a_filename: STRING;
		a_factory: like ast_factory; an_error_handler: like error_handler) is
			-- Create a new Eiffel scanner.
		require
			a_filename_not_void: a_filename /= Void
			a_factory_not_void: a_factory /= Void
			an_error_handler_not_void: an_error_handler /= Void
		do
			make_with_buffer (Empty_buffer)
			last_text_count := 1
			last_literal_start := 1
			filename := a_filename
			ast_factory := a_factory
			error_handler := an_error_handler
			set_use_assign_keyword (True)
			set_use_attribute_keyword (True)
			set_use_convert_keyword (True)
			set_use_create_keyword (True)
			set_use_recast_keyword (True)
			set_use_reference_keyword (True)
			set_use_void_keyword (True)
		ensure
			filename_set: filename = a_filename
			ast_factory_set: ast_factory = a_factory
			error_handler_set: error_handler = an_error_handler
		end

feature -- Initialization

	reset is
			-- Reset scanner before scanning next input.
		do
			last_literal_start := 1
			last_literal_end := 0
			verbatim_marker := Void
			verbatim_open_white_characters := Void
			verbatim_close_white_characters := Void
			precursor
		end

feature -- Access

	filename: STRING
			-- Name of file being parsed

	current_position: ET_POSITION is
			-- Current position
			-- (Create a new object at each call.)
		do
			create {ET_FILE_POSITION} Result.make (filename, line, column)
		ensure
			current_position_not_void: Result /= Void
		end

	ast_factory: ET_AST_FACTORY
			-- Abstract Syntax Tree factory

feature -- Status report

	use_assign_keyword: BOOLEAN
			-- Should 'assign' be considered as
			-- a keyword (otherwise identifier)?

	use_attribute_keyword: BOOLEAN
			-- Should 'attribute' be considered as
			-- a keyword (otherwise identifier)?

	use_convert_keyword: BOOLEAN
			-- Should 'convert' be considered as
			-- a keyword (otherwise identifier)?

	use_create_keyword: BOOLEAN
			-- Should 'create' be considered as
			-- a keyword (otherwise identifier)?

	use_recast_keyword: BOOLEAN
			-- Should 'recast' be considered as
			-- a keyword (otherwise identifier)?

	use_reference_keyword: BOOLEAN
			-- Should 'reference' be considered as
			-- a keyword (otherwise identifier)?

	use_void_keyword: BOOLEAN
			-- Should 'void' be considered as
			-- a keyword (otherwise identifier)?

feature -- Statut setting

	set_use_assign_keyword (b: BOOLEAN) is
			-- Set `use_assign_keyword' to `b'.
		do
			use_assign_keyword := b
		ensure
			use_assign_keyword_set: use_assign_keyword = b
		end

	set_use_attribute_keyword (b: BOOLEAN) is
			-- Set `use_attribute_keyword' to `b'.
		do
			use_attribute_keyword := b
		ensure
			use_attribute_keyword_set: use_attribute_keyword = b
		end

	set_use_convert_keyword (b: BOOLEAN) is
			-- Set `use_convert_keyword' to `b'.
		do
			use_convert_keyword := b
		ensure
			use_convert_keyword_set: use_convert_keyword = b
		end

	set_use_create_keyword (b: BOOLEAN) is
			-- Set `use_create_keyword' to `b'.
		do
			use_create_keyword := b
		ensure
			use_create_keyword_set: use_create_keyword = b
		end

	set_use_recast_keyword (b: BOOLEAN) is
			-- Set `use_recast_keyword' to `b'.
		do
			use_recast_keyword := b
		ensure
			use_recast_keyword_set: use_recast_keyword = b
		end

	set_use_reference_keyword (b: BOOLEAN) is
			-- Set `use_reference_keyword' to `b'.
		do
			use_reference_keyword := b
		ensure
			use_reference_keyword_set: use_reference_keyword = b
		end

	set_use_void_keyword (b: BOOLEAN) is
			-- Set `use_void_keyword' to `b'.
		do
			use_void_keyword := b
		ensure
			use_void_keyword_set: use_void_keyword = b
		end

feature -- Error handling

	error_handler: ET_ERROR_HANDLER
			-- Error handler

feature -- Tokens

	has_break: BOOLEAN is
			-- Has a break been scanned?
		do
			Result := last_break_end > last_text_count
		ensure
			definition: Result = (last_break_end > last_text_count)
		end

	has_comment: BOOLEAN is
			-- Has a comment been scanned?
		do
			Result := last_comment_end > last_text_count
		ensure
			definition: Result = (last_comment_end > last_text_count)
		end

	last_literal_count: INTEGER is
			-- Number of characters in `last_literal'
		do
			Result := last_literal_end - last_literal_start + 1
		ensure
			last_literal_count_positive: Result >= 0
			definition: Result = last_literal.count
		end

	last_literal: STRING is
			-- Last literal scanned
		do
			Result := text_substring (last_literal_start, last_literal_end)
		ensure
			last_literal_not_void: Result /= Void
		end

	last_identifier: ET_IDENTIFIER is
			-- Last identifier scanned
		local
			a_string: STRING
			a_name: STRING
			a_code: INTEGER
		do
			a_string := string_buffer
			STRING_.wipe_out (a_string)
			append_text_substring_to_string (last_literal_start, last_literal_end, a_string)
			strings.search (a_string)
			if strings.found then
				a_name := strings.found_key
				a_code := strings.found_item
				if a_code >= 0 then
					create Result.make_with_hash_code (a_name, a_code)
				else
					create Result.make (a_name)
					strings.replace_found_item (Result.hash_code)
				end
			else
				a_name := STRING_.make (a_string.count)
				a_name.append_string (a_string)
				create Result.make (a_name)
				strings.force_new (Result.hash_code, a_name)
			end
		ensure
			last_identifier_not_void: Result /= Void
		end

	last_break: STRING is
			-- Last break scanned
		require
			has_break: has_break
		do
			Result := text_substring (last_text_count + 1, last_break_end)
		ensure
			last_break_not_void: Result /= Void
			last_break_not_empty: Result.count > 0
		end

	last_comment: STRING is
			-- Last comment scanned
		require
			has_comment: has_comment
		do
			Result := text_substring (last_text_count + 1, last_comment_end)
		ensure
			last_comment_not_void: Result /= Void
			last_comment_not_empty: Result.count > 0
		end

	text: STRING is
			-- Text of last token read
			-- (Share strings when already scanned.)
		local
			a_string: STRING
		do
			a_string := string_buffer
			STRING_.wipe_out (a_string)
			append_text_to_string (a_string)
			strings.search (a_string)
			if strings.found then
				Result := strings.found_key
			else
				Result := STRING_.make (a_string.count)
				Result.append_string (a_string)
				strings.force_new (-1, Result)
			end
		end

	text_substring (s, e: INTEGER): STRING is
			-- Substring of last token read
			-- (Share strings when already scanned.)
		local
			a_string: STRING
		do
			a_string := string_buffer
			STRING_.wipe_out (a_string)
			append_text_substring_to_string (s, e, a_string)
			strings.search (a_string)
			if strings.found then
				Result := strings.found_key
			else
				Result := STRING_.make (a_string.count)
				Result.append_string (a_string)
				strings.force_new (-1, Result)
			end
		end

feature {NONE} -- Positions

	last_literal_start: INTEGER
	last_literal_end: INTEGER
	last_text_count: INTEGER
	last_break_end: INTEGER
	last_comment_end: INTEGER
			-- Positions of various parts of the token

feature {NONE} -- String handler

	strings: DS_HASH_TABLE [INTEGER, STRING] is
			-- Strings known by the current scanner, and the associated
			-- hash codes when they are used as identifier
		once
			create Result.make_map (100000)
			Result.set_key_equality_tester (string_equality_tester)
				-- Insert basic strings in `strings'.
			Result.force_new (-1, tokens.capitalized_any_name)
			Result.force_new (-1, tokens.capitalized_array_name)
			Result.force_new (-1, tokens.capitalized_bit_name)
			Result.force_new (-1, tokens.capitalized_boolean_name)
			Result.force_new (-1, tokens.capitalized_character_name)
			Result.force_new (-1, tokens.capitalized_double_name)
			Result.force_new (-1, tokens.capitalized_function_name)
			Result.force_new (-1, tokens.capitalized_general_name)
			Result.force_new (-1, tokens.capitalized_integer_name)
			Result.force_new (-1, tokens.capitalized_integer_8_name)
			Result.force_new (-1, tokens.capitalized_integer_16_name)
			Result.force_new (-1, tokens.capitalized_integer_64_name)
			Result.force_new (-1, tokens.capitalized_none_name)
			Result.force_new (-1, tokens.capitalized_pointer_name)
			Result.force_new (-1, tokens.capitalized_predicate_name)
			Result.force_new (-1, tokens.capitalized_procedure_name)
			Result.force_new (-1, tokens.capitalized_real_name)
			Result.force_new (-1, tokens.capitalized_routine_name)
			Result.force_new (-1, tokens.capitalized_special_name)
			Result.force_new (-1, tokens.capitalized_string_name)
			Result.force_new (-1, tokens.capitalized_tuple_name)
			Result.force_new (-1, tokens.capitalized_typed_pointer_name)
			Result.force_new (-1, tokens.capitalized_wide_character_name)
			Result.force_new (-1, tokens.capitalized_unknown_name)
			Result.force_new (-1, tokens.area_name)
			Result.force_new (-1, tokens.call_name)
			Result.force_new (-1, tokens.count_name)
			Result.force_new (-1, tokens.default_create_name)
			Result.force_new (-1, tokens.item_name)
			Result.force_new (-1, tokens.last_result_name)
			Result.force_new (-1, tokens.lower_name)
			Result.force_new (-1, tokens.put_name)
			Result.force_new (-1, tokens.put_reference_name)
			Result.force_new (-1, tokens.reference_item_name)
			Result.force_new (-1, tokens.set_operands_name)
			Result.force_new (-1, tokens.upper_name)
			Result.force_new (-1, tokens.capitalized_current_keyword_name)
			Result.force_new (-1, tokens.capitalized_false_keyword_name)
			Result.force_new (-1, tokens.capitalized_precursor_keyword_name)
			Result.force_new (-1, tokens.capitalized_result_keyword_name)
			Result.force_new (-1, tokens.capitalized_true_keyword_name)
			Result.force_new (-1, tokens.capitalized_void_keyword_name)
			Result.force_new (-1, tokens.capitalized_unique_keyword_name)
			Result.force_new (-1, tokens.agent_keyword_name)
			Result.force_new (-1, tokens.alias_keyword_name)
			Result.force_new (-1, tokens.all_keyword_name)
			Result.force_new (-1, tokens.and_keyword_name)
			Result.force_new (-1, tokens.as_keyword_name)
			Result.force_new (-1, tokens.assign_keyword_name)
			Result.force_new (-1, tokens.attribute_keyword_name)
			Result.force_new (-1, tokens.cat_keyword_name)
			Result.force_new (-1, tokens.check_keyword_name)
			Result.force_new (-1, tokens.class_keyword_name)
			Result.force_new (-1, tokens.convert_keyword_name)
			Result.force_new (-1, tokens.create_keyword_name)
			Result.force_new (-1, tokens.creation_keyword_name)
			Result.force_new (-1, tokens.current_keyword_name)
			Result.force_new (-1, tokens.debug_keyword_name)
			Result.force_new (-1, tokens.deferred_keyword_name)
			Result.force_new (-1, tokens.do_keyword_name)
			Result.force_new (-1, tokens.else_keyword_name)
			Result.force_new (-1, tokens.elseif_keyword_name)
			Result.force_new (-1, tokens.end_keyword_name)
			Result.force_new (-1, tokens.ensure_keyword_name)
			Result.force_new (-1, tokens.expanded_keyword_name)
			Result.force_new (-1, tokens.export_keyword_name)
			Result.force_new (-1, tokens.external_keyword_name)
			Result.force_new (-1, tokens.false_keyword_name)
			Result.force_new (-1, tokens.feature_keyword_name)
			Result.force_new (-1, tokens.from_keyword_name)
			Result.force_new (-1, tokens.frozen_keyword_name)
			Result.force_new (-1, tokens.if_keyword_name)
			Result.force_new (-1, tokens.implies_keyword_name)
			Result.force_new (-1, tokens.indexing_keyword_name)
			Result.force_new (-1, tokens.infix_keyword_name)
			Result.force_new (-1, tokens.inherit_keyword_name)
			Result.force_new (-1, tokens.inspect_keyword_name)
			Result.force_new (-1, tokens.invariant_keyword_name)
			Result.force_new (-1, tokens.is_keyword_name)
			Result.force_new (-1, tokens.like_keyword_name)
			Result.force_new (-1, tokens.local_keyword_name)
			Result.force_new (-1, tokens.loop_keyword_name)
			Result.force_new (-1, tokens.not_keyword_name)
			Result.force_new (-1, tokens.obsolete_keyword_name)
			Result.force_new (-1, tokens.old_keyword_name)
			Result.force_new (-1, tokens.once_keyword_name)
			Result.force_new (-1, tokens.or_keyword_name)
			Result.force_new (-1, tokens.precursor_keyword_name)
			Result.force_new (-1, tokens.prefix_keyword_name)
			Result.force_new (-1, tokens.redefine_keyword_name)
			Result.force_new (-1, tokens.recast_keyword_name)
			Result.force_new (-1, tokens.reference_keyword_name)
			Result.force_new (-1, tokens.rename_keyword_name)
			Result.force_new (-1, tokens.require_keyword_name)
			Result.force_new (-1, tokens.rescue_keyword_name)
			Result.force_new (-1, tokens.result_keyword_name)
			Result.force_new (-1, tokens.retry_keyword_name)
			Result.force_new (-1, tokens.select_keyword_name)
			Result.force_new (-1, tokens.separate_keyword_name)
			Result.force_new (-1, tokens.strip_keyword_name)
			Result.force_new (-1, tokens.then_keyword_name)
			Result.force_new (-1, tokens.true_keyword_name)
			Result.force_new (-1, tokens.undefine_keyword_name)
			Result.force_new (-1, tokens.unique_keyword_name)
			Result.force_new (-1, tokens.until_keyword_name)
			Result.force_new (-1, tokens.variant_keyword_name)
			Result.force_new (-1, tokens.void_keyword_name)
			Result.force_new (-1, tokens.when_keyword_name)
			Result.force_new (-1, tokens.xor_keyword_name)
			Result.force_new (-1, tokens.arrow_symbol_name)
			Result.force_new (-1, tokens.assign_symbol_name)
			Result.force_new (-1, tokens.assign_attempt_symbol_name)
			Result.force_new (-1, tokens.at_symbol_name)
			Result.force_new (-1, tokens.bang_symbol_name)
			Result.force_new (-1, tokens.colon_symbol_name)
			Result.force_new (-1, tokens.comma_symbol_name)
			Result.force_new (-1, tokens.div_symbol_name)
			Result.force_new (-1, tokens.divide_symbol_name)
			Result.force_new (-1, tokens.dollar_symbol_name)
			Result.force_new (-1, tokens.dot_symbol_name)
			Result.force_new (-1, tokens.dotdot_symbol_name)
			Result.force_new (-1, tokens.equal_symbol_name)
			Result.force_new (-1, tokens.ge_symbol_name)
			Result.force_new (-1, tokens.gt_symbol_name)
			Result.force_new (-1, tokens.le_symbol_name)
			Result.force_new (-1, tokens.left_array_symbol_name)
			Result.force_new (-1, tokens.left_brace_symbol_name)
			Result.force_new (-1, tokens.left_bracket_symbol_name)
			Result.force_new (-1, tokens.left_parenthesis_symbol_name)
			Result.force_new (-1, tokens.lt_symbol_name)
			Result.force_new (-1, tokens.minus_symbol_name)
			Result.force_new (-1, tokens.mod_symbol_name)
			Result.force_new (-1, tokens.not_equal_symbol_name)
			Result.force_new (-1, tokens.plus_symbol_name)
			Result.force_new (-1, tokens.power_symbol_name)
			Result.force_new (-1, tokens.question_mark_symbol_name)
			Result.force_new (-1, tokens.right_array_symbol_name)
			Result.force_new (-1, tokens.right_brace_symbol_name)
			Result.force_new (-1, tokens.right_bracket_symbol_name)
			Result.force_new (-1, tokens.right_parenthesis_symbol_name)
			Result.force_new (-1, tokens.semicolon_symbol_name)
			Result.force_new (-1, tokens.tilde_symbol_name)
			Result.force_new (-1, tokens.times_symbol_name)
		ensure
			strings_not_void: Result /= Void
			no_void_string: not Result.has (Void)
		end

	string_buffer: STRING is
			-- String buffer
		once
			Result := STRING_.make (30)
		ensure
			string_buffer_not_void: Result /= Void
		end

feature {NONE} -- Multi-line manifest strings

	ms_line, ms_column: INTEGER
			-- Line and column numbers of currently
			-- scanned special manifest string

feature {NONE} -- Verbatim strings

	verbatim_marker: STRING
			-- Marker of verbatim string currently scanned

	verbatim_open_white_characters: STRING
			-- White characters after "xyz[

	verbatim_close_white_characters: STRING
			-- White characters before ]xyz"

	is_verbatim_string_closer (a_start, an_end: INTEGER): BOOLEAN is
			-- Is string between indexes `a_start' and `an_end' the
			-- end marker of the verbatim string currently scanned?
		require
			verbatim_string_scanned: verbatim_marker /= Void
			a_start_large_enough: a_start >= 1
			an_end_small_enough: an_end <= text_count
			-- valid_string: ([ \t\r]*\][^%\n"]*).recognizes (text_substring (a_start, an_end))
		local
			i, j, nb: INTEGER
		do
				-- Skip white characters:
			from i := a_start until text_item (i) = ']' loop
				i := i + 1
			end
				-- Compare end marker with start marker.
			nb := an_end - i
			if nb = verbatim_marker.count then
				i := i + 1
				Result := True
				from j := 1 until j > nb loop
					if verbatim_marker.item (j) = text_item (i) then
						i := i + 1
						j := j + 1
					else
						Result := False
						j := nb + 1 -- Jump out of the loop.
					end
				end
			end
		end

feature {NONE} -- Breaks

	break_kind: INTEGER
			-- Kind of break being parsed when reading the
			-- following break or comment

	identifier_break, freeop_break, character_break, integer_break,
	uinteger_break, hinteger_break, real_break, ureal_break,
	bit_break, string_break, str_freeop_break, str_special_break,
	str_verbatim_break: INTEGER is unique
			-- Various kinds of breaks being parsed when
			-- reading the following break or comment

feature {NONE} -- Processing

	process_identifier (nb: INTEGER) is
			-- Process identifier with `nb' characters.
			-- Detect keywords.
		require
			nb_large_enough: nb >= 1
			nb_small_enough: nb <= text_count
			-- valid_string: ([a-zA-Z][a-zA-Z0-9_]*).recognizes (text_substring (1, nb))
		do
			last_token := E_IDENTIFIER
			last_literal_start := 1
			last_literal_end := nb
			inspect nb
			when 2 then
				inspect text_item (1)
				when 'a', 'A' then
					inspect text_item (2)
					when 's', 'S' then
						last_token := E_AS
						last_et_keyword_value := ast_factory.new_as_keyword (Current)
					else
						-- Do nothing.
					end
				when 'd', 'D' then
					inspect text_item (2)
					when 'o', 'O' then
						last_token := E_DO
						last_et_keyword_value := ast_factory.new_do_keyword (Current)
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (2)
					when 'f', 'F' then
						last_token := E_IF
						last_et_keyword_value := ast_factory.new_if_keyword (Current)
					when 's', 'S' then
						last_token := E_IS
						last_et_keyword_value := ast_factory.new_is_keyword (Current)
					else
						-- Do nothing.
					end
				when 'o', 'O' then
					inspect text_item (2)
					when 'r', 'R' then
						last_token := E_OR
						last_et_keyword_operator_value := ast_factory.new_or_keyword (Current)
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 3 then
				inspect text_item (1)
				when 'a', 'A' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'd', 'D' then
							last_token := E_AND
							last_et_keyword_operator_value := ast_factory.new_and_keyword (Current)
						else
							-- Do nothing.
						end
					when 'l', 'L' then
						inspect text_item (3)
						when 'l', 'L' then
							last_token := E_ALL
							last_et_keyword_value := ast_factory.new_all_keyword (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'b', 'B' then
					inspect text_item (2)
					when 'i', 'I' then
						inspect text_item (3)
						when 't', 'T' then
							last_token := E_BITTYPE
							last_et_identifier_value := ast_factory.new_identifier (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'e', 'E' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'd', 'D' then
							last_token := E_END
							last_et_keyword_value := ast_factory.new_end_keyword (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'n', 'N' then
					inspect text_item (2)
					when 'o', 'O' then
						inspect text_item (3)
						when 't', 'T' then
							last_token := E_NOT
							last_et_keyword_operator_value := ast_factory.new_not_keyword (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'o', 'O' then
					inspect text_item (2)
					when 'l', 'L' then
						inspect text_item (3)
						when 'd', 'D' then
							last_token := E_OLD
							last_et_keyword_value := ast_factory.new_old_keyword (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'x', 'X' then
					inspect text_item (2)
					when 'o', 'O' then
						inspect text_item (3)
						when 'r', 'R' then
							last_token := E_XOR
							last_et_keyword_operator_value := ast_factory.new_xor_keyword (Current)
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 4 then
				inspect text_item (1)
				when 'e', 'E' then
					inspect text_item (2)
					when 'l', 'L' then
						inspect text_item (3)
						when 's', 'S' then
							inspect text_item (4)
							when 'e', 'E' then
								last_token := E_ELSE
								last_et_keyword_value := ast_factory.new_else_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'f', 'F' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'o', 'O' then
							inspect text_item (4)
							when 'm', 'M' then
								last_token := E_FROM
								last_et_keyword_value := ast_factory.new_from_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'l', 'L' then
					inspect text_item (2)
					when 'i', 'I' then
						inspect text_item (3)
						when 'k', 'K' then
							inspect text_item (4)
							when 'e', 'E' then
								last_token := E_LIKE
								last_et_keyword_value := ast_factory.new_like_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'o', 'O' then
						inspect text_item (3)
						when 'o', 'O' then
							inspect text_item (4)
							when 'p', 'P' then
								last_token := E_LOOP
								last_et_keyword_value := ast_factory.new_loop_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'o', 'O' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'c', 'C' then
							inspect text_item (4)
							when 'e', 'E' then
								last_token := E_ONCE
								last_et_keyword_value := ast_factory.new_once_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 't', 'T' then
					inspect text_item (2)
					when 'h', 'H' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'n', 'N' then
								last_token := E_THEN
								last_et_keyword_value := ast_factory.new_then_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'r', 'R' then
						inspect text_item (3)
						when 'u', 'U' then
							inspect text_item (4)
							when 'e', 'E' then
								last_token := E_TRUE
								last_et_boolean_constant_value := ast_factory.new_true_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'v', 'V' then
					inspect text_item (2)
					when 'o', 'O' then
						inspect text_item (3)
						when 'i', 'I' then
							inspect text_item (4)
							when 'd', 'D' then
								if use_void_keyword then
									last_token := E_VOID
									last_et_void_value := ast_factory.new_void_keyword (Current)
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'w', 'W' then
					inspect text_item (2)
					when 'h', 'H' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'n', 'N' then
								last_token := E_WHEN
								last_et_keyword_value := ast_factory.new_when_keyword (Current)
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 5 then
				inspect text_item (1)
				when 'a', 'A' then
					inspect text_item (2)
					when 'g', 'G' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'n', 'N' then
								inspect text_item (5)
								when 't', 'T' then
									last_token := E_AGENT
									last_et_keyword_value := ast_factory.new_agent_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'l', 'L' then
						inspect text_item (3)
						when 'i', 'I' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 's', 'S' then
									last_token := E_ALIAS
									last_et_keyword_value := ast_factory.new_alias_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'c', 'C' then
					inspect text_item (2)
					when 'h', 'H' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'c', 'C' then
								inspect text_item (5)
								when 'k', 'K' then
									last_token := E_CHECK
									last_et_keyword_value := ast_factory.new_check_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'l', 'L' then
						inspect text_item (3)
						when 'a', 'A' then
							inspect text_item (4)
							when 's', 'S' then
								inspect text_item (5)
								when 's', 'S' then
									last_token := E_CLASS
									last_et_keyword_value := ast_factory.new_class_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'd', 'D' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'b', 'B' then
							inspect text_item (4)
							when 'u', 'U' then
								inspect text_item (5)
								when 'g', 'G' then
									last_token := E_DEBUG
									last_et_keyword_value := ast_factory.new_debug_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'f', 'F' then
					inspect text_item (2)
					when 'a', 'A' then
						inspect text_item (3)
						when 'l', 'L' then
							inspect text_item (4)
							when 's', 'S' then
								inspect text_item (5)
								when 'e', 'E' then
									last_token := E_FALSE
									last_et_boolean_constant_value := ast_factory.new_false_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'f', 'F' then
							inspect text_item (4)
							when 'i', 'I' then
								inspect text_item (5)
								when 'x', 'X' then
									last_token := E_INFIX
									last_et_keyword_value := ast_factory.new_infix_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'l', 'L' then
					inspect text_item (2)
					when 'o', 'O' then
						inspect text_item (3)
						when 'c', 'C' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 'l', 'L' then
									last_token := E_LOCAL
									last_et_keyword_value := ast_factory.new_local_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'r', 'R' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 't', 'T' then
							inspect text_item (4)
							when 'r', 'R' then
								inspect text_item (5)
								when 'y', 'Y' then
									last_token := E_RETRY
									last_et_retry_instruction_value := ast_factory.new_retry_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 's', 'S' then
					inspect text_item (2)
					when 't', 'T' then
						inspect text_item (3)
						when 'r', 'R' then
							inspect text_item (4)
							when 'i', 'I' then
								inspect text_item (5)
								when 'p', 'P' then
									last_token := E_STRIP
									last_et_keyword_value := ast_factory.new_strip_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 't', 'T' then
					inspect text_item (2)
					when 'u', 'U' then
						inspect text_item (3)
						when 'p', 'P' then
							inspect text_item (4)
							when 'l', 'L' then
								inspect text_item (5)
								when 'e', 'E' then
									last_token := E_TUPLE
									last_et_identifier_value := ast_factory.new_identifier (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'u', 'U' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 't', 'T' then
							inspect text_item (4)
							when 'i', 'I' then
								inspect text_item (5)
								when 'l', 'L' then
									last_token := E_UNTIL
									last_et_keyword_value := ast_factory.new_until_keyword (Current)
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 6 then
				inspect text_item (1)
				when 'a', 'A' then
					inspect text_item (2)
					when 's', 'S' then
						inspect text_item (3)
						when 's', 'S' then
							inspect text_item (4)
							when 'i', 'I' then
								inspect text_item (5)
								when 'g', 'G' then
									inspect text_item (6)
									when 'n', 'N' then
										if use_assign_keyword then
											last_token := E_ASSIGN
											last_et_keyword_value := ast_factory.new_assign_keyword (Current)
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'c', 'C' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 't', 'T' then
									inspect text_item (6)
									when 'e', 'E' then
										if use_create_keyword then
											last_token := E_CREATE
											last_et_keyword_value := ast_factory.new_create_keyword (Current)
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'e', 'E' then
					inspect text_item (2)
					when 'l', 'L' then
						inspect text_item (3)
						when 's', 'S' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'i', 'I' then
									inspect text_item (6)
									when 'f', 'F' then
										last_token := E_ELSEIF
										last_et_keyword_value := ast_factory.new_elseif_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'n', 'N' then
						inspect text_item (3)
						when 's', 'S' then
							inspect text_item (4)
							when 'u', 'U' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'e', 'E' then
										last_token := E_ENSURE
										last_et_keyword_value := ast_factory.new_ensure_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'x', 'X' then
						inspect text_item (3)
						when 'p', 'P' then
							inspect text_item (4)
							when 'o', 'O' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 't', 'T' then
										last_token := E_EXPORT
										last_et_keyword_value := ast_factory.new_export_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'f', 'F' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'o', 'O' then
							inspect text_item (4)
							when 'z', 'Z' then
								inspect text_item (5)
								when 'e', 'E' then
									inspect text_item (6)
									when 'n', 'N' then
										last_token := E_FROZEN
										last_et_keyword_value := ast_factory.new_frozen_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'p', 'P' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'f', 'F' then
								inspect text_item (5)
								when 'i', 'I' then
									inspect text_item (6)
									when 'x', 'X' then
										last_token := E_PREFIX
										last_et_keyword_value := ast_factory.new_prefix_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'r', 'R' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'c', 'C' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 's', 'S' then
									inspect text_item (6)
									when 't', 'T' then
										if use_recast_keyword then
											last_token := E_RECAST
											last_et_keyword_value := ast_factory.new_recast_keyword (Current)
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						when 'n', 'N' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 'm', 'M' then
									inspect text_item (6)
									when 'e', 'E' then
										last_token := E_RENAME
										last_et_keyword_value := ast_factory.new_rename_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						when 's', 'S' then
							inspect text_item (4)
							when 'c', 'C' then
								inspect text_item (5)
								when 'u', 'U' then
									inspect text_item (6)
									when 'e', 'E' then
										last_token := E_RESCUE
										last_et_keyword_value := ast_factory.new_rescue_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							when 'u', 'U' then
								inspect text_item (5)
								when 'l', 'L' then
									inspect text_item (6)
									when 't', 'T' then
										last_token := E_RESULT
										last_et_result_value := ast_factory.new_result_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 's', 'S' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'l', 'L' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'c', 'C' then
									inspect text_item (6)
									when 't', 'T' then
										last_token := E_SELECT
										last_et_keyword_value := ast_factory.new_select_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'u', 'U' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'i', 'I' then
							inspect text_item (4)
							when 'q', 'Q' then
								inspect text_item (5)
								when 'u', 'U' then
									inspect text_item (6)
									when 'e', 'E' then
										last_token := E_UNIQUE
										last_et_keyword_value := ast_factory.new_unique_keyword (Current)
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 7 then
				inspect text_item (1)
				when 'c', 'C' then
					inspect text_item (2)
					when 'u', 'U' then
						inspect text_item (3)
						when 'r', 'R' then
							inspect text_item (4)
							when 'r', 'R' then
								inspect text_item (5)
								when 'e', 'E' then
									inspect text_item (6)
									when 'n', 'N' then
										inspect text_item (7)
										when 't', 'T' then
											last_token := E_CURRENT
											last_et_current_value := ast_factory.new_current_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'o', 'O' then
						inspect text_item (3)
						when 'n', 'N' then
							inspect text_item (4)
							when 'v', 'V' then
								inspect text_item (5)
								when 'e', 'E' then
									inspect text_item (6)
									when 'r', 'R' then
										inspect text_item (7)
										when 't', 'T' then
											if use_convert_keyword then
												last_token := E_CONVERT
												last_et_keyword_value := ast_factory.new_convert_keyword (Current)
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'f', 'F' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'a', 'A' then
							inspect text_item (4)
							when 't', 'T' then
								inspect text_item (5)
								when 'u', 'U' then
									inspect text_item (6)
									when 'r', 'R' then
										inspect text_item (7)
										when 'e', 'E' then
											last_token := E_FEATURE
											last_et_keyword_value := ast_factory.new_feature_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (2)
					when 'm', 'M' then
						inspect text_item (3)
						when 'p', 'P' then
							inspect text_item (4)
							when 'l', 'L' then
								inspect text_item (5)
								when 'i', 'I' then
									inspect text_item (6)
									when 'e', 'E' then
										inspect text_item (7)
										when 's', 'S' then
											last_token := E_IMPLIES
											last_et_keyword_operator_value := ast_factory.new_implies_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					when 'n', 'N' then
						inspect text_item (3)
						when 'h', 'H' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 't', 'T' then
											last_token := E_INHERIT
											last_et_keyword_value := ast_factory.new_inherit_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						when 's', 'S' then
							inspect text_item (4)
							when 'p', 'P' then
								inspect text_item (5)
								when 'e', 'E' then
									inspect text_item (6)
									when 'c', 'C' then
										inspect text_item (7)
										when 't', 'T' then
											last_token := E_INSPECT
											last_et_keyword_value := ast_factory.new_inspect_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'r', 'R' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'q', 'Q' then
							inspect text_item (4)
							when 'u', 'U' then
								inspect text_item (5)
								when 'i', 'I' then
									inspect text_item (6)
									when 'r', 'R' then
										inspect text_item (7)
										when 'e', 'E' then
											last_token := E_REQUIRE
											last_et_keyword_value := ast_factory.new_require_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'v', 'V' then
					inspect text_item (2)
					when 'a', 'A' then
						inspect text_item (3)
						when 'r', 'R' then
							inspect text_item (4)
							when 'i', 'I' then
								inspect text_item (5)
								when 'a', 'A' then
									inspect text_item (6)
									when 'n', 'N' then
										inspect text_item (7)
										when 't', 'T' then
											last_token := E_VARIANT
											last_et_keyword_value := ast_factory.new_variant_keyword (Current)
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 8 then
				inspect text_item (1)
				when 'c', 'C' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 't', 'T' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 'o', 'O' then
											inspect text_item (8)
											when 'n', 'N' then
												last_token := E_CREATION
												last_et_keyword_value := ast_factory.new_creation_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'd', 'D' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'f', 'F' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'r', 'R' then
										inspect text_item (7)
										when 'e', 'E' then
											inspect text_item (8)
											when 'd', 'D' then
												last_token := E_DEFERRED
												last_et_keyword_value := ast_factory.new_deferred_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'e', 'E' then
					inspect text_item (2)
					when 'x', 'X' then
						inspect text_item (3)
						when 'p', 'P' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 'n', 'N' then
									inspect text_item (6)
									when 'd', 'D' then
										inspect text_item (7)
										when 'e', 'E' then
											inspect text_item (8)
											when 'd', 'D' then
												last_token := E_EXPANDED
												last_et_keyword_value := ast_factory.new_expanded_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						when 't', 'T' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'n', 'N' then
										inspect text_item (7)
										when 'a', 'A' then
											inspect text_item (8)
											when 'l', 'L' then
												last_token := E_EXTERNAL
												last_et_keyword_value := ast_factory.new_external_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'd', 'D' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'x', 'X' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 'n', 'N' then
											inspect text_item (8)
											when 'g', 'G' then
												last_token := E_INDEXING
												last_et_keyword_value := ast_factory.new_indexing_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'o', 'O' then
					inspect text_item (2)
					when 'b', 'B' then
						inspect text_item (3)
						when 's', 'S' then
							inspect text_item (4)
							when 'o', 'O' then
								inspect text_item (5)
								when 'l', 'L' then
									inspect text_item (6)
									when 'e', 'E' then
										inspect text_item (7)
										when 't', 'T' then
											inspect text_item (8)
											when 'e', 'E' then
												last_token := E_OBSOLETE
												last_et_keyword_value := ast_factory.new_obsolete_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'r', 'R' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'd', 'D' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'f', 'F' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 'n', 'N' then
											inspect text_item (8)
											when 'e', 'E' then
												last_token := E_REDEFINE
												last_et_keyword_value := ast_factory.new_redefine_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 's', 'S' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'p', 'P' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'a', 'A' then
										inspect text_item (7)
										when 't', 'T' then
											inspect text_item (8)
											when 'e', 'E' then
												last_token := E_SEPARATE
												last_et_keyword_value := ast_factory.new_separate_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'u', 'U' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'd', 'D' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'f', 'F' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 'n', 'N' then
											inspect text_item (8)
											when 'e', 'E' then
												last_token := E_UNDEFINE
												last_et_keyword_value := ast_factory.new_undefine_keyword (Current)
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 9 then
				inspect text_item (1)
				when 'a', 'A' then
					inspect text_item (2)
					when 't', 'T' then
						inspect text_item (3)
						when 't', 'T' then
							inspect text_item (4)
							when 'r', 'R' then
								inspect text_item (5)
								when 'i', 'I' then
									inspect text_item (6)
									when 'b', 'B' then
										inspect text_item (7)
										when 'u', 'U' then
											inspect text_item (8)
											when 't', 'T' then
												inspect text_item (9)
												when 'e', 'E' then
													if use_attribute_keyword then
														last_token := E_ATTRIBUTE
														last_et_keyword_value := ast_factory.new_attribute_keyword (Current)
													end
												else
													-- Do nothing.
												end
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (2)
					when 'n', 'N' then
						inspect text_item (3)
						when 'v', 'V' then
							inspect text_item (4)
							when 'a', 'A' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'i', 'I' then
										inspect text_item (7)
										when 'a', 'A' then
											inspect text_item (8)
											when 'n', 'N' then
												inspect text_item (9)
												when 't', 'T' then
													last_token := E_INVARIANT
													last_et_keyword_value := ast_factory.new_invariant_keyword (Current)
												else
													-- Do nothing.
												end
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'p', 'P' then
					inspect text_item (2)
					when 'r', 'R' then
						inspect text_item (3)
						when 'e', 'E' then
							inspect text_item (4)
							when 'c', 'C' then
								inspect text_item (5)
								when 'u', 'U' then
									inspect text_item (6)
									when 'r', 'R' then
										inspect text_item (7)
										when 's', 'S' then
											inspect text_item (8)
											when 'o', 'O' then
												inspect text_item (9)
												when 'r', 'R' then
													last_token := E_PRECURSOR
													last_et_precursor_keyword_value := ast_factory.new_precursor_keyword (Current)
												else
													-- Do nothing.
												end
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'r', 'R' then
					inspect text_item (2)
					when 'e', 'E' then
						inspect text_item (3)
						when 'f', 'F' then
							inspect text_item (4)
							when 'e', 'E' then
								inspect text_item (5)
								when 'r', 'R' then
									inspect text_item (6)
									when 'e', 'E' then
										inspect text_item (7)
										when 'n', 'N' then
											inspect text_item (8)
											when 'c', 'C' then
												inspect text_item (9)
												when 'e', 'E' then
													if use_reference_keyword then
														last_token := E_REFERENCE
														last_et_keyword_value := ast_factory.new_reference_keyword (Current)
													end
												else
													-- Do nothing.
												end
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			else
				-- Do nothing.
			end
			if last_token = E_IDENTIFIER then
				last_et_identifier_value := ast_factory.new_identifier (Current)
			end
		end

	process_one_char_symbol (c: CHARACTER) is
			-- Process Eiffel symbol with made up of only
			-- one character `c'.
		require
			one_char: text_count >= 1
			-- valid_string: ([-+*/^=><.;,:!?(){}[\]$]).recognizes (text_substring (1, 1))
			valid_c: text_item (1) = c
		do
			last_literal_start := 1
			last_literal_end := 1
			inspect c
			when '-' then
				last_token := Minus_code
				last_et_symbol_operator_value := ast_factory.new_minus_symbol (Current)
			when '+' then
				last_token := Plus_code
				last_et_symbol_operator_value := ast_factory.new_plus_symbol (Current)
			when '*' then
				last_token := Star_code
				last_et_symbol_operator_value := ast_factory.new_times_symbol (Current)
			when '/' then
				last_token := Slash_code
				last_et_symbol_operator_value := ast_factory.new_divide_symbol (Current)
			when '^' then
				last_token := Caret_code
				last_et_symbol_operator_value := ast_factory.new_power_symbol (Current)
			when '=' then
				last_token := Equal_code
				last_et_symbol_value := ast_factory.new_equal_symbol (Current)
			when '>' then
				last_token := Greater_than_code
				last_et_symbol_operator_value := ast_factory.new_gt_symbol (Current)
			when '<' then
				last_token := Less_than_code
				last_et_symbol_operator_value := ast_factory.new_lt_symbol (Current)
			when '.' then
				last_token := Dot_code
				last_et_symbol_value := ast_factory.new_dot_symbol (Current)
			when ';' then
				last_token := Semicolon_code
				last_et_semicolon_symbol_value := ast_factory.new_semicolon_symbol (Current)
			when ',' then
				last_token := Comma_code
				last_et_symbol_value := ast_factory.new_comma_symbol (Current)
			when ':' then
				last_token := Colon_code
				last_et_symbol_value := ast_factory.new_colon_symbol (Current)
			when '!' then
				last_token := Exclamation_code
				last_et_symbol_value := ast_factory.new_bang_symbol (Current)
			when '?' then
				last_token := Question_mark_code
				last_et_question_mark_symbol_value := ast_factory.new_question_mark_symbol (Current)
			when '(' then
				last_token := Left_parenthesis_code
				last_et_symbol_value := ast_factory.new_left_parenthesis_symbol (Current)
			when ')' then
				last_token := Right_parenthesis_code
				last_et_symbol_value := ast_factory.new_right_parenthesis_symbol (Current)
			when '{' then
				last_token := Left_brace_code
				last_et_symbol_value := ast_factory.new_left_brace_symbol (Current)
			when '}' then
				last_token := Right_brace_code
				last_et_symbol_value := ast_factory.new_right_brace_symbol (Current)
			when '[' then
				last_token := Left_bracket_code
				last_et_symbol_value := ast_factory.new_left_bracket_symbol (Current)
			when ']' then
				last_token := Right_bracket_code
				last_et_symbol_value := ast_factory.new_right_bracket_symbol (Current)
			when '$' then
				last_token := Dollar_code
				last_et_symbol_value := ast_factory.new_dollar_symbol (Current)
			when '~' then
				last_token := Tilde_code
				last_et_symbol_value := ast_factory.new_tilde_symbol (Current)
			else
				last_token := E_UNKNOWN
				last_et_position_value := current_position
			end
		end

	process_two_char_symbol (c1, c2: CHARACTER) is
			-- Process Eiffel symbol with made up of exactly
			-- two characters `c1' and `c2'.
		require
			two_chars: text_count >= 2
			-- valid_string: ("//"|"\\\\"|"/="|">="|"<="|"!!"|"->"|".."|"<<"|">>"|":="|"?=").recognizes (text_substring (1, 2))
			valid_c1: text_item (1) = c1
			valid_c2: text_item (2) = c2
		do
			last_literal_start := 1
			last_literal_end := 2
			inspect c1
			when '/' then
				inspect c2
				when '/' then
					last_token := E_DIV
					last_et_symbol_operator_value := ast_factory.new_div_symbol (Current)
				when '=' then
					last_token := E_NE
					last_et_symbol_value := ast_factory.new_not_equal_symbol (Current)
				else
					last_token := E_UNKNOWN
					last_et_position_value := current_position
				end
			when '\' then
				check valid_symbol: c2 = '\' end
				last_token := E_MOD
				last_et_symbol_operator_value := ast_factory.new_mod_symbol (Current)
			when '>' then
				inspect c2
				when '=' then
					last_token := E_GE
					last_et_symbol_operator_value := ast_factory.new_ge_symbol (Current)
				when '>' then
					last_token := E_RARRAY
					last_et_symbol_value := ast_factory.new_right_array_symbol (Current)
				else
					last_token := E_UNKNOWN
					last_et_position_value := current_position
				end
			when '<' then
				inspect c2
				when '=' then
					last_token := E_LE
					last_et_symbol_operator_value := ast_factory.new_le_symbol (Current)
				when '<' then
					last_token := E_LARRAY
					last_et_symbol_value := ast_factory.new_left_array_symbol (Current)
				else
					last_token := E_UNKNOWN
					last_et_position_value := current_position
				end
			when '-' then
				check valid_symbol: c2 = '>' end
				last_token := E_ARROW
				last_et_symbol_value := ast_factory.new_arrow_symbol (Current)
			when '.' then
				check valid_symbol: c2 = '.' end
				last_token := E_DOTDOT
				last_et_symbol_value := ast_factory.new_dotdot_symbol (Current)
			when ':' then
				check valid_symbol: c2 = '=' end
				last_token := E_ASSIGN_SYMBOL
				last_et_symbol_value := ast_factory.new_assign_symbol (Current)
			when '?' then
				check valid_symbol: c2 = '=' end
				last_token := E_REVERSE
				last_et_symbol_value := ast_factory.new_assign_attempt_symbol (Current)
			else
				last_token := E_UNKNOWN
				last_et_position_value := current_position
			end
		end

	process_c1_character_constant (c: CHARACTER) is
			-- Process character constant of the form 'A'.
		require
			c1_char: text_count >= 3
			-- valid_string: (\'[^%\n]\').recognizes (text_substring (1, 3))
			valid_c: text_item (2) = c
		do
			if c = '%'' then
					-- Syntax error: character quote should be declared
					-- as '%'' and not as ''' in character constant.
				column := column + 1
				error_handler.report_SCTQ_error (filename, current_position)
				column := column - 1
			end
			last_literal_start := 2
			last_literal_end := 2
			last_token := E_CHARACTER
			last_et_character_constant_value := ast_factory.new_c1_character_constant (c, Current)
		end

	process_c2_character_constant (c: CHARACTER) is
			-- Process character constant of the form '%A'.
		require
			c2_char: text_count >= 4
			-- valid_string: (\'%.\').recognizes (text_substring (1, 4))
			valid_c: text_item (3) = c
		local
			a_value: CHARACTER
		do
			inspect c
			when 'A' then
				a_value := '%A'
			when 'B' then
				a_value := '%B'
			when 'C' then
				a_value := '%C'
			when 'D' then
				a_value := '%D'
			when 'F' then
				a_value := '%F'
			when 'H' then
				a_value := '%H'
			when 'L' then
				a_value := '%L'
			when 'N' then
				a_value := '%N'
			when 'Q' then
				a_value := '%Q'
			when 'R' then
				a_value := '%R'
			when 'S' then
				a_value := '%S'
			when 'T' then
				a_value := '%T'
			when 'U' then
				a_value := '%U'
			when 'V' then
				a_value := '%V'
			when '%%' then
				a_value := '%%'
			when '%'' then
				a_value := '%''
			when '%"' then
				a_value := '%"'
			when '(' then
				a_value := '%('
			when ')' then
				a_value := '%)'
			when '<' then
				a_value := '%<'
			when '>' then
				a_value := '%>'
			when 'a' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%A'
			when 'b' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%B'
			when 'c' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%C'
			when 'd' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%D'
			when 'f' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%F'
			when 'h' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%H'
			when 'l' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%L'
			when 'n' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%N'
			when 'q' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%Q'
			when 'r' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%R'
			when 's' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%S'
			when 't' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%T'
			when 'u' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%U'
			when 'v' then
					-- Syntax error: special character specification
					-- %l where l is a letter code should be in
					-- upper-case in character constant.
				column := column + 2
				error_handler.report_SCCU_error (filename, current_position)
				column := column - 2
				a_value := '%V'
			else
					-- Syntax error: invalid special character
					-- %l in character constant.
				column := column + 2
				error_handler.report_SCSC_error (filename, current_position)
				column := column - 2
				a_value := c
			end
			last_literal_start := 3
			last_literal_end := 3
			last_token := E_CHARACTER
			last_et_character_constant_value := ast_factory.new_c2_character_constant (a_value, Current)
		end

	process_regular_manifest_string (nb: INTEGER) is
			-- Process regular manifest string of the form "..."
			-- with length `nb' (including the two quotes).
		require
			nb_large_enough: nb >= 2
			nb_small_enough: nb <= text_count
			-- valid_string: (\"[^%\n"]*\").recognizes (text_substring (1, nb))
		do
			last_token := E_STRING
			inspect nb
			when 3 then
				inspect text_item (2)
				when '+' then
					last_token := E_STRPLUS
				when '-' then
					last_token := E_STRMINUS
				when '*' then
					last_token := E_STRSTAR
				when '/' then
					last_token := E_STRSLASH
				when '^' then
					last_token := E_STRPOWER
				when '<' then
					last_token := E_STRLT
				when '>' then
					last_token := E_STRGT
				else
					-- Do nothing.
				end
			when 4 then
				inspect text_item (2)
				when '/' then
					inspect text_item (3)
					when '/' then
						last_token := E_STRDIV
					else
						-- Do nothing.
					end
				when '\' then
					inspect text_item (3)
					when '\' then
						last_token := E_STRMOD
					else
						-- Do nothing.
					end
				when '<' then
					inspect text_item (3)
					when '=' then
						last_token := E_STRLE
					else
						-- Do nothing.
					end
				when '>' then
					inspect text_item (3)
					when '=' then
						last_token := E_STRGE
					else
						-- Do nothing.
					end
				when 'o', 'O' then
					inspect text_item (3)
					when 'r', 'R' then
						last_token := E_STROR
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 5 then
				inspect text_item (2)
				when 'a', 'A' then
					inspect text_item (3)
					when 'n', 'N' then
						inspect text_item (4)
						when 'd', 'D' then
							last_token := E_STRAND
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'n', 'N' then
					inspect text_item (3)
					when 'o', 'O' then
						inspect text_item (4)
						when 't', 'T' then
							last_token := E_STRNOT
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'x', 'X' then
					inspect text_item (3)
					when 'o', 'O' then
						inspect text_item (4)
						when 'r', 'R' then
							last_token := E_STRXOR
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 9 then
				inspect text_item (2)
				when 'o', 'O' then
					inspect text_item (3)
					when 'r', 'R' then
						inspect text_item (4)
						when ' ' then
							inspect text_item (5)
							when 'e', 'E' then
								inspect text_item (6)
								when 'l', 'L' then
									inspect text_item (7)
									when 's', 'S' then
										inspect text_item (8)
										when 'e', 'E' then
											last_token := E_STRORELSE
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				when 'i', 'I' then
					inspect text_item (3)
					when 'm', 'M' then
						inspect text_item (4)
						when 'p', 'P' then
							inspect text_item (5)
							when 'l', 'L' then
								inspect text_item (6)
								when 'i', 'I' then
									inspect text_item (7)
									when 'e', 'E' then
										inspect text_item (8)
										when 's', 'S' then
											last_token := E_STRIMPLIES
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			when 10 then
				inspect text_item (2)
				when 'a', 'A' then
					inspect text_item (3)
					when 'n', 'N' then
						inspect text_item (4)
						when 'd', 'D' then
							inspect text_item (5)
							when ' ' then
								inspect text_item (6)
								when 't', 'T' then
									inspect text_item (7)
									when 'h', 'H' then
										inspect text_item (8)
										when 'e', 'E' then
											inspect text_item (9)
											when 'n', 'N' then
												last_token := E_STRANDTHEN
											else
												-- Do nothing.
											end
										else
											-- Do nothing.
										end
									else
										-- Do nothing.
									end
								else
									-- Do nothing.
								end
							else
								-- Do nothing.
							end
						else
							-- Do nothing.
						end
					else
						-- Do nothing.
					end
				else
					-- Do nothing.
				end
			else
				-- Do nothing.
			end
			last_literal_start := 2
			last_literal_end := nb - 1
			last_et_manifest_string_value := ast_factory.new_regular_manifest_string (Current)
		end

	process_break is
			-- Process break.
		do
			inspect break_kind
			when identifier_break then
				process_identifier (last_text_count)
			when freeop_break then
				last_token := E_FREEOP
				last_et_free_operator_value := ast_factory.new_free_operator (Current)
			when character_break then
				last_token := E_CHARACTER
				last_et_character_constant_value := ast_factory.new_c3_character_constant (Current)
			when integer_break then
				last_token := E_INTEGER
				last_et_integer_constant_value := ast_factory.new_regular_integer_constant (Current)
			when uinteger_break then
				last_token := E_INTEGER
				last_et_integer_constant_value := ast_factory.new_underscored_integer_constant (Current)
			when hinteger_break then
				last_token := E_INTEGER
				last_et_integer_constant_value := ast_factory.new_hexadecimal_integer_constant (Current)
			when real_break then
				last_token := E_REAL
				last_et_real_constant_value := ast_factory.new_regular_real_constant (Current)
			when ureal_break then
				last_token := E_REAL
				last_et_real_constant_value := ast_factory.new_underscored_real_constant (Current)
			when bit_break then
				last_token := E_BIT
				last_et_bit_constant_value := ast_factory.new_bit_constant (Current)
			when string_break then
				process_regular_manifest_string (last_text_count)
			when str_freeop_break then
				last_token := E_STRFREEOP
				last_et_manifest_string_value := ast_factory.new_regular_manifest_string (Current)
			when str_special_break then
				last_token := E_STRING
				last_et_manifest_string_value := ast_factory.new_special_manifest_string (Current)
			when str_verbatim_break then
				last_token := E_STRING
				last_et_manifest_string_value := ast_factory.new_verbatim_string (verbatim_marker,
					verbatim_open_white_characters, verbatim_close_white_characters, Current)
				verbatim_marker := Void
				verbatim_open_white_characters := Void
				verbatim_close_white_characters := Void
			else
				last_token := E_UNKNOWN
				last_et_position_value := current_position
			end
		end

feature {NONE} -- Implementation

	tmp_file: KL_TEXT_INPUT_FILE is
			-- Temporary file object
		do
			Result := shared_file
			if not Result.is_closed then
				create Result.make (dummy_name)
			end
		ensure
			file_not_void: Result /= Void
			file_closed: Result.is_closed
		end

	shared_file: KL_TEXT_INPUT_FILE is
			-- Shared file object
		once
			create Result.make (dummy_name)
		ensure
			file_not_void: Result /= Void
		end

	dummy_name: STRING is "dummy"
			-- Dummy name

invariant

	filename_not_void: filename /= Void
	ast_factory_not_void: ast_factory /= Void
	error_handler_not_void: error_handler /= Void
	last_text_count_positive: last_text_count >= 0
	last_literal_start_large_enough: last_literal_start >= 1
	last_literal_start_small_enough: last_literal_start <= last_literal_end + 1
	last_literal_end_small_enough: last_literal_end <= text_count

end
