## Represents an XML document.
class_name XMLDocument extends RefCounted

## The XML root node.
var root: XMLNode


func _to_string():
    return "<XMLDocument root=%s>" % str(root)
