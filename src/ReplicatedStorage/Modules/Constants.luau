local constants = {}

constants.DEBUG = true

--GENERATION DATA

constants.GRID_SIZE = 50
constants.Y_OFFSET = 16
constants.RENDER_DISTANCE = 5

constants.CHUNK_FOLDER = workspace.Chunks
constants.CHUNK_COLLISION_GROUP = "Chunk"

--NOTE DATA

constants.CURRENT_NOTE_STORE = "NOTEBETA_3"
constants.NOTE_RELOAD_TIME = 12

constants.NOTE_SIZE = Vector3.new(1.8, 2.4, .2)
constants.NOTE_PLACE_BOX = constants.NOTE_SIZE * 1.1

--MODULE DATA

constants.ignoredModules = {
    "Constants",
    "Chunk",
    "GenerationController",
    "NoteTypes",
    "NoteNetwork",
    "NotePlacer",
    "GenerationNetwork",
    "areProjectionsOverlapping",
    "doOBBsIntersect"
}

constants.clientServices = {
    "GenerationClient",
    "NoteClientService",
    "UILoader"
}

constants.serverServices = {
    "NoteServerService"
}

return constants
