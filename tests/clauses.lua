package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select{
	id = 'ID',
	nick = 'Name',
	msg = 'Entry',
	dated = 'Added',
	ctg = 'Category'
}

Object:from 'entries'

Object:where( 'ctg IN', "('tv', 'book', 'movie')" )
Object:where( {
	ctg = "'docu'",
	dated = 'CURDATE()'
}, 'or' )
Object:where( 'nick = ', "'hjpotter92'" )

print( Object )

--- Output
--! ------
--!
--! SELECT dated `Added`,
--! 	nick `Name`,
--! 	ctg `Category`,
--! 	id `ID`,
--! 	msg `Entry`
--! FROM entries
--! WHERE ctg IN ('tv', 'book', 'movie')
--! 	OR ctg = 'docu'
--! 	OR dated = CURDATE()
--! 	AND nick = 'hjpotter92'
--
