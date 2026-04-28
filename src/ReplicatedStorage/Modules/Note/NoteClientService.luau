local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Constants = require(ReplicatedStorage.Modules.Constants)

local NoteClientService = {}

function NoteClientService:Init()
    NoteClientService.NotePlacer = require(ReplicatedStorage.Modules.Note.Classes.NotePlacer).new()
end

function NoteClientService:Start()
    NoteClientService.NotePlacer.NotePlaceEvent.Event:Connect(function(NoteCFrame: CFrame)
        if Constants.DEBUG then
            print("initiating request for", Players.LocalPlayer.Name, "to place note at", NoteCFrame)
        end

        
    end)

    RunService:BindToRenderStep("UPDATE_NOTE_PLACER_RENDERSTEP_BIND", Enum.RenderPriority.Camera.Value, function(delta: number)
        if not NoteClientService.NotePlacer then
            NoteClientService.NotePlacer = require(ReplicatedStorage.Modules.Note.Classes.NotePlacer).new()
        end

        NoteClientService.NotePlacer:Update()
    end)
end

return NoteClientService
