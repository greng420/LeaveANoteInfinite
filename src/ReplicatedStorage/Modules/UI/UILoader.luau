local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILoader = {}

function UILoader:Init()
    UILoader.NoteUI = require(ReplicatedStorage.Modules.UI.UIClasses.NotePlacerUI).new()
    UILoader.NoteExamineUI = require(ReplicatedStorage.Modules.UI.UIClasses.NoteExamineUI).new()
end

function UILoader:Start()
    UILoader.NoteUI:Setup()
    UILoader.NoteExamineUI:Setup()
end

return UILoader
