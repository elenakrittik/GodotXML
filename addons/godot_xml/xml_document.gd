## Represents an XML document.
class_name XMLDocument extends RefCounted

## The XML declaration node (AKA prolog node).
var prolog: XMLNode

## The XML root node.
var root: XMLNode

func to_dict(
    include_empty_fields: bool = false,
    node_content_placement: String = "first_child",
    node_content_field_name: String = "__content__",
):
    pass


func _to_string():
    return "<XMLDocument prolog=%s root=%s>" % [str(prolog), str(root)]
