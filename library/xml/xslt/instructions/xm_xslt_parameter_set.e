indexing

	description:

		"Objects that represent a set of parameters"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_PARAMETER_SET

creation

	make, make_empty

feature {NONE} -- Initialization

	make (a_parameter_set: XM_XSLT_PARAMETER_SET) is
			-- Create as a copy of `a_parameter_set'.
		require
			parameter_set_not_void: a_parameter_set /= Void
		do
			create map.make_map (a_parameter_set.count)
			map.copy (a_parameter_set.map)
		end

	make_empty is
			-- Create an empty parameter set.
		do
			create map.make_map_default
		end

feature -- Access

	value (a_fingerprint: INTEGER): XM_XPATH_VALUE is
			-- Value of parameter referenced by `a_fingerprint'
		require
			parameter_bound: has (a_fingerprint)
		do
			Result := map.item (a_fingerprint)
		end

feature -- Measurement

	count: INTEGER is
			-- Number of parameters in `Current'
		do
			Result := map.count
		end

feature -- Status report

	has (a_fingerprint: INTEGER): BOOLEAN is
			-- Does `a_fingerprint'represent a bound parameter in `Current'?
		do
			Result := map.has (a_fingerprint)
		end

feature -- Element change

	put (a_value: XM_XPATH_VALUE; a_fingerprint: INTEGER) is
			-- Add a parameter to `Current'.
		do
			if map.has (a_fingerprint) then
				map.replace (a_value, a_fingerprint)
			else
				map.force (a_value, a_fingerprint)
			end
		ensure
			value_present: map.has (a_fingerprint) and then map.item (a_fingerprint) = a_value
		end

feature {XM_XSLT_PARAMETER_SET} -- Implementation

	map: DS_HASH_TABLE [XM_XPATH_VALUE, INTEGER]
			-- Maps fingerprints to values

invariant

	map_not_void: map /= Void

end
