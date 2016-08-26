--- Query builder module for Lua.
-- @module LuaQuB
-- @author [hjpotter92](https://github.com/hjpotter92)
-- @release 2.0.0
-- @license MIT

--- Metatable for `LuaQuB` module
-- @table metatable
-- @field _DESCRIPTION Module description
-- @field _VERSION Module version
-- @field _AUTHOR Module author "hjpotter92 <hjpotter92+github@gmail.com>"
local luaqub = {
  _DESCRIPTION = "LuaQuB is a small query builder module for Lua",
  _VERSION = "2.0.0",
  _AUTHOR = "hjpotter92 <hjpotter92+github@gmail.com>",
}

local Functions = require "functions"

do
  local _meta = {
    __metatable = "Private metatable for LuaQuB object",
  }
  _meta.__index = _meta

  local Explode, TableAdd = Functions.Explode, Functions.TableAdd
  local TableCopy, Trim = Functions.TableCopy, Functions.Trim
  local Insert, Concat = table.insert, table.concat

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
    self._built = false
    local __select = ( type(_columns) == "table" and _columns ) or Explode( _columns )
    if not self._select then self._select = {} end
    TableAdd( self._select, __select )
    return self
  end

  --- `FROM` parameter aggregator.
  -- The parameters passed to this function shall be aggregated
  -- over all the calls. This function can be called more than
  -- once for the same object.
  -- @param _tables List of tables either as a string or in a table
  -- @return `LuaQuB` The reference to updated object itself
  -- @function from
  -- @raise Argument type mismatch
  -- @todo Add support so that it'll accept another `LuaQuB` object
  function _meta:from( _tables )
    if not _tables then
      error "bad argument #2 to 'from' (table/string expected, got nil)"
    end
    self._built = false
    local __from = ( type(_tables) == "table" and _tables ) or Explode( _tables )
    if not self._from then self._from = {} end
    TableAdd( self._from, __from )
    return self
  end

  --- `LIMIT` parameter aggregator.
  -- Generates the `LIMIT` and `OFFSET` clauses for the query.
  -- @param iLimit Integer value for setting LIMIT
  -- @param iOffset Integer value to set OFFSET
  -- @return `LuaQuB` The reference to updated object itself
  -- @function limit
  -- @raise Argument type mismatch
  function _meta:limit( iLimit, iOffset )
    if not iLimit or type(iLimit) ~= "number" then
      error "bad argument #2 to 'limit' (number expected)"
    end
    self._limit = ("\nLIMIT %d"):format(iLimit)
    if iOffset and type(iOffset) ~= "number" then
      error "bad argument #3 to 'limit' (number expected)"
    end
    if iOffset then
      self._offset = ("\nOFFSET %d"):format(iOffset)
    end
    return self
  end

  --- `ORDER BY` parameter aggregator.
  -- Generates the `ORDER BY` clause for various table keys and
  -- associated directions with them.
  -- @param _key The table key (column) which to order against. Can be
  -- an integer or string or a table of strings.
  -- @tparam string _dir The direction (`ASC` or `DESC` or `RANDOM`). Default
  -- is `ASC`.
  -- @return `LuaQuB` The reference to updated object itself
  -- @function order
  -- @raise Argument type mismatch
  function _meta:order( _key, _dir )
    if not _key then
      error "bad argument #2 to 'order' (number/string/table expected)"
    end
    local sDirection = Trim( _dir and _dir:upper() or "ASC" )
    if tonumber( _key ) and sDirection ~= "RANDOM" then
      error "invalid argument #3 to 'order' for 'number' type argument #2"
    end
    local __order = ( type(_key) == "table" and _key ) or Explode(_key)
    local tTemp = {}
    if #__order == 0 then
      for col, dir in pairs(__order) do
        Insert( tTemp, ("%s %s"):format(Trim(col), Trim(dir:upper())) )
      end
    else
      for _, value in ipairs(__order) do
        if tonumber( value ) then
          Insert( tTemp, ("RANDOM(%d)"):format(value) )
        else
          Insert( tTemp, ("%s %s"):format(Trim(value), sDirection) )
        end
      end
    end
    if not self._order then self._order = {} end
    TableAdd( self._order, tTemp )
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
    local sSelect, sFrom = Concat( self._select, ",\n\t" ), Concat( self._from, ",\n\t" )
    self._query = ( "SELECT %s\nFROM %s" ):format( sSelect, sFrom )
    if self._order then
      self._query = self._query .. ( "\nORDER BY %s" ):format( Concat(self._order, ",\n\t") )
    end
    if self._limit then
      self._query = self._query .. self._limit
      if self._offset then
        self._query = self._query .. self._offset
      end
    end
    self._built = true
    return true
  end

  --- Fetch the compiled query string.
  -- After a successful `build` call, the built query is cached by the object
  -- and can be retrieved by this function.
  -- @function query
  -- @treturn string The result of compiled query
  -- @raise `build` was not called prior to fetching the query
  function _meta:query()
    if self._built == false or not self._query then
      error "You need to `build` the query before trying to fetch it."
    end
    return self._query
  end

  local function _new( self )
    return setmetatable( {}, _meta )
  end

  setmetatable(
    luaqub,
    {
      new = _new,
      __call = _new,
      __metatable = "Private metatable for LuaQuB module",
    }
  )
end

luaqub.__index = luaqub

return luaqub
