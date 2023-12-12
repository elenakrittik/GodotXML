# GodotXML - advanced XML support for Godot 4.

This addon adds support for manipulating XML data in Godot 4 with ease.

> Supports Godot 4.0-4.2, and likely future versions too.

> HINT: Migrating from v1? See [changelog](./CHANGELOG.md) for a complete list of breaking (and not) changes.

## Features

- Pure-Godot - everything is done using built-in `XMLParser`;
- Loading and dumping XML data into/from a convenient class-based format;
- Beautifying XML;
- Converting XML into dictionaries;
- Access uniquely named children of nodes as if they were regular attributes (works in the editor too!);
- Decent error messages for when the input is malformed (i mean, `XMLParser` doesn't have them at all, so :> ).

## Installation

Search for the "GodotXML" addon on the asset library ([link](https://godotengine.org/asset-library/asset/1684)) or alternatively copy the `addons/` folder into your project's root.

## API

All functions and attributes that are meant for use by you do not have `_` before their name
and are also listed before any internal function.

All other functions and attributes are **not meant** to be used by you, though of course
you can edit them as you like.

## Roadmap

- [ ] Setup automated tests.
