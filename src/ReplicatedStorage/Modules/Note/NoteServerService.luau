local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NoteServerService = {}

local NoteTypes = require(script.Parent.NoteTypes)
local Constants = require(ReplicatedStorage.Modules.Constants)
local GenerationNetwork = require(ReplicatedStorage.Modules.Generation.GenerationNetwork)
local NoteNetwork = require(ReplicatedStorage.Modules.Note.NoteNetwork)
local doOBBsIntersect = require(ReplicatedStorage.Modules.Utility.doOBBsIntersect)

local NoteDataStore = DataStoreService:GetDataStore(Constants.CURRENT_NOTE_STORE)

local function StringToCFrame(String)
	local Split = string.split(String, ",")
	return CFrame.new(Split[1],Split[2],Split[3],Split[4],Split[5],Split[6],Split[7],Split[8],Split[9],Split[10],Split[11],Split[12])
end

local function getChunkNote(Player, ChunkPosition: Vector2)
        local ChunkKey = (ChunkPosition.X.."_"..ChunkPosition.Y)

        local success, errorMessage
        local chunkData
        local attempts = 0
        repeat
            success, errorMessage = pcall(function(...)
                chunkData = NoteDataStore:GetAsync(ChunkKey)
            end)
            attempts += 1
            task.wait()
        until success == true or (attempts >= 50)

        if chunkData then
            if typeof(chunkData) == "string" then
                chunkData = HttpService:JSONDecode(chunkData)
            end

            local newChunkData = {}

            for _, note: {} in pairs(chunkData) do
                local NoteObject: NoteTypes.Note = {
                    ["Text"] = note.Text,
                    ["Creator"] = note.Creator,
                    ["DateCreated"] = note.Time,
                    ["NoteCFrame"] = StringToCFrame(note.CFrame)
                }

                table.insert(newChunkData, NoteObject)
            end

            return newChunkData
        end
    end

local function VerifyChunkPosition(Position: Vector2)
    local NewX = Position.X
    local NewY = Position.Y

    if Position.X == -0 then
        NewX = 0
    end

    if Position.Y == -0 then
        NewY = 0
    end

    return Vector2.new(NewX, NewY)
end

function NoteServerService:Init()

end

function NoteServerService:Start()
    NoteNetwork.PlaceNoteRequest.OnServerInvoke = function(Player: Player, NoteCFrame: CFrame, NoteMessage: string)
        local RawPlayerChunkPosition: Vector2 = GenerationNetwork.GetPlayerChunkPosition:InvokeClient(Player)

        local PlayerChunkPosition: Vector2 = VerifyChunkPosition(RawPlayerChunkPosition)

        --GET CHUNK DATA AND CHECK IF WE HAVE ENOUGH SPACE FOR THIS NOTE
        local cData: {} = getChunkNote(Player, PlayerChunkPosition)
        local foundAtleastOneIntersectingNoteOBB = false

        if cData then --BUT ONLY CHECK IF THE CHUNK HAS AN EXISTING DATA STORE KEY

            for _, note: NoteTypes.Note in pairs(cData) do
                local currentCFrame = note.NoteCFrame

                local doTheyIntersect = doOBBsIntersect(NoteCFrame, Constants.NOTE_PLACE_BOX, currentCFrame, Constants.NOTE_PLACE_BOX)

                if doTheyIntersect then
                    foundAtleastOneIntersectingNoteOBB = true
                    break
                end
            end

            if foundAtleastOneIntersectingNoteOBB then
                return false, "Not Enough Space"
            end
        end

        local success, err
        repeat
            success, err = pcall(function(...)  
                NoteDataStore:UpdateAsync(PlayerChunkPosition.X.."_"..PlayerChunkPosition.Y, function(data)
                    if data == nil then
                        --if there is no chunk data, then we can just add a table with the note
                        if Constants.DEBUG then
                            print("No chunk data found, adding some")
                        end

                        return HttpService:JSONEncode({
                            {
                                ["Creator"] = Player.UserId,
                                ["Text"] = NoteMessage,
                                ["Time"] = DateTime.now().UnixTimestamp,
                                ["CFrame"] = tostring(NoteCFrame)
                            }
                        })
                    end

                    local isDataJSON = (typeof(data) == 'string')
                    local newData

                    if isDataJSON then
                        newData = HttpService:JSONDecode(data)
                    else
                        newData = data
                    end

                    table.insert(newData, {
                        ["Creator"] = Player.UserId,
                        ["Text"] = NoteMessage,
                        ["Time"] = DateTime.now().UnixTimestamp,
                        ["CFrame"] = tostring(NoteCFrame)
                    })

                    return newData
                end)
            end)
        until success == true

        return true, "Placed note successfully."
    end

    NoteNetwork.GetNoteForChunkRequest.OnServerInvoke = function(Player, ChunkPosition: Vector2)
        return getChunkNote(Player, ChunkPosition)
    end
end

return NoteServerService