package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select{ id = "ID", ctg = "Category", msg = "Message", "nick", date = "Date" }

Object:from( 'entries' ):limit( 35 ):order( 'id', 'desc' )

Object:where{ date = "CURDATE()", ctg = "'book'" }

print( Object )

--- Output
--! ------
--!
--! SELECT nick,
--! 	id `ID`,
--! 	msg `Message`,
--! 	ctg `Category`,
--! 	date `Date`
--! FROM entries
--! WHERE date = CURDATE()
--! 	AND ctg = 'book'
--! ORDER BY id DESC
--! LIMIT 35
--
