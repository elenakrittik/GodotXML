# v1.0.0 -> v2.0.0

## Breaking Changes

- `XMLNodeType` was removed due to not being used anywhere.
- `beautify` parameter in all `XML.dump_*()` functions was renamed to `pretty`.
- Move `XMLDocument.to_dict()` to `XMLNode.to_dict()`.
- Make `XMLNode.to_dict()` opinionated by removing all controllability functions.
- Change structure of `XMLNode.to_dict()`'s output.

## Features

- `XML` can now handle semantically invalid XML.
- Added `indent_level` and `indent_length` to control initial indentation level and level width respectively.
- Allow accessing `XMLNode` children by their name if their name is unqiue amongst that `XMLNode`'s children. Works in the editor too.
- Document structure of `XMLNode.to_dict()`'s output.

## Bug Fixes

- Fix empty standalone nodes geting two spaces before `>` when prettified.
- Fix node content being on the same line as it's node when prettified.

## Internal Changes

- Remove pointless checks in parsing logic.
- Properly document code to make contributing easier.
- Reformat code to use 4-space indent instead of the previous tabs.
- Remove commented out code in some places.
- Refactor prettifier and dictionary converter to be recursive-descent, significantly simplifying logic.
