## GodotXML - Advanced XML support for Godot 4.
## 
## This class allows parsing and dumping XML data from and to various sources.
class_name XML extends RefCounted


## Parses file content as XML into [XMLDocument].
## The file at a specified [code]path[/code] [b]must[/b] be readable.
## File content [b]must[/b] be a syntactically valid XML document.
static func parse_file(path: String) -> XMLDocument:
    var file = FileAccess.open(path, FileAccess.READ)
    var xml: PackedByteArray = file.get_as_text().to_utf8_buffer()
    file = null

    return _parse(xml)


## Parses string as XML into [XMLDocument].
## File content [b]must[/b] be a syntactically valid XML document.
static func parse_str(xml: String) -> XMLDocument:
    return _parse(xml.to_utf8_buffer())


## Parses byte buffer as XML into [XMLDocument].
## File content [b]must[/b] be a syntactically valid XML document.
static func parse_buffer(xml: PackedByteArray) -> XMLDocument:
    return _parse(xml)


## Dumps [param document] to the specified file.
## The file at a specified [code]path[/code] [b]must[/b] be writeable.
## Set [param pretty] to [code]true[/code] if you want indented output.
## If [param pretty] is [code]true[/code], [param indent_level] controls the initial indentation level.
## If [param pretty] is [code]true[/code], [param indent_length] controls the length of a single indentation level.
static func dump_file(path: String, document: XMLDocument,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
):
    var file = FileAccess.open(path, FileAccess.WRITE)
    var xml: String = dump_str(document, pretty, indent_level, indent_length)
    file.store_string(xml)
    file = null


## Dumps [param document] to a [PackedByteArray].
## Set [param pretty] to [code]true[/code] if you want indented output.
## If [param pretty] is [code]true[/code], [param indent_level] controls the initial indentation level.
## If [param pretty] is [code]true[/code], [param indent_length] controls the length of a single indentation level.
static func dump_buffer(
    document: XMLDocument,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> PackedByteArray:
    return dump_str(document, pretty, indent_level, indent_length).to_utf8_buffer()


## Dumps [param document] to [String].
## Set [param pretty] to [code]true[/code] if you want indented output.
## If [param pretty] is [code]true[/code], [param indent_level] controls the initial indentation level.
## If [param pretty] is [code]true[/code], [param indent_length] controls the length of a single indentation level.
static func dump_str(document: XMLDocument,
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
    
    return document.root._dump() if not pretty else document.root._dump_pretty(indent_level, indent_length)



static func _parse(xml: PackedByteArray) -> XMLDocument:
    xml = _cleanup_double_blankets(xml)  # see comment in function body

    var doc: XMLDocument = XMLDocument.new()
    var queue: Array = []  # queue of unclosed tags

    var parser: XMLParser = XMLParser.new()
    parser.open_buffer(xml)

    while parser.read() != ERR_FILE_EOF:
        var node: XMLNode = _make_node(queue, parser)

        # if node type is NODE_TEXT, there will be no node, so we just skip
        if node == null:
            continue

        # if we just started, we set our first node as root and initialize queue
        if len(queue) == 0:
            doc.root = node
            queue.append(node)
        else:
            var node_type = parser.get_node_type()

            # below, `queue.back().children.append(...)` means:
            # - take the last node
            # - since we are inside that unclosed node, all non-closing nodes we get are it's children
            # - therefore, we access .children and append our non-closing node to them

            # hopefully speaks for itself
            if node.standalone:
                queue.back().children.append(node)

            # same here
            elif node_type == XMLParser.NODE_ELEMENT_END:
                var last = queue.pop_back()  # get-remove last unclosed node

                # if we got a closing node, but it's name is not the same as opening one, it's an error
                if node.name != last.name:
                    push_error(
                        "Invalid closing tag: started with %s but ended with %s. Ignoring (output may be incorrect)." % [last.name, node.name]
                    )
                    # instead of break'ing here we just continue, since often invalid name is just a typo
                    continue

                # we just closed a node, so if the queue is empty we stop parsing (effectively ignoring
                # anything past the first root). this is done to prevent latter roots overwriting former
                # ones in case when there's more than one root (invalid per standard, but still used in
                # some documents). we do not natively support multiple roots (and will not, please do not
                # open PRs for that), but if the user really needs to, it is trivial to wrap the input with
                # another "housing" node.
                if queue.is_empty():
                    break

            # opening node
            else:
                queue.back().children.append(node)
                queue.append(node)  # move into our node's body

    # if parsing ended, but there are still unclosed nodes, we report it
    if not queue.is_empty():
        queue.reverse()
        var names = []

        for node in queue:
            names.append(node.name)

        push_error("The following nodes were not closed: %s" % ", ".join(names))

    return doc


static func _make_node(queue: Array, parser: XMLParser):
    var node_type = parser.get_node_type()

    match node_type:
        XMLParser.NODE_ELEMENT:
            return _make_node_element(parser)
        XMLParser.NODE_ELEMENT_END:
            return _make_node_element_end(parser)
        XMLParser.NODE_TEXT:
            # ignores blank text before root node; it is easier this way, trust me
            if queue.is_empty():
                return
            _attach_node_data(queue.back(), parser)
            return


static func _make_node_element(parser: XMLParser):
    var node: XMLNode = XMLNode.new()

    node.name = parser.get_node_name()
    node.attributes = _get_attributes(parser)
    node.content = ""
    node.standalone = parser.is_empty()  # see .is_empty() docs
    node.children = []

    return node


static func _make_node_element_end(parser: XMLParser) -> XMLNode:
    var node: XMLNode = XMLNode.new()

    node.name = parser.get_node_name()
    node.attributes = {}
    node.content = ""
    node.standalone = false  # standalone nodes are always NODE_ELEMENT
    node.children = []

    return node


static func _attach_node_data(node: XMLNode, parser: XMLParser) -> void:
    if node.content.is_empty():
        # XMLParser treats even blank stuff between nodes as NODE_TEXT, which is at least incorrect
        # therefore we strip blankets, resulting in only actual content slipping into .content
        node.content = parser.get_node_data().strip_edges().lstrip(" ").rstrip(" ")


static func _get_attributes(parser: XMLParser) -> Dictionary:
    var attrs: Dictionary = {}
    var attr_count: int = parser.get_attribute_count()

    for attr_idx in range(attr_count):
        attrs[parser.get_attribute_name(attr_idx)] = parser.get_attribute_value(attr_idx)

    return attrs


static func _cleanup_double_blankets(xml: PackedByteArray) -> PackedByteArray:
    # XMLParser is again "incorrect" and duplicates nodes due to double blank escapes
    # https://github.com/godotengine/godot/issues/81896#issuecomment-1731320027
    var cleaned: PackedByteArray = PackedByteArray()

    for byte in xml:
        if byte not in [9, 10, 13]: # [\t, \n, \r]
            cleaned.append(byte)

    return cleaned
