indexing
	description:

		"Objects that implement xsl:copy"

	library: "Gobo Eiffel XSLT Library"
	copyright: "Copyright (c) 2004, Colin Adams and others"
	license: "Eiffel Forum License v2 (see forum.txt)"
	date: "$Date$"
	revision: "$Revision$"

class XM_XSLT_COMPILED_COPY

inherit

	XM_XSLT_COPY_ROUTINES

	XM_XSLT_ELEMENT_CONSTRUCTOR
		redefine
			evaluate_item, process_leaving_tail
		end

creation

	make

feature {NONE} -- Initialization

	make (an_executable: XM_XSLT_EXECUTABLE; a_content: XM_XPATH_EXPRESSION; some_attribute_sets: DS_ARRAYED_LIST [XM_XSLT_COMPILED_ATTRIBUTE_SET];
			a_copy_namespaces: BOOLEAN; an_inherit_namespaces: BOOLEAN; a_schema_type: XM_XPATH_SCHEMA_TYPE; a_validation_action: INTEGER) is
			-- Establish invariant.
		require
			executable_not_void: an_executable /= Void
			content_not_void: a_content /= Void
		do
			executable := an_executable
			content := a_content
			adopt_child_expression (content)
			attribute_sets := some_attribute_sets
			validation_action := a_validation_action
			type := a_schema_type
			is_copy_namespaces := a_copy_namespaces
			is_inherit_namespaces := an_inherit_namespaces
			compute_static_properties
			initialize
		ensure
			executable_set: executable = an_executable
			content_set: content = a_content
			attribute_sets_set: attribute_sets = some_attribute_sets
			validation_action_set: validation_action = a_validation_action
			type_set: type = a_schema_type
			is_copy_namespaces_set: is_copy_namespaces = a_copy_namespaces
			is_inherit_namespaces_set: is_inherit_namespaces = an_inherit_namespaces
		end

feature -- Access
	
	instruction_name: STRING is
			-- Name of instruction, for diagnostics
		do
			Result := "xsl:copy"
		end

	name_code (a_context: XM_XSLT_EVALUATION_CONTEXT): INTEGER is
			-- Name code
		local
			a_node: XM_XPATH_NODE
		do
			a_node ?= a_context.context_item
			check
				context_item_is_node: a_node /= Void
			end
			Result := a_node.name_code
		end

feature -- Status report

	display (a_level: INTEGER) is
			-- Diagnostic print of expression structure to `std.error'
		do
			std.error.put_string ("copy%N")
		end

feature -- Evaluation

	evaluate_item (a_context: XM_XPATH_CONTEXT) is
			-- Evaluate as a single item.
		local
			a_new_context: XM_XPATH_CONTEXT
			an_outputter: XM_XSLT_SEQUENCE_OUTPUTTER
		do
			a_new_context := a_context.new_minor_context
			create an_outputter.make_with_size (1)
			a_new_context.change_to_sequence_output_destination (an_outputter)
			an_outputter.start_document
			an_outputter.start_document
			process (a_new_context)
			an_outputter.end_document
			last_evaluated_item := an_outputter.first_item
		end

	process_leaving_tail (a_context: XM_XSLT_EVALUATION_CONTEXT) is
			-- Execute `Current', writing results to the current `XM_XPATH_RECEIVER'.
		local
			a_transformer: XM_XSLT_TRANSFORMER
			a_receiver: XM_XPATH_SEQUENCE_RECEIVER
			an_item: XM_XPATH_ITEM
			a_node: XM_XPATH_NODE
			a_document: XM_XPATH_DOCUMENT
			a_new_context: XM_XSLT_EVALUATION_CONTEXT
		do
			last_tail_call := Void
			a_transformer := a_context.transformer
			a_new_context := a_context.new_minor_context
			a_receiver := a_new_context.current_receiver
			an_item := a_new_context.context_item
			a_node ?= an_item
			if a_node = Void then
				a_receiver.append_item (an_item)
			else
				inspect
					a_node.node_type
				when Element_node then
					Precursor (a_new_context)
				when Attribute_node then
					copy_attribute (a_node, a_new_context, Void, Validation_strip)
				when Text_node then
					a_receiver.notify_characters (a_node.string_value, 0)
				when Processing_instruction_node then
					a_receiver.notify_processing_instruction (a_node.node_name, a_node.string_value, 0)
				when Comment_node then
					a_receiver.notify_comment (a_node.string_value, 0)
				when Namespace_node then
					a_node.copy_node (a_receiver, No_namespaces, False)
				when Document_node then
					a_document ?= a_node
					copy_document (a_document, a_new_context, a_transformer, a_receiver)
				end
			end
		end

feature {XM_XSLT_ELEMENT_CREATOR} -- Local

	output_namespace_nodes (a_context: XM_XSLT_EVALUATION_CONTEXT; a_receiver: XM_XPATH_RECEIVER) is
			-- Output namespace nodes for the new element.
		local
			an_element: XM_XPATH_ELEMENT
		do
			if is_copy_namespaces then
				an_element ?= a_context.context_item
				check
					context_item_is_element: an_element /= Void
				end
				an_element.output_namespace_nodes (a_receiver, True)
			end
		end

feature {NONE} -- Implementation
	
	is_copy_namespaces: BOOLEAN
			-- Are namespaces to be copied to the output?

	copy_document (a_document: XM_XPATH_DOCUMENT; a_context: XM_XSLT_EVALUATION_CONTEXT; a_transformer: XM_XSLT_TRANSFORMER; a_receiver: XM_XPATH_SEQUENCE_RECEIVER) is
			-- Copy an entire document.
		require
			document_node: a_document /= Void
			transformer_not_void: a_transformer /= Void
			receiver_not_void: a_receiver /= Void
		local
			a_validator: XM_XPATH_RECEIVER
		do

			-- TODO: add a document node to the result sequence (copying it only if necessary?)

			a_validator := a_transformer.configuration.document_validator (a_receiver,
																								 a_document.base_uri,
																								 validation_action)
			if a_validator /= a_receiver then
				todo ("copy_document (validation)", True)
			end
			a_receiver.start_document
			content.process (a_context)
			a_receiver.end_document
		end

end
	
