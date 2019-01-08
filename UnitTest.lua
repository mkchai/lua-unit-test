--[[----------------------------------------------------------------------------
UnitTest

Simple unit testing framework.

--]]----------------------------------------------------------------------------


-- Module Creation
local UnitTest = {}


-- Submodule Declarations
local IndividualTest
local TestCase
local Assert


-- Submodule Requires
IndividualTest = require("IndividualTest")
TestCase = require("TestCase")
Assert = require("Assert")


-- Assignment
UnitTest.IndividualTest = IndividualTest
UnitTest.TestCase = TestCase
UnitTest.Assert = Assert


return UnitTest
-- eof