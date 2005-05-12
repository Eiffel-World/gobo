indexing

	description:

		"Objects that provide system configuration information"

	library: "Gobo Eiffel XPath Library"
	copyright: "Copyright (c) 2005, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XPATH_CONFIGURATION

creation

	make_configuration

feature {NONE} -- Initialization

	make_configuration is
			-- Nothing to do.
		do
		end

feature -- Status report

	is_tracing: BOOLEAN is
			-- Is tracing active?
		do
			Result := False
		end

	is_tracing_suppressed: BOOLEAN
			-- Is output from XPath trace() function suppressed?

feature -- Status setting

	suppress_trace_output (yes_or_no: BOOLEAN) is
			-- Turn tracing supression on-or-off.
		do
			is_tracing_suppressed := yes_or_no
		ensure
			set: is_tracing_suppressed = yes_or_no
		end

feature -- Element change

	trace (a_label, a_value: STRING) is
			-- Create trace entry.
		require
			tracing_enabled: is_tracing
			value_not_void: a_value /= Void
			label_not_void: a_label /= Void
		do
			-- Default is to do nothing - host language should override.
		end

end
