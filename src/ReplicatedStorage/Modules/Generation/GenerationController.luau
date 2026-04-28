--!strict
--@author: YOUR_NAME_HERE
--@date: CREATION_DATE_HERE
--[[@description:

]]
-----------------------------
-- SERVICES --
-----------------------------
local EncodingService = game:GetService("EncodingService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-----------------------------
-- DEPENDENCIES --
-----------------------------

local Constants = require(ReplicatedStorage.Modules.Constants)
local Chunk = require(ReplicatedStorage.Modules.Generation.Chunk)

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

local function getPlayerChunkPosition(): Vector2
    local Character = Players.LocalPlayer.Character
    if not Character then return Vector2.zero end

    local RootPart: BasePart = Character.HumanoidRootPart

    local NewPosition = Vector3.new(math.round(RootPart.Position.X / Constants.GRID_SIZE), 0, math.round(RootPart.Position.Z / Constants.GRID_SIZE))

    return Vector2.new(NewPosition.X, NewPosition.Y)
end

-----------------------------
-- CLASS FUNCTIONS --
-----------------------------

function Module.new(): ExampleType
	local self = setmetatable({} :: fields, MT) :: ExampleType
	self._userData = {
        loadedChunks = {},
        generateNearbyChunks = false
    }

    RunService:BindToRenderStep("UPDATE_CHUNKS", Enum.RenderPriority.Last.Value, function(delta: number)
        if not self._userData.generateNearbyChunks then return end

        local Character = Players.LocalPlayer.Character
        if not Character then return end

        local RootPart: BasePart = Character.HumanoidRootPart

        local NewPosition = Vector3.new(math.round(RootPart.Position.X / Constants.GRID_SIZE), 0, math.round(RootPart.Position.Z / Constants.GRID_SIZE))
        local newPositionV2 = Vector2.new(NewPosition.X, NewPosition.Z) * (Vector2.one * 50)

        for x = -Constants.RENDER_DISTANCE, Constants.RENDER_DISTANCE do
            for z = -Constants.RENDER_DISTANCE, Constants.RENDER_DISTANCE do
                local c: Chunk.Chunk = self:LoadChunk(Vector2.new(NewPosition.X + x, NewPosition.Z + z))
                local chunkPos: Vector2 = c.Position * (Vector2.one * 50)

                local Distance = (chunkPos - newPositionV2).Magnitude

                if Distance < (Constants.RENDER_DISTANCE * 30) then
                    c:LoadNotes()
                end
            end
        end

        --CHECK FAR AWAY CHUNKS AND NOTE RELOAD HERE

        local CurrentlyLoadedChunks: { Chunk.Chunk } = self:GetLoadedChunks()

        for _, chunk: Chunk.Chunk in pairs(CurrentlyLoadedChunks) do
            --CHECK IF TOO FAR AWAY
            local chunkPos = chunk.Position * (Vector2.one * 50)

            local Distance = (chunkPos - newPositionV2).Magnitude

            if Distance > (Constants.RENDER_DISTANCE * 55) then
                self:UnloadChunk(chunk)
            end

            --CHECK IF ITS TIME TO RELOAD NOTES
            if not chunk.NotesLoaded then
                continue
            end
            local timeSinceLastLoadedNotes = (tick() - chunk.LastLoadedNote)

            if (timeSinceLastLoadedNotes > Constants.NOTE_RELOAD_TIME) then
                chunk:ReloadNotes()
            end
        end
    end)

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

function MT.LoadChunk(self: ExampleType, Position: Vector2): Chunk.Chunk
    local foundChunk = self:GetChunkAtPosition(Position)
    if foundChunk then --[[warn("Chunk at", Position, 'already exists')]] return foundChunk end

    local NewChunk = Chunk.new(Position)

    NewChunk:Load()
    table.insert(self._userData.loadedChunks, NewChunk)

    return NewChunk
end

function MT.UnloadChunk(self: ExampleType, Chunk: Chunk.Chunk)
    local ChunkInTable, index = self:GetChunkAtPosition(Chunk.Position)

    if not ChunkInTable then
        return
    end

    ChunkInTable:Unload()
    table.remove(self._userData.loadedChunks, index)
end

-----------------------------
-- SETTERS --
-----------------------------

-----------------------------
-- GETTERS --
-----------------------------

function MT.GetUserChunkPosition(): Vector2
    return getPlayerChunkPosition()
end

function MT.GetLoadedChunks(self: ExampleType): { Chunk.Chunk }
    return self:GetUserData().loadedChunks
end

function MT.GetChunkAtPosition(self: ExampleType, Position: Vector2): Chunk.Chunk?
    for i, chunk: Chunk.Chunk in pairs(self:GetLoadedChunks()) do
        if chunk.Position == Position then
            return chunk, i
        end
    end

    return nil
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