indexing

	description:

		"Eiffel dynamic type sets"

	library: "Gobo Eiffel Tools Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

deferred class ET_DYNAMIC_TYPE_SET

feature -- Status report

	has_type (a_type: ET_DYNAMIC_TYPE): BOOLEAN is
			-- Does current type set contain `a_type'?
		require
			a_type_not_void: a_type /= Void
		do
			Result := (first_type = a_type)
			if not Result then
				if other_types /= Void then
					Result := other_types.has (a_type)
				end
			end
		end

feature -- Access

	static_type: ET_DYNAMIC_TYPE is
			-- Type at compilation time
		deferred
		ensure
			static_type_not_void: Result /= Void
		end

	first_type: ET_DYNAMIC_TYPE is
			-- First type in current set;
			-- Void if no type in the set
		deferred
		end

	other_types: ET_DYNAMIC_TYPE_LIST is
			-- Other types in current set;
			-- Void if zero or one type in the set
		deferred
		end

	sources: ET_DYNAMIC_ATTACHMENT is
			-- Sub-sets of current set
		deferred
		end

feature -- Measurement

	count: INTEGER is
			-- Number of types in current type set
		do
			if first_type /= Void then
				if other_types /= Void then
					Result := other_types.count + 1
				else
					Result := 1
				end
			end
		ensure
			count_non_negative: Result >= 0
		end

feature -- Element change

	put_type (a_type: ET_DYNAMIC_TYPE; a_system: ET_SYSTEM) is
			-- Add `a_type' to current set.
		require
			a_type_not_void: a_type /= Void
			a_system_not_void: a_system /= Void
		deferred
		end

	put_source (a_source: ET_DYNAMIC_ATTACHMENT; a_system: ET_SYSTEM) is
			-- Add `a_source' to current set.
			-- (Sources are sub-sets of current set.)
		require
			a_source_not_void: a_source /= Void
			a_system_not_void: a_system /= Void
		deferred
		end

	propagate_types (a_system: ET_SYSTEM) is
			-- Propagate types from `sources'.
		require
			a_system_not_void: a_system /= Void
		local
			l_source: ET_DYNAMIC_ATTACHMENT
		do
			from
				l_source := sources
			until
				l_source = Void
			loop
				l_source.propagate_types (Current, a_system)
				l_source := l_source.next_attachment
			end
		end

end
