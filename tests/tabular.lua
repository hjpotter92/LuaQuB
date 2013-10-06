package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select( {
	col1 = "ID",
	col2 = "Name",
	col3 = "Date",
	"col4"
} )
Object:from( 'tblName' )
Object:limit( 15, 200 )
Object:where( { "col1 <> 1", col2 = "'hi'" } )

print( Object )

--- Output
--! ------
--!
--! SELECT col4,
--! 	col1 ID,
--! 	col2 Name,
--! 	col3 Date
--! FROM tblName
--! WHERE col1 <> 1
--! 	AND col2 = 'hi'
--! LIMIT 15
--! OFFSET 200
--
