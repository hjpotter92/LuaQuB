local luaqub, Compile = {}, {}

local function Trim( sInput )
	if type( sInput ) ~= 'string' then return end
	local x = sInput:match "^%s*(.-)%s*$"
	return x
end

local function TableCopy( tInput )
	local tReturn = {}
	for k, v in pairs( tInput ) do
		tReturn[k] = v
	end
	return tReturn
end

local function ParseString( sInput )
	local tReturn = {}
	for sMatch in sInput:gmatch( "[^,]+" ) do
		table.insert( tReturn, Trim(sMatch) )
	end
	return tReturn
end

local function ParseTable( tInput )
	local tReturn = {}
	for Key, Value in pairs( tInput ) do
		if tonumber( Key ) then
			table.insert( tReturn, Trim(Value) )
		else
			table.insert( tReturn, ("%s `%s`"):format(Trim(Key), Trim(Value)) )
		end
	end
	return tReturn
end

local function ParseWhere( sQuery, tWhere )
	local tInput = TableCopy( tWhere )
	if #tInput == 0 then return sQuery end
	sQuery = sQuery.."\nWHERE "..tInput[1].statement
	table.remove( tInput, 1 )
	if #tInput == 0 then return sQuery end
	for _, tValue in ipairs( tInput ) do
		sQuery = sQuery.."\n\t"..tValue.join.." "..tValue.statement
	end
	return sQuery
end

local function ParseHaving( sQuery, tHaving )
	local tInput = TableCopy( tHaving )
	if #tInput == 0 then return sQuery end
	sQuery = sQuery.."\nHAVING "..tInput[1].statement
	table.remove( tInput, 1 )
	if #tInput == 0 then return sQuery end
	for _, tValue in ipairs( tInput ) do
		sQuery = sQuery.."\n\t"..tValue.join.." "..tValue.statement
	end
	return sQuery
end

local function ParseJoins( sInput, Object )
	if #(Object._join) <= 0 then
		return sInput
	end
	for Key, tValue in pairs( Object._join ) do
		sInput = sInput.."\n"..tValue.condition.." "..tValue.tbl.."\n\tON "..tValue.on
	end
	return sInput
end

local function ParseGroup( sInput, Object )
	if #(Object._group) <= 0 then
		return sInput
	end
	sInput = sInput.."\nGROUP BY "..table.concat( Object._group, ",\n\t" )
	return sInput
end

