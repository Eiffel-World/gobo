indexing

	description:

		"Eiffel call agents"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2002, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class ET_CALL_AGENT

inherit

	ET_EXPRESSION
		redefine
			reset
		end

creation

	make

feature {NONE} -- Initialization

	make (a_target: like target; a_name: like qualified_name; args: like arguments) is
			-- Create a new call agent.
		require
			a_name_not_void: a_name /= Void
		do
			agent_keyword := tokens.agent_keyword
			target := a_target
			qualified_name := a_name
			arguments := args
		ensure
			target_set: target = a_target
			name_set: qualified_name = a_name
			arguments_set: arguments = args
		end

feature -- Initialization

	reset is
			-- Reset expression as it was when it was first parsed.
		do
			name.reset
			if target /= Void then
				target.reset
			end
			if arguments /= Void then
				arguments.reset
			end
		end

feature -- Access

	agent_keyword: ET_AST_LEAF
			-- 'agent' keyword or '~' symbol

	target: ET_AGENT_TARGET
			-- Target

	qualified_name: ET_QUALIFIED_FEATURE_NAME
			-- Qualified feature name

	name: ET_FEATURE_NAME is
			-- Feature name
		do
			Result := qualified_name.feature_name
		ensure
			definition: Result = qualified_name.feature_name
		end

	arguments: ET_AGENT_ACTUAL_ARGUMENT_LIST
			-- Arguments

	position: ET_POSITION is
			-- Position of first character of
			-- current node in source code
		do
			if target /= Void and use_tilde then
				Result := target.position
			else
				Result := agent_keyword.position
				if Result.is_null then
					if target /= Void then
						Result := target.position
					end
				end
			end
			if Result.is_null then
				Result := name.position
			end
		end

	break: ET_BREAK is
			-- Break which appears just after current node
		do
			if arguments /= Void then
				Result := arguments.break
			else
				Result := qualified_name.break
			end
		end

feature -- Status report

	use_tilde: BOOLEAN is
			-- Is the old syntax with '~' used?
		local
			a_symbol: ET_SYMBOL
		do
			a_symbol ?= agent_keyword
			Result := a_symbol /= Void
		end

feature -- Setting

	set_agent_keyword (an_agent: like agent_keyword) is
			-- Set `agent_keyword' to `an_agent'.
		require
			an_agent_not_void: an_agent /= Void
		do
			agent_keyword := an_agent
		ensure
			agent_keyword_set: agent_keyword = an_agent
		end

feature -- Processing

	process (a_processor: ET_AST_PROCESSOR) is
			-- Process current node.
		do
			a_processor.process_call_agent (Current)
		end

invariant

	agent_keyword_not_void: agent_keyword /= Void
	qualified_name_not_void: qualified_name /= Void

end
