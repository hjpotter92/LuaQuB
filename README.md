Lua Query Builder
========================

LuaQuB is a small query builder module for Lua. The current stable release
for the module is **1.1.0**.

## Requirements

The module works perfectly with Lua v5.x. It has been tested successfully
with Lua 5.1.5 and Lua 5.2.4 on Windows 7 x64 and Debian 8 x64 platforms.

## Support(s)

LuaQuB was designed to build queries for `SELECT`, `UPDATE`, `INSERT` and
`DELETE` commands. There is no plan on increasing support for other database
engines.

## Examples

Short examples for each of the four supported commands and their various
variations have been added under the `tests/` directory.

## Not supported

The module does not check whether your input was properly escaped or not. It
assumes that your input will be accordingly given.
