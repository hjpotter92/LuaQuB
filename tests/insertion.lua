package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object, tInsert = LuaQuB.new(), {
	id = 2,
	nick = 'hjpotter92',
	msg = "Testing INSERT query",
	date = os.date( '%Y-%m-%d' ),
}

Object:insert( 'entries', tInsert )

print( Object )

--- Output
--! ------
--!
--! INSERT INTO `entries` ( `id`, `nick`, `date`, `msg` )
--! VALUES
--! (
--! 	2,
--! 	'hjpotter92',
--! 	'2013-10-08',
--! 	'Testing INSERT query'
--! )
--
