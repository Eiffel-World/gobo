indexing

	description:

		"Objects that use a set of rules to implement an XSLT mode"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class	XM_XSLT_MODE

inherit

	XM_XSLT_SHARED_NO_NODE_TEST

	XM_XPATH_TYPE

	XM_XPATH_ERROR_TYPES

	XM_XPATH_DEBUGGING_ROUTINES

	MA_DECIMAL_MATH

	XM_XSLT_CONFIGURATION_CONSTANTS

creation

	make, make_with_copy

feature {NONE} -- Initialization

	make is
			-- Establish invariant.
		do
			create rule_dictionary.make (1, Number_of_buckets + Namespace_node + 1)
		end

	make_with_copy (other: XM_XSLT_MODE) is
			-- Create by copying rules from `other'.
		require
			other_mode_not_void: other /= Void
		local
			an_index: INTEGER
			a_rule, a_new_rule: XM_XSLT_RULE
			a_rule_dictionary: ARRAY [XM_XSLT_RULE]
		do
			create rule_dictionary.make (1, Number_of_buckets + Namespace_node + 1)
			from
				a_rule_dictionary := other.rule_dictionary
				an_index := 1
			variant
				a_rule_dictionary.count + 1 - an_index
			until
				an_index > a_rule_dictionary.count
			loop
				a_rule := a_rule_dictionary.item (an_index)
				if a_rule /= Void then
					create a_new_rule.make_with_copy (a_rule)
					rule_dictionary.put (a_new_rule, an_index)
				end
				an_index := an_index +1
			end
			sequence_number := other.sequence_number
		end

feature -- Access

	rule (a_node: XM_XPATH_NODE; a_transformer: XM_XSLT_TRANSFORMER): XM_XSLT_RULE_VALUE is
			-- Handler for `a_node'
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
		local
			a_key, a_specific_precedence: INTEGER
			a_rule, a_specific_rule: XM_XSLT_RULE
			a_specific_priority: MA_DECIMAL
			finished: BOOLEAN
		do
			debug ("XSLT template rules")
				std.error.put_string ("Searching for a rule in Mode ")
				std.error.put_string (name)
				std.error.put_new_line
				std.error.put_string ("Fingerprint is ")
				std.error.put_string (a_node.fingerprint.out)
				std.error.put_string (", node type is ")
				std.error.put_string (a_node.node_type.out)
				std.error.put_new_line
			end
			a_key := rule_key (a_node.fingerprint, a_node.node_type)
			a_specific_precedence := -1
			a_specific_priority := negative_infinity

			-- Search the specific list for this node type / node name.

			if a_key /= Any_node + 1 then
				debug ("XSLT template rules")
					std.error.put_string ("Searching for a specific rule ...%N")
					std.error.put_string ("key is " + a_key.out)
					std.error.put_new_line
				end
				from
					a_rule := rule_dictionary.item (a_key)
				until
					finished or else a_rule = Void
				loop

					-- If we already have a match, and the precedence or priority of this
            	--  rule is lower, quit the search for a second match.

					debug ("XSLT template rules")
						std.error.put_string ("Searching for a specific rule ... found a candidate...%N")
					end
					if a_specific_rule /= Void and then (a_rule.precedence  < a_specific_precedence or else
																	 (a_rule.precedence = a_specific_precedence and then a_rule.priority < a_specific_priority)) then
						finished := True
						debug ("XSLT template rules")
							std.error.put_string ("Searching for a specific rule ... found best match.%N")
						end
					else
						debug ("XSLT template rules")
							std.error.put_string (" Pattern is ")
							std.error.put_string (a_rule.pattern.original_text)
							std.error.put_new_line
						end
						if a_rule.pattern.matches (a_node, a_transformer) then
							debug ("XSLT template rules")
								std.error.put_string ("Searching for a specific rule ... found a match.%N")
							end
							
							-- Is this a second match?

							if a_specific_rule /= Void then
								if a_rule.precedence = a_specific_precedence and then a_rule.priority = a_specific_priority then
									report_ambiguity (a_node, a_specific_rule, a_rule, a_transformer)
									finished := True
								end
							end
							a_specific_rule := a_rule
							a_specific_precedence := a_rule.precedence
							a_specific_priority := a_rule.priority
							if a_transformer.recovery_policy = Recover_silently then
								finished := True -- Find the first; they are in priority order.
							end

						end
						a_rule := a_rule.next_rule
					end
				end

				-- Search the general list.

				if not a_transformer.is_error then
					Result := general_rule (a_node, a_transformer, a_specific_rule, a_specific_precedence, a_specific_priority)
				end
			end
		ensure
			Maybe_no_rule_matches: True
		end

	imported_rule (a_node: XM_XPATH_NODE; a_minimum_precedence, a_maximum_precedence: INTEGER; a_transformer: XM_XSLT_TRANSFORMER): XM_XSLT_RULE_VALUE is
			-- Handler for `a_node' within specified precedence range
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
		local
			a_key: INTEGER
			a_rule, a_specific_rule, a_general_rule: XM_XSLT_RULE
			finished: BOOLEAN
		do
			a_key := rule_key (a_node.fingerprint, a_node.node_type)

			-- Search the specific list for this node type / node name.

			if a_key /= Any_node + 1 then
				from
					a_rule := rule_dictionary.item (a_key)
				until
					finished or else a_rule = Void
				loop
					if a_rule.precedence >= a_minimum_precedence and then a_rule.precedence <= a_maximum_precedence and then a_rule.pattern.matches (a_node, a_transformer) then
						a_specific_rule := a_rule

						-- Find the first; they are in priority order.

						finished := True
					else
						a_rule := a_rule.next_rule
					end
				end
			end

			-- Search the general list.

			if not a_transformer.is_error then
				from
					finished := False
					a_rule := rule_dictionary.item (Any_node + 1)
				until
					finished or else a_rule = Void
				loop
					if a_rule.precedence >= a_minimum_precedence and then a_rule.precedence <= a_maximum_precedence and then a_rule.pattern.matches (a_node, a_transformer) then
						a_general_rule := a_rule

						-- Find the first; they are in priority order.

						finished := True
					else
						a_rule := a_rule.next_rule
					end
				end

				if a_specific_rule /= Void and then a_general_rule = Void then
					Result := a_specific_rule.handler
				elseif a_specific_rule = Void and then a_general_rule /= Void then
					Result := a_general_rule.handler
				elseif a_specific_rule /= Void and then a_general_rule /= Void then
					if a_specific_rule.precedence > a_general_rule.precedence or else
						(a_specific_rule.precedence = a_general_rule.precedence and then
						 a_specific_rule.priority > a_general_rule.priority) then
						Result := a_specific_rule.handler
					else
						Result := a_general_rule.handler
					end
				end
			end
		ensure
			Maybe_no_rule_matches: True
		end

	next_matching_rule (a_node: XM_XPATH_NODE; a_current_template: XM_XSLT_COMPILED_TEMPLATE; a_transformer: XM_XSLT_TRANSFORMER): XM_XSLT_RULE_VALUE is
			-- Handler for `a_node' within specified precedence range
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
		local
			a_key: INTEGER
			a_rule: XM_XSLT_RULE
			finished: BOOLEAN
			a_current_priority: MA_DECIMAL
			a_current_precedence, a_current_sequence_number: INTEGER
			a_handler: XM_XSLT_RULE_VALUE
			a_template: XM_XSLT_COMPILED_TEMPLATE
		do
			a_key := rule_key (a_node.fingerprint, a_node.node_type)
			a_current_sequence_number := -1
			a_current_precedence := -1
			a_current_priority := minus_one

			-- First find the rule corresponding to the current handler.

			from
				a_rule := rule_dictionary.item (a_key)
			until
				finished or else a_rule = Void
			loop
				a_handler := a_rule.handler
				if a_handler.is_template then
					a_template := a_handler.as_template
				else
					a_template := Void
				end
				if a_template /= Void and then a_template = a_current_template then
					a_current_precedence := a_rule.precedence
					a_current_priority := a_rule.priority
					a_current_sequence_number := a_rule.sequence_number
					finished := True
				else
					a_rule := a_rule.next_rule
				end
			end
			if a_rule = Void and then a_key /= Any_node + 1 then
				from
					a_rule := rule_dictionary.item (Any_node + 1)
				until
					finished or else a_rule = Void
				loop
					a_handler := a_rule.handler
					if a_handler.is_template then
						a_template := a_handler.as_template
					else
						a_template := Void
					end
					if a_template /= Void and then a_template = a_current_template then
						a_current_precedence := a_rule.precedence
						a_current_priority := a_rule.priority
						a_current_sequence_number := a_rule.sequence_number
						finished := True
					else
						a_rule := a_rule.next_rule
					end
				end
			end
			check
				current_template_matches_node: a_rule /= Void
			end
			Result := proper_next_matching_rule (a_node, a_key, a_transformer, a_current_priority, a_current_precedence, a_current_sequence_number)
		ensure
			Maybe_no_rule_matches: True
		end
			
	name: STRING is
			-- Name
		do
			if internal_name = Void then
				Result := "#default"
			else
				Result := internal_name
			end
		ensure
			name_not_void: Result /= Void
		end

