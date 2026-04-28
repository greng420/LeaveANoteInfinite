--!strict
--@author: YOUR_NAME_HERE
--@date: CREATION_DATE_HERE
--[[@description:

]]
-----------------------------
-- SERVICES --
-----------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-----------------------------
-- DEPENDENCIES --
-----------------------------

-----------------------------
-- TYPES --
-----------------------------

-----------------------------
-- VARIABLES --
-----------------------------
local Network = {}

-- CONSTANTS --

-----------------------------
-- PRIVATE FUNCTIONS --
-----------------------------

local function CreateBindableFunction(name): BindableFunction
	local RemoteFunction

	if not script:FindFirstChild(name) then
		RemoteFunction = Instance.new('BindableFunction',script)
		RemoteFunction.Name = name
	else
		RemoteFunction = script:FindFirstChild(name)
	end

	return RemoteFunction	
end

local function CreateRemoteFunction(name): RemoteFunction
	local RemoteFunction

	if not script:FindFirstChild(name) then
		RemoteFunction = Instance.new('RemoteFunction',script)
		RemoteFunction.Name = name
	else
		RemoteFunction = script:FindFirstChild(name)
	end

	return RemoteFunction	
end

Network.GetPlayerChunkPosition = CreateRemoteFunction("GetPlayerChunkPosition")

-----------------------------
-- PUBLIC FUNCTIONS --
-----------------------------

function Network:Init()

end

function Network:Start()

end

-----------------------------
-- MAIN --
-----------------------------
return Network