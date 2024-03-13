# v2.0.0 -> v2.1.0

## Features

- Implement `XMLNode.dump_file`, `XMLNode.dump_buffer` and `XMLNode.dump_str`.
- Implement support for CDATA nodes.

## Bug Fixes

- Only remove trailing blankets instead of all.
- Concatenate all `NODE_TEXT` nodes' contents instead of respecting only the first one.

## Deprecations

- Deprecate `XML.dump_file`, `XML.dump_buffer` and `XML.dump_str`.

## Internal Changes

- Improve type safety across the codebase.
- Improve documentation and README wording.
- Miscellaneous code clean-ups.

# v1.0.0 -> v2.0.0

## Breaking Changes

- Remove `XMLNodeType` due to being unused.
- Rename `beautify` parameter in all `XML.dump_*()` functions to `pretty`.
- Move `XMLDocument.to_dict()` to `XMLNode.to_dict()`.
- Remove "configurability" parameters from `XMLNode.to_dict()`.
- Change structure of `XMLNode.to_dict()`'s output.

## Features

- Make `XML` able to handle semantically invalid XML.
- Add `indent_level` and `indent_length` to control initial indentation level and level width respectively.
- Allow accessing `XMLNode` children by their name if their name is unqiue amongst that `XMLNode`'s children. Works in the editor too.
- Document structure of `XMLNode.to_dict()`'s output.

## Bug Fixes

- Fix empty standalone nodes geting two spaces before `>` when prettified.
- Fix node content being on the same line as it's node when prettified.

## Internal Changes

- Remove unnecessary checks in parsing logic.
- Properly document code to make contributing easier.
- Reformat code to use 4-space indent instead of tabs.
- Remove commented out code in some places.
- Refactor prettifier and dictionary converter to be recursive-descent, significantly simplifying logic.
