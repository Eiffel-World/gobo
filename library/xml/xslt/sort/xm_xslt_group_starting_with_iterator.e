indexing

	description:

		"TBA"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_GROUP_STARTING_WITH_ITERATOR

inherit

	XM_XSLT_GROUP_ITERATOR

creation

	make

feature {NONE} -- Initialization

	make (a_population: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM];
			a_key: XM_XSLT_PATTERN;
			a_context: XM_XSLT_EVALUATION_CONTEXT;
			a_locator: XM_XPATH_LOCATOR) is
			-- Establish invariant.
		require
			population_not_void: a_population /= Void
			key_not_void: a_key /= Void
			context_not_void: a_context /= Void
		do
			population := a_population
			key_pattern := a_key
			base_context := a_context
			running_context := a_context.new_minor_context
			running_context.set_current_iterator (population)
			locator := a_locator
		ensure
			population_set: population = a_population
			key_set: key_pattern = a_key
			base_context_set: base_context = a_context
			locator_set: locator = a_locator
		end

feature -- Access

	item: XM_XPATH_ITEM
			-- Initial item of current group

	current_grouping_key: XM_XPATH_ATOMIC_VALUE is
			-- Grouping key for current group
		do
			-- Result := Void
		end
	
feature -- Status report

	after: BOOLEAN is
			-- Are there any more items in the sequence?
		do
			Result := index > 0 and then item = Void
		end

feature -- Cursor movement

	forth is
			-- Move to next position
		local
			a_node: XM_XPATH_NODE
			next_group_reached: BOOLEAN
			an_error: XM_XPATH_ERROR_VALUE
		do
			index := index + 1
			create current_members.make_default
			if index = 1 then
				population.start
				if not population.after then
					item := population.item
					a_node ?= item
					if a_node = Void then
						create an_error.make_from_string ("Member of group-starting-with population is not a node.", "", "XT1120", Dynamic_error)
						running_context.transformer.report_fatal_error (an_error, locator)
					end
				end
			else
				item := next_candidate
			end
			if item /= Void then current_members.force_last (item) end
			from
			until
				population.after or else next_group_reached
			loop
				population.forth
				if population.after then
					next_candidate := Void
				else
					next_candidate := population.item
					a_node ?= next_candidate
					if a_node = Void then
						create an_error.make_from_string ("Member of group-starting-with population is not a node.", "", "XT1120", Dynamic_error)
						running_context.transformer.report_fatal_error (an_error, locator)
					else
						if key_pattern.matches (a_node, running_context) then
							next_group_reached := True
						else
							current_members.force_last (next_candidate)
						end
					end
				end
			end
		end

feature -- Evaluation

	current_group_iterator: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM] is
			-- Iterator over the members of the current group, in population order.
		do
			create {XM_XPATH_ARRAY_LIST_ITERATOR [XM_XPATH_ITEM]} Result.make (current_members)
		end

feature -- Duplication

	another: like Current is
			-- Another iterator that iterates over the same items as the original
		do
			create Result.make (population, key_pattern, base_context, locator)
		end
	
feature {NONE} -- Implementation

	population: XM_XPATH_SEQUENCE_ITERATOR [XM_XPATH_ITEM]
			-- Iterator over population

	key_pattern: XM_XSLT_PATTERN
			-- Grouping key

	base_context: XM_XSLT_EVALUATION_CONTEXT
			-- Original context
	
	running_context: XM_XSLT_EVALUATION_CONTEXT
			-- Context used

	next_candidate: like item
			-- Next item in population

	current_members: DS_ARRAYED_LIST [XM_XPATH_ITEM]
			-- Members of current group

	locator: XM_XPATH_LOCATOR
			-- Location of xsl:for-each-group

invariant

	population_not_void: population /= Void
	key_pattern_not_void: key_pattern /= Void
	base_context_not_void: base_context /= Void
	running_context_not_void: running_context /= Void

end
	
