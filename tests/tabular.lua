package.path = [[..\src\?.lua]]
local x = require "qublua"

local myQubObj = x.new()

myQubObj:select( {
	col1 = "ID",
	col2 = "Name",
	col3 = "Date",
	"col4"
} )
myQubObj:from( 'tblName' )
myQubObj:limit( 15, 200 )
myQubObj:where( { "col1 <> 1", col2 = "'hi'" } )

print( tostring(myQubObj) )

--- Output
--! ------
--!
--! SELECT col4,
--! 	col1 ID,
--! 	col2 Name,
--! 	col3 Date
--! FROM tblName
--! WHERE col1 <> 1
--! 	AND col2 = 'hi'
--! LIMIT 15
--! OFFSET 200
--
