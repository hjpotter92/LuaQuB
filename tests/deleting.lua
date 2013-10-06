package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:delete():from( 'entries' )

print( Object )

--- Output
--! ------
--!
--! DELETE FROM entries
--

Object:where{ nick = "'hjpotter92'", 'id > 450', 'date < CURDATE()' }

print( Object )

--- Output
--! ------
--!
--! DELETE FROM entries
--! WHERE id > 450
--! 	AND date < CURDATE()
--! 	AND nick = 'hjpotter92'
--

Object:limit( 300 )

print( Object )

--- Output
--! ------
--!
--! DELETE FROM entries
--! WHERE id > 450
--! 	AND date < CURDATE()
--! 	AND nick = 'hjpotter92'
--! LIMIT 300
--
