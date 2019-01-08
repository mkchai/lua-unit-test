--[[----------------------------------------------------------------------------
TestCase

Collection of individual tests.

PROPERTIES
Name<string>
Tests<table<IndividualTest>>

--]]----------------------------------------------------------------------------


-- Class Creation
local TestCase = {}
TestCase.__index = TestCase


-- Global Constants
local LINE_WIDTH = 80
local TEST_MODULE_NAMES = {
	["Assert.lua"] = true,
	["IndividualTest.lua"] = true,
	["TestCase.lua"] = true
}


-- Helper Function Declarations
local GetCallingFileNameAndLine = function(error_msg) end


-- Function Declarations
local New = function(name, tests) end
local Execute = function(self) end


-- Helper Function Definitions
--[[----------------------------------------------------------------------------
GetCallingFileNameAndLine()

Calls debug.getinfo sequentially using level = [3,12]. (Level 1 is this function
and Level 2 shall be the member function Execute.) At each level, compares the
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


-- Function Definitions
--[[----------------------------------------------------------------------------
New(name, tests)

Creates new test case.

PARAMETERS
name<string>
tests<table<IndividualTest>>

--------------------------------------------------------------------------------
Execute()

Executes all IndividualTest contained in the test case. Outputs formatted result.

--]]----------------------------------------------------------------------------
New = function(name, tests)
	local self = setmetatable({}, TestCase)
	for i = 1, #tests do
		local individual_test = tests[i]
		individual_test.TestCase = self
	end
	self.Name = name
	self.Tests = tests
	return self
end

Execute = function(self)
	local tests = self.Tests
	local passed_tests = 0
	local failed_tests = 0
	-- generating header
	local header = self.Name
	local calling_file, line_number = GetCallingFileNameAndLine()
	if calling_file and line_number then
		header = header .. ", " .. calling_file .. ":" .. line_number
	end
	-- outputting result
	print(string.rep("=", LINE_WIDTH))
	print(header)
	print(string.rep("=", LINE_WIDTH))
	for i = 1, #tests do
		local test = tests[i]
		local result, msg, caller, line_num = test:Execute()
		test:Output(result, msg, caller, line_num)
		if result then
			passed_tests = passed_tests + 1
		else
			failed_tests = failed_tests + 1
		end
	end
	print(string.rep("-", LINE_WIDTH))
	local total_tests = passed_tests + failed_tests
	if total_tests ~= #tests then
		print("WARNING: Not all tests (" .. #tests .. " total) run.")
	end
	local tests_run_substr = total_tests ~= 1 and total_tests .. " tests run. " or total_tests .. " test run. "
	local test_case_summary = tests_run_substr .. passed_tests .. " passed, " .. failed_tests .. " failed."
	print("\n" .. test_case_summary)
	print(string.rep("=", LINE_WIDTH))
end


-- Member Function Assigment
TestCase.New = New
TestCase.Execute = Execute


return TestCase
-- eof