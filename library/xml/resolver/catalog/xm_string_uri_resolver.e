indexing

	description:

	"External URI resolver for the string scheme using%
   %the bootstrap resolver's `well_known_system_ids'."

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_STRING_URI_RESOLVER

inherit

	XM_URI_RESOLVER

	XM_SHARED_CATALOG_MANAGER

	KL_IMPORTED_STRING_ROUTINES
		export {NONE} all end

creation

	make
	
feature

	make is
			-- Create.
		do
		end
		
feature -- Status report

	scheme: STRING is "string"
		
feature -- Action(s)

	resolve (a_uri: UT_URI) is
			-- Resolve file URI.
		local
			a_system_id: STRING
		do
			if shared_catalog_manager.bootstrap_resolver.well_known_system_ids.has (a_uri.full_reference) then
				a_system_id := shared_catalog_manager.bootstrap_resolver.well_known_system_ids.item (a_uri.full_reference)
				create {KL_STRING_INPUT_STREAM} last_stream.make (a_system_id)
				last_error := Void
			else
				last_stream := Void
				last_error := System_id_not_known_error
			end
		end
		
feature -- Result

	last_stream: KI_CHARACTER_INPUT_STREAM
			-- File matching stream

	last_error: STRING
			-- Error

	has_error: BOOLEAN is
			-- Is there an error?
		do
			Result := last_error /= Void
		end

feature {NONE} -- Error messages
	
	System_id_not_known_error: STRING is "SYSTEM id not known to bootstrap resolver "
	
end
