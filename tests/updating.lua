package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

local tUpdating = {
	logout = 'NOW()',
	last_used = 'CURDATE()',
	used_times = 'used_times + 1'
}

Object:update( 'userstats', tUpdating ):where{ nick = "'hjpotter92'" }:order{ id = 'DESC' }:limit( 1 )

print( Object )

--- Output
--! ------
--!
--! UPDATE userstats
--! SET logout = NOW(),
--! 	last_used = CURDATE(),
--! 	used_times = used_times + 1
--! WHERE nick = 'hjpotter92'
--! ORDER BY id DESC
--! LIMIT 1
--
