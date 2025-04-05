# GodotXML - advanced XML support for Godot 4.

This addon adds support for manipulating XML data in Godot 4 with ease.

> Supports Godot 4.0-4.4, and likely future versions too.

> HINT: Migrating from v1? See [changelog](./CHANGELOG.md#v100---v200) for a complete list of breaking (and not) changes.

## Features

- Pure-Godot - everything is done using built-in `XMLParser`;
- Loading and dumping XML data into/from a convenient class-based format;
- Beautifying XML;
- Converting XML into dictionaries;
- Access uniquely named children of nodes as if they were regular attributes (works in the editor too!);
- Decent error messages for when the input is malformed (i mean, `XMLParser` doesn't have them at all, so :> ).

## Installation

Search for the "GodotXML" addon on the asset library ([link](https://godotengine.org/asset-library/asset/1684))
or alternatively copy the `addons/` folder into your project's root.

## Usage

Use the `XML.parse_[buffer|string|file]` functions to parse XML into an `XMLDocument`, then use `XMLDocument.root`
to get the root `XMLNode`, from which point use `XMLNode`'s properties to inspect a node and use the `XMLNode.dump_[buffer|string|file|]`
functions to convert a node back into XML. It's that simple!

## Version Guarantees

All functions and attributes that are meant for use by you do not start with an `_` and are governed by the usual
SemVer rules. Accordingly, all functions and attributes that *do* start with an `_`  are **not meant** to be used
by you (and can change or be removed entirely even in patch versions, although that's usually not the case). If you
*really* need to use something that is currently "private", open an issue and let's talk!

## Roadmap

- [ ] Setup automated tests.
