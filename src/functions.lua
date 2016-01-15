local functions = {}

do
   local function _trim( sInput )
      if type( sInput ) ~= "string" then return tostring( sInput ) end
      return sInput:match "^%s*(.-)%s*$"
   end

   local function _table_copy( tInput )
      local tReturn = {}
      for Key, Value in pairs( tInput ) do
         tReturn[Key] = Value
      end
      return tReturn
   end

   local function _explode( sInput, cTrigger )
      local tReturn, sPattern = {}, "([^"..(cTrigger or ",").."]+)"
      for sGroup in sInput:gmatch( sPattern ) do
         table.insert( tReturn, _trim(sGroup) )
      end
      return tReturn
   end

   local function _table_add( tInput, tOther )
      for Key, Value in ipairs( tOther ) do
         table.insert( tInput, Key, Value )
      end
      return
   end

   functions.Trim = _trim
   functions.TableCopy = _table_copy
   functions.TableAdd = _table_add
   functions.Explode = _explode
end

return functions
