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

   function _meta:select( _columns )
      if not _columns then
         error "bad argument #2 to 'select' (table/string expected, got nil)"
      end
      local __select = ( type(_columns) == "table" and _columns ) or Explode( _columns )
      if not self._select then self._select = {} end
      TableAdd( self._select, __select )
      return self
   end

   function _meta:from( _tables )
      if not _tables then
         error "bad argument #2 to 'from' (table/string expected, got nil)"
      end
      local __from = ( type(_tables) == "table" and _tables ) or Explode( _tables )
      if not self._from then self._from = {} end
      TableAdd( self._from, __from )
      return self
   end

   function _meta:compile()
      local sSelect, sFrom = table.concat( self._select, ",\n\t" ), table.concat( self._from, ",\n\t" )
      return ( "SELECT %s\nFROM %s;" ):format( sSelect, sFrom )
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
