package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select( "id, nick" ):from( "scores" ):where( "nick <>", " 'hjpotter92'" ):limit( 20 )

Object:where( "date = ", "CURDATE()" )

print( Object )

--- Output
--! ------
--!
--! SELECT id,
--! 	nick
--! FROM scores
--! WHERE nick <> 'hjpotter92'
--! 	AND date = CURDATE()
--! LIMIT 20
--
