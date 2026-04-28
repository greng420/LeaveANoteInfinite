local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Modules.Constants)
local module_loader = require(ReplicatedStorage.Packages["module-loader"])

module_loader.ChangeSettings({
    VERBOSE_LOADING = Constants.DEBUG,
    FOLDER_SEARCH_DEPTH = 2
})

module_loader.Start(ReplicatedStorage.Modules)
