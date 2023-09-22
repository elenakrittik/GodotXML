# GodotXML - advanced XML support for Godot 4.

This addon adds support for manipulating XML data in Godot 4 with ease.

> Supports Godot 4.0, 4.1 and the likely the upcoming 4.2.

> HINT: Migrating from v1? See [changelog](./CHANGELOG.md) for a complete list of breaking (and not) changes.

## Features

- Pure-Godot - everything is done using built-in `XMLParser` and does not rely on external bindings*;
- Loading and dumping XML data into/from a convenient class-based format;
- Beautifying XML;
- Converting XML into dictionaries;
- Access uniquely named children of nodes as if they were regular attributes (works in the editor too!);
- Decent error messages for when the input is malformed*.

<details>
  <summary>*Future plans</summary>

  `XMLParser`, Godot's native, low-level XML parser that this addon works on top of, or, more specifically,
  `irrXML` (on which `XMLParser` is based), always assumes input to be trusted and valid, and therefore lacks both
  adequate error handling and adequate security measures. In case of error handling addon currently
  implements a few workarounds that eliminate *known* godot bugs, but still cannot handle syntactically invalid
  input; in case of security we can't do anything unfortunately. Due to the above and our intention for this
  plugin to be usable in as much cases as possible, this addon will soon migrate to a custom, more modern XML
  library like Expat.

  Related issues on Godot's tracker:
  - https://github.com/godotengine/godot/issues/72517
  - https://github.com/godotengine/godot/issues/51380
  - https://github.com/godotengine/godot/issues/81896
  - https://github.com/godotengine/godot/issues/51622
  - https://github.com/godotengine/godot/issues/81896#issuecomment-1731320027

</details>

## Installation

Search for the "GodotXML" addon on the asset library ([link](https://godotengine.org/asset-library/asset/1684)) or alternatively copy the `addons/` folder into your project's root.

## API

All functions and attributes that are meant for use by you do not have `_` before their name
and are also listed before any internal function.

All other functions and attributes are **not meant** to be used by you, though of course
you can edit them as you like.

## Roadmap

- [ ] Setup automated tests.
