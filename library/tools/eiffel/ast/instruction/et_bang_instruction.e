indexing

	description:

		"Eiffel bang creation instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_BANG_INSTRUCTION

inherit

	ET_CREATION_INSTRUCTION

creation

	make

feature {NONE} -- Initialization

	make (a_type: like type; a_target: like target; a_call: like creation_call) is
			-- Create a new bang creation instruction.
		require
			a_target_not_void: a_target /= Void
		do
			type := a_type
			target := a_target
			creation_call := a_call
			left_bang := tokens.bang_symbol
			right_bang := tokens.bang_symbol
		ensure
			type_set: type = a_type
			target_set: target = a_target
			creation_call_set: creation_call = a_call
		end

feature -- Access

	left_bang: ET_SYMBOL
			-- Left '!' symbol

	type: ET_TYPE
			-- Creation type

	right_bang: ET_SYMBOL
			-- Right '!' symbol

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if not left_bang.position.is_null then
				Result := left_bang.position
			elseif type /= Void then
				Result := type.position
			else
				Result := target.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if creation_call /= Void then
				Result := creation_call.break
			else
				Result := target.break
			end
		end

feature -- Setting

	set_left_bang (a_bang: like left_bang) is
			-- Set `left_bang' to `a_bang'.
		require
			a_bang_not_void: a_bang /= Void
		do
			left_bang := a_bang
		ensure
			left_bang_set: left_bang = a_bang
		end

	set_right_bang (a_bang: like right_bang) is
			-- Set `right_bang' to `a_bang'.
		require
			a_bang_not_void: a_bang /= Void
		do
			right_bang := a_bang
		ensure
			right_bang_set: right_bang = a_bang
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_bang_instruction (Current)
		end

invariant

	left_bang_not_void: left_bang /= Void
	right_bang_not_void: right_bang /= Void

end
