--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local NoteNetwork = require(ReplicatedStorage.Modules.Note.NoteNetwork)
local NoteTypes = require(ReplicatedStorage.Modules.Note.NoteTypes)

export type Chunk = {
    Position: Vector2,
    Model: Model,
    NotesLoaded: boolean,
    Loaded: boolean,
    LastLoadedNote: number,
    NoteData: { NoteTypes.Note }
}

local Chunk = {}
Chunk.__index = Chunk

function Chunk:renderNoteObject(note: NoteTypes.Note)
    local NotePart = ReplicatedStorage.Assets.Note:Clone()
    NotePart.Size = Constants.NOTE_SIZE
    NotePart.CFrame = note.NoteCFrame
    NotePart.CanCollide = false
    NotePart.CollisionGroup = "Note"
    NotePart.Anchored = true
    local NoteSurfaceUI: SurfaceGui = NotePart.SurfaceGui
    NoteSurfaceUI.Frame.NoteText.Text = note.Text
    NoteSurfaceUI.Frame.NoteText.TextWrapped = true
    NoteSurfaceUI.Frame.NoteCreator.Text = "-"..Players:GetNameFromUserIdAsync(note.Creator)

    NotePart.Parent = self.Model
end

local function ConvertVector2ToGridPosition(Position: Vector2): Vector2
    local NewPosition = Vector2.new(Position.X * Constants.GRID_SIZE, Position.Y * Constants.GRID_SIZE)
    return NewPosition  
end

local function ConvertGridPositionToVector3(GridPosition: Vector2): Vector3
    return Vector3.new(GridPosition.X, Constants.Y_OFFSET, GridPosition.Y)
end

function Chunk.new(Position: Vector2): Chunk
    local self = setmetatable({}, Chunk) :: Chunk

    self.Position = Position or Vector2.zero
    self.Model = ReplicatedStorage.Assets.Chunk:Clone()
    self.NotesLoaded = false
    self.Loaded = false
    self.LastLoadedNote = tick()

    return self
end

function Chunk:Unload()
    self.Model:Destroy()

    self.Loaded = false
end

function Chunk:LoadNotes()
    if self.NotesLoaded then
        return
    end
    self.LastLoadedNote = tick()
    self.NotesLoaded = true

    local NoteData: { NoteTypes.Note } = NoteNetwork.GetNoteForChunkRequest:InvokeServer(self.Position)

    if NoteData == nil then
        return
    end

    self.NoteData = NoteData

    for _, note in pairs(NoteData) do
        self:renderNoteObject(note)
    end
end

function Chunk:ReloadNotes()
    if not self.NotesLoaded then
        return
    end

    self.LastLoadedNote = tick()

    local NewNoteData: { NoteTypes.Note } = NoteNetwork.GetNoteForChunkRequest:InvokeServer(self.Position)
    local CurrentNoteData: { NoteTypes.Note } = self.NoteData

    if not CurrentNoteData then
        self.NoteData = {}
        return
    end

    if not NewNoteData then
        return
    end

    if NewNoteData == CurrentNoteData then
        return
    end

    for _, NoteObject: NoteTypes.Note in pairs(NewNoteData) do
        local FoundIdenticalNote

        for _, n: NoteTypes.Note in pairs(CurrentNoteData) do
            if (n.DateCreated == NoteObject.DateCreated) and (n.Creator == NoteObject.Creator) then
                FoundIdenticalNote = n
            end
        end 

        if FoundIdenticalNote then
            continue
        end

        if Constants.DEBUG then
            print("A new note has been added")
        end

        self:renderNoteObject(NoteObject)
    end

    self.NoteData = NewNoteData
end

function Chunk:Load()
    local GridPosition = ConvertVector2ToGridPosition(self.Position)

    local WorldPosition = ConvertGridPositionToVector3(GridPosition)

    self.Model:PivotTo(CFrame.new(WorldPosition))
    self.Model.Parent = Constants.CHUNK_FOLDER

    self.Loaded = true
end

return Chunk
