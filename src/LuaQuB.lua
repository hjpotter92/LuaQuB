--- Query builder module for Lua.
-- @author [hjpotter92](https://github.com/hjpotter92)
-- @module LuaQuB
-- @license MIT

--- Metatable for `LuaQuB` module
-- @table metatable
-- @field __index Index lookup for metatable
-- @field _DESCRIPTION Module description
-- @field _VERSION Module version
-- @field _AUTHOR Module author
local luaqub = {
   _DESCRIPTION = "LuaQuB is a small query builder module for Lua",
   _VERSION = "2.0.0",
   _AUTHOR = "hjpotter92",
}

local Functions = require "functions"

do
   local _meta = {
      __metatable = "Private metatable for LuaQuB",
   }
   _meta.__index = _meta

   local Explode, TableAdd = Functions.Explode, Functions.TableAdd
   local TableCopy, Trim = Functions.TableCopy, Functions.Trim

   --- `SELECT` parameter aggregator.
   -- The parameters passed to this function shall be aggregated
   -- over all the calls. This function can be called more than
   -- once for the same object.
   -- @param _columns List of columns either as a string or in a table
   -- @return `LuaQuB` The reference to updated object itself
   -- @function select
   -- @raise Argument type mismatch
   function _meta:select( _columns )
      if not _columns then
         error "bad argument #2 to 'select' (table/string expected, got nil)"
      end
      local __select = ( type(_columns) == "table" and _columns ) or Explode( _columns )
      if not self._select then self._select = {} end
      TableAdd( self._select, __select )
      return self
   end

   --- `FROM` parameter aggregator.
   -- The parameters passed to this function shall be aggregated
   -- over all the calls. This function can be called more than
   -- once for the same object.
   -- @param _tables List of columns either as a string or in a table
   -- @return `LuaQuB` The reference to updated object itself
   -- @function from
   -- @raise Argument type mismatch
   -- @todo Add support so that `from` accepts another `LuaQuB` object
   function _meta:from( _tables )
      if not _tables then
         error "bad argument #2 to 'from' (table/string expected, got nil)"
      end
      local __from = ( type(_tables) == "table" and _tables ) or Explode( _tables )
      if not self._from then self._from = {} end
      TableAdd( self._from, __from )
      return self
   end

   --- Build the query with provided parameters.
   -- The function call can be put in a conditional statement to test whether
   -- your parameters can be used by the module to generate a meaningful query
   -- or not. After `build` call, you can call upon `query` to fetch the built
   -- query string.
   -- @function build
   -- @treturn boolean On successful build, returns `true`
   -- @raise Invalid type of query parameters provided
   function _meta:build()
      if not ( self._select and self._from ) then
         error "Invalid parameters provided to the module. The build failed."
      end
      local sSelect, sFrom = table.concat( self._select, ",\n\t" ), table.concat( self._from, ",\n\t" )
      self._query = ( "SELECT %s\nFROM %s;" ):format( sSelect, sFrom )
      return true
   end

   --- Fetch the compiled query string.
   -- After a successful `build` call, the built query is cached by the object
   -- and can be retrieved by this function.
   -- @function query
   -- @treturn string The result of compiled query
   -- @raise `build` was not called prior to fetching the query
   function _meta:query()
      if not self._query then
         error "You need to `build` the query before trying to fetch it."
      end
      return self._query
   end

   local function _new( self )
      return setmetatable( {}, _meta )
   end

   setmetatable( luaqub, {
       new = _new,
       __call = _new,
   })
end

luaqub.__index = luaqub

return luaqub
