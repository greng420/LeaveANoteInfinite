local ReplicatedStorage = game:GetService("ReplicatedStorage")
local module_loader = require(ReplicatedStorage.Packages["module-loader"])
local constants = require(ReplicatedStorage.Modules.Constants)

for _, service: ModuleScript in pairs(ReplicatedStorage.Modules:GetDescendants()) do
    if table.find(constants.ignoredModules, service.Name) then
        service:SetAttribute("IgnoreLoader", true)
    end
end

for _, service: ModuleScript in pairs(ReplicatedStorage.Modules:GetDescendants()) do
    if table.find(constants.serverServices, service.Name) then
        service:SetAttribute("ServerOnly", true)
    end
end

for _, service: ModuleScript in pairs(ReplicatedStorage.Modules:GetDescendants()) do
    if table.find(constants.clientServices, service.Name) then
        service:SetAttribute("ClientOnly", true)
    end
end

module_loader.ChangeSettings({
    VERBOSE_LOADING = constants.DEBUG,
    FOLDER_SEARCH_DEPTH = 2
})

module_loader.Start(ReplicatedStorage.Modules)
