--!nocheck

local bit64 = {}

type Bit = string | number

local Bit32 = bit32
local BIT_SIZE = 64 

local band, bor, bxor, bnot = Bit32.band, Bit32.bor, Bit32.bxor, Bit32.bnot
local lshift, rshift, arshift = Bit32.lshift, Bit32.rshift, Bit32.arshift
local bswap = Bit32.byteswap

local function bit64_split(x: Bit)
	local num = tonumber(x) :: number
	return tonumber(num / 0x100000000),  tonumber(num % 0x100000000)
end

local function bit64_join(hi: number, lo: number)
	hi = rshift(hi, 1) * 2 + band(hi, 1)
	lo = rshift(lo, 1) * 2 + band(lo, 1)
	return (hi * 0x100000000) + (lo % 0x100000000)
end

local function _binop(op: (...number) -> number, x1: Bit, x2: Bit, ...)
	local hi1, lo1 = bit64_split(x1)
	local hi2, lo2 = bit64_split(x2)
	local hi, lo = op(hi1, hi2), op(lo1, lo2)
	for n=1, select("#", ...) do
		local hi_n, lo_n = bit64_split(select(n, ...))
		hi = op(hi, hi_n)
		lo = op(lo, lo_n)
	end
	return bit64_join(hi, lo)
end

local function bit64_rshift(x: Bit, disp: Bit)
	local _disp = tonumber(disp) :: number
	
	if band(_disp, 0x3F) == 0 then 
		return x 
	end

	local hi, lo = bit64_split(x)
	if band(_disp, 0x20) == 0 then
		lo, hi = bor(rshift(lo, _disp), lshift(hi, 32 - _disp)), rshift(hi, _disp)
	else
		lo, hi = rshift(hi, _disp - 32), 0
	end

	return bit64_join(hi, lo)
end

local function bit64_lshift(x: Bit, disp: Bit)
	local _disp = tonumber(disp) :: number
	if band(_disp, 0x3F) == 0 then 
		return x 
	end
	local hi, lo = bit64_split(x)
	if band(_disp, 0x20) == 0 then
		lo, hi = lshift(lo, _disp), bor(lshift(hi, _disp), rshift(lo, 32 - _disp))
	else
		lo, hi = 0, lshift(lo, _disp)
	end
	return bit64_join(hi, lo)
end

local function bit64_arshift(x: Bit, disp: Bit)
	local _disp = tonumber(disp) :: number
	if band(_disp, 0x3F) == 0 then 
		return x 
	end
	local hi, lo = bit64_split(x)
	if band(_disp, 0x20) == 0 then
		lo, hi = bor(rshift(lo, _disp), lshift(hi, 32 - _disp)), arshift(hi, _disp)
	else
		lo, hi = arshift(hi, _disp - 32), arshift(hi, 31)
	end
	return bit64_join(hi, lo)
end

bit64.rshift = bit64_rshift
bit64.lshift = bit64_lshift
bit64.arshift = bit64_arshift


function bit64.band(...: Bit)
	return _binop(band, ...)
end

function bit64.btest(x: Bit, ...)
	return bit64.band(x, ...) ~= 0 
end

function bit64.bor(...: number)
	return _binop(bor, ...)
end

function bit64.bxor(...: number)
	return _binop(bxor, ...)
end

function bit64.bnot(x: Bit)
	local hi, lo = bit64_split(x)
	local bnot = bnot
	return bit64_join(bnot(hi), bnot(lo))
end


function bit64.byteswap(n: Bit)
	local hi, lo = bit64_split(n)
	return bit64_join(bswap(lo), bswap(hi))
end

function bit64.lrotate(x: Bit, disp: number)
	if band(disp, 0x3F) == 0 then return x end
	local hi, lo = bit64_split(x)
	if band(disp, 0x20) ~= 0 then
		lo, hi = hi, lo
	end
	if band(disp, 0x1F) ~= 0 then
		lo, hi = bor(lshift(lo, disp), rshift(hi, 32 - disp)), bor(lshift(hi, disp), rshift(lo, 32 - disp))
	end
	return bit64_join(hi, lo)
end

function bit64.rrotate(x: Bit, disp: number)
	return bit64.lrotate(x, BIT_SIZE - disp)
end

function bit64.countlz(n: Bit)
	local hi, lo = bit64_split(n)

	-- Check if hi is nonzero, if so, count leading zeros in hi
	if hi ~= 0 then
		local count = 0
		for i = BIT_SIZE - 1, 0, -1 do
			if bit64.band(hi, bit64.lshift(1, i)) ~= 0 then
				break
			end
			count = count + 1
		end
		return count
	end

	-- If hi is zero, count leading zeros in lo
	local count = 0
	for i = BIT_SIZE - 1, 0, -1 do
		if bit64.band(lo, bit64.lshift(1, i)) ~= 0 then
			break
		end
		count = count + 1
	end
	return count
end

function bit64.countrz(n: Bit)
	local hi, lo = bit64_split(n)
	if lo ~= 0 then
		local count = 0
		for i = 0, BIT_SIZE - 1 do
			if bit64.band(lo, bit64.lshift(1, i)) ~= 0 then
				break
			end
			count = count + 1
		end
		return count
	end
	local count = 0
	for i = 0, BIT_SIZE - 1 do
		if bit64.band(hi, bit64.lshift(1, i)) ~= 0 then
			break
		end
		count = count + 1
	end
	return count
end


function bit64.extract(n: Bit, field: number, width: number?)
	local result = bit64.rshift(n, field) -- Right shift to align the desired bits
	if width then
		-- If width is specified, mask out the bits beyond the desired width
		local mask = bit64.lshift(1, width) - 1
		result = bit64.band(result, mask)
	end
	return result 
end

bit64.split = bit64_split

local OPERATORS = {
	[">>"] = bit64.rshift,
	["<<"] = bit64.lshift,
	["&"] = bit64.band
}

local PRECEDENCE = {
	["<<"] = 1,  -- Left Shift
	[">>"] = 1,  -- Right Shift
	["&"] = 2,   -- Bitwise AND
}

local function applyOperator(operands: { number | string }, operator: str)
	local right = table.remove(operands)
	local left = table.remove(operands)
	
	if OPERATORS[operator] then
		table.insert(operands, OPERATORS[operator](left, right))
	end
end

local function evaluate(tokens: { string })
	local operands = {}
	local operatorsStack = {}

	for _, token in ipairs(tokens) do
		if tonumber(token) then
			table.insert(operands, token)
		else
			while #operatorsStack > 0 and PRECEDENCE[operatorsStack[#operatorsStack]] <= PRECEDENCE[token] do
				applyOperator(operands, table.remove(operatorsStack))
			end
			table.insert(operatorsStack, token)
		end
	end

	while #operatorsStack > 0 do
		applyOperator(operands, table.remove(operatorsStack))
	end
	
	return operands[1]
end

local function parseExpression(expression: string): number
	local tokens = {}
	for token in string.gmatch(expression, "%S+") do
		table.insert(tokens, token)
	end

	return evaluate(tokens)
end

setmetatable(bit64, {
	__call = function(_, expression: string)		
		return parseExpression(expression)
	end,
})

export type Bit64 = typeof(setmetatable(bit64, {} :: {
	__call: (_, expression: string) -> number
}))

return bit64 :: Bit64