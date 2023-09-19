## Represents an XML element (AKA XML node).
class_name XMLNode extends RefCounted

## XML node name.
var name: String = ""

## XML node attributes.
var attributes: Dictionary = {}

## XML node content.
var content: String = ""

## Whether the XML node is an empty node (AKA standalone node).
var standalone: bool = false

## XML node's children.
var children: Array[XMLNode] = []

var _node_props = null  # Array[String]

func _to_string():
	return "<XMLNode name=%s attributes=%s content=%s standalone=%s children=%s>" % [
		name,
		"{...}" if len(attributes) > 0 else "{}",
		"\"...\"" if len(content) > 0 else "\"\"",
		str(standalone),
		"[...]" if len(children) > 0 else "[]"
	]


# Dotted access via GDScript
func _get(property: StringName):
	if _node_props == null:
		_initialize_node_properties()

	if property not in ["name", "attributes", "content", "standalone", "children"] and property in _node_props:
		for child in children:
			if child.name == property:
				return child


# Dotted access via editor
func _get_property_list():
	var props = []

	if _node_props == null:
		_initialize_node_properties()
	
	for child_name in _node_props:
		var child = _get(child_name)

		props.append({
			"name": child_name,
			"type": TYPE_OBJECT,
			"class_name": "XMLNode",
			"usage": PROPERTY_USAGE_DEFAULT,
			"hint": PROPERTY_HINT_NONE,
			"hint_string": "",
		})
	
	return props


func _initialize_node_properties():
	var names_to_nodes = {}

	for child in children:
		if not child.name in names_to_nodes.keys():
			names_to_nodes[child.name] = child
		else:
			names_to_nodes.erase(child.name)

	_node_props = names_to_nodes.keys()
