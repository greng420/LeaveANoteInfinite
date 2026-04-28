--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local GenerationNetwork = require(script.Parent.GenerationNetwork)
local Constants = require(ReplicatedStorage.Modules.Constants)

local GenerationClient = {}

local GenerationController = require(ReplicatedStorage.Modules.Generation.GenerationController).new()

function GenerationClient:Init()
    GenerationController._userData.generateNearbyChunks = true

    GenerationNetwork.GetPlayerChunkPosition.OnClientInvoke = function()
        return GenerationController:GetUserChunkPosition()
    end
end

function GenerationClient:Start()

end

return GenerationClient