indexing

	description:

		"Eiffel loop instructions"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 1999-2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_LOOP_INSTRUCTION

inherit

	ET_INSTRUCTION
		redefine
			reset
		end

creation

	make

feature {NONE} -- Initialization

	make (a_from_compound: like from_compound;
		an_until_conditional: like until_conditional;
		a_loop_compound: like loop_compound) is
			-- Create a new loop instruction.
		require
			an_until_conditional_not_void: an_until_conditional /= Void
		do
			from_compound := a_from_compound
			until_conditional := an_until_conditional
			loop_compound := a_loop_compound
			end_keyword := tokens.end_keyword
		ensure
			from_compound_set: from_compound = a_from_compound
			until_conditional_set: until_conditional = an_until_conditional
			loop_compound_set: loop_compound = a_loop_compound
		end

feature -- Initialization

	reset is
			-- Reset instruction as it was when it was first parsed.
		do
			if from_compound /= Void then
				from_compound.reset
			end
			if invariant_part /= Void then
				invariant_part.reset
			end
			if variant_part /= Void then
				variant_part.reset
			end
			until_expression.reset
			if loop_compound /= Void then
				loop_compound.reset
			end
		end

feature -- Access

	from_compound: ET_COMPOUND
			-- From compound

	invariant_part: ET_LOOP_INVARIANTS
			-- Invariant part

	variant_part: ET_VARIANT
			-- Variant part

	until_conditional: ET_CONDITIONAL
			-- Until conditional

	until_expression: ET_EXPRESSION is
			-- Until boolean expression
		do
			Result := until_conditional.expression
		ensure
			until_expression_not_void: Result /= Void
		end

	loop_compound: ET_COMPOUND
			-- Loop compound

	end_keyword: ET_KEYWORD
			-- 'end' keyword

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if from_compound /= Void then
				Result := from_compound.position
			elseif invariant_part /= Void then
				Result := invariant_part.position
			elseif variant_part /= Void then
				Result := variant_part.position
			else
				Result := until_conditional.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			Result := end_keyword.break
		end

feature -- Setting

	set_invariant_part (an_invariant: like invariant_part) is
			-- Set `invariant_part' to `an_invariant'.
		do
			invariant_part := an_invariant
		ensure
			invariant_part_set: invariant_part = an_invariant
		end

	set_variant_part (a_variant: like variant_part) is
			-- Set `variant_part' to `a_variant'.
		do
			variant_part := a_variant
		ensure
			variant_part_set: variant_part = a_variant
		end

	set_end_keyword (an_end: like end_keyword) is
			-- Set `end_keyword' to `an_end'.
		require
			an_end_not_void: an_end /= Void
		do
			end_keyword := an_end
		ensure
			end_keyword_set: end_keyword = an_end
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_loop_instruction (Current)
		end

invariant

	until_conditional_not_void: until_conditional /= Void
	end_keyword_not_void: end_keyword /= Void

end
