## GodotXML - Advanced XML support for Godot 4.
## 
## This class allows parsing and dumping XML data from and to various sources.
class_name XML extends RefCounted


## Parses file content as XML into a [XMLDocument].
## The file at the specified [code]path[/code] [b]must[/b] be readable.
## File content [b]must[/b] be a syntactically valid XML document.
static func parse_file(path: String) -> XMLDocument:
    var file = FileAccess.open(path, FileAccess.READ)
    var xml: PackedByteArray = file.get_as_text().to_utf8_buffer()
    file = null

    return XML._parse(xml)


## Parses string as XML into a [XMLDocument].
## String content [b]must[/b] be a syntactically valid XML document.
static func parse_str(xml: String) -> XMLDocument:
    return XML._parse(xml.to_utf8_buffer())


## Parses byte buffer as XML into a [XMLDocument].
## Buffer content [b]must[/b] be a syntactically valid XML document.
static func parse_buffer(xml: PackedByteArray) -> XMLDocument:
    return XML._parse(xml)


## Dumps [param document] to the specified file.
## See [method XMLNode.dump_file] for further documentation.
##
## @deprecated: Use [method XMLNode.dump_file] directly.
static func dump_file(
    path: String,
    document: XMLDocument,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> void:
    return document.root.dump_file(path, pretty, indent_level, indent_length)


## Dumps [param document] to a [PackedByteArray].
## See [method XMLNode.dump_buffer] for further documentation.
##
## @deprecated: Use [method XMLNode.dump_buffer] directly.
static func dump_buffer(
    document: XMLDocument,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> PackedByteArray:
    return document.root.dump_buffer(pretty, indent_level, indent_length)


## Dumps [param document] to a [String].
## See [method XMLNode.dump_str] for further documentation.
##
## @deprecated: Use [method XMLNode.dump_str] directly.
static func dump_str(
    document: XMLDocument,
    pretty: bool = false,
    indent_level: int = 0,
    indent_length: int = 2,
) -> String:
    return document.root.dump_str(pretty, indent_level, indent_length)


static func _parse(xml: PackedByteArray) -> XMLDocument:
    xml = _cleanup_double_blankets(xml)  # see comment in function body

    var doc := XMLDocument.new()
    var queue: Array[XMLNode] = []  # queue of unclosed tags

    var parser := XMLParser.new()
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
            var node_type := parser.get_node_type()

            # below, `queue.back().children.append(...)` means:
            # - take the last node
            # - since we are inside that unclosed node, all non-closing nodes we get are it's children
            # - therefore, we access .children and append our non-closing node to them

            # hopefully speaks for itself
            if node.standalone:
                queue.back().children.append(node)

            # same here
            elif node_type == XMLParser.NODE_ELEMENT_END:
                var last := queue.pop_back()  # get-remove last unclosed node

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
        var names: Array[String] = []

        for node in queue:
            names.append(node.name)

        push_error("The following nodes were not closed: %s" % ", ".join(names))

    return doc


# TODO: add "-> XMLNode | null" when unions are supported
static func _make_node(queue: Array[XMLNode], parser: XMLParser) -> Variant:
    var node_type := parser.get_node_type()

    match node_type:
        XMLParser.NODE_ELEMENT:
            return XML._make_node_element(parser)
        XMLParser.NODE_ELEMENT_END:
            return XML._make_node_element_end(parser)
        XMLParser.NODE_TEXT:
            # ignores blank text before root node; it is easier this way, trust me
            if queue.is_empty():
                return
            XML._attach_node_data(queue.back(), parser)
            return
        XMLParser.NODE_CDATA:
            if queue.is_empty():
                return
            _attach_node_cdata(queue.back(), parser)
            return

    return


static func _make_node_element(parser: XMLParser) -> XMLNode:
    var node := XMLNode.new()

    node.name = parser.get_node_name()
    node.attributes = XML._get_attributes(parser)
    node.content = ""
    node.standalone = parser.is_empty()  # see .is_empty() docs
    node.children = []

    return node


static func _make_node_element_end(parser: XMLParser) -> XMLNode:
    var node := XMLNode.new()

    node.name = parser.get_node_name()
    node.attributes = {}
    node.content = ""
    node.standalone = false  # standalone nodes are always NODE_ELEMENT
    node.children = []

    return node


static func _attach_node_data(node: XMLNode, parser: XMLParser) -> void:
    # XMLParser treats blank stuff between nodes as NODE_TEXT, which is unwanted
    # we therefore strip "blankets", resulting in only actual content slipping into .content
    node.content += parser.get_node_data().strip_edges()

static func _attach_node_cdata(node: XMLNode, parser: XMLParser) -> void:
    node.cdata.append(parser.get_node_name().strip_edges())

static func _get_attributes(parser: XMLParser) -> Dictionary:
    var attrs: Dictionary = {}
    var attr_count: int = parser.get_attribute_count()

    for attr_idx in range(attr_count):
        attrs[parser.get_attribute_name(attr_idx)] = parser.get_attribute_value(attr_idx)

    return attrs


static func _cleanup_double_blankets(xml: PackedByteArray) -> PackedByteArray:
    # XMLParser is again "incorrect" and duplicates nodes due to double blank escapes
    # https://github.com/godotengine/godot/issues/81896#issuecomment-1731320027

    var rm_count := 0 # How much elements (blankets) to remove from the source
    var idx := xml.size() - 1

    # Iterate in reverse order. This matters for perf because otherwise we
    # would need to do a double .reverse() and remove elements from the start
    # of the array, both of which are quite expensive
    while idx >= 0:
        if xml[idx] in [9, 10, 13]: # [\t, \n, \r]
            rm_count += 1
            idx -= 1
        else:
            break

    # Remove blankets
    while rm_count > 0:
        xml.remove_at(xml.size() - 1)
        rm_count -= 1

    return xml
