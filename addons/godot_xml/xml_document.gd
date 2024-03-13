## Represents an XML document.
class_name XMLDocument extends RefCounted

## The root XML node.
var root: XMLNode


func _to_string():
    return "<XMLDocument root=%s>" % self.root
