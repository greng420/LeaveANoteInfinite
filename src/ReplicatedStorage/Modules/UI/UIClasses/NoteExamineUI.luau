--!strict
local Players = game:GetService("Players")
--@author: YOUR_NAME_HERE
--@date: CREATION_DATE_HERE
--[[@description:

]]
-----------------------------
-- SERVICES --
-----------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-----------------------------
-- DEPENDENCIES --
-----------------------------

local Constants = require(ReplicatedStorage.Modules.Constants)
local NoteNetwork = require(ReplicatedStorage.Modules.Note.NoteNetwork)

-----------------------------
-- TYPES --
-----------------------------
-- For all of the properties/fields of an object made from this class.
type fields = {
	_userData: { [any]: any }
}

-----------------------------
-- VARIABLES --
-----------------------------
local Module = {}
local MT = {}
MT.__index = MT
export type ExampleType = typeof(setmetatable({} :: fields, MT))

local objectCache = {}

-- CONSTANTS --

-----------------------------
-- PRIVATE FUNCTIONS --
-----------------------------

-----------------------------
-- CLASS FUNCTIONS --
-----------------------------

function Module.new(): ExampleType
	local self = setmetatable({} :: fields, MT) :: ExampleType
	self._userData = {
        UI = ReplicatedStorage.Assets.UI.Note:Clone(),
        currentCFrame = nil,

    }

	table.insert(objectCache, self)
	return self
end

function Module:BelongsToClass(object: any)
	assert(typeof(object) == "table", "Expected table for object!")

	return getmetatable(object) == MT
end

function Module:GetObjects(): { ExampleType }
	return objectCache
end 

-----------------------------
-- METHODS --
-----------------------------

-----------------------------
-- SETTERS --
-----------------------------

function MT.Setup(self: ExampleType)
    local Player = Players.LocalPlayer

    if Constants.DEBUG then
        warn('NOTE EXAMINER UI LOADED')
    end
end

-----------------------------
-- GETTERS --
-----------------------------

function MT.GetUserData(self: ExampleType): { [any]: any }
	return self._userData
end

-----------------------------
-- CLEANUP --
-----------------------------

function MT.Destroy(self: ExampleType)
	local i = table.find(objectCache, self)
	if i then
		table.remove(objectCache, i)
	end
end

-----------------------------
-- MAIN --
-----------------------------
return Module
