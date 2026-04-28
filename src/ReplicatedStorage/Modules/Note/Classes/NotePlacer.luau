--!strict
--@author: YOUR_NAME_HERE
--@date: CREATION_DATE_HERE
--[[@description:

]]
-----------------------------
-- SERVICES --
-----------------------------
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Constants = require(ReplicatedStorage.Modules.Constants)

-----------------------------
-- DEPENDENCIES --
-----------------------------

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

MT.NotePlaceEvent = Instance.new("BindableEvent")

local RP = RaycastParams.new()
RP.CollisionGroup = Constants.CHUNK_COLLISION_GROUP
RP.FilterDescendantsInstances = {}
RP.RespectCanCollide = true

local objectCache = {}

-- CONSTANTS --

-----------------------------
-- PRIVATE FUNCTIONS --
-----------------------------

local function RaycastToMousePoint(): RaycastResult
    local mousePosition: Vector2 = UserInputService:GetMouseLocation()

    local STWRay = workspace.CurrentCamera:ViewportPointToRay(mousePosition.X, mousePosition.Y)

    local Raycast = workspace:Raycast(STWRay.Origin, STWRay.Direction * 40, RP)

    return Raycast
end

local function CreatePlacementIndicator(): BasePart
    local Indicator = Instance.new("Part")

    Indicator.Size = Constants.NOTE_SIZE
    Indicator.Color = Color3.fromRGB(0, 255, 0)
    Indicator.Transparency = 0.7
    Indicator.Anchored = true
    Indicator.CollisionGroup = "PlacementIndicator"
    Indicator.CanCollide = false
    Indicator.Parent = workspace

    return Indicator
end

-----------------------------
-- CLASS FUNCTIONS --
-----------------------------

function Module.new(): ExampleType
	local self = setmetatable({} :: fields, MT) :: ExampleType
	self._userData = {
        indicator = CreatePlacementIndicator(),
        canPlace = true,
        enabled = true,
    }

    ContextActionService:BindAction("NOTE_ACTION", function(actionName: string, inputState: Enum.UserInputState, inputObject: InputObject): Enum.ContextActionResult?
        if inputState ~= Enum.UserInputState.Begin then return end

        self.NotePlaceEvent:Fire(self._userData.indicator.CFrame)

        return Enum.ContextActionResult.Pass
    end, false, Enum.UserInputType.MouseButton1)

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

function MT.Update(self: ExampleType)
    local Character = Players.LocalPlayer.Character
    if Character then
        RP.FilterDescendantsInstances = {Character, self._userData.indicator}
    end

    local PlacementIndicator: BasePart = self._userData.indicator
    if not PlacementIndicator then
        self._userData.indicator = CreatePlacementIndicator()
    end

    PlacementIndicator.Transparency = 1

    local MousePointRaycast = RaycastToMousePoint()

    if not MousePointRaycast or not self:GetEnabled() then
        return
    end

    PlacementIndicator.Transparency = .7
    PlacementIndicator.CFrame = CFrame.new(MousePointRaycast.Position, MousePointRaycast.Position + MousePointRaycast.Normal)
end

-----------------------------
-- SETTERS --
-----------------------------

-----------------------------
-- GETTERS --
-----------------------------

function MT.GetEnabled(self: ExampleType): boolean
    return self:GetUserData().enabled
end

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
