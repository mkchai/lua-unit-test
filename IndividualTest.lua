--[[----------------------------------------------------------------------------
IndividualTest

Smallest unit of testing for unit test framework. For sanity purposes, name
instances of IndividualTest with a sufficiently descriptive string (module_test,
modulefunction_test, name of file, etc).

PROPERTIES
Name<string>
Tests<function> | Tests<table<function>>
TestCase<TestCase>

--]]----------------------------------------------------------------------------


-- Class Creation
local IndividualTest = {}
IndividualTest.__index = IndividualTest


-- Global Constants
local LINE_WIDTH = 80
local TEST_MODULE_NAMES = {
	["Assert.lua"] = true,
	["IndividualTest.lua"] = true,
	["TestCase.lua"] = true
}


-- Helper Function Declarations
local ProcessErrorMessage = function(error_msg) end
local GetCallingFileNameAndLine = function(error_msg) end
local GenerateHeader = function(result, calling_file, line_num, test_case) end


-- Function Declarations
local New = function(name, tests) end
local Execute = function(self) end
local Output = function(self, result, msg) end


-- Helper Function Definitions
--[[----------------------------------------------------------------------------
ProcessErrorMessage(error_msg)

Error messages generally have a filepath plus line number of the form:

dir/dir/dir ... /file_name.lua:line_number: error_msg


If a match for a similar pattern is found, strips the front matter to return
only the error message. If a pattern is not found, returns original argument.

PARAMETERS
error_msg<string>

--------------------------------------------------------------------------------
GetCallingFileNameAndLine()

Calls debug.getinfo sequentially using level = [3,12]. (Level 1 is this function
and Level 2 shall be the member function Execute.) At each level, compares the
calling function's file name to those in the UnitTest module (since some classes
in this module call IndividualTest Execute.) The first file not in the UnitTest
module is considered to be the calling file.

Returns nil if such a file is not found or the stack trace goes further than
Level 12.

--]]----------------------------------------------------------------------------
ProcessErrorMessage = function(error_msg)
	local trcbck_begin, trcbck_end = string.find(error_msg, "[.]*%.lua:[%d]*:%s")
	local err_gen_by_module = string.find(error_msg, "ASSERT_")
	if trcbck_end and err_gen_by_module then
		return string.sub(error_msg, trcbck_end + 1)
	else
		local file_begin, file_end = string.find(error_msg, "[\\/][%w%s%-_]*%.lua")
		if file_begin then
			return string.sub(error_msg, file_begin + 1)
		else
			return error_msg
		end
	end
end

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

GenerateHeader = function(test, result, calling_file, line_num, test_case)
	local front = result and "PASSED | " or "FAILED | "
	local src = test.Name
	local back = ""
	if calling_file and line_num and not test_case then
		src = src .. ", " .. calling_file .. ":" .. line_num
	end
	if test_case then
		back = " | " .. test_case.Name
	end
	local str_length = #front + #src + #back
	if str_length < LINE_WIDTH then
		local num_spaces = LINE_WIDTH - str_length
		return front .. src .. string.rep(" ", num_spaces) .. back
	else
		return front .. src .. back
	end
end


-- Function Definitions
--[[----------------------------------------------------------------------------
New(name, tests)

Creates new individual test. tests argument may either be a function or a table
of functions.

PARAMETERS
name<string>
tests<function> | tests<table<function>>

--------------------------------------------------------------------------------
Execute()

Runs test. Returns 4-tuple: passed<bool>, error_msg<string>, caller<string>,
line_num<int>. error_msg will be nil if the test passed, caller and line_num
will be nil if one is not found (as described in the description for 
GetCallingFileNameAndLine).

The returned msg is the error message of self.Tests (if it is a single function)
or the concatenation of all error messages (if self.Tests is a table of
functions).

--------------------------------------------------------------------------------
Output(passed, msg)

Prints formatted result of test given results from Execute().

PARAMETERS
passed<bool>
[msg<string>]
[caller<string>]
[line_num<int>]

--]]----------------------------------------------------------------------------
New = function(name, tests)
	local self = setmetatable({}, IndividualTest)
	self.Name = name
	self.Tests = tests
	self.TestCase = nil
	return self
end

Execute = function(self)
	local single_test = type(self.Tests) == "function"
	local multiple_tests = type(self.Tests) == "table"
	-- single test execution
	if single_test then
		local test_passed, test_msg = pcall(function() self.Tests(self) end)
		test_msg = ProcessErrorMessage(test_msg)
		local calling_file, line_num = GetCallingFileNameAndLine()
		return test_passed, test_msg, calling_file, line_num
	-- multiple tests execution
	elseif multiple_tests then
		local messages = {}
		local test_passed = true
		for i = 1, #self.Tests do
			local subtest = self.Tests[i]
			local subtest_passed, subtest_msg = pcall(function() subtest(self) end)
			if not subtest_passed then
				test_passed = false
				messages[#messages + 1] = ProcessErrorMessage(subtest_msg)
			end
		end
		local test_msg = table.concat(messages, "\n")
		local calling_file, line_num = GetCallingFileNameAndLine()
		return test_passed, test_msg, calling_file, line_num
	else
		error("\"" .. self.Name .. "\" does not contain any tests.")
	end
end

Output = function(self, result, msg, calling_file, line_num)
	local test_case = self.TestCase
	print(string.rep("-", LINE_WIDTH))
	local result_header = GenerateHeader(self, result, calling_file, line_num, test_case)
	print(result_header)
	if not result then
		print(msg)
	end
	if not test_case then
		print(string.rep("-", LINE_WIDTH))
	end
end


-- Member Function Assigment
IndividualTest.New = New
IndividualTest.Execute = Execute
IndividualTest.Output = Output


return IndividualTest
-- eof