local function ParseOrder( sInput, Object )
	if #(Object._order) <= 0 then
		return sInput
	end
	sInput, tOrder = sInput.."\nORDER BY ", {}
	for Key, tValue in pairs( Object._order ) do
		tOrder[#tOrder + 1] = tValue.col.." "..tValue.dir
	end
	return sInput..table.concat( tOrder, ",\n\t" )
end

function Compile.SELECT( Object )
	local sReturn, colNames, tbls = "SELECT ", table.concat( Object._select, ",\n\t" ), table.concat( Object._from, ",\n\t" )
	sReturn = sReturn..colNames
	if #(Object._from) > 0 then
		sReturn = sReturn.."\nFROM "..tbls
	end
	sReturn = ParseJoins( sReturn, Object )
	sReturn = ParseWhere( sReturn, Object._where )
	sReturn = ParseGroup( sReturn, Object )
	sReturn = ParseHaving(sReturn, Object._having )
	sReturn = ParseOrder( sReturn, Object )
	if Object._limit > 0 then
		sReturn = sReturn.."\nLIMIT "..tostring( Object._limit )
	end
	if Object._offset > 0 then
		sReturn = sReturn.."\nOFFSET "..tostring( Object._offset )
	end
	return sReturn
end

function Compile.UPDATE( Object )
	if type( Object._from ) ~= "string" then
		error( "Update can be performed on a single table." )
		return false
	end
	local sReturn, tSet = "UPDATE "..Object._from.."\nSET ", {}
	for Key, Value in pairs( Object._update ) do
		tSet[#tSet + 1] = Key.." = "..Value
	end
	sReturn = sReturn..table.concat( tSet, ",\n\t" )
	sReturn = ParseWhere( sReturn, Object._where )
	sReturn = ParseOrder( sReturn, Object )
	if Object._limit > 0 then
		sReturn = sReturn.."\nLIMIT "..tostring( Object._limit )
	end
	return sReturn
end

function Compile.DELETE( Object )
	if #(Object._from) == 0 then
		error( "No table has been specified for DELETE call." )
		return false
	end
	local sReturn = "DELETE FROM "..table.concat( Object._from, ",\n\t" )
	sReturn = ParseWhere( sReturn, Object._where )
	if #(Object._from) == 1 then
		sReturn = ParseOrder( sReturn, Object )
		if Object._limit > 0 then
			sReturn = sReturn.."\nLIMIT "..tostring( Object._limit )
		end
	end
	return sReturn
end

function Compile.INSERT( Object )
	local tInsert = Object._insert
	local sReturn = ("INSERT INTO `%s` ( %s )\nVALUES\n(\n\t%s\n)"):format( tInsert.tbl, table.concat(tInsert.cols, ', '), table.concat(tInsert.val, ',\n\t') )
	return sReturn
end

luaqub.__index = luaqub

function luaqub:__tostring()
	return Compile[self._flag:upper()]( self )
end

function luaqub:select( cols )
	if not cols then
		error( "Argument to select function expected" )
		return false
	end
	if type( cols ) == "string" then
		if Trim( cols ) == "*" then
			self._select = { '*' }
		else
			self._select, cols = ParseString( cols ), nil
		end
	elseif type( cols ) == "table" then
		self._select, cols = ParseTable( cols ), nil
	end
	self._flag = "select"
	return self
end

function luaqub:from( tbls )
	if not tbls then
		error( "Argument to from function expected" )
		return false
	end
	if type( tbls ) == "string" then
		self._from, tbls = ParseString( tbls ), nil
	elseif type( tbls ) == "table" then
		self._from, tbls = ParseTable( tbls ), nil
	end
	return self
end

function luaqub:where( clauses, value, joiner )
	if not clauses then
		error( "Matching clauses to where function expected" )
		return false
	end
	if type( clauses ) == "string" then
		if not joiner then joiner = 'and' end
		table.insert( self._where, { join = joiner:upper(), statement = Trim(clauses).." "..Trim(value) } )
		clauses = nil
	elseif type( clauses ) == "table" then
		if not value then value = 'and' end
		joiner = value:upper()
		for Key, Value in pairs( clauses ) do
			if tonumber( Key ) then
				table.insert( self._where, { join = joiner, statement = Value } )
			else
				table.insert( self._where, { join = joiner, statement = ("%s = %s"):format(Trim(Key), Trim(Value)) } )
			end
		end
		clauses = nil
	end
	return self
end

function luaqub:having( clauses, value, joiner )
	if not clauses then
		error( "Matching clauses to having function expected" )
		return false
	end
	if type( clauses ) == "string" then
		if not joiner then joiner = 'and' end
		table.insert( self._having, { join = joiner:upper(), statement = Trim(clauses).." "..Trim(value) } )
		clauses = nil
	elseif type( clauses ) == "table" then
		if not value then value = 'and' end
		joiner = value:upper()
		for Key, Value in pairs( clauses ) do
			if tonumber( Key ) then
				table.insert( self._having, { join = joiner, statement = Value } )
			else
				table.insert( self._having, { join = joiner, statement = ("%s = %s"):format(Trim(Key), Trim(Value)) } )
			end
		end
		clauses = nil
	end
	return self
end

function luaqub:join( tbl, clause, cond )
	if not cond then
		cond = "JOIN"
	else
		cond = Trim( cond:upper() ).." JOIN"
	end
	if type( clause ) == "string" then
		clause = Trim( clause )
	end
	table.insert( self._join, { condition = cond, tbl = tbl, on = clause } )
	return self
end

function luaqub:limit( lim, off )
	if not tonumber( lim ) then
		error( "Limit argument should be a number" )
		return false
	end
	if off then
		if not tonumber( off ) then
			error( "Offset argument should be a number" )
			return false
		end
		self._offset = tonumber( off )
	end
	self._limit = tonumber( lim )
	return self
end

function luaqub:order( col, dir )
	if not col then
		error( "Blank call of order function is not allowed" )
		return false
	end
	if type( col ) == "string" then
		dir = ( dir and dir:upper() ) or "ASC"
		table.insert( self._order, { col = col, dir = dir } )
	elseif type( col ) == "table" then
		for Key, Value in pairs( col ) do
			if tonumber( Key ) then
				table.insert( self._order, { col = Value, dir = "ASC" } )
			else
				table.insert( self._order, { col = Key, dir = Value:upper() } )
			end
		end
	end
	return self
end

function luaqub:group( col )
	if not col then
		error( "Blank call of group function is not allowed" )
		return false
	end
	if type( col ) == "string" then
		table.insert( self._group, col )
	elseif type( col ) == "table" then
		for Key, Value in pairs( col ) do
			table.insert( self._group, Value )
		end
	end
	return self
end

function luaqub:update( tbl, datas )
	if type( tbl ) ~= 'string' then
		error( "Update can be performed on a single table." )
		return false
	end
	if type( datas ) ~= 'table' then
		error( "Unexpected argument #2 to update. Table expected, got "..type(datas) )
		return false
	end
	self._from, self._flag, self._update = tbl, 'update', datas
	return self
end

function luaqub:delete()
	self._flag = 'delete'
	return self
end

function luaqub:insert( tbl, datas )
	if not datas or type( datas ) ~= 'table' then
		error( "Unexpected argument #2 passed to insert function." )
		return false
	end
	if type( tbl ) ~= 'string' then
		error( "String argument expected for insert function." )
		return false
	end
	local tCols, tValue = {}, {}
	for Key, Value in pairs( datas ) do
		table.insert( tCols, ('`%s`'):format(Trim(Key)) )
		if not tonumber(Value) then
			table.insert( tValue, ("'%s'"):format(Trim(Value)) )
		else
			table.insert( tValue, Trim(Value) )
		end
	end
	self._flag, self._insert.cols, self._insert.val, self._insert.tbl = 'insert', tCols, tValue, tbl
	return self
end

function luaqub.new()
	local tNew = {
		_select = {},
		_update = {},
		_from = {},
		_where = {},
		_join = {},
		_order = {},
		_group = {},
		_having = {},
		_insert = {},
		_limit = 0,
		_offset = 0,
		_flag = '',
	}
	setmetatable( tNew, luaqub )
	return tNew
end

return luaqub
