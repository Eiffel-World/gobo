indexing

	description:

		"Scanners for 'gepp' preprocessors"

	author:     "Eric Bezault <ericb@gobo.demon.co.uk>"
	copyright:  "Copyright (c) 1998, Eric Bezault"
	date:       "$Date$"
	revision:   "$Revision$"

deferred class GEPP_SCANNER

inherit

	YY_COMPRESSED_SCANNER_SKELETON
		rename
			make as make_compressed_scanner_skeleton,
			reset as reset_compressed_scanner_skeleton
		redefine
			wrap
		end

	GEPP_TOKENS
		export
			{NONE} all
		end


feature {NONE} -- Implementation

	yy_build_tables is
			-- Build scanner tables.
		do
			yy_nxt := yy_nxt_
			yy_chk := yy_chk_
			yy_base := yy_base_
			yy_def := yy_def_
			yy_ec := yy_ec_
			yy_meta := yy_meta_
			yy_accept := yy_accept_
		end

	yy_execute_action (yy_act: INTEGER) is
			-- Execute semantic action.
		do
if yy_act <= 11 then
if yy_act <= 6 then
if yy_act <= 3 then
if yy_act <= 2 then
if yy_act = 1 then
--|#line 43
set_start_condition (S_PREPROC)
else
--|#line 44

						if not ignored then
							echo
						end
						line_nb := line_nb + 1
					
end
else
--|#line 45

						if not ignored then
							echo
						end
						line_nb := line_nb + 1
					
end
else
if yy_act <= 5 then
if yy_act = 4 then
--|#line 51

						if not ignored then
							echo
						end
					
else
--|#line 59
-- Separator.
end
else
--|#line 60
-- Comment.
end
end
else
if yy_act <= 9 then
if yy_act <= 8 then
if yy_act = 7 then
--|#line 61
last_token := P_IFDEF
else
--|#line 62
last_token := P_IFNDEF
end
else
--|#line 63
last_token := P_ELSE
end
else
if yy_act = 10 then
--|#line 64
last_token := P_ENDIF
else
--|#line 65
last_token := P_INCLUDE
end
end
end
else
if yy_act <= 16 then
if yy_act <= 14 then
if yy_act <= 13 then
if yy_act = 12 then
--|#line 66
last_token := P_DEFINE
else
--|#line 67
last_token := P_UNDEF
end
else
--|#line 68

						last_token := P_STRING
						last_value := text_substring (2, text_count - 1)
					
end
else
if yy_act = 15 then
--|#line 72

						last_token := P_NAME
						last_value := text
					
else
--|#line 76
last_token := P_AND
end
end
else
if yy_act <= 19 then
if yy_act <= 18 then
if yy_act = 17 then
--|#line 77
last_token := P_OR
else
--|#line 78

						last_token := P_EOL
						line_nb := line_nb + 1
						set_start_condition (INITIAL)
					
end
else
--|#line 83
last_token := text_item (1).code
end
else
if yy_act = 20 then
--|#line 86
last_token := text_item (1).code
else
--|#line 0
fatal_error ("scanner jammed")
end
end
end
end
			yy_set_beginning_of_line
		end

	yy_execute_eof_action (yy_sc: INTEGER) is
			-- Execute EOF semantic action.
		do
			inspect yy_sc
			else
				terminate
			end
		end

