indexing
	
	description:

		"URI resolver:handles relative URI resolution, delegates scheme specific URL resolution"

	library: "Gobo Eiffel XML Library"
	copyright: "Copyright (c) 2004, Eric Bezault and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_SIMPLE_URI_EXTERNAL_RESOLVER

inherit

	XM_URI_REFERENCE_RESOLVER

	XM_URI_EXTERNAL_RESOLVER
		redefine
			resolve_finish
		end

	UC_SHARED_STRING_EQUALITY_TESTER
		export {NONE} all end

creation

	make,
	make_with_base
	
feature {NONE} -- Creation

	make is
			-- Create `uris'.
			-- (Useful to descendant to establish invariant.)
		do
			create {DS_LINKED_STACK [UT_URI]} uris.make
			create schemes.make_map_default
			schemes.set_key_equality_tester (string_equality_tester)
		end
		
	make_with_base (a_uri: UT_URI) is
			-- Create resolver with specified base URI.
		require
			a_uri_not_void: a_uri /= Void
		do
			make
			uris.put (a_uri)
		end

feature -- Status report

	uris: DS_STACK [UT_URI]
			-- Base URI stack.
			-- (A client or descendant may be entitled to put in and remove 
			-- intermediate values directly.)

	supports_registering_schemes: BOOLEAN is
			-- Does `Current' support resgitering scheme resolvers?
		do
			Result := True
		end

	is_stack_empty: BOOLEAN is
			-- Is URI stack empty?
		do
			Result := uris.is_empty 
		end

	uri: UT_URI is
			-- Current URI.
		do
			Result := uris.item
		end

	schemes: DS_HASH_TABLE [XM_URI_RESOLVER, STRING]
			-- Registered scheme resolvers.
			
feature -- Setting

	register_scheme (a_scheme: XM_URI_RESOLVER) is
			-- Register scheme.
		do
			schemes.force (a_scheme, a_scheme.scheme)
		end

feature -- Element change

	push_uri (a_uri: UT_URI ) is
			-- Push `a_uri' onto the stack.
		do
			uris.put (a_uri)
		end
	
feature -- Operation(s)

	resolve (a_string_uri: STRING) is
			-- Resolve a URI into the context of the base URI.
		local
			a_uri: UT_URI
		do
				-- Set current URI, resolving relative URI if needed.
			if uris.is_empty then
				create a_uri.make (a_string_uri)
			else
				create a_uri.make_resolve (uri, a_string_uri)
			end
			uris.put (a_uri)
				-- Apply current URI.
			resolve_absolute_uri (uri)
		end

	resolve_uri (a_uri_reference: STRING) is
			-- Resolve `a_uri_reference' on behalf of an application.
		do
			resolve (a_uri_reference)
		end

	resolve_finish is
			-- Get out of current URI scope.
		do
			check balanced: not uris.is_empty end
			uris.remove
		end
		
feature -- URI

	resolve_absolute_uri (an_uri: UT_URI) is
			-- Resolve an absolute URI.
		require
			an_uri_not_void: an_uri /= Void
		do
			last_resolver := Void
			if schemes.has (an_uri.scheme) then
				last_resolver := schemes.item (an_uri.scheme)
				last_resolver.resolve (an_uri)
			end
		end

feature {NONE} -- Implementation

	last_resolver: XM_URI_RESOLVER
			-- Last resolver used.

feature -- Result

	last_stream: KI_CHARACTER_INPUT_STREAM is
			-- Last stream initialised from external entity.
		do
			Result := last_resolver.last_stream
		end

	has_error: BOOLEAN is
			-- Did the last resolution attempt succeed?
		do
			if last_resolver /= Void then
				Result := last_resolver.has_error
			else
				Result := True
			end
		end
	
	last_error: STRING is
			-- Last error message.
		do
			if last_resolver /= Void then
				Result := last_resolver.last_error
			else
				Result := Unknown_scheme_error
			end
		end

	last_uri_reference_stream: KI_CHARACTER_INPUT_STREAM is
			-- Last stream initialised from URI reference.
		do
			Result := last_stream
		end

	last_system_id: UT_URI is
			-- System id used to actually open `last_uri_reference_stream'
		do
			Result := uri
		end

	has_uri_reference_error: BOOLEAN is
			-- Did the last resolution attempt succeed?
		do
			Result := has_error
		end
		
	last_uri_reference_error: STRING is
			-- Last error message.
		do
			Result := last_error
		end
	
feature {NONE} -- Errors

	Unknown_scheme_error: STRING is "No handler for URL scheme"

invariant

	uris_not_void: uris /= Void
	
end
