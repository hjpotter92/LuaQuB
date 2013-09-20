local luaqub, Compile = {}, {}

function Compile.SELECT( Object )
	local sReturn, colNames, tbls = "SELECT ", table.concat( Object._select, ",\n\t" ), table.concat( Object._from, ",\n\t" )
	sReturn = sReturn..colNames.."\nFROM "..tbls
	if #(Object._where) > 0 then
		sReturn = sReturn.."\nWHERE "..table.concat( Object._where, "\n\tAND " )
	end
	if Object._limit > 0 then
		sReturn = sReturn.."\nLIMIT "..tostring( Object._limit )
	end
	if Object._offset > 0 then
		sReturn = sReturn.."\nOFFSET "..tostring( Object._offset )
	end
	return sReturn
end

luaqub.__index = luaqub

local function Trim( sInput )
	local x = sInput:match( "^[%s]*(.-)[%s]*$" )
	return x
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
			table.insert( tReturn, ("%s %s"):format(Trim(Key), Trim(Value)) )
		end
	end
	return tReturn
end

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

function luaqub:where( clauses )
	if not clauses then
		error( "Matching clauses to where function expected" )
		return false
	end
	if type( clauses ) == "string" then
		table.insert( self._where, clauses )
		clauses = nil
	elseif type( clauses ) == "table" then
		for Key, Value in pairs( clauses ) do
			if tonumber( Key ) then
				table.insert( self._where, Value )
			else
				table.insert( self._where, ("%s = %s"):format(Trim(Key), Trim(Value)) )
			end
		end
		clauses = nil
	end
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

function luaqub.new()
	local tNew = {
		_select = {},
		_from = {},
		_where = {},
		_limit = 0,
		_offset = 0,
		_flag = '',
	}
	setmetatable( tNew, luaqub )
	return tNew
end

return luaqub
