package.path = [[../?.lua]]
local LuaQuB = require "LuaQuB"
local Object = LuaQuB.new()

Object:select{ ["COUNT(1)"] = "count", ["DATE(dated)"] = "date" }
Object:from( 'scores' )
Object:group( 'date' ):order{ count = 'ASC', date = 'DESC' }

print( Object )

--- Output
--! ------
--!
--! SELECT COUNT(1) `count`,
--! 	DATE(dated) `date`
--! FROM scores
--! GROUP BY date
--! ORDER BY count ASC,
--! 	date DESC
--
