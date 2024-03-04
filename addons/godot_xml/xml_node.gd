## Represents an XML element (AKA XML node). Hint: if there's only one child with
## the same name, you can access it via [code]this_node.my_child_name[/code]!
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


## Converts this node (and all of it's children) into a [Dictionary].
## Name is set as [code]__name__: name[/code].
## Content is set as [code]__content__: content[/code].
## Attributes are set as [code]attrs: {attr_name: attr_value}[/code].
## Children are set as [code]children: {child_name: child_dict}[/code].
func to_dict() -> Dictionary:
    var output = {}

    output["__name__"] = name
    output["__content__"] = content
    output["attrs"] = attributes

    var children_dict = {}
    for child in children:
        children_dict[child.name] = child.to_dict()

    output["children"] = children_dict

    return output

## Dumps this node to the specified file.
## The file at the specified [code]path[/code] [b]must[/b] be writeable.
## See [method XMLNode.dump_str] for further documentation.
func dump_file(
    path: String,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
):
    var file = FileAccess.open(path, FileAccess.WRITE)
    var xml: String = dump_str(pretty, indent_level, indent_length)
    file.store_string(xml)
    file = null


## Dumps this node to a [PackedByteArray].
## See [method XMLNode.dump_str] for further documentation.
func dump_buffer(
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> PackedByteArray:
    return self.dump_str(pretty, indent_level, indent_length).to_utf8_buffer()


## Dumps this node to a [String].
## Set [param pretty] to [code]true[/code] if you want indented output.
## If [param pretty] is [code]true[/code], [param indent_level] controls the initial indentation level.
## If [param pretty] is [code]true[/code], [param indent_length] controls the length of a single indentation level.
func dump_str(
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> String:
    if indent_level < 0:
        push_warning("indent_level must be >= 0")
        indent_level = 0

    if indent_length < 0:
        push_warning("indent_length must be >= 0")
        indent_length = 0

    return self._dump() if not pretty else self._dump_pretty(indent_level, indent_length)


func _to_string():
    return "<XMLNode name=%s attributes=%s content=%s standalone=%s children=%s>" % [
        name,
        "{...}" if len(attributes) > 0 else "{}",
        '"..."' if len(content) > 0 else '""',
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


func _dump() -> String:
    var template = (
        "<{node_name}{attributes}>{content}{children}</{node_name}>"
        if not standalone else
        "<{node_name}{attributes}/>"
    )
    var attribute_string = ""
    var children_string = ""

    if not attributes.is_empty():
        attribute_string += " "

        for attribute_key in attributes:
            var attribute_value = attributes.get(attribute_key)
            attribute_string += '{key}="{value}"'.format({"key": attribute_key, "value": attribute_value})

    for child in children:
        children_string += child._dump()

    return template.format({
        "node_name": name,
        "attributes": attribute_string,
        "content": content,
        "children": children_string,
    })


func _dump_pretty(indent_level: int, indent_length: int) -> String:
        var template = (
            "{indent}<{node_name}{attributes}>{content}{children}\n{indent}</{node_name}>"
            if not standalone else
            "{indent}<{node_name}{attributes}/>"
        )
        var indent_string = " ".repeat(indent_level * indent_length)
        var indent_next_string = indent_string + " ".repeat(indent_length)
        var attribute_string = ""
        var content_string = "\n" + indent_next_string + content if not content.is_empty() else ""
        var children_string = ""

        if not attributes.is_empty():
            attribute_string += " "

            for attribute_key in attributes:
                var attribute_value = attributes.get(attribute_key)
                attribute_string += '{key}="{value}"'.format({"key": attribute_key, "value": attribute_value})
    
        for child in children:
            children_string += "\n" + child._dump_pretty(indent_level + 1, indent_length)

        return template.format({
            "node_name": name,
            "attributes": attribute_string,
            "content": content_string,
            "children": children_string,

            "indent": indent_string,
        })