feature {NONE} -- Tables

	yy_nxt_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,   25,   61,    8,   25,    9,   10,   11,   12,   13,
			   14,   15,   16,   16,   17,   18,   16,   19,   16,   16,
			   16,   20,   21,   30,   31,   32,   40,   28,   33,   60,
			   59,   41,    6,    6,    6,    6,    7,    7,    7,    7,
			   22,   22,   22,   22,   26,   58,   26,   26,   57,   56,
			   55,   54,   53,   52,   51,   50,   49,   48,   47,   46,
			   45,   44,   43,   42,   39,   38,   37,   36,   24,   23,
			   35,   34,   29,   27,   24,   23,   61,    5,   61,   61,
			   61,   61,   61,   61,   61,   61,   61,   61,   61,   61,
			   61,   61,   61,   61,   61>>, 0)
		end

	yy_chk_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,   65,    0,    2,   65,    2,    3,    3,    3,    3,
			    3,    3,    3,    3,    3,    3,    3,    3,    3,    3,
			    3,    3,    3,   18,   18,   19,   32,   67,   19,   59,
			   55,   32,   62,   62,   62,   62,   63,   63,   63,   63,
			   64,   64,   64,   64,   66,   54,   66,   66,   51,   50,
			   49,   48,   47,   46,   44,   43,   42,   41,   40,   39,
			   38,   37,   34,   33,   31,   30,   29,   25,   24,   22,
			   21,   20,   17,   15,   11,    7,    5,   61,   61,   61,
			   61,   61,   61,   61,   61,   61,   61,   61,   61,   61,
			   61,   61,   61,   61,   61>>, 0)
		end

	yy_base_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,    0,    0,    5,    0,   76,   77,   72,   77,   77,
			   77,   72,   77,    0,    0,   67,    0,   62,   10,   14,
			   57,   53,   66,   77,   66,   63,    0,   77,    0,   55,
			   50,   55,   17,   55,   53,   77,   77,   49,   50,   47,
			   48,   48,   43,   45,   40,    0,   42,   41,   41,   34,
			   38,   38,    0,    0,   34,   21,    0,    0,    0,   19,
			    0,   77,   31,   35,   39,    0,   43,   23>>, 0)
		end

	yy_def_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,   62,   63,   61,    3,   61,   61,   64,   61,   61,
			   61,   61,   61,   65,   66,   61,   67,   67,   67,   67,
			   67,   61,   64,   61,   61,   65,   66,   61,   67,   67,
			   67,   67,   67,   67,   67,   61,   61,   67,   67,   67,
			   67,   67,   67,   67,   67,   67,   67,   67,   67,   67,
			   67,   67,   67,   67,   67,   67,   67,   67,   67,   67,
			   67,    0,   61,   61,   61,   61,   61,   61>>, 0)
		end

	yy_ec_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,    1,    1,    1,    1,    1,    1,    1,    1,    2,
			    3,    1,    1,    2,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    2,    1,    4,    5,    1,    1,    6,    1,
			    1,    1,    1,    1,    1,    7,    7,    1,    7,    7,
			    7,    7,    7,    7,    7,    7,    7,    7,    1,    1,
			    1,    1,    1,    1,    1,    7,    7,    8,    9,   10,
			   11,    7,    7,   12,    7,    7,   13,    7,   14,    7,
			    7,    7,    7,   15,    7,   16,    7,    7,    7,    7,
			    7,    1,    1,    1,    1,    7,    1,    7,    7,    8,

			    9,   10,   11,    7,    7,   12,    7,    7,   13,    7,
			   14,    7,    7,    7,    7,   15,    7,   16,    7,    7,
			    7,    7,    7,    1,   17,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,

			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1,    1,    1,    1,
			    1,    1,    1,    1,    1,    1,    1>>, 0)
		end

	yy_meta_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,    1,    1,    2,    3,    1,    1,    4,    4,    4,
			    4,    4,    4,    4,    4,    4,    4,    1>>, 0)
		end

	yy_accept_: ARRAY [INTEGER] is
		once
			Result := integer_array_.make_from_array (<<
			    0,    0,    0,    0,    0,   22,   20,    4,    3,    1,
			   19,    5,   18,   19,    6,   19,   15,   15,   15,   15,
			   15,   19,    4,    2,    5,    0,    6,   16,   15,   15,
			   15,   15,   15,   15,   15,   17,   14,   15,   15,   15,
			   15,   15,   15,   15,   15,    9,   15,   15,   15,   15,
			   15,   15,   10,    7,   15,   15,   13,   12,    8,   15,
			   11,    0>>, 0)
		end

feature {NONE} -- Constants

	yyJam_base: INTEGER is 77
			-- Position in `yy_nxt'/`yy_chk' tables
			-- where default jam table starts

	yyJam_state: INTEGER is 61
			-- State id corresponding to jam state

	yyTemplate_mark: INTEGER is 62
			-- Mark between normal states and templates

	yyNull_equiv_class: INTEGER is 1
			-- Equivalence code for NULL character

	yyReject_used: BOOLEAN is false
			-- Is `reject' called?

	yyVariable_trail_context: BOOLEAN is false
			-- Is there a regular expression with
			-- both leading and trailing parts having
			-- variable length?

	yyReject_or_variable_trail_context: BOOLEAN is false
			-- Is `reject' called or is there a
			-- regular expression with both leading
			-- and trailing parts having variable length?

	yyNb_rules: INTEGER is 21
			-- Number of rules

	yyEnd_of_buffer: INTEGER is 22
			-- End of buffer rule code

	INITIAL: INTEGER is 0
	S_PREPROC: INTEGER is 1
			-- Start condition codes

feature -- User-defined features



feature {NONE} -- Initialization

	make is
			-- Create a new scanner.
		do
			make_compressed_scanner_skeleton
			line_nb := 1
		end

feature -- Initialization

	reset is
			-- Reset scanner before scanning next input.
		do
			reset_compressed_scanner_skeleton
			line_nb := 1
		end

feature -- Access

	line_nb: INTEGER
			-- Current line number

	last_value: ANY
			-- Semantic value to be passed to the parser

	include_stack: DS_STACK [YY_BUFFER] is
			-- Input buffers not completely parsed yet
		deferred
		ensure
			include_stack_not_void: Result /= Void
			no_void_buffer: not Result.has (Void)
		end

feature -- Status report

	ignored: BOOLEAN is
			-- Is current line ignored?
		deferred
		end

feature -- Element change

	wrap: BOOLEAN is
			-- Should current scanner terminate when end of file is reached?
			-- True unless an include file was being processed.
		local
			old_buffer: YY_FILE_BUFFER
		do
			if not include_stack.is_empty then
				old_buffer ?= input_buffer
				set_input_buffer (include_stack.item)
				include_stack.remove
				if old_buffer /= Void then
					INPUT_STREAM_.close (old_buffer.file)
				end
				set_start_condition (INITIAL)
			else
				Result := True
			end
		end

end -- class GEPP_SCANNER
