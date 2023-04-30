--[[
-- THIS SCRIPT HAS BEEN CODED BY RAFA (discord.gg/MilkUp)
-- DON'T BE A STUPID SKIDDIE THAT STEAL PEOPLE CODE AND PUT ON A SHIT PAID (or "watch ad to get key") SCRIPT
-- hi Project WD please don't steal my code again thx

-- For Preston:
-- Sorry for any incovenience I don't make any malicous script like mail/bank stealers, trade scam and this shit, just auto-farm and QoL scripts, feel free to use this repo to fix any vulnerability on your game
--]]

-- Join us at 
-- discord.gg/MilkUp




--[[
-- TODO LIST:
-- • Huge notifier on Discord Webhook (its ez but I'm lazy)
-- • Auto quest
-- • Improve Bank Index with "Auto buy storage upgrades" (+ withdraw needed diamonds from bank)
--]]


-- Important Variables
local SCRIPT_NAME = "Rafa PSX GUI"
local SCRIPT_VERSION = "v0.4" -- Hey rafa remember to change it before updating lmao

-- Detect if the script has executed by AutoExec
local AutoExecuted = false
if not game:IsLoaded() then AutoExecuted = true end

repeat task.wait() until game.PlaceId ~= nil
if not game:IsLoaded() then game.Loaded:Wait() end

--//-------------- SERVICES ----------------//*
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local InputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local ContentProvider = game:GetService("ContentProvider")

--//*--------- GLOBAL VARIABLES -----------//*
local ScriptIsCurrentlyBusy = false
local Character = nil
local Humanoid = nil
local HumanoidRootPart = nil
local CurrentWorld = ""
local CurrentPosition = nil

local Settings_DisableRendering = true

local Webhook_Enabled = false
local Webhook_URL = ""
local Webhook_Daycare = true
local Webhook_Huge = true

LocalPlayer.CharacterAdded:Connect(function(char) 
	Character = char
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

if game.PlaceId == 6284583030 or game.PlaceId == 10321372166 or game.PlaceId == 7722306047 or game.PlaceId == 12610002282 then
	
	local banSuccess, banError = pcall(function() 
		local Blunder = require(game:GetService("ReplicatedStorage"):WaitForChild("X", 10):WaitForChild("Blunder", 10):WaitForChild("BlunderList", 10))
		if not Blunder or not Blunder.getAndClear then LocalPlayer:Kick("Error while bypassing the anti-cheat! (Didn't find blunder)") end
		
		local OldGet = Blunder.getAndClear
		setreadonly(Blunder, false)
		local function OutputData(Message)
		   print("-- PET SIM X BLUNDER --")
		   print(Message .. "\n")
		end
		
		Blunder.getAndClear = function(...)
		   local Packet = ...
			for i,v in next, Packet.list do
			   if v.message ~= "PING" then
				   OutputData(v.message)
				   table.remove(Packet.list, i)
			   end
		   end
		   return OldGet(Packet)
		end
		
		setreadonly(Blunder, true)
	end)

	if not banSuccess then
		LocalPlayer:Kick("Error while bypassing the anti-cheat! (".. banError ..")")
		return
	end
	
	local Library = require(game:GetService("ReplicatedStorage").Library)
	assert(Library, "Oopps! Library has not been loaded. Maybe try re-joining?") 
	while not Library.Loaded do task.wait() end
	
	Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	
	
	local bypassSuccess, bypassError = pcall(function()
		if not Library.Network then 
			LocalPlayer:Kick("Network not found, can't bypass!")
		end
		
		if not Library.Network.Invoke or not Library.Network.Fire then
			LocalPlayer:Kick("Network Invoke/Fire was not found! Failed to bypass!")
		end
		
		hookfunction(debug.getupvalue(Library.Network.Invoke, 1), function(...) return true end)
		-- Currently we don't need to hook Fire, since both Invoke/Fire have the same upvalue, this may change in future.
		-- hookfunction(debug.getupvalue(Library.Network.Fire, 1), function(...) return true end)
		
		local originalPlay = Library.Audio.Play
		Library.Audio.Play = function(...) 
			if checkcaller() then
				local audioId, parent, pitch, volume, maxDistance, group, looped, timePosition = unpack({ ... })
				if type(audioId) == "table" then
					audioId = audioId[Random.new():NextInteger(1, #audioId)]
				end
				if not parent then
					warn("Parent cannot be nil", debug.traceback())
					return nil
				end
				if audioId == 0 then return nil end
				
				if type(audioId) == "number" or not string.find(audioId, "rbxassetid://", 1, true) then
					audioId = "rbxassetid://" .. audioId
				end
				if pitch and type(pitch) == "table" then
					pitch = Random.new():NextNumber(unpack(pitch))
				end
				if volume and type(volume) == "table" then
					volume = Random.new():NextNumber(unpack(volume))
				end
				if group then
					local soundGroup = game.SoundService:FindFirstChild(group) or nil
				else
					soundGroup = nil
				end
				if timePosition == nil then
					timePosition = 0
				else
					timePosition = timePosition
				end
				local isGargabe = false
				if not pcall(function() local _ = parent.Parent end) then
					local newParent = parent
					pcall(function()
						newParent = CFrame.new(newParent)
					end)
					parent = Instance.new("Part")
					parent.Anchored = true
					parent.CanCollide = false
					parent.CFrame = newParent
					parent.Size = Vector3.new()
					parent.Transparency = 1
					parent.Parent = workspace:WaitForChild("__DEBRIS")
					isGargabe = true
				end
				local sound = Instance.new("Sound")
				sound.SoundId = audioId
				sound.Name = "sound-" .. audioId
				sound.Pitch = pitch and 1
				sound.Volume = volume and 0.5
				sound.SoundGroup = soundGroup
				sound.Looped = looped and false
				sound.MaxDistance = maxDistance and 100
				sound.TimePosition = timePosition
				sound.RollOffMode = Enum.RollOffMode.Linear
				sound.Parent = parent
				if not require(game:GetService("ReplicatedStorage"):WaitForChild("Library"):WaitForChild("Client")).Settings.SoundsEnabled then
					sound:SetAttribute("CachedVolume", sound.Volume)
					sound.Volume = 0
				end
				sound:Play()
				getfenv(originalPlay).AddToGarbageCollection(sound, isGargabe)
				return sound
			end
			
			return originalPlay(...)
		end
	
	end)
	
	if not bypassSuccess then
		print(bypassError)
		LocalPlayer:Kick("Error while bypassing network, try again or wait for an update!")
		return
	end
	
	LocalPlayer.PlayerScripts:WaitForChild("Scripts", 10):WaitForChild("Game", 10):WaitForChild("Coins", 10)
	LocalPlayer.PlayerScripts:WaitForChild("Scripts", 10):WaitForChild("Game", 10):WaitForChild("Pets", 10)
	wait()
	-- local orbsScript = getsenv(game.Players.LocalPlayer.PlayerScripts.Scripts.Game:WaitForChild("Orbs", 10))
	-- local CollectOrb = orbsScript.Collect
	
	local GetRemoteFunction = debug.getupvalue(Library.Network.Invoke, 2)
		-- OrbList = debug.getupvalue(orbsScript.Collect, 1)
	local CoinsTable = debug.getupvalue(getsenv(LocalPlayer.PlayerScripts.Scripts.Game:WaitForChild("Coins", 10)).DestroyAllCoins, 1)
	local RenderedPets = debug.getupvalue(getsenv(LocalPlayer.PlayerScripts.Scripts.Game:WaitForChild("Pets", 10)).NetworkUpdate, 1)
	
	
	local IsHardcore = Library.Shared.IsHardcore

	local AllGameWorlds = {}
	for name, world in pairs(Library.Directory.Worlds) do 
		if name ~= "WIP" and name ~= "Trading Plaza" and not world.disabled and world.worldOrder and world.worldOrder ~= 0 then
			world.name = name
			table.insert(AllGameWorlds, world)
		end
	end
	
	table.sort(AllGameWorlds, function(a, b) 
		return a.worldOrder < b.worldOrder
	end)
	

	local WorldWithAreas = {}
	for areaName, area in pairs(Library.Directory.Areas) do 
		if area and area.world then
			local world = Library.Directory.Worlds[area.world]
			local containsSpawn = false
			
			if world and world.spawns then
				for spawnName, spawn in pairs(world.spawns) do 
					if spawn.settings and spawn.settings.area and spawn.settings.area == name then 
						containsSpawn = true 
						break 
					end
				end
			end
			
			if containsSpawn then
				if not WorldWithAreas[area.world] then 
					WorldWithAreas[area.world] = {}
				end

				table.insert(WorldWithAreas[area.world], area.name)
			end
		end
	end
	

	function GetAllAreasInWorld(world)
		-- local AllAreasInSelectedWorld = {}

		-- for name, area in pairs(Library.Directory.Areas) do
			-- local containsSpawn = false
			-- for spawnName, spawn in pairs(world.spawns) do 
				-- if spawn.settings and spawn.settings.area and spawn.settings.area == name then 
					-- containsSpawn = true 
					-- break 
				-- end
			-- end
			
			-- if area.world == world.name and containsSpawn then
				-- table.insert(AllAreasInSelectedWorld, name)
			-- end
		-- end

		-- table.sort(AllAreasInSelectedWorld, function(a, b)
			-- local areaA = Library.Directory.Areas[a]
			-- local areaB = Library.Directory.Areas[b]
			-- return areaA.id < areaB.id
		-- end)

		-- return AllAreasInSelectedWorld 
		return WorldWithAreas[world] or {}
	end
	
	--// AUTO COMPLETE game
	local AllGameAreas = {}
	
	for name, area in pairs(Library.Directory.Areas) do
		local world = Library.Directory.Worlds[area.world]
		if world and world.worldOrder and world.worldOrder > 0 then
			if not area.hidden and not area.isVIP then
				local containsArea = false
				if world.spawns then
					for i,v in pairs(world.spawns) do
						if v.settings and v.settings.area and v.settings.area == name then 
							containsArea = true 
							break 
						end
					end
				end
				
				if area.gate or containsArea then
					table.insert(AllGameAreas, name)
				end
			end
		end
	end
	

	
	table.sort(AllGameAreas, function(a, b)
		local areaA = Library.Directory.Areas[a]
		local areaB = Library.Directory.Areas[b]

		local worldA = Library.Directory.Worlds[areaA.world]
		if a == "Ice Tech" then 
			worldA = Library.Directory.Worlds["Fantasy"]
		end
		
		local worldB = Library.Directory.Worlds[areaB.world]
		if b == "Ice Tech" then 
			worldB = Library.Directory.Worlds["Fantasy"]
		end

		if worldA.worldOrder ~= worldB.worldOrder then
			return worldA.worldOrder < worldB.worldOrder
		end
		
		local currencyA = Library.Directory.Currency[worldA.mainCurrency]
		local currencyB = Library.Directory.Currency[worldB.mainCurrency]
		if currencyA.order ~= currencyB.order then
			return currencyA.order < currencyB.order
		end
		
		if not areaA.gate or not areaB.gate then
			return areaA.id < areaB.id
		end
		
		return areaA.gate.cost < areaB.gate.cost
	end)
	

	function GetCurrentAndNextArea()
		local cArea, nArea = "", ""

		
		for i, v in ipairs(AllGameAreas) do 
			if cArea == "" and Library.WorldCmds.HasArea(v) then
				local nxtArea = AllGameAreas[i + 1]
				if nxtArea and not Library.WorldCmds.HasArea(nxtArea) then 
					cArea = v
					nArea = nxtArea
					break
				elseif not nxtArea then
					cArea = v
					nArea = "COMPLETED"
				end
			end
		end
		
		
		return cArea, nArea
	end

	
	function CheckIfCanAffordArea(areaName)
		local saveData = Library.Save.Get()
		local area = Library.Directory.Areas[areaName]
		
		if not saveData then 
			return false 
		end
		
		if not area then return false end
		
		if not area.gate then 
			return true 
		end -- Area is free =)
		
		local gateCurrency = area.gate.currency
		local currency = saveData[gateCurrency]
		if IsHardcore then
			if gateCurrency ~= "Diamonds" then
				currency = saveData.HardcoreCurrency[gateCurrency]
			end
		end
		
		if currency and currency >= area.gate.cost then
			return true
		end
		
		return false
	end
	
	-- TODO: Implement huge webhook notifier 
	function RewardsRedeemed(rewards)

		for v, rewardBox in pairs(rewards) do 
			local reward, quantity = unpack(rewardBox)
			if Webhook_Huge and reward == "Huge Pet" then 
				local petId = quantity
				local petData = Library.Directory.Pets[petId]
				if petData then
					SendWebhook()
				end
			end
			print(quantity, reward)
		end
		
	end
	
	Library.Network.Fired("Rewards Redeemed"):Connect(function(rewards)
		RewardsRedeemed(rewards)
	end)
	
	Library.Signal.Fired("Rewards Redeemed"):Connect(function(rewards)
		RewardsRedeemed(rewards)
	end)

	local GetCoinsInstance = GetRemoteFunction("Get Coins")
	local OpenEggInstance = GetRemoteFunction("Buy Egg")
	-- print(OpenEggInstance, typeof(OpenEggInstance))
	local metatable = getrawmetatable(game)
	setreadonly(metatable, false)
	local oldNamecall = metatable.__namecall
	
		metatable.__namecall = function(self, ...)
			local InstanceMethod = getnamecallmethod()
			local args = {...}

			if InstanceMethod == "InvokeServer" then
				if self == OpenEggInstance then
					LastOpenEggId = args[1]
					LastOpenEggData = Library.Directory.Eggs[LastOpenEggId]
					LastHatchSetting = "Normal"
					
					if args[2] then 
						LastHatchSetting = "Triple"
					end
					
					if args[3] then 
						LastHatchSetting = "Octuple"
					end
					
					coroutine.wrap(function()
						while true do
							SaveCustomFlag("CurrentEgg", LastOpenEggId)
							wait()
							SaveCustomFlag("CurrentHatchSettings", LastHatchSetting)
							break
						end
					end)()
				end
			end
			
			return oldNamecall(self, ...)
		end
	
	setreadonly(metatable, true)
	
	-- local originalInvokeServer = OpenEggInstance.InvokeServer
	-- originalInvokeServer = hookfunction(OpenEggInstance.InvokeServer, newcclosure(function(...)
		-- local args = {...}
		-- print(args[1])
		-- -- if self == OpenEggInstance then
			-- LastOpenEggId = args[1]
			-- LastOpenEggData = Library.Directory.Eggs[LastOpenEggId]
			-- LastHatchSetting = "Normal"
			
			-- if args[2] then 
				-- LastHatchSetting = "Triple"
			-- end
			
			-- if args[3] then 
				-- LastHatchSetting = "Octuple"
			-- end
			
			-- coroutine.wrap(function()
				-- while true do
					-- SaveCustomFlag("CurrentEgg", LastOpenEggId)
					-- wait()
					-- SaveCustomFlag("CurrentHatchSettings", LastHatchSetting)
					-- break
				-- end
			-- end)()
		-- -- end

		-- return originalInvokeServer(...)
	-- end))
	

	
	local fastPets = false
	local Original_HasPower = Library.Shared.HasPower
	Library.Shared.HasPower = function(pet, powerName) 
		if fastPets and powerName == "Agility" then 
			return true, 3
		end
		return Original_HasPower(pet, powerName)
	end
	
	local Original_GetPowerDir = Library.Shared.GetPowerDir
	Library.Shared.GetPowerDir = function(powerName, tier) 
		if fastPets and powerName == "Agility" then 
			return  {
				title = "Agility III", 
				desc = "Pet moves 50% faster", 
				value = 20
			}
		end
		return Original_GetPowerDir(powerName, tier)
	end

	getgenv().SecureMode = true
	getgenv().DisableArrayfieldAutoLoad = true
	
	local Rayfield = nil
	if isfile("UI/ArrayField.lua") then
		Rayfield = loadstring(readfile("UI/ArrayField.lua"))()
	else
		Rayfield = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rafacasari/ArrayField/main/v2.lua"))()
	end
	
	-- local Rayfield = (isfile("UI/ArrayField.lua") and loadstring(readfile("UI/ArrayField.lua"))()) or loadstring(game:HttpGet("https://raw.githubusercontent.com/Rafacasari/ArrayField/main/v2.lua"))()
	assert(Rayfield, "Oopps! Rayfield has not been loaded. Maybe try re-joining?") 
	

	local Window = Rayfield:CreateWindow({
	   Name = "Pet Simulator GUI | by Rafa ",
	   LoadingTitle = SCRIPT_NAME .. " " .. SCRIPT_VERSION,
	   LoadingSubtitle = "by Rafa",
	   ConfigurationSaving = {
		  Enabled = true,
		  FolderName = "Rafa",
		  FileName = "PetSimulatorX_" .. tostring(LocalPlayer.UserId)
	   },
	   OldTabLayout = true
	})
	
	coroutine.wrap(function() 
		wait(0.5)
		if not isfile("Rafa/AcceptedTerms.txt") then 
			Window:Prompt({
				Title = 'Disclaimer',
				SubTitle = 'Misuse of this script may result in penalties!',
				Content = "I am not responsible for any harm caused by this tool, use at your own risk.",
				Actions = {
					
					Accept = {
						Name = "Ok",
						Callback = function()
							if not isfolder("Rafa") then makefolder("Rafa") end
							writefile("Rafa/AcceptedTerms.txt", "true")
						end,
						
					}
				}
			})
		end 
	
	end)()
	
	
	function AddCustomFlag(flagName, defaultValue, callback)
		if Rayfield and Rayfield.Flags and not Rayfield.Flags[flagName] then
			local newFlag = {
				CurrentValue = defaultValue
			}
			
			function newFlag:Set(newValue)
				Rayfield.Flags[flagName].CurrentValue = newValue
				
				callback(newValue)
			end
			
			Rayfield.Flags[flagName] = newFlag
		end
	end
	
	function SaveCustomFlag(flagName, value)
		if Rayfield and Rayfield.Flags and Rayfield.Flags[flagName] then
			pcall(function() 
				Rayfield.Flags[flagName]:Set(value)
				
				coroutine.wrap(function()
					Rayfield.SaveConfiguration()
				end)()
			end)
		end
	end
	
	
	
	Library.ChatMsg.New(string.format("Hello, %s! You're running %s %s", LocalPlayer.DisplayName, SCRIPT_NAME, SCRIPT_VERSION), Color3.fromRGB(175, 70, 245))
	
	--local mainTab = Window:CreateTab("Main", "12434808810")
	
	
	-- task.spawn(function() 
		-- while true do 
			-- stats:Set({Title = "Hello, " .. LocalPlayer.DisplayName, Content = string.format("There are some useful information:\nServer age: %s\n", Library.Functions.TimeString(workspace.DistributedGameTime, true))})
			-- task.wait(1)
		-- end
	-- end)
	
	LocalPlayer.PlayerScripts:WaitForChild("Scripts", 10):WaitForChild("Game", 10)
	
	
	local autoFarmTab = Window:CreateTab("Farm", "13075651575", true)
	local stats = autoFarmTab:CreateParagraph({Title = "Hello, <b><font color=\"#2B699F\">" .. LocalPlayer.DisplayName .. "</font></b>!", Content = "Thanks for using my script! - Rafa\nMake sure to join us at <b><font color=\"#2B699F\">discord.gg/MilkUp</font></b>"})
	local autoFarmSection = autoFarmTab:CreateSection("Auto Farm", false, false, "7785988164")
	local enableAutoFarm = false
	autoFarmTab:CreateToggle({
		Name = "Enable Auto-Farm",
		Info = 'Auto Farm will automatically destroy/farm coins for you, be aware of the risks of abusing it',
		Flag = "AutoFarm_Enabled",
		SectionParent = autoFarmSection,
		CurrentValue = false,
		Callback = function(Value) 
			enableAutoFarm = Value
		end
	})
	
	local AutoFarm_FastMode = false
	autoFarmTab:CreateToggle({
		Name = "Fast Mode (unlegit farm)",
		Flag = "AutoFarm_FastMode", 
		SectionParent = autoFarmSection,
		CurrentValue = false,
		Callback = function(Value) 
			AutoFarm_FastMode = Value
		end
	})
	
	local AutoFarm_FarmSpeed = 0.3
	autoFarmTab:CreateSlider({
	   Name = "Farm Speed",
	   Flag = "AutoFarm_FarmSpeed",
	   SectionParent = autoFarmSection,
	   Range = {0.05, 2},
	   Increment = 0.05,
	   Suffix = "Second(s)",
	   CurrentValue = 0.3,
	   Callback = function(Value)
			AutoFarm_FarmSpeed = Value
	   end,
	})
	
	local farmMaxDistance = 150
	autoFarmTab:CreateSlider({
	   Name = "Farm Max Distance",
	   Flag = "AutoFarm_MaxDistance",
	   SectionParent = autoFarmSection,
	   Range = {10, tonumber(Library.Settings.CoinGrabDistance) or 300},
	   Increment = 1,
	   Suffix = "Studs",
	   CurrentValue = 150,
	   Callback = function(Value)
			farmMaxDistance = Value
	   end,
	})
	
	local farmPreferences = autoFarmTab:CreateSection("Farm Priority", false, true)
	local farmFocusListText = autoFarmTab:CreateParagraph({Title = "Current Farming", Content = "Nothing"}, farmPreferences)

	local DefaultFarmFocusList = {
		"Fruits",
		"Highest Multiplier",
		"Diamonds",
		"Lowest Life",
		"Highest Life",
		"Nearest",
		"Longest"
	}
	
	function CalcMultiplier(coinBonus)
		if not coinBonus then return 0 end
		local totalMultiplier = 0	
		if coinBonus.l then
			
			for _, v in pairs(coinBonus.l) do
				pcall(function() 
					if v.m and tonumber(v.m) then
						totalMultiplier = totalMultiplier + v.m
					end
				end)
			end
			
		end
		return totalMultiplier
	end
	

	local FarmFocusList = {}
	local FarmFocusListButtons = {}
	
	
	function UpdateFarmFocusUI()
		local farmingText = ""
		if not FarmFocusList or #FarmFocusList < 1 then
			farmingText = "There is nothing on your priority list!\nAdd some by <b>clicking on buttons</b>!"
		else
			for i, v in ipairs(FarmFocusList) do 
				farmingText = farmingText .. (farmingText == "" and "This is your priority list to farm.\nYou can <b>modify it by clicking on buttons</b>!\n\n" or "\n") .. i .. "° - <b>" .. tostring(v) .. "</b>"
			end
		end
		
		farmFocusListText:Set({Title = "Current Farming", Content = farmingText})
		
		for _, button in pairs(FarmFocusListButtons) do 
			local buttonName = button.Button.Name
			if buttonName then 
				if table.find(FarmFocusList, buttonName) then
					button:Set(nil, "Remove")
				else
					button:Set(nil, "Add")
				end
			end
		end
	end
	

	
	for _, focusName in pairs(DefaultFarmFocusList) do 
		local function UpdateButton(text, interact)
			if not FarmFocusListButtons[focusName] then return end
			while true do
				wait()
				FarmFocusListButtons[focusName]:Set(text, interact)
				break
			end
		end
		
		FarmFocusListButtons[focusName] = autoFarmTab:CreateButton({
			Name = focusName,
			SectionParent = farmPreferences,
			Interact = table.find(FarmFocusList, focusName) and "Remove" or "Add",
			CurrentValue = false,
			Callback = function(Value) 
				if table.find(FarmFocusList, focusName) then
					table.remove(FarmFocusList, table.find(FarmFocusList, focusName))
					-- UpdateButton(nil, "Add")
				else
					table.insert(FarmFocusList, focusName)
					-- UpdateButton(nil, "Remove")
				end
				
				
				
				coroutine.wrap(function() 
					while true do 
						wait()
						UpdateFarmFocusUI()
						break
					end
				end)
				
				SaveCustomFlag("AutoFarm_FarmFocusList", FarmFocusList)
			end
		})
		
		-- FarmFocusListButtons[focusName]:Disable("Coming soon")
	end	
	
	
	
	AddCustomFlag("AutoFarm_FarmFocusList", {}, function(newTable)
		FarmFocusList = newTable
		
		local hasChanges = false
		
		for i, v in pairs(FarmFocusList) do 
			if not table.find(DefaultFarmFocusList, v) then
				table.remove(FarmFocusList, i)
				hasChanges = true
			end
		end
		
		
		
		if hasChanges then 
			coroutine.wrap(function() 
				wait()
				SaveCustomFlag("AutoFarm_FarmFocusList", FarmFocusList)
			end)
		end
		
		UpdateFarmFocusUI()
	end)

	
	local farmUtilities = autoFarmTab:CreateSection("Farm Utilities", false, true)
	local FarmUtilities_CollectDrops = false
	local FarmUtilities_CurrentOrbs = {} 
	autoFarmTab:CreateToggle({
		Name = "Collect Drops",
		SectionParent = farmUtilities,
		CurrentValue = false,
		Flag = "FarmUtilities_CollectDrops", 
		Callback = function(Value) 
			FarmUtilities_CollectDrops = Value
			
			if Value then
				table.clear(FarmUtilities_CurrentOrbs)
				FarmUtilities_CurrentOrbs = {}
				CollectAllOrbs()
				CollectAllLootbags()
			end
			
			if not FarmUtilities_CollectDrops then return end
			task.spawn(function() 
				
				while FarmUtilities_CollectDrops do
					wait(0.05)
					if not FarmUtilities_CollectDrops then break end
					if FarmUtilities_CurrentOrbs and #FarmUtilities_CurrentOrbs > 0 then
						Library.Network.Fire("Claim Orbs", FarmUtilities_CurrentOrbs)
						table.clear(FarmUtilities_CurrentOrbs)
						FarmUtilities_CurrentOrbs = {}
					end
				end
				
			end)
		end
	})

	function CollectAllOrbs()			
		pcall(function() 
			
			local OrbsToCollect = {}
			for orbId, orb in pairs(Library.Things:FindFirstChild("Orbs"):GetChildren()) do
				if not FarmUtilities_CollectDrops then break end
				if orbId and orb then
					table.insert(OrbsToCollect, orb.Name)
				end
			end
			
			if OrbsToCollect and #OrbsToCollect > 0 and FarmUtilities_CollectDrops then
				Library.Network.Fire("Claim Orbs", OrbsToCollect)
			end
		end)
	end
	
	function CollectAllLootbags()			
		pcall(function() 
			for _, lootbag in pairs(Library.Things:FindFirstChild("Lootbags"):GetChildren()) do
				if not FarmUtilities_CollectDrops then break end

				if lootbag and not lootbag:GetAttribute("Collected") then
					Library.Network.Fire("Collect Lootbag", lootbag.Name, HumanoidRootPart.Position + Vector3.new(math.random(-0.05, 0.05), math.random(-0.05, 0.05), math.random(-0.05, 0.05)))
					wait(0.03)
				end
			end
		end)
	end
	
	Library.Things:FindFirstChild("Lootbags").ChildAdded:Connect(function(child) 
		wait()
		if FarmUtilities_CollectDrops and child then 
			Library.Network.Fire("Collect Lootbag", child.Name, HumanoidRootPart.Position + Vector3.new(math.random(-0.05, 0.05), math.random(-0.05, 0.05), math.random(-0.05, 0.05)))
		end
	end)
	
	Library.Things:FindFirstChild("Orbs").ChildAdded:Connect(function(child) 
		task.wait()
		if FarmUtilities_CollectDrops and child then
			table.insert(FarmUtilities_CurrentOrbs, child.name)
		end
	end)
		
	autoFarmTab:CreateToggle({
		Name = "Fast Pets",
		SectionParent = farmUtilities,
		CurrentValue = false,
		Flag = "FarmUtilities_FastPets", 
		Callback = function(Value) 
			fastPets = Value
		end
	})
	
	local instantFall = false
	autoFarmTab:CreateToggle({
		Name = "Instant Fall Coins",
		SectionParent = farmUtilities,
		CurrentValue = false,
		Flag = "FarmUtilities_InstantFallCoins", 
		Callback = function(Value) 
			instantFall = Value
		end
	})
	
	local WorldCoins = Library.Things:WaitForChild("Coins")

	WorldCoins.ChildAdded:Connect(function(ch)
		if instantFall then 
			ch:SetAttribute("HasLanded", true)
			ch:SetAttribute("IsFalling", false)
			
			local coin = ch:WaitForChild("Coin")
			coin:SetAttribute("InstantLand", true)
		end
	end)

	local areaToFarmSection = autoFarmTab:CreateSection("Areas to Farm", false, true)
	for w, world in ipairs(AllGameWorlds) do
		coroutine.wrap(function()
			if world and world.name then
				local containsSpawns = false
				if world.spawns then
					for i,v in pairs(world.spawns) do containsSpawns = true break end
				end
				
				if containsSpawns then
					local worldDropdown = autoFarmTab:CreateDropdown({
						Name = world.name,
						MultiSelection = true,
						CurrentOption = {},
						Flag = "SelectedAreas_" .. world.name,
						Icon = Library.Directory.Currency[world.mainCurrency].tinyImage,
						Options = GetAllAreasInWorld(world),
						SectionParent = areaToFarmSection,
						Callback = function(Option)
							
						end
					})
					worldDropdown:Lock("Coming soon!", true)
				end
			end
		end)()
	end
	
	function GetCoinsInArea(area)
		local coinsInArea = {}

		
		for _, coin in pairs(WorldCoins:GetChildren()) do 
			if coin and coin:GetAttribute("Area") and coin:GetAttribute("Area") == area then 
				table.insert(coinsInArea, coin)
			end
		end
		
		return coinsInArea
	end
	

	
	function SortCoinsByPriority(coins)
		local sortedCoins = {}
		
		
		CoinsTable = debug.getupvalue(getsenv(LocalPlayer.PlayerScripts.Scripts.Game.Coins).DestroyAllCoins, 1)
		
		for _, coin in pairs(coins) do
			local coinMesh = coin:FindFirstChild("Coin")
			local mag = (HumanoidRootPart.Position - coinMesh.Position).magnitude	
			if CoinsTable[coin.Name] and mag <= math.max(math.min(farmMaxDistance, Library.Settings.CoinGrabDistance), 10) and Library.WorldCmds.HasArea(coin:GetAttribute("Area")) then
				table.insert(sortedCoins, coin)
			end
		end
	
	
		table.sort(sortedCoins, function(coinA, coinB)
			local a = CoinsTable[coinA.Name]
			local b = CoinsTable[coinB.Name]
			
			local APriority = GetCoinLowestPriority(a, b)
			local BPriority = GetCoinLowestPriority(b, a)
			
			return APriority < BPriority 
		end)
			
		
		
		return sortedCoins
	end
	
	function SortCoinsByPriorityFastMode(coins)
		local sortedCoins = {}
		
		
		for coinId, coin in pairs(coins) do
			coin.coinId = coinId
			local mag = (HumanoidRootPart.Position - coin.p).magnitude	
			if mag <= math.max(math.min(farmMaxDistance, Library.Settings.CoinGrabDistance), 10) and Library.WorldCmds.HasArea(coin.a) then
				table.insert(sortedCoins, coin)
			end
		end
	
		table.sort(sortedCoins, function(a, b)
			local APriority = GetCoinLowestPriority(a, b)
			local BPriority = GetCoinLowestPriority(b, a)
			
			return APriority < BPriority 
		end)
		
		
		return sortedCoins
	end
	
	function GetCoinLowestPriority(mainCoin, coinToCompare)
		local coin = Library.Directory.Coins[mainCoin.n]
		local coinCompare = Library.Directory.Coins[coinToCompare.n]
		
		local aMagnitude = (HumanoidRootPart.Position - mainCoin.p).magnitude
		local bMagnitude = (HumanoidRootPart.Position - coinToCompare.p).magnitude
		
		local coinIsFruit = coin.breakSound == "fruit"
		local coinIsDiamond = coin.currencyType == "Diamonds"
		local coinIsEaster = coin.currencyType == "Easter Coins"
		
		local coinHighestMultiplier = CalcMultiplier(mainCoin.b) > CalcMultiplier(coinToCompare.b)
		
		local coinPriority = 9999999

		
		for priority, priorityName in ipairs(FarmFocusList) do 
			if priorityName == "Fruits" and coinIsFruit then
				mainCoin.priority = priorityName 
				coinPriority = priority
				break
			elseif priorityName == "Highest Multiplier" and coinHighestMultiplier then
				mainCoin.priority = priorityName
				coinPriority = priority
				break
			elseif priorityName == "Diamonds" and coinIsDiamond then
				mainCoin.priority = priorityName
				coinPriority = priority
				break
			elseif priorityName == "Lowest Life" and coin.health < coinCompare.health then
				mainCoin.priority = priorityName 
				coinPriority = priority
				break
			elseif priorityName == "Highest Life" and coin.health > coinCompare.health then
				mainCoin.priority = priorityName 
				coinPriority = priority
				break
			elseif priorityName == "Nearest" and aMagnitude < bMagnitude then
				mainCoin.priority = priorityName
				coinPriority = priority
				break
			elseif priorityName == "Longest" and aMagnitude > bMagnitude then
				mainCoin.priority = priorityName
				coinPriority = priority
				break
			elseif priorityName == "Easter Coins" and coinIsEaster then
				mainCoin.priority = priorityName
				coinPriority = priority
				break
			end
		end
		
		
		return coinPriority
	end
	
	local petsCurrentlyFarming = {}
	

	coroutine.wrap(function()
		while true do 
				if enableAutoFarm and not ScriptIsCurrentlyBusy then 
					CoinsTable = debug.getupvalue(getsenv(LocalPlayer.PlayerScripts.Scripts.Game.Coins).DestroyAllCoins, 1)
					RenderedPets = debug.getupvalue(getsenv(LocalPlayer.PlayerScripts.Scripts.Game.Pets).NetworkUpdate, 1)
					
					if AutoFarm_FastMode then 

						local foundCoins = SortCoinsByPriorityFastMode(CoinsTable)
						local equippedPets = Library.PetCmds.GetEquipped()
						if equippedPets and #equippedPets > 0 and #foundCoins > 0 then
							for _, pet in pairs(equippedPets) do
								local selectedCoin = foundCoins[1]
								task.spawn(function()
									Library.Network.Invoke("Join Coin", selectedCoin.coinId, {pet.uid}) 
									Library.Network.Fire("Farm Coin", selectedCoin.coinId, pet.uid)
									
								end)
								
								table.remove(foundCoins, 1)
								task.wait(AutoFarm_FarmSpeed)
							end
						end
					else
						local equippedPets = Library.PetCmds.GetEquipped()
						local foundCoins = {}

						for _, ch in ipairs(SortCoinsByPriority(WorldCoins:GetChildren())) do
							local containsMyPet = false
							local coin = CoinsTable[ch.Name]
							local coinMesh = ch:FindFirstChild("Coin")
							local mag = (HumanoidRootPart.Position - coinMesh.Position).magnitude	
			
							for _, pet in pairs(equippedPets) do
								if coin and coin.pets and table.find(coin.pets, pet.uid) then 
									containsMyPet = true
									break
								end
							end
							
							if not containsMyPet and mag <= math.max(math.min(farmMaxDistance, Library.Settings.CoinGrabDistance), 10) and Library.WorldCmds.HasArea(ch:GetAttribute("Area")) then
								table.insert(foundCoins, ch)
							end
						end
						
						
						for i, pet in pairs(RenderedPets) do 
							if ScriptIsCurrentlyBusy or not enableAutoFarm or #foundCoins <= 0 then break end
							if pet.spawned.owner == LocalPlayer and not pet.farming then
								local coin = foundCoins[1]
								if coin then 
									if not coin:FindFirstChild("Pets") then
										local petsFolder = Instance.new("Folder")
										petsFolder.Name = "Pets"
										petsFolder.Parent = coin
									end
									
									-- Legit Mode
									Library.Signal.Fire("Select Coin", coin, pet)

									table.remove(foundCoins, 1)
									wait(AutoFarm_FarmSpeed)
								end

							end
							
						end
					end
				end
			wait(0.1)
		end	
	end)()
	
	
	
	function IsEggUnlocked(eggId)
		local egg = Library.Directory.Eggs[eggId]
		local saveData = Library.Save.Get()
		if egg.areaRequired then
			if not Library.WorldCmds.HasArea(egg.area) then
				return false
			end
		end
		
		if egg.eggRequired ~= "" then
			if egg.eggRequired ~= eggId then
				if not IsEggUnlocked(egg.eggRequired) then
					return false
				end
			end
		end
		
		if egg.eggRequiredOpenAmount > 0 then
			if egg.eggRequired ~= "" then
				local eggsHatched = (IsHardcore and saveData.Hardcore.EggsOpened or saveData.EggsOpened)[egg.eggRequired]
				if eggsHatched then
					if eggsHatched < egg.eggRequiredOpenAmount then
						return false
					end
				else
					return false
				end
			end
		end
		
		if eggId == "Dominus Egg" then	
			if IsHardcore and not saveData.Hardcore.OwnsDominusGate then return false end
			if not IsHardcore and not saveData.OwnsDominusGate then return false end
		elseif eggId == "Hacker Egg" or eggId == "Hacker Golden Egg" then
			if IsHardcore and not saveData.Hardcore.OwnsHackerGate then return false end
			if not IsHardcore and not saveData.OwnsHackerGate then return false end
		end
		
		return true
	end
	
	function HatchEgg(eggId, tripleHatch, octupleHatch, teleportToEgg) 
		if ScriptIsCurrentlyBusy then return false, "Script is currently busy!" end
		
		if not eggId or eggId == "None" then return false, "No egg provided!" end
		local eggToHatch = Library.Directory.Eggs[eggId]
		if not eggToHatch then return false, "Didn't found this egg!" end
		
		if tripleHatch == nil then tripleHatch = false end	
		if octupleHatch == nil then  octupleHatch = false end
		
		if not eggToHatch.hatchable or eggToHatch.disabled then return false, "This is egg is not available!" end
		if not IsEggUnlocked(eggId) then return false, "This egg is not unlocked yet!" end
		
		local eggArea = Library.Directory.Areas[eggToHatch.area]
		if eggArea then
			if teleportToEgg and Library.WorldCmds.Get() ~= eggArea.world then 
				Library.WorldCmds.Load(eggArea.world)
				wait(0.25)
			elseif not teleportToEgg and Library.WorldCmds.Get() ~= eggArea.world then return false, "You're not in the right world!" end
			
			local mapEgg = nil
			
			for i,v in pairs(Library.WorldCmds.GetAllEggs()) do 
				if v:GetAttribute("ID") and v:GetAttribute("ID") == eggId then 
					mapEgg = v
					break
				end
			end
			
			if not mapEgg then return false, "Didn't found the egg in map!" end
			
			local isNearEgg = Library.LocalPlayer:DistanceFromCharacter(mapEgg.PrimaryPart.CFrame.p) <= 30
			
			if teleportToEgg and not isNearEgg then 
				HumanoidRootPart.CFrame = CFrame.new(mapEgg.PrimaryPart.CFrame.p) + (mapEgg.PrimaryPart.CFrame.RightVector * 10)
				wait(0.25)
			elseif not teleportToEgg and not isNearEgg then return false, "You're too far from the egg!" end
		end

		return Library.Network.Invoke("Buy Egg", eggId, tripleHatch, octupleHatch)
	end
	
	-- local easterEventTab = Window:CreateTab("Easter Event", "13075572975", true)
	-- local easterEventSection = easterEventTab:CreateSection("Easter Event", true)
	-- easterEventTab:CreateButton({
		-- Name = "Teleport to Easter Isle",
		-- Callback = function()
			-- if Library.WorldCmds.Get() ~= "Spawn" then 
				-- if not Library.WorldCmds.Load("Spawn") then return end
			-- end
			-- wait(0.25)
			
			-- local areaTeleport = Library.WorldCmds.GetMap().Teleports:FindFirstChild("Easter")
			-- if areaTeleport then 
				-- Character:PivotTo(areaTeleport.CFrame + areaTeleport.CFrame.UpVector * (Humanoid.HipHeight + HumanoidRootPart.Size.Y / 2))
			-- end	
		-- end
	-- })
	
	-- local Easter_AutoEggHunt = false
	-- local isEggHuntHappening = false
	-- local eggHuntTimeSeed = 0
	-- local lastEggHuntSeed = 0
	
	-- task.spawn(function() 
		-- task.wait(1)
		-- local checkEggHuntSeed = Library.Network.Invoke("Easter Egg Hunt: Get Time Seed")
		-- if checkEggHuntSeed and checkEggHuntSeed and checkEggHuntSeed > 0 and os.time() >= checkEggHuntSeed and os.time() < checkEggHuntSeed + (60 * 60) then 
			-- isEggHuntHappening = true
			-- eggHuntTimeSeed = checkEggHuntSeed
			-- lastEggHuntSeed = 0
		-- end
	-- end)
	
	
	-- local easterEventAutoEggHunt = easterEventTab:CreateToggle({
		-- Name = "Auto Egg Hunt",
		-- CurrentValue = false,
		-- Flag = "Easter_AutoEggHunt",
		-- Callback = function(value) 
			-- Easter_AutoEggHunt = value
			-- lastEggHuntSeed = 0
			
			-- if not value then return end
			
			-- local checkEggHuntSeed = Library.Network.Invoke("Easter Egg Hunt: Get Time Seed")
			-- if checkEggHuntSeed and checkEggHuntSeed and checkEggHuntSeed > 0 and os.time() >= checkEggHuntSeed and os.time() < checkEggHuntSeed + (60 * 60) then 
				-- isEggHuntHappening = true
				-- eggHuntTimeSeed = checkEggHuntSeed
				-- lastEggHuntSeed = 0
			-- end
			
			-- wait()
			-- task.spawn(function() 
				-- while Easter_AutoEggHunt do
					-- local saveData = Library.Save.Get()
					-- if isEggHuntHappening and eggHuntTimeSeed > 0 and lastEggHuntSeed == 0 then
						-- if not (saveData and saveData.Easter2023.FoundEggs and saveData.Easter2023.FoundEggs[tostring(eggHuntTimeSeed)] and #saveData.Easter2023.FoundEggs[tostring(eggHuntTimeSeed)] >= 100) then		
							-- if ScriptIsCurrentlyBusy then 
								-- while ScriptIsCurrentlyBusy do wait() end
								-- ScriptIsCurrentlyBusy = true
								-- wait(1)
							-- end
							
							-- ScriptIsCurrentlyBusy = true
							-- CurrentWorld = Library.WorldCmds.Get()		
							-- CurrentPosition = HumanoidRootPart.CFrame
			
							-- for i, world in ipairs(AllGameWorlds) do
								-- if not Easter_AutoEggHunt then break end
								-- if not world.requiredArea or Library.WorldCmds.HasArea(world.requiredArea) then
									
									-- if Library.WorldCmds.Get() ~= world.name then
										-- Library.WorldCmds.Load(world.name)
									-- end
									
									-- for i,v in pairs(Library.WorldCmds.GetMap():WaitForChild("EasterEggs"):GetChildren()) do
										-- if not Easter_AutoEggHunt then break end
										-- if v:GetAttribute("Enabled") then	
											-- task.spawn(function()
												-- local success, errorMessage = Library.Network.Invoke("Easter Egg Hunt: Claim", v.Name, (v:GetAttribute("TextureIDX")))
												-- if not success then print(errorMessage) end
											-- end)
											-- wait(0.05)
										-- end
										
									-- end
								-- end
							-- end
							
							-- wait(5)
							-- TeleportBack()
							-- wait(1)
							-- ScriptIsCurrentlyBusy = false
						-- end
						-- lastEggHuntSeed = eggHuntTimeSeed
					-- end
					
					-- wait(5)
				-- end
			-- end)
		-- end
	-- })
	
	
	-- Library.Network.Fired("Easter Egg Hunt: End"):Connect(function()
		-- isEggHuntHappening = false
		-- eggHuntTimeSeed = 0
		-- lastEggHuntSeed = 0
	-- end)
	
	-- Library.Network.Fired("Easter Egg Hunt: Start"):Connect(function(eggHuntData)
		-- isEggHuntHappening = true
		-- eggHuntTimeSeed = Library.Network.Invoke("Easter Egg Hunt: Get Time Seed")
		-- lastEggHuntSeed = 0
	-- end)


	
	
	local eggTab = Window:CreateTab("Eggs", "13075637275", true)
	local hatchingSection = eggTab:CreateSection("Egg Hatching", false)
	local eggInfo = eggTab:CreateParagraph({Title = "Information", Content = "Buy some egg in-game and it will be automatically selected!\nSelected Egg: %s\nMode: %s\nQuantity Hatched: %s\nQuantity Remaining: %s\n25x Insane Luck: %s\n\n\n\naaa"}, hatchingSection)
	
	local LastOpenEggId = "None"
	AddCustomFlag("CurrentEgg", "None", function(newValue) 
		LastOpenEggId = newValue
	end)
	
	local LastOpenEggData = nil
	local LastHatchSetting = "Normal"
	AddCustomFlag("CurrentHatchSettings", "Normal", function(newValue) 
		LastHatchSetting = newValue
	end)
	
	local EnableAutoHatch = false
	eggTab:CreateToggle({
		Name = "Auto Hatch",
		Flag = "AutoHatch_Enabled",
		SectionParent = hatchingSection,
		Callback = function(Value) 
			EnableAutoHatch = Value
			if EnableAutoHatch then 
				coroutine.wrap(function() 
					while EnableAutoHatch do 
						wait(math.random(3, 3.1))
						if not EnableAutoHatch then break end
						local tripleHatch = false
						local octupleHatch = false
						if LastHatchSetting == "Triple" then tripleHatch = true end
						if LastHatchSetting == "Octuple" then octupleHatch = true end
						--print("Trying to hatch: ", LastOpenEggId, tripleHatch, octupleHatch)
						local successHatch, errorHatch = HatchEgg(LastOpenEggId, tripleHatch, octupleHatch, true)
						if not successHatch then print(errorHatch or "Opss, failed to hatch!") end
					end
				end)()
			end
		end
	})
	
	local Original_OpenEgg = nil
	eggTab:CreateToggle({
		Name = "Skip Egg Animation", 
		Flag = "AutoFarm_SkipEggAnimation",
		SectionParent = hatchingSection,
		Callback = function(Value) 
			if Value then SkipEggAnimation() else RestoreEggAnimation() end
		end
	})
		

	local OpenEggsScript = getsenv(LocalPlayer.PlayerScripts.Scripts.Game:WaitForChild("Open Eggs", 10))
	
	function SkipEggAnimation()
		if not Original_OpenEgg then
			Original_OpenEgg = OpenEggsScript.OpenEgg
		end
		
		OpenEggsScript.OpenEgg = function()
			return true
		end
	end

	function RestoreEggAnimation()
		if not Original_OpenEgg then return end
		OpenEggsScript.OpenEgg = Original_OpenEgg
	end
	
	function UpdateEggInfo()
		local playerData = Library.Save.Get()
		local playerEggsOpened = playerData["EggsOpened"]
		local serverBoosts = Library.ServerBoosts.GetActiveBoosts()
		
		if eggInfo then
			local selectedEgg = LastOpenEggId or "None" 			
			local selectedSetting = LastHatchSetting or "Normal"
			local eggsOpened = Library.Functions.Commas(playerEggsOpened and playerEggsOpened[LastOpenEggId] and playerEggsOpened[LastOpenEggId] or 0)
			local eggsRemaining = Library.Functions.Commas(Library.Directory.Eggs[selectedEgg] and math.floor(playerData[Library.Directory.Eggs[selectedEgg].currency] / Library.Directory.Eggs[selectedEgg].cost) > 0 and math.floor(playerData[Library.Directory.Eggs[selectedEgg].currency] / Library.Directory.Eggs[selectedEgg].cost) or 0)
			local insaneLucky = serverBoosts and serverBoosts["Insane Luck"] and tostring(serverBoosts["Insane Luck"].totalTimeLeft) .. "s" or "Inactive" 
			eggInfo:Set({Title = "Information", Content = string.format("Buy some egg in-game and it will be automatically selected!\n\n<b>Selected Egg:</b> %s\n<b>Mode:</b> %s\n<b>Quantity Hatched:</b> %s\n<b>Quantity Remaining:</b> %s\n<b>25x Insane Luck:</b> %s", selectedEgg, selectedSetting, eggsOpened, eggsRemaining, insaneLucky)})
		end
	end	
	
	task.spawn(function() 
		while true do 
			UpdateEggInfo()
			task.wait()
		end
	end)
	
	local automationTab = Window:CreateTab("Automation", "13075622619", true)
		
	local automaticFunctionsSection = automationTab:CreateSection("Automatic Functions", false)
	local enableAutoDaycare = false
	local autodaycareButton = automationTab:CreateToggle({
		Name = "Auto Daycare",
		CurrentValue = false,
		Flag = "Automation_AutoDaycare",
		SectionParent = automaticFunctionsSection,
		Callback = function(Value) 
			enableAutoDaycare = Value
			
			if Value then 
				CreateReminder()
			end
		end
	})
	
	local Automations_AutoGameComplete = false
	local autoCompleteGameToggle = automationTab:CreateToggle({
		Name = "Auto Complete Game",
		Flag = "Automation_AutoCompleteGame",
		CurrentValue = false,
		SectionParent = automaticFunctionsSection,
		Callback = function(Value) 
			
			if Value then 
				local currentAreaName, nextAreaName = GetCurrentAndNextArea()
				if nextAreaName ~= "COMPLETED" then 
					local areaToTeleport = Library.Directory.Areas[currentAreaName]
					if areaToTeleport and areaToTeleport.world then
						if Library.WorldCmds.Get() ~= areaToTeleport.world then 
							Library.WorldCmds.Load(areaToTeleport.world)
						end
						wait(0.25)
			
						local areaTeleport = Library.WorldCmds.GetMap().Teleports:FindFirstChild(currentAreaName)
						if areaTeleport then 
							Library.Signal.Fire("Teleporting")
							task.wait(0.25)
							Character:PivotTo(areaTeleport.CFrame + areaTeleport.CFrame.UpVector * (Humanoid.HipHeight + HumanoidRootPart.Size.Y / 2))
							Library.Network.Fire("Performed Teleport", currentAreaName)
							task.wait(0.25)
						end	
					end
				else
					Value = false
					Rayfield.Flags["Automation_AutoCompleteGame"]:Set(false)
				end
			-- CHECK FOR CURRENT AREA AND TELEPORT TO IT
			end
			
			Automations_AutoGameComplete = Value
			
		end
	})
	local _, nextAreaCheck = GetCurrentAndNextArea() 
	if nextAreaCheck == "COMPLETED" then 
		autoCompleteGameToggle:Lock("No areas to unlock! 🎉", true)
	end

	local bankIndexSection = automationTab:CreateSection("Bank Index", false, false, "13080063246")
	automationTab:CreateParagraph({ Title = "What is this?", Content = "Some people <font color=\"#2B699F\">store pets in a bank to complete the pet collection</font> on alt accounts.\n<b>This feature should help on that process, it will automatically do:</b>\n- <font color=\"#2B699F\"><b>Check non-indexed pets on current account</b></font>\n- <font color=\"#2B699F\"><b>Take pets from the bank</b></font>\n- <font color=\"#2B699F\"><b>Put back on the bank after indexed</b></font>" }, bankIndexSection)
	
	local BankIndex_Debounce = false
	local BankIndex_InProgress = false
	local BankIndex_OwnerUsername = ""
	
	local Input = automationTab:CreateInput({
	   Name = "Bank Owner",
	   Info = "Owner of the bank", -- Speaks for itself, Remove if none.
	   PlaceholderText = "CoolUsername69",
	   Flag = "BankIndex_OwnerUsername",
	   SectionParent = bankIndexSection,
	   OnEnter = false, -- Will callback only if the user pressed ENTER while the box is focused.
	   RemoveTextAfterFocusLost = false,
	   Callback = function(Text)
			BankIndex_OwnerUsername = Text
	   end,
	})
	
	local bankIndexInfo = automationTab:CreateParagraph({
			Title = "Idling",
			Content = "Not doing anything yet..."
		}, bankIndexSection)
	
	local startBankIndex = nil
	
	function BankMessage(message)
		if not startBankIndex then return end
		coroutine.wrap(function() 
			while true do
				wait()
				startBankIndex:Set(nil, message)
				break
			end
		end)()
	end
			
	function BankError(errorMessage)
		pcall(function() 
			bankIndexInfo:Set({
				Title = "Idling",
				Content = "Not doing anything yet..."
			})
		end)
		BankMessage(errorMessage)
		print("Error on Bank Index: " .. errorMessage)
		wait(3)
		BankMessage("")
	end

	startBankIndex = automationTab:CreateButton({
		Name = "Start Indexing",
		CurrentValue = false,
		Interact = "",
		SectionParent = bankIndexSection,
		Callback = function(Value)

			if BankIndex_Debounce then return end
			
			if not BankIndex_InProgress then
				BankIndex_Debounce = true
				coroutine.wrap(function() 
					wait(0.3)
					BankIndex_Debounce = false
				end)()
			end
			
			-- Start bank functions
			if BankIndex_InProgress then 
				-- Cancel process
				BankIndex_Debounce = true
				BankIndex_InProgress = false
				BankMessage(nil, "")
				coroutine.wrap(function() 
					while true do
						wait()
						startBankIndex:Set("Waiting deposit to stop...", nil)
						break
					end
				end)()
			else
				-- Start process
				local SaveData = Library.Save.Get()
				if not SaveData or not SaveData.Collection then 
					BankError("Failed to get data!")
					return
				end
				
				if Library.WorldCmds.Get() ~= "Spawn" then
					if not Library.WorldCmds.Load("Spawn") then return end
					wait(1)
				end

				HumanoidRootPart.CFrame = Library.WorldCmds.GetMap().Interactive.Bank.Pad.CFrame + Vector3.new(0, 3, 0) 
				HumanoidRootPart.CFrame = HumanoidRootPart.CFrame + (HumanoidRootPart.CFrame.LookVector * 15)
				
				wait(0.5)
				
				local BankUID = nil

				BankMessage(nil, "Getting UserID")
				local success, result = pcall(function() return Players:GetUserIdFromNameAsync(BankIndex_OwnerUsername) end)
				if not success then 
					BankError("User not found!")
					print(result)
					return
				end
				
				ownerId = result
				if not ownerId or not tonumber(ownerId) then
					BankError("Can't get UserID")
					return
				end
				
				local myBanks = Library.Network.Invoke("Get My Banks")
				if not myBanks then 
					BankError("Bank is on cooldown!")
					return 
				end 
				
				for _, bank in pairs(myBanks) do 
					if bank.Owner == tonumber(ownerId) then 
						BankUID = bank.BUID
						break
					end
				end 
				

				if not BankUID then BankError("Bank was not found!") return end
				
				-- Get missing collection pets
				local allCollectablePets = Library.Shared.GetAllCollectablePets()
				local remainingPets = {}
				
				for i, pet in pairs(allCollectablePets) do 
					local petId = pet.petId
					local isGolden = pet.isGolden
					local isRainbow = pet.isRainbow
					local isDarkMatter = pet.isDarkMatter
					
					local petType = 1
					if isGolden then
						petType = 2
					elseif isRainbow then
						petType = 3
					elseif isDarkMatter then
						petType = 4
					end
								
					local isUnlocked = Library.Functions.SearchArray(SaveData.Collection, tostring(petId) .. "-" .. tostring(petType))
					if not isUnlocked then
						remainingPets[petId] = true
					end
				end
				
				
				local Bank = Library.Network.Invoke("Get Bank", BankUID) 
				if not Bank then BankError("Bank was not found!") return end

				local BankPets = Bank.Storage.Pets

				
				local petsAvailableOnBank = {}
				for _, pet in pairs(BankPets) do 
					local petId = pet.id
					local isGolden = pet.g
					local isRainbow = pet.r
					local isDarkMatter = pet.dm
					
					local petType = 1
					if isGolden then petType = 2
					elseif isRainbow then petType = 3
					elseif isDarkMatter then petType = 4 end
					
					local isUnlocked = Library.Functions.SearchArray(SaveData.Collection, tostring(petId) .. "-" .. tostring(petType))
					
					local petData = Library.Directory.Pets[petId]
					if petData and (petData.titanic or petData.huge or petData.rarity == "Exclusive" or petData.rarity == "Event") then petType = 5 end -- Huges/Exclusives/Event don't need to be indexed more than 1 time
					
					local petIdentifer = tostring(petId) .. "-" .. tostring(petType)
					-- Pet is not unlocked and not on our table, put they on list!
					if remainingPets[petId] and not petsAvailableOnBank[petIdentifer] and not isUnlocked then petsAvailableOnBank[petIdentifer] = pet end
				end


				local function UpdateInfo()
					local petsAvailableOnBankCount = 0
					for _, pet in pairs(petsAvailableOnBank) do
						if pet then 
							petsAvailableOnBankCount = petsAvailableOnBankCount + 1
						end
					end
					
					bankIndexInfo:SetContent(string.format("You have <b>%s</b> of %s unlockable pets\n", tostring(#SaveData.Collection), tostring(#allCollectablePets)) ..
									  string.format("This bank have %s pets in total\n", tostring(#BankPets)) ..
									  string.format("This bank have <b>%s</b> of %s pets that you need to complete your collection", tostring(petsAvailableOnBankCount), tostring(#allCollectablePets - #SaveData.Collection)))
				
				end
				UpdateInfo()
				
				BankIndex_InProgress = true
				
				coroutine.wrap(function() 
					while true do
						wait()
						startBankIndex:Set("Stop Indexing", nil)
						break
					end
				end)()
				
				wait(1)
	
				coroutine.wrap(function()
					local petsToWithdraw = {}
					local failedToDeposit = false
					while BankIndex_InProgress do
					
						UpdateInfo()
						if not petsToWithdraw or #petsToWithdraw < 50 then
							for petIdentifer, pet in pairs(petsAvailableOnBank) do 
								if pet and pet.uid and #petsToWithdraw < 50 then
									table.insert(petsToWithdraw, pet.uid)
									petsAvailableOnBank[petIdentifer] = nil
								end
								
								if #petsToWithdraw >= 50 then break end
							end
						end
						
						UpdateInfo()
						if petsToWithdraw and #petsToWithdraw > 0 then
							bankIndexInfo:SetTitle(string.format("Withdrawing %s pets...", tostring(#petsToWithdraw)))
							wait(0.5)
							
							local oldCollectionCount = 0 + #SaveData.Collection
							local expectedCollectionCount = oldCollectionCount + #petsToWithdraw
							
							local withdrawSuccess, withdrawMessage = Library.Network.Invoke("Bank Withdraw", BankUID, petsToWithdraw, 0)
							if withdrawSuccess then
								UpdateInfo()
								bankIndexInfo:SetTitle(string.format("Waiting for %s pets to index...", tostring(#petsToWithdraw)))
								wait(5)
								
								local cTick = tick()
								repeat UpdateInfo() wait() until #SaveData.Collection > oldCollectionCount or not BankIndex_InProgress or tick() - cTick > 15
								bankIndexInfo:SetTitle(string.format("Depositing %s pets...", tostring(#petsToWithdraw)))
								
								UpdateInfo()
								local depositsAttempts = 0
								
								
								local function TryToDeposit()
									local depositSuccess, depositMessage = Library.Network.Invoke("Bank Deposit", BankUID, petsToWithdraw, 0)
									if not depositSuccess then 
										if depositsAttempts >= 5 then 
											failedToDeposit = true 
											return 
										end
										depositsAttempts = depositsAttempts + 1
										wait(5)
										TryToDeposit()
									end
								end
								
								TryToDeposit()
								
								if failedToDeposit then
									bankIndexInfo:SetTitle("Oopps... Aborting process!")
									bankIndexInfo:SetContent(string.format("Damn! <b>Failed to deposit</b> after <b>5</b> attempts, <font color=\"#FF0000\">process has been canceled</font>!\nFailed to deposit: %s pets!", tostring(#petsToWithdraw)))
									break
								else 
									-- CLEAR THE WITHDRAW TABLE
									petsToWithdraw = {}
								end
							else
								print(withdrawMessage)
							end
						else break end
						wait(10)
					end
					
					BankIndex_InProgress = false
					BankIndex_Debounce = false
					UpdateInfo()
					
					coroutine.wrap(function() 
						while true do
							wait()
							startBankIndex:Set("Start Indexing", nil)
							break
						end
					end)()
					
					if not failedToDeposit then 
						bankIndexInfo:Set({
							Title = "Idling",
							Content = "Not doing anything yet..."
						})
					end
					
					BankMessage(nil, "")
				end)()
			end
		end
	})
	
	local CompleteCollection_NormalEggs = true
	local CompleteCollection_GoldenEggs = true
	local CompleteCollection_MakeRainbows = false
	local CompleteCollection_MakeDarkMatter = false
	
	function GetNextMissingPet()
		local SaveData = Library.Save.Get()
		if not SaveData then return nil end
		
		local allCollectablePets = Library.Shared.GetAllCollectablePets()
		local remainingPets = {}

		for i, pet in pairs(allCollectablePets) do 
			local petId = pet.petId
			local petData = Library.Directory.Pets[petId]
			local isGolden = pet.isGolden
			local isRainbow = pet.isRainbow
			local isDarkMatter = pet.isDarkMatter
			
			local petType = 1
			if isGolden then
				petType = 2
			elseif isRainbow then
				petType = 3
			elseif isDarkMatter then
				petType = 4
			end
						
					
			local isUnlocked = Library.Functions.SearchArray(SaveData.Collection, tostring(petId) .. "-" .. tostring(petType))
			if petData and not (petData.titanic or petData.huge or petData.rarity == "Exclusive" or petData.rarity == "Event") and not isUnlocked then
				-- remainingPets[petId] = petType
				table.insert(remainingPets, {petId, petType})
			end
		end
		
		table.sort(remainingPets, function(a, b)
			local petDataA = Library.Directory.Pets[a[1]]
			local petDataB = Library.Directory.Pets[b[1]]
			
			local petTypeA = a[2]
			local petTypeB = b[2]
			
			if a == b then 
				return petTypeA < petTypeB
			end
			
			return a[1] < b[1]
		end)
		
		for i, v in ipairs(remainingPets) do return v end
	end
	
	function GetBestEggForPet(petId)
		local allEggs = Library.Directory.Eggs
		local eggsWithPet = {}
		for eggId, v in pairs(allEggs) do
			if v and v.drops and typeof(v.drops) == "table" then
				for _, drop in pairs(v.drops) do
					local petDropId = drop[1]
					if petDropId == tostring(petId) then
						table.insert(eggsWithPet, {eggId, drop[2]})
					end
				end
			end
		end
		
		table.sort(eggsWithPet, function(a, b) 
			local chanceA = eggsWithPet[a][2]
			local chanceB = eggsWithPet[b][2]
			
			return chanceA > chanceB
		end)
		
		for i, v in ipairs(eggsWithPet) do
			return v[1]
		end
		return nil
	end
	
	local completeCollectionSection = automationTab:CreateSection("Auto Pet Collection", false, true)
	local completeCollectionStatus = automationTab:CreateParagraph({Title = "Status", Content = "Waiting to start"}, completeCollectionSection)
	
	local completeCollectionNormalEggs = automationTab:CreateToggle({
		Name = "Normal Eggs",
		SectionParent = completeCollectionSection,
		CurrentValue = true,
		Flag = "CompleteCollection_NormalEggs",
		Callback = function(value) 
			CompleteCollection_NormalEggs = value
			
			coroutine.wrap(function()
				local currentPet, currentPetType = unpack(GetNextMissingPet())
				local currentEgg = GetBestEggForPet(currentPet)
				completeCollectionStatus:SetContent("Pet: " .. Library.Directory.Pets[currentPet].name .. "\nType: " .. currentPetType .. "\nEgg: " .. currentEgg)
				
				
				while task.wait(3) do
				
				end
			end)()
		end
	})
	
	
	local completeCollectionGolldenEggs = automationTab:CreateToggle({
		Name = "Golden Eggs",
		SectionParent = completeCollectionSection,
		CurrentValue = true,
		Flag = "CompleteCollection_GoldenEggs",
		Callback = function(value) 
			CompleteCollection_GoldenEggs = value
		end
	})

	local completeCollectionMakeRainbows = automationTab:CreateToggle({
		Name = "Make Rainbows",
		SectionParent = completeCollectionSection,
		CurrentValue = false,
		Flag = "CompleteCollection_MakeRainbows",
		Callback = function(value) 
			CompleteCollection_MakeRainbows = value
		end
	})
	
	local completeCollectionMakeDarkMatter = automationTab:CreateToggle({
		Name = "Make Dark Matter",
		SectionParent = completeCollectionSection,
		CurrentValue = false,
		Flag = "CompleteCollection_MakeDarkMatter",
		Callback = function(value) 
			CompleteCollection_MakeDarkMatter = value
		end
	})
	
	
	-- SETTINGS
	local AUTODAYCARE_OTHER_GAMEMODES = false -- CHANGE THIS TO TRUE IF YOU WANT TO AUTO-COLLECT/ENROLL BOTH NORMAL AND HARDCORE GAMEMODES 
	local TRY_TO_TELEPORT_SAME_SERVER = true -- If auto-daycare is enabled for both gamemodes, this option will TRY teleport you back to the same server that you were before



	local DAYCARE_WORLD = "Spawn"
	local DAYCARE_POSITION = Vector3.new(35, 110, 40)
	local PetsToDaycare = {}

	local DaycareGUI = Library.GUI.Daycare;

	local DISCORD_EMOTES = {
		["Diamonds"] = "<:e:1062469796341497887>",
		["Triple Coins"] = "<:e:1082130777355079800>",
		["Triple Damage"] = "<:e:1082130816261443674>",
		["Super Lucky"] = "<:e:1082130793880621167>",
		["Ultra Lucky"] = "<:e:1082130805914079313>"
	}

	local COIN_EMOTE = "<:e:1087199766401794168>"
	local PET_EMOTE = "<:e:1083222082533462098>"

	local AUTODAYCARE_SETTINGS_FOLDER = "AutoDaycare"
	local AUTODAYCARE_SETTINGS_FILE = "SaveData"

	function SaveSettings() 
		pcall(function() 
			if not isfolder(AUTODAYCARE_SETTINGS_FOLDER) then
				makefolder(AUTODAYCARE_SETTINGS_FOLDER)
			end
			
			local fileData = {}
			
			if CurrentWorld and CurrentWorld ~= "" then 
				fileData.World = CurrentWorld
			end
			
			if CurrentPosition and CurrentPosition ~= nil then 
				fileData.Position = CurrentPosition
			end
			
			fileData.GameMode = "normal"
			if Library.Shared.IsHardcore then 
				fileData.GameMode = "hardcore"
			end
			
			writefile(AUTODAYCARE_SETTINGS_FOLDER .. "/" .. AUTODAYCARE_SETTINGS_FILE .. ".json", tostring(HttpService:JSONEncode(fileData)))
		end)
	end

	local IsTeleporting = false
	function LoadSettings() 
		pcall(function()
			if isfile(AUTODAYCARE_SETTINGS_FOLDER .. "/" .. AUTODAYCARE_SETTINGS_FILE .. ".json") then
				local saveData = readfile(AUTODAYCARE_SETTINGS_FOLDER .. "/" .. AUTODAYCARE_SETTINGS_FILE .. ".json")
				local save = HttpService:JSONDecode(saveData)
				
				if not save.GameMode or save.GameMode == "" then return end
				
				local shouldTeleport = false
				if save.World and save.World ~= "" then
					CurrentWorld = save.World
					shouldTeleport = true
				end
				
				if save.Position and save.Position ~= nil then
					CurrentPosition = save.Position
					shouldTeleport = true
				end
				
				local gamemode = "normal"
				if Library.Shared.IsHardcore then 
					gamemode = "hardcore"
				end
				
				if save.GameMode ~= gamemode then return end
				
				if shouldTeleport then 
					IsTeleporting = true
					TeleportBack()
					IsTeleporting = false
				end
			end
		end)
	end

	function SendWebhookInfo(quantity, loots)
		if not Webhook_Enabled or not Webhook_Daycare or not Webhook_URL or Webhook_URL == "" then return end

		local gamemode = "[NORMAL]"
		if Library.Shared.IsHardcore then 
			gamemode = "[HARDCORE]"
		end
		
		local lootString = ""
		
		local ContainsPet = false
		for _, loot in pairs(loots) do 
			local selectedEmote = ""
			if DISCORD_EMOTES[loot.Data] then 
				selectedEmote = DISCORD_EMOTES[loot.Data]
			elseif loot.Category == "Currency" then
				selectedEmote = COIN_EMOTE
			elseif loot.Category == "Pet" then
				ContainsPet = true
				selectedEmote = PET_EMOTE
			end
			
			lootString = lootString .. selectedEmote .. " " .. Library.Functions.NumberShorten(loot.Min) .. " **" .. loot.Data .. "**\n" 
		end

		local embed = {
				["title"] = "Daycare has been collected! " .. gamemode,
				["description"] = "Successfully collected **".. tostring(quantity) .."** pets from daycare!",
				["color"] = tonumber(0x90ff90),

				["fields"] = {
					{
						["name"] = "Collected Loot",
						["value"] = lootString,
						["inline"] = false
					}
				},
				["footer"] = {
					["text"] = "Pet Simulator X",
					["icon_url"] = "https://i.imgur.com/pWIzvzD.png"
				}
			}
			
		(syn and syn.request or http_request or http.request) {
			Url = Webhook_URL;
			Method = 'POST';
			Headers = {
				['Content-Type'] = 'application/json';
			};
			Body = HttpService:JSONEncode({
				username = "Daycare Update", 
				avatar_url = 'https://i.imgur.com/pWIzvzD.png',
				embeds = {embed} 
			})
		}
	end


	function TeleportToDaycare()
		CurrentWorld = Library.WorldCmds.Get()
		
		
		CurrentPosition = HumanoidRootPart.CFrame
		task.wait()
		
		-- Go to Spawn World
		if CurrentWorld ~= DAYCARE_WORLD then
			Library.WorldCmds.Load(DAYCARE_WORLD)
		end

		HumanoidRootPart.CFrame = CFrame.new(DAYCARE_POSITION) 
	end

	function SendNotification(msg, options)
		if not options then
			options = {
				time = 10,
				color = Color3.fromRGB(160, 30, 245),
				force = true
			}
		end

		Library.Signal.Fire("Notification", msg, options)
	end

	function ErrorNotification(msg) 
		SendNotification(msg, {
			time = 10, color = Color3.fromRGB(255, 60, 60), force = true
		})
	end

	local BoostIcons = {
		["Triple Coins"] = "rbxassetid://7402604552", 
		["Triple Damage"] = "rbxassetid://7402604431", 
		["Super Lucky"] = "rbxassetid://7402604677", 
		["Ultra Lucky"] = "rbxassetid://7402706511"
	}

	function CollectDaycare()
		local saving = Library.Save.Get()
		if not saving then 
			ErrorNotification("Something went wrong! Try re-logging!")
			return
		end
		
		local success, errorMsg, pets, loots, queue = Library.Network.Invoke("Daycare: Claim", nil)
		if not success then
			return false, (errorMsg and "Can't claim, unknown error!")
		end

		if loots then 
			
			for _, loot in pairs(loots) do
				-- print (tostring(loot.Category) .. ": " .. tostring(loot.Min) .. "x " .. tostring(loot.Data) )
				-- Quantity: loot.Min
				if loot.Category == "Currency" then 
					-- CurrencyIcon: Library.Directory.Currency[loot.Data].tinyImage;	
				elseif loot.Category == "Boost" then
					-- BoostIcon = BoostIcon[loot.Data]
				elseif loot.Category == "Pet" then
					local petData = loot.Data;
					
					-- Open Huge Egg
					if petData.id ~= "1019" then
						Library.Signal.Fire("Open Egg", "Huge Machine Egg 1", { petData });
					end
				end
			end
			
		end
		
		if queue then
			if Library.Shared.IsHardcore then
				saving.DaycareHardcoreQueue = queue;
			else
				saving.DaycareQueue = queue;
			end
			
			-- Remove pets that isn't ready yet
			
			for _, pet in pairs(queue) do
				if pet["Pet"] and pet["Pet"].uid then
					local tablePos = table.find(PetsToDaycare, pet["Pet"].uid)
					if tablePos then
						-- print("A pet was not ready yet!")
						table.remove(PetsToDaycare, tablePos)
					end
				end
			end
			
		end
		
		SendWebhookInfo(#PetsToDaycare, loots)

		return true, nil
	end

	function PutPetsInDaycare()
		local saving = Library.Save.Get()
		local success, errorMsg, _ = Library.Network.Invoke("Daycare: Enroll", PetsToDaycare)
		if not success then
			return false, (errorMsg and "Can't enroll pets, unknown error!")
		end

		print(tostring(#PetsToDaycare) .. " pets have been put on daycare!")
		task.wait(1)
		
		Library.Signal.Fire("Stat Changed", "DaycareTier")
		Library.Signal.Fire("Window Closed", DaycareGUI.Gui)
		return true, nil
	end

	function CreateReminder()
		if getgenv().AutoDaycare then
			return 
		end
		
		local saving = Library.Save.Get()
		
		local queue = saving.DaycareQueue
		if Library.Shared.IsHardcore then
			queue = saving.DaycareHardcoreQueue
		end
		
		-- Check if queue isn't nil and queue lenght is more than 1 (pet)
		if queue ~= nil and #queue > 0 then	
			getgenv().AutoDaycare = true
			coroutine.wrap(function() 
				while true do
					local allPetsAreReady = true
					
					for _, pet in pairs(queue) do
						local remainingTime = Library.Shared.DaycareComputeRemainingTime(saving, pet)

						if remainingTime > 0 then
							allPetsAreReady = false
							break
						end

					end
					
					
					if allPetsAreReady or not enableAutoDaycare then break end
					task.wait(1)
				end
				
				getgenv().AutoDaycare = false
				
				if not enableAutoDaycare then return end
				if ScriptIsCurrentlyBusy then 
					while ScriptIsCurrentlyBusy do wait() end
					ScriptIsCurrentlyBusy = true
					wait(3)
				end
				
				ScriptIsCurrentlyBusy = true
				
				--if reminder then Library.Message.New("Your pets in daycare are ready to collect!") end
				
				PetsToDaycare = {}
				
				for _, pet in pairs(queue) do	
					local remainingTime = Library.Shared.DaycareComputeRemainingTime(saving, pet)

					if remainingTime <= 0 and pet["Pet"] and pet["Pet"].uid then
						table.insert(PetsToDaycare, pet["Pet"].uid)
					end
				end
				
				TeleportToDaycare()
				task.wait(1)
				
				local collected, collectError = CollectDaycare()
				if not collected then		
					ErrorNotification(collectError)
					ResetDaycare()
					return
				end
				
				task.wait(3)
				
				local enrollSuccess, enrollError = PutPetsInDaycare()
				if not enrollSuccess then
					ErrorNotification(enrollError)
					ResetDaycare()
					return
				end

				SendNotification("Successfully put pets in daycare!")
				ResetDaycare()
			end)()
		end
	end

	function TeleportBack()
		pcall(function() 
			-- Go to Spawn World
			if CurrentWorld ~= "" and Library.WorldCmds.Get() ~= CurrentWorld then
				Library.WorldCmds.Load(CurrentWorld)
			end
			CurrentWorld = ""
			
			if CurrentPosition then
				HumanoidRootPart.CFrame = CurrentPosition
			end
			CurrentPosition = nil
		end)
	end

	function ResetDaycare()
		TeleportBack()
		DaycareGUI.Categories.ViewPets.Frame.PetReady.Visible = false

		-- FIRE CLOSE CONNECTION
		for _, connection in pairs(getconnections(DaycareGUI.Close.Activated)) do 
			connection:Fire()
		end

		wait(3)
		ScriptIsCurrentlyBusy = false
	end

	Library.Signal.Fired("Stat Changed"):Connect(function(stat)
		if stat == "DaycareQueue" and enableAutoDaycare then
			CreateReminder()
		end
	end)

	task.spawn(function() 
		while true do
			if Automations_AutoGameComplete then	
				local saveData = Library.Save.Get()
				local currentAreaName, nextAreaName = GetCurrentAndNextArea()
				local currentArea = Library.Directory.Areas[currentAreaName]
				local nextArea = Library.Directory.Areas[nextAreaName]
				
				local shouldSkip = false
				if currentAreaName == "Hacker Portal" then
					shouldSkip = true
					local ownsHackerGate = IsHardcore and saveData.Hardcore.HackerPortalUnlocked or not IsHardcore and saveData.HackerPortalUnlocked
					if not ownsHackerGate then
					
						local currentProgress, currentMission = unpack(IsHardcore and saveData.Hardcore.HackerPortalProgress or saveData.HackerPortalProgress)
						if currentMission < 0 then
							-- Start quest
							local map = Library.WorldCmds.GetMap()
							local interactive = nil
							if map then interactive = map:FindFirstChild("Interactive") end
							
							local hackerPortal = nil
							if interactive then hackerPortal = interactive:FindFirstChild("Hacker Portal") end
							
							local interactLocation = nil
							if hackerPortal then interactLocation = hackerPortal:FindFirstChild("_INTERACT") end
							
							if interactLocation then
								HumanoidRootPart.CFrame = CFrame.new(interactLocation.CFrame.p) + (interactLocation.CFrame.RightVector * 10)
								SendNotification("Starting hacker portal mission...")
								Library.Network.Fire("Start Hacker Portal Quests")
								currentMission = 1
							end
						end
						
						if currentMission > 1 then
							currentMission = 1
							currentProgress = Library.Shared.HackerPortalQuests[1]

						end
						
						if currentMission > -1 then
							local totalToComplete = Library.Shared.HackerPortalQuests[currentMission]
							if totalToComplete and tonumber(totalToComplete) and currentProgress >= totalToComplete then
								local map = Library.WorldCmds.GetMap()
								local interactive = nil
								if map then interactive = map:FindFirstChild("Interactive") end
								
								local hackerPortal = nil
								if interactive then hackerPortal = interactive:FindFirstChild("Hacker Portal") end
								
								local interactLocation = nil
								if hackerPortal then interactLocation = hackerPortal:FindFirstChild("_INTERACT") end
								
								if interactLocation then
									HumanoidRootPart.CFrame = CFrame.new(interactLocation.CFrame.p) + (interactLocation.CFrame.RightVector * 10)
									wait(0.3)
								end
								
								if Library.Network.Invoke("Finish Hacker Portal Quest")	then
									SendNotification("Unlocking Void...")
									Library.WorldCmds.Load("Void")
									wait(2)
									SendNotification("Unlocking ".. nextAreaName .. "...")
									Library.WorldCmds.Load(nextArea.world)
									wait(1)
								end
							end
						end
					else 
						SendNotification("Unlocking Void...")
						Library.WorldCmds.Load("Void")
						wait(2)
						SendNotification("Unlocking ".. nextAreaName .. "...")
						Library.WorldCmds.Load(nextArea.world)
						wait(1)
					end
				end
				
				if nextAreaName ~= "COMPLETED" and not shouldSkip and CheckIfCanAffordArea(nextAreaName) then 
					-- Buy area
					local currentWorld = Library.WorldCmds.Get() 
					if currentWorld ~= nextArea.world then 
						Library.WorldCmds.Load(nextArea.world)
						wait(1)
					end
					
					local map = Library.WorldCmds.GetMap()
					local allGates = nil
					if map then allGates = map:FindFirstChild("Gates") end
					
					local successfullyTeleported = false
					if allGates and allGates:FindFirstChild(nextAreaName) then
						local gate = allGates:FindFirstChild(nextAreaName):FindFirstChild("Gate")
						if gate and gate:FindFirstChild("GateHUD") then
							local gateTP = gate:FindFirstChild("GateHUD").Parent
							if gateTP then 
								HumanoidRootPart.CFrame = CFrame.new(gateTP.CFrame.p) * CFrame.new(1,0,0)
								successfullyTeleported = true
							end
						end
					elseif currentArea.world == "Fantasy" then
						local interactive = map:FindFirstChild("Interactive")
						local portals = nil
						if interactive then portals = interactive:FindFirstChild("Portals") end
						if portals and portals:FindFirstChild(nextAreaName) then 
							local portal = portals:FindFirstChild(nextAreaName)
							HumanoidRootPart.CFrame = CFrame.new(portal.PrimaryPart.CFrame.p) + (portal.PrimaryPart.CFrame.RightVector * 5)
							successfullyTeleported = true
						end 
						
					end
					
					if successfullyTeleported then
						wait(0.1)
						SendNotification("Unlocking ".. nextAreaName .. "...")
						local success, errorMsg = Library.Network.Invoke("Buy Area", nextAreaName)
						if success then
							if currentAreaName == "Cat Kingdom" then
								SendNotification("Unlocking Limbo...")
								Library.WorldCmds.Load("Limbo")
								wait(1)
							end
							-- TELEPORT TO THE NEW AREA
							local areaTeleport = Library.WorldCmds.GetMap().Teleports:FindFirstChild(nextAreaName);
							if areaTeleport then 
								Library.Signal.Fire("Teleporting")
								task.wait(0.25)
								Character:PivotTo(areaTeleport.CFrame + areaTeleport.CFrame.UpVector * (Humanoid.HipHeight + HumanoidRootPart.Size.Y / 2))
								Library.Network.Fire("Performed Teleport", nextAreaName)
								task.wait(0.25)
							end	
						end
					end
					
					wait(1)
				else 
					-- NOT AVAILABLE YET
					-- Start farming? Teleport to area? Idk yet
				end
			end
			
			task.wait(0.5)
		end
	end)

	
	local settingsTab = Window:CreateTab("Settings", "13075268290", true)
	local windowSettings = settingsTab:CreateSection("General Options", false, false, "13080063021")
	
	settingsTab:CreateToggle({
		Name = "Compact Mode",
		CurrentValue = false,
		Flag = "Settings_CompactMode",
		SectionParent = windowSettings,
		Callback = function(value) 
			Rayfield:ToggleOldTabStyle(not value)
		end
	})
	
	settingsTab:CreateToggle({
		Name = "Disable Rendering when Alt-Tab",
		CurrentValue = true,
		Flag = "Settings_DisableRendering",
		SectionParent = windowSettings,
		Callback = function(value) 
			Settings_DisableRendering = value
		end
	})
	
	local discordSettings = settingsTab:CreateSection("Webhook Options", false, true, "13085068876")
	settingsTab:CreateToggle({
		Name = "Enable Webhook",
		CurrentValue = false,
		Flag = "Webhook_Enabled",
		SectionParent = discordSettings,
		Callback = function(value) 
			Webhook_Enabled = value
		end
	})

	local WebhookURLInput = settingsTab:CreateInput({
	   Name = "Webhook URL",
	   PlaceholderText = "Paste your Discord Webhook here",
	   SectionParent = discordSettings,
	   NumbersOnly = false,
	   OnEnter = false,
	   RemoveTextAfterFocusLost = false,
	   Callback = function(Text)
			SaveCustomFlag("Webhook_URL", Text)
	   end,
	   
	})	
		
	AddCustomFlag("Webhook_URL", "", function(newValue) 
		Webhook_URL = newValue
		if WebhookURLInput and newValue and newValue ~= "" then
			WebhookURLInput:Set(newValue)
		end
	end)
	
	settingsTab:CreateToggle({
		Name = "Daycare Updates",
		CurrentValue = false,
		Flag = "Webhook_Daycare",
		SectionParent = discordSettings,
		Callback = function(value) 
			Webhook_Daycare = value
		end
	})
	
	-- TODO: Change this to a Dropdown with rarities to notify
	settingsTab:CreateToggle({
		Name = "Notify Huge Hatches",
		CurrentValue = false,
		Flag = "Webhook_Huge",
		SectionParent = discordSettings,
		Callback = function(value) 
			Webhook_Huge = value
		end
	})
	
	Rayfield.LoadConfiguration()

	for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
		v:Disable()
	end

	InputService.WindowFocused:Connect(function()
		RunService:Set3dRenderingEnabled(true)
	end)

	InputService.WindowFocusReleased:Connect(function()
		if Settings_DisableRendering then
			RunService:Set3dRenderingEnabled(false)
		end
	end)
end

-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
-- discord.gg/MilkUp
