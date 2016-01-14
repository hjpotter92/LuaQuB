package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select( "nick, max(score)" ):from( "scores" ):where( "nick <>", " 'hjpotter92'" ):limit( 20 )

Object:where( "date = ", "CURDATE()" )
Object:group('nick'):having('max(score) > ', '3'):having('max(score) < ', '1', 'OR')

print( Object )

--- Output
--! ------
--!
--! SELECT nick,
--! 	max(score)
--! FROM scores
--! WHERE nick <> 'hjpotter92'
--! 	AND date = CURDATE()
--! GROUP BY nick
--! HAVING max(score) > 3
--!     OR max(score) < 1
--! LIMIT 20
--