feature -- Element change

	set_name (a_name: STRING) is
			-- Set name.
		require
			name_not_void: a_name /= Void
		do
			internal_name := a_name
		ensure
			name_set: internal_name = a_name
		end

	add_rule (a_pattern: XM_XSLT_PATTERN; a_handler: XM_XSLT_RULE_VALUE; a_precedence: INTEGER; a_priority: MA_DECIMAL) is
			-- Add a rule to handle `a_pattern'.
		require
			pattern_not_void: a_pattern /= Void
			handler_not_void: a_handler /= Void
		local
			a_key: INTEGER
			a_rule, a_new_rule, a_previous_rule: XM_XSLT_RULE
			finished: BOOLEAN
		do
			debug ("XSLT template rules")
				std.error.put_string ("Adding a rule in Mode: ")
				std.error.put_string (name)
				std.error.put_new_line
			end

			-- Ignore a pattern that will never match, e.g. "@comment"

			if a_pattern /= xslt_empty_item then

				-- For fast lookup, we maintain one list for each element name for patterns that can only
				--  match elements of a given name, one list for each node type for patterns that can only
				--  match one kind of non-element node, and one generic list.
				-- Each list is sorted in precedence/priority order so we find the highest-priority rule first

				a_key := rule_key (a_pattern.fingerprint, a_pattern.node_kind)
				debug ("XSLT template rules")
					std.error.put_string ("Pattern's class is " + a_pattern.generating_type)
					std.error.put_string (", fingerprint is ")
					std.error.put_string (a_pattern.fingerprint.out)
					std.error.put_string (", node type is ")
					std.error.put_string (a_pattern.node_kind.out)
				std.error.put_new_line
					std.error.put_string ("Rule key for node to be added is " + a_key.out)
					std.error.put_new_line
				end
					
				create a_new_rule.make (a_pattern, a_handler, a_precedence, a_priority, sequence_number)
				sequence_number := sequence_number + 1
				a_rule := rule_dictionary.item (a_key)
				if a_rule = Void then
					debug ("XSLT template rules")
						std.error.put_string ("New rule added%N")
					end
					rule_dictionary.put (a_new_rule, a_key)
				else
					debug ("XSLT template rules")
						std.error.put_string ("Inserting rule into existing chain%N")
					end

					-- Insert the new rule into this list before others of the same precedence/priority

					from
						a_previous_rule := Void
					until
						finished or else a_rule = Void
					loop
						if a_rule.precedence < a_precedence or else
							(a_rule.precedence = a_precedence and then a_rule.priority <= a_priority) then
							a_new_rule.set_next_rule (a_rule)
							if a_previous_rule = Void then
								rule_dictionary.put (a_new_rule, a_key)
							else
								a_previous_rule.set_next_rule (a_new_rule)
							end
							finished := True
						else
							a_previous_rule := a_rule
							a_rule := a_rule.next_rule
						end
					end

					if a_rule = Void then
						a_previous_rule.set_next_rule (a_new_rule)
						a_new_rule.set_next_rule (Void)
					end
				end
			end
		ensure

		end

feature {XM_XSLT_MODE} -- Local
	
	rule_dictionary: ARRAY [XM_XSLT_RULE]
			-- Rule dictionary

	sequence_number: INTEGER
			-- Sequence number for next rule to be created

feature {NONE} -- Implementation

	Number_of_buckets: INTEGER is 101
			-- Hash factor

	internal_name: STRING
			-- Mode name

	rule_key (a_fingerprint, a_node_kind: INTEGER): INTEGER is
			-- Rule dictionary index
		do
			if a_node_kind = Element_node then
				if a_fingerprint = - 1 then
					Result := Any_node + 1 -- the generic list
				else
					Result := Namespace_node + (a_fingerprint \\ Number_of_buckets) + 1
				end
			else
				Result := a_node_kind + 1
			end
		end

	report_ambiguity (a_node: XM_XPATH_NODE; a_rule, another_rule: XM_XSLT_RULE; a_transformer: XM_XSLT_TRANSFORMER)	is
			-- Report an ambiguity;
			--  that is, the situation where two rules of the same
			--  precedence and priority match the same node.
		require
			node_not_void: a_node /= Void
			transformer_not_void: a_transformer /= Void
			rules_not_void: a_rule /= Void and then another_rule /= Void
		local
			a_pattern, another_pattern: XM_XSLT_PATTERN
			a_message: STRING
			an_error: XM_XPATH_ERROR_VALUE
		do

			-- Don't report an error if the conflict is between two branches of the same.union pattern

			if a_rule /= another_rule then
				a_pattern := a_rule.pattern
				another_pattern := another_rule.pattern
				a_message := STRING_.concat ("Ambiguous rule match for ", a_node.path)
				a_message := STRING_.appended_string (a_message, "%NMatches both %"")
				a_message := STRING_.appended_string (a_message, a_pattern.original_text)
				a_message := STRING_.appended_string (a_message, " on line ")
				a_message := STRING_.appended_string (a_message, a_pattern.line_number.out)
				a_message := STRING_.appended_string (a_message, " of ")
				a_message := STRING_.appended_string (a_message, a_pattern.system_id)
				a_message := STRING_.appended_string (a_message, "%Nand %"")
				a_message := STRING_.appended_string (a_message, another_pattern.original_text)
				a_message := STRING_.appended_string (a_message, " on line ")
				a_message := STRING_.appended_string (a_message, another_pattern.line_number.out)
				a_message := STRING_.appended_string (a_message, " of ")
				a_message := STRING_.appended_string (a_message, another_pattern.system_id)
				create an_error.make_from_string (a_message, "", "XT0540", Static_error)
				a_transformer.report_recoverable_error (an_error, Void)
			end
		end

	general_rule (a_node: XM_XPATH_NODE; a_transformer: XM_XSLT_TRANSFORMER; a_specific_rule: XM_XSLT_RULE;
		a_specific_precedence: INTEGER; a_specific_priority: MA_DECIMAL): XM_XSLT_RULE_VALUE is
			-- Rule on general list
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
			priority_not_void: a_specific_priority /= Void
		local
			a_rule, a_general_rule: XM_XSLT_RULE
			finished: BOOLEAN
		do
			debug ("XSLT template rules")
					std.error.put_string ("Searching for a general rule ...%N")
			end
			from
				a_rule := rule_dictionary.item (Any_node + 1)
			until
				finished or else a_rule = Void
			loop
				debug ("XSLT template rules")
					std.error.put_string ("Searching for a general rule ... found one%N")
				end
				if a_rule.precedence < a_specific_precedence or else
					(a_rule.precedence = a_specific_precedence and then a_rule.priority < a_specific_priority) then

					-- no point in looking at a lower priority rule than the one we've got

					finished := True
				else
					if a_rule.pattern.matches (a_node, a_transformer) then

						-- Is it a second match?

						if a_general_rule /= Void then
							if a_rule.precedence = a_general_rule.precedence and then a_rule.priority = a_general_rule.priority then
									report_ambiguity (a_node, a_rule, a_general_rule, a_transformer)
									finished := True
							end
						else
							a_general_rule := a_rule
							if a_transformer.recovery_policy = Recover_silently then finished := True end 
						end
						
					end
					
				end
				a_rule := a_rule.next_rule
			end
			if not a_transformer.is_error then
				Result := general_or_specific_rule (a_node, a_transformer, a_specific_rule, a_general_rule)
			end
		end

	proper_next_matching_rule (a_node: XM_XPATH_NODE; a_key: INTEGER; a_transformer: XM_XSLT_TRANSFORMER; a_current_priority: MA_DECIMAL; a_current_precedence, a_current_sequence_number: INTEGER): XM_XSLT_RULE_VALUE is
			-- Next matching rule.
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
			priority_not_void: a_current_priority /= Void
			positive_sequence_number: a_current_sequence_number >= 0
		local
			a_rule, a_specific_rule, a_general_rule: XM_XSLT_RULE
			a_specific_precedence: INTEGER
			a_specific_priority: MA_DECIMAL
			finished: BOOLEAN
		do
			a_specific_precedence := -1
			a_specific_priority := negative_infinity

			-- Search the specific list for this node type / node name.

			if a_key /= Any_node + 1 then
				from
					a_rule := rule_dictionary.item (a_key)
				until
					finished or else a_rule = Void
				loop

					-- Skip this rule unless it's "below" the current rule in search order.

					if a_rule.precedence > a_current_precedence or else
						(a_rule.precedence = a_current_precedence and then
						 (a_rule.priority > a_current_priority or else
						  (a_rule.priority = a_current_priority and then a_rule.sequence_number >= a_current_sequence_number))) then
						do_nothing -- skip rule
					else

						-- Quit the search on finding the second (recoverable error) match.

						if a_specific_rule /= Void then
							if a_rule.precedence < a_specific_precedence or else
								(a_rule.precedence = a_specific_precedence and then a_rule.priority < a_specific_priority) then
								finished := True
							end
						end
						if not finished and then a_rule.pattern.matches (a_node, a_transformer) then

							-- Is this a second match?

							if a_specific_rule /= Void then
								if a_rule.precedence = a_specific_precedence and then a_rule.priority = a_specific_priority then
									finished := True
									report_ambiguity (a_node, a_specific_rule, a_rule, a_transformer)
								end
							end

							if not finished then
								a_specific_rule := a_rule
								a_specific_precedence := a_rule.precedence
								a_specific_priority := a_rule.priority
							end
						end
					end
					if not finished then
						a_rule := a_rule.next_rule
					end
				end
			end

			-- Search the general list.

			if not a_transformer.is_error then
				Result := general_next_matching_rule (a_node, a_transformer, a_specific_rule, a_current_priority, a_current_precedence, a_current_sequence_number)
			end
		ensure
			Maybe_no_rule_matches: True
		end

	general_next_matching_rule (a_node: XM_XPATH_NODE; a_transformer: XM_XSLT_TRANSFORMER; a_specific_rule: XM_XSLT_RULE;
										 a_current_priority: MA_DECIMAL; a_current_precedence, a_current_sequence_number: INTEGER): XM_XSLT_RULE_VALUE is
			-- Next matching rule.
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
			priority_not_void: a_current_priority /= Void
			positive_sequence_number: a_current_sequence_number >= 0
		local
			a_rule, a_general_rule: XM_XSLT_RULE
			finished: BOOLEAN
			a_specific_precedence: INTEGER
			a_specific_priority: MA_DECIMAL
		do
			if a_specific_rule /= Void then
				a_specific_precedence := -a_specific_rule.precedence
				a_specific_priority := a_specific_rule.priority
			else
				a_specific_precedence := -1
				a_specific_priority := negative_infinity
			end
			from
				a_rule := rule_dictionary.item (Any_node + 1)
			until
				finished or else a_rule = Void
			loop

				-- Skip this rule unless it's "after" the current rule in search order
		
				if a_rule.precedence > a_current_precedence or else
					(a_rule.precedence = a_current_precedence and then
					 (a_rule.priority > a_current_priority or else
					  (a_rule.priority = a_current_priority and then a_rule.sequence_number >= a_current_sequence_number))) then
					do_nothing -- skip rule
				else
					if a_rule.precedence < a_specific_precedence or else
						(a_rule.precedence = a_specific_precedence and then a_rule.priority < a_specific_priority) then
						finished := True -- no point in looking at a lower priority rule than the one we've got
					end
					if not finished and then a_rule.pattern.matches (a_node, a_transformer) then

						-- Is this a second match?

						if a_general_rule /= Void then
							if a_rule.precedence = a_general_rule.precedence and then a_rule.priority = a_general_rule.priority then
								finished := True
								report_ambiguity (a_node, a_specific_rule, a_rule, a_transformer)
							end
						else
							a_general_rule := a_rule
							if a_transformer.recovery_policy = Recover_silently then
								finished := True -- Find the first; they are in priority order.
							end
						end
					end
				end
				if not finished then
					a_rule := a_rule.next_rule
				end	
			end
			if not a_transformer.is_error then
				Result := general_or_specific_rule (a_node, a_transformer, a_specific_rule, a_general_rule)
			end
		ensure
			Maybe_no_rule_matches: True
		end

	general_or_specific_rule (a_node: XM_XPATH_NODE; a_transformer: XM_XSLT_TRANSFORMER; a_specific_rule, a_general_rule: XM_XSLT_RULE): XM_XSLT_RULE_VALUE is
			-- General or specific rule
		require
			node_not_void: a_node /= Void
			transformer_not_in_error: a_transformer /= Void and then not a_transformer.is_error
		do
			if a_specific_rule /= Void and then a_general_rule = Void then
				debug ("XSLT template rules")
					std.error.put_string ("found a specific rule%N")
				end
				Result := a_specific_rule.handler
			elseif a_specific_rule = Void and then a_general_rule /= Void then
				debug ("XSLT template rules")
					std.error.put_string ("Found a general rule%N")
				end
				Result := a_general_rule.handler
			elseif a_specific_rule /= Void and then a_general_rule /= Void then
				if a_specific_rule.precedence = a_general_rule.precedence and then
					a_specific_rule.priority = a_general_rule.priority then
					
					-- This situation is exceptional: we have a "specific" pattern and
					--  a "general" pattern with the same priority. We have to select
					--  the one that was added last.
					
					if a_specific_rule.sequence_number > a_general_rule.sequence_number then
						debug ("XSLT template rules")
							std.error.put_string ("Found a specific rule%N")
						end
						Result := a_specific_rule.handler
					else
						debug ("XSLT template rules")
							std.error.put_string ("Found a general rule%N")
						end
						Result := a_general_rule.handler
					end
					if a_transformer.recovery_policy /= Recover_silently then
						report_ambiguity (a_node, a_specific_rule, a_general_rule, a_transformer)
					end
				elseif a_specific_rule.precedence > a_general_rule.precedence or else
					(a_specific_rule.precedence = a_general_rule.precedence and then a_specific_rule.priority >= a_general_rule.priority) then
					debug ("XSLT template rules")
						std.error.put_string ("Found a specific rule%N")
					end
					Result := a_specific_rule.handler
				else
					debug ("XSLT template rules")
						std.error.put_string ("Found a general rule%N")
					end
					Result := a_general_rule.handler
				end
			else
				debug ("XSLT template rules")
					std.error.put_string ("couldn't find a rule%N")
				end
				Result := Void
			end
		ensure
			Maybe_no_rule_matches: True
		end

invariant

	rule_dictionary_not_void: rule_dictionary /= Void

end
	
