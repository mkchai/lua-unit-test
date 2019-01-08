--[[----------------------------------------------------------------------------
Assert

Set of assertions for unit testing. To be used within IndividualTest.

--]]----------------------------------------------------------------------------


-- Module Creation
local Assert = {}


-- Global Constants
local ALMOST_EQUAL_CMP = 2.384185791015625e-7 -- 2^-22
-- local ALMOST_EQUAL_CMP = 4.44089209850062616169452667236328125e-16 -- 2^-51
local LINE_WIDTH = 80
local TEST_MODULE_NAMES = {
	["Assert.lua"] = true,
	["IndividualTest.lua"] = true,
	["TestCase.lua"] = true
}


-- Helper Function Declarations
local GetCallingFileNameAndLine = function(error_msg) end
local GetLeftPaddedLineNum = function(assert_str, line_num) end


-- Function Declarations
local Equal = function(arg1, arg2) end
local NotEqual = function(arg1, arg2) end
local True = function(arg) end
local False = function(arg) end
local Truthy = function(arg) end
local Falsy = function(arg) end
local Nil = function(arg) end
local Raises = function(func) end
local NotRaises = function(func) end
local AlmostEqual = function(arg1, arg2) end
local NotAlmostEqual = function(arg1, arg2) end
local Greater = function(arg1, arg2) end
local GreaterEqual = function(arg1, arg2) end
local Less = function(arg1, arg2) end
local LessEqual = function(arg1, arg2) end


-- Helper Function Definitions
--[[----------------------------------------------------------------------------
GetCallingFileNameAndLine()

Calls debug.getinfo sequentially using level = [3,12]. (Level 1 is this function
and Level 2 shall be an Assert function.) At each level, compares the
calling function's file name to those in the UnitTest module (since some classes
in this module call IndividualTest Execute.) The first file not in the UnitTest
module is considered to be the calling file.

Returns nil if such a file is not found or the stack trace goes further than
Level 12.

--]]----------------------------------------------------------------------------
GetCallingFileNameAndLine = function()
	for i = 3, 12 do
		local info = debug.getinfo(i)
		local src_name = info.short_src
		local file_begin, file_end = string.find(src_name, "[\\/][%w%s%-_]*%.lua")
		if file_begin then
			src_name = string.sub(src_name, file_begin + 1)
		end
		if not TEST_MODULE_NAMES[src_name] then
			local line_num = info.currentline
			return src_name, line_num
		end
	end
	return nil
end

GetLeftPaddedLineNum = function(assert_str, line_num)
	local line_num_partial = " :" .. line_num
	local str_length = #assert_str + #line_num_partial
	if str_length < LINE_WIDTH then
		local num_spaces = LINE_WIDTH - str_length
		return string.rep(" ", num_spaces) .. line_num_partial
	else
		return line_num_partial
	end
end


-- Function Definitions
--[[----------------------------------------------------------------------------
All functions return nil if the condition is true, and error if they are false.

--]]----------------------------------------------------------------------------
Equal = function(arg1, arg2)
	local check = arg1 == arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_EQUAL: " .. str_arg_1 .. " is not equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check,  assert_msg .. padded_line_num)
end

NotEqual = function(arg1, arg2)
	local check = arg1 ~= arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_NOT_EQUAL: " .. str_arg_1 .. " is equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

True = function(arg)
	local check = arg == true
	local str_arg = tostring(arg)
	local assert_msg = "ASSERT_TRUE: " .. str_arg .. " is not true."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

False = function(arg)
	local check = arg == false
	local str_arg = tostring(arg)
	local assert_msg = "ASSERT_FALSE: " .. str_arg .. " is not false."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

Truthy = function(arg)
	local str_arg = tostring(arg)
	local assert_msg = "ASSERT_TRUTHY: " .. str_arg .. " is not truthy."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(arg, assert_msg .. padded_line_num)
end

Falsy = function(arg)
	local str_arg = tostring(arg)
	local assert_msg = "ASSERT_FALSY: " .. str_arg .. " is not falsy."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(not arg, assert_msg .. padded_line_num)
end


Nil = function(arg)
	local check = arg == nil
	local str_arg = tostring(arg)
	local assert_msg = "ASSERT_NIL: " .. str_arg .. " is not nil."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

Raises = function(func)
	local check = pcall(func) == false
	local str_arg = tostring(func)
	local assert_msg = "ASSERT_RAISES: " .. str_arg .. " did not raise error."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

NotRaises = function(func)
	local check = pcall(func) == true
	local str_arg = tostring(func)
	local assert_msg = "ASSERT_NOT_RAISES: " .. str_arg .. " raised an error."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num  =GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

AlmostEqual = function(arg1, arg2)
	local check = math.abs(arg1 - arg2) < ALMOST_EQUAL_CMP
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_ALMOST_EQUAL: " .. str_arg_1 .. " is not almost equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

NotAlmostEqual = function(arg1, arg2)
	local check = math.abs(arg1 - arg2) > ALMOST_EQUAL_CMP
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_NOT_ALMOST_EQUAL: " .. str_arg_1 .. " is almost equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

Greater = function(arg1, arg2)
	local check = arg1 > arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_GREATER: " .. str_arg_1 .. " is not greater than " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

GreaterEqual = function(arg1, arg2)
	local check = arg1 >= arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_GREATER_EQUAL: " .. str_arg_1 .. " is not greater or equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

Less = function(arg1, arg2)
	local check = arg1 < arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_LESS: " .. str_arg_1 .. " is not less than " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end

LessEqual = function(arg1, arg2)
	local check = arg1 <= arg2
	local str_arg_1, str_arg_2 = tostring(arg1), tostring(arg2)
	local assert_msg = "ASSERT_LESS_EQUAL: " .. str_arg_1 .. " is not less or equal to " .. str_arg_2 .. "."
	local src_name, line_num = GetCallingFileNameAndLine()
	local padded_line_num = GetLeftPaddedLineNum(assert_msg, line_num)
	assert(check, assert_msg .. padded_line_num)
end


-- Function Assignment
Assert.Equal = Equal
Assert.NotEqual = NotEqual
Assert.True = True
Assert.False = False
Assert.Truthy = Truthy
Assert.Falsy = Falsy
Assert.Nil = Nil
Assert.Raises = Raises
Assert.NotRaises = NotRaises
Assert.AlmostEqual = AlmostEqual
Assert.NotAlmostEqual = NotAlmostEqual
Assert.Greater = Greater
Assert.GreaterEqual = GreaterEqual
Assert.Less = Less
Assert.LessEqual = LessEqual


return Assert
--eof