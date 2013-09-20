package.path = [[..\src\?.lua]]
local x = require "qublua"
local y = x.new()

y:select( "id, nick" ):from( "scores" ):where( "nick <> 'hjpotter92'" ):limit( 20 )

y:where( "date = CURDATE()" )

print( tostring(y) )

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
