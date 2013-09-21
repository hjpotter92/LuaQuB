package.path = [[..\src\?.lua]]
local LuaQuB = require "qublua"
local Object = LuaQuB.new()

Object:select( { id = "ID", nick = "Name", prof = "Profile", mail = "e-Mail" } )

Object:from( { nickstats = 'n' } )

Object:join( 'nickstats_login', 'n.id = nickstats_login.nickstats_id', 'LEFT' ):limit( 15 )

print( tostring(Object) )

--- Output
--! ------
--!
--! SELECT id `ID`,
--! 	nick `Name`,
--! 	mail `e-Mail`,
--! 	prof `Profile`
--! FROM nickstats `n`
--! LEFT JOIN nickstats_login
--! 	ON n.id = nickstats_login.nickstats_id
--! LIMIT 15
--
