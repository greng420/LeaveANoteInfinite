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

    local NoteFrame: Frame = self._userData.UI.Frame
    local SubmitButton: TextButton = NoteFrame:WaitForChild("PlaceButton")
    local CancelButton: TextButton = NoteFrame:WaitForChild("CancelButton")

    self._userData.UI.Parent = Player.PlayerGui
    NoteFrame.Visible = false

    CancelButton.MouseButton1Click:Connect(function(...)
        NoteFrame.Visible = false
    end)

    SubmitButton.MouseButton1Click:Connect(function(...)
        local cframeToPlace: CFrame? = self._userData.currentCFrame

        if not cframeToPlace then
            return
        end

        local noteMessage: string = NoteFrame.NoteText.Text

        if Constants.DEBUG then
            print("Requesting to place note at CFrame", cframeToPlace, "with message", noteMessage)
        end

        NoteFrame.Visible = false

        local success, errorMessage = NoteNetwork.PlaceNoteRequest:InvokeServer(cframeToPlace, noteMessage)

        if Constants.DEBUG then
            warn(success, errorMessage)
        end
    end)

    require(ReplicatedStorage.Modules.Note.NoteClientService).NotePlacer.NotePlaceEvent.Event:Connect(function(NoteCFrame: CFrame)
        self._userData.currentCFrame = NoteCFrame

        NoteFrame.Visible = true

        if Constants.DEBUG then
            print("Caught request to place note at", NoteCFrame)
        end
    end)
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