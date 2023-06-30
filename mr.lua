if not game:IsLoaded() then game.Loaded:Wait() end
if game.PlaceId ~= 4490140733 then return end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local Library = require(game:GetService("ReplicatedStorage"):WaitForChild("Framework"):WaitForChild("Library"))
assert(Library, "Oopps! Library has not been loaded. Maybe try re-joining?") 
while not Library.Loaded do wait() end

function GetPath(...)
    local path = {...}
    local oldPath = Library
	if path and #path > 0 then
		for _,v in ipairs(path) do
			oldPath = oldPath[v]
		end
	end
    return oldPath
end 

-------
-------------------------//
--// Libraries
-------------------------//
local Food = GetPath("Food")
local Entity = GetPath("Entity")
local Customer = GetPath("Customer")
local Waiter = GetPath("Waiter")
local Appliance = GetPath("Appliance")
local Bakery = GetPath("Bakery")
local Gamepasses = GetPath("Gamepasses")
local Network = GetPath("Network")

------------------//
--// Variables
-------------------------//
local StartTick = tick()

local Player = Players.LocalPlayer
local StoreTeleports = {}
local PlayerTeleports = {}
local Wells = {"101","49","50"}
local Slots = {"57"}
local FurnituresCooldowns = {}

-- Settings Variables
local FastWaiter = false
local GoldFood = false
local AutoGift = false
local FastOrder = false
local FastNPC = false
local TeleportNPC = false
local NPCSpeed = 100
local AutoInteract = false
local AutoBuyWorkers = false
local AutoBlacklist = false
local AutoCloseRestaurant = false
local AutoCloseEvery = 600
local LastTimeClose = 0

--// Force better customer
local ForceCustomers = false
local ForceVIP = false
local ForcePirate = false
local ForceYoutuber = false
local ForceHeadless = false
local ForceCorruptedVIP = false
local ForceSanta = false
local ForceElf = false
local ForceLifeguard = false
local ForceAlien = false
local ForcePrincess = false
local ForceSuperHero = false

local InstantCook = false
local InstantEat = false
local InstantWash = false

local IS_DEV_MODE = true
local PRINT_NETWORK = false

local OptimizedMode = false

-------------------------//
--// Overwrite Functions
-------------------------//
local Original_EntityNew = Entity.new
Entity.new = function(id, uid, entityType, p4, p5)
	local entity = Original_EntityNew(id, uid, entityType, p4, p5)

	-- if entityType == "Customer" then 
		-- entity.model:Destroy()
	-- end
	
	if entityType == "Customer" and OptimizedMode then
		pcall(function()
			if entity and entity.model and entity.model:FindFirstChild("Humanoid") then
				entity.model.Humanoid:RemoveAccessories()
			end
		end)
	end
	--print(id, uid, entityType, p4, p5)
	return entity
end


local Original_StartWashingDishes = Appliance.StartWashingDishes
Appliance.StartWashingDishes = function(appliance)
	if not InstantWash then Original_StartWashingDishes(appliance) return end
	
	if appliance.stateData.isWashingDishes then
		return
	end
	
	appliance.stateData.isWashingDishes = true

	coroutine.wrap(function()
		while not appliance.isDeleted and appliance.stateData.numberDishes > 0 do
			appliance.stateData.dishStartTime = tick()
			appliance.stateData.dishwasherUI.Enabled = true
			wait(0.05)
			appliance:RemoveDish()	
		end
		
		if appliance.isDeleted then
			return
		end
		
		if not appliance.isDeleted then
			appliance.stateData.dishwasherUI.Frame.DishProgress.Bar.Size = UDim2.new(0, 0, 1, 0)
			appliance.stateData.dishwasherUI.Enabled = false
		end
		
		appliance.stateData.isWashingDishes = false
		if appliance.stateData.washingLoopSound then
			appliance.stateData.washingLoopSound:Destroy()
			appliance.stateData.washingLoopSound = nil
		end
	end)()
end

local Original_ChangeToReadyToExitState = Customer.ChangeToReadyToExitState
Customer.ChangeToReadyToExitState = function(customer, forceToLeaveATip)
	if InstantEat then 
		Original_ChangeToReadyToExitState(customer, true) 
	else 
		Original_ChangeToReadyToExitState(customer, forceToLeaveATip) 
	end
end

local Original_AddCustomersToQueueIfNecessary = Bakery.AddCustomersToQueueIfNecessary
Bakery.AddCustomersToQueueIfNecessary = function(bakery, kickCustomerIfNecessary, UIDBatch)
	if not ForceCustomers then return Original_AddCustomersToQueueIfNecessary(bakery, kickCustomerIfNecessary, UIDBatch) end
	
	if #bakery.customerQueue >= 4 then
		return 0
	end

	local firstFloor = bakery.floors[1]

	local selectedTable, selectedSeatGroup
	local indices = Library.Functions.RandomIndices(Library.Variables.MyBakery.floors)
	for _, index in ipairs(indices) do
		if index and tonumber(index) and index > 0 then 
			local floor = bakery.floors[index]
			selectedTable, selectedSeatGroup = floor:GetAvailableSeatGroupings()
			if selectedTable and selectedSeatGroup then
				break
			end
		end
	end
	
	if not (selectedTable and selectedSeatGroup) then
		if kickCustomerIfNecessary then
			local didKickCustomer = false
			for _, floor in ipairs(bakery.floors) do
				for _, customer in ipairs(floor.customers) do
					if customer.state ~= "ReadyToExit" then
						customer:ForcedToLeave()
						didKickCustomer = true
						break
					end
				end
				if didKickCustomer then
					break
				end
			end
			
		end
		
		return 0
	end
	local queueEntry = {}
	
		
	local didPlayVIPCustomerSound = false

	local vipOverride = {}	
	local pirateOverride = {}
	local youtuberOverride = {}
	local shadowOverride = {}
	local corruptedVIPOverride = {}
	local santaOverride = {}
	local elfOverride = {}
	local treeTable = {}
	local lifeguardOverride = {}
	local alienOverride = {}
	local princessOverride = {}
	local superheroOverride = {}
	
	-- create customers to fill this seat grouping
	local containsGhostOrSpecial = false
	for i, seatGroup in pairs(selectedSeatGroup) do
		local seat = seatGroup
		local tabl = selectedTable
		
		local hasAlreadyBeenForced = false

		local floor = bakery.floors[seat.floorLevel]
		for _, entity in ipairs(floor:GetEntitiesFromClassAndSubClass("Furniture", "ChristmasTree")) do
			local dist = math.sqrt(math.pow(entity.xVoxel - seat.xVoxel, 2) + math.pow(entity.zVoxel - seat.zVoxel, 2))
			if dist < 4*math.sqrt(2)+0.1 then
				treeTable[i] = true
				break
			end
		end
		

		local overrideUID = nil
			
		--// ROYAL TABLE
		if not hasAlreadyBeenForced and ForceVIP then
			if seat.ID == "43" and tabl.ID == "44" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "43" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "44" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "13"
				vipOverride[i] = overrideUID
			end
		end
		
		--// ROYAL HALLOWEEN TABLE
		if not hasAlreadyBeenForced and ForceHeadless then
			if seat.ID == "98" and tabl.ID == "99" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "98" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "99" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end

			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "26"
				corruptedVIPOverride[i] = overrideUID
			end
		end
		
		--// LIFEGUARD
		if not hasAlreadyBeenForced and ForceLifeguard then
			if seat.ID == "118" and tabl.ID == "119" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "118" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "119" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "29"
				lifeguardOverride[i] = overrideUID
			end
		end
		
		--// ALIEN
		if not hasAlreadyBeenForced and ForceAlien then
			if seat.ID == "120" and tabl.ID == "121" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "120" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "121" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "30"
				alienOverride[i] = overrideUID	
			end
		end
		
		if not hasAlreadyBeenForced and ForcePrincess then
			if seat.ID == "124" and tabl.ID == "125" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "124" then
				hasAlreadyBeenForced = true
				overrideUID = v219.UID
			elseif tabl.ID == "125" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "31"
				princessOverride[i] = overrideUID
			end
		end

		if not hasAlreadyBeenForced then
			if seat.ID == "127" and tabl.ID == "128" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "127" then
				hasAlreadyBeenForced = true
				overrideUID = v219.UID
			elseif tabl.ID == "128" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "32"
				superheroOverride[i] = overrideUID
			end
		end
		
		-- PIRATE
		if not hasAlreadyBeenForced and ForcePirate then
			if seat.ID == "74" and tabl.ID == "75" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "74" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "75" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "21"
				pirateOverride[i] = overrideUID
			end
		end
		
		--// YOUTUBER
		if not hasAlreadyBeenForced and ForceYoutuber then
			if seat.ID == "84" and tabl.ID == "85" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "84" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "85" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "22"
				youtuberOverride[i] = overrideUID
			end
		end
		
		-- SANTA
		if not hasAlreadyBeenForced and ForceSanta then
			if seat.ID == "108" and true then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
				UIDBatch[i].ID = "27"
				santaOverride[i] = overrideUID
			end
		end
		
		-- ELF
		if not hasAlreadyBeenForced and ForceElf then 
			if seat.ID == "110" and tabl.ID == "111" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif seat.ID == "110" then
				hasAlreadyBeenForced = true
				overrideUID = seat.UID
			elseif tabl.ID == "111" then
				hasAlreadyBeenForced = true
				overrideUID = tabl.UID
			end
			
			if hasAlreadyBeenForced then
				UIDBatch[i].ID = "28"
				elfOverride[i] = overrideUID
			end
		end
	end
	
	local originalResponse  = {Original_AddCustomersToQueueIfNecessary(bakery, kickCustomerIfNecessary, UIDBatch)}

	--// EDIT THE ORIGINAL RESPONSE
	originalResponse[1] = #selectedSeatGroup
	originalResponse[2] = vipOverride
	originalResponse[3] = pirateOverride
	originalResponse[4] = youtuberOverride
	originalResponse[5] = shadowOverride
	originalResponse[6] = corruptedVIPOverride
	originalResponse[7] = santaOverride
	originalResponse[8] = elfOverride
	originalResponse[9] = treeTable
	originalResponse[10] = lifeguardOverride
	originalResponse[11] = alienOverride
	originalResponse[12] = princessOverride
	originalResponse[13] = superheroOverride
	
	return unpack(originalResponse)
	
end
local Original_NetworkInvoke = Network.Invoke
Network.Invoke = function(...)
	local args = {...}

	if args[1] then
		if args[1] == "WaitForCookTime" and InstantCook then
			coroutine.wrap(function() Original_NetworkInvoke(unpack(args)) end)()
			return true
		elseif args[1] == "WaitForEatTime" and InstantEat then
			coroutine.wrap(function() Original_NetworkInvoke(unpack(args)) end)()
			return true
		end
	end
	
	if IS_DEV_MODE and PRINT_NETWORK then 
		local stringBuilder = "Network.Invoke: "
		for _, n in pairs(args) do 
			stringBuilder = stringBuilder .. " | " .. tostring(n)
		end
		print(stringBuilder)
	end
	
	return Original_NetworkInvoke(unpack(args))
end

Waiter.StartActionLoop = function(waiter)
	coroutine.wrap(function()
		while not waiter.isDeleted do
			Waiter.PerformAction(waiter)
			-- Wait for next waiter action
			if FastWaiter then
				wait()
			else
				wait(1.5)
			end
		end
	end)()
end

local Original_UpdateCustomerQueuePositioning = Bakery.UpdateCustomerQueuePositioning
Bakery.UpdateCustomerQueuePositioning = function(bakery)
	Original_UpdateCustomerQueuePositioning(bakery)
	if not FastWaiter then return end
	
	-- this fix stuck on door problem?
	wait(0.05)
	
	if bakery:IsMyBakery() then
		for _, groupQueue in ipairs(bakery.customerQueue) do 
			if groupQueue and groupQueue[1] then 
				local entity = groupQueue[1]
				entity:StopGroupEmoji()
				entity:CleanupGroupInteract()
				bakery:SeatQueuedCustomerGroup(entity)
				bakery:UpdateCustomerQueuePositioning()
			end
		end
	end
end

local Original_PerformAction = Waiter.PerformAction
Waiter.PerformAction = function(waiter)
	if not FastWaiter then Original_PerformAction(waiter) return end
	
	if waiter.state == "Idle" then
		--waiter.humanoid.WalkSpeed = waiter.data.walkSpeed * (waiter.boost and 1)
		local waiterFunctions = { Waiter.CheckForCustomerOrder, Waiter.CheckForFoodDelivery, Waiter.CheckForDishPickup }

		for _, action in ipairs(Library.Functions.RandomizeTable(waiterFunctions)) do 
			if action(waiter) then
				break
			end
		end
	end
end

local Original_CheckForDishPickup = Waiter.CheckForDishPickup
Waiter.CheckForDishPickup = function(waiter)
	if not FastWaiter then return Original_CheckForDishPickup(waiter) end
	
	local myFloor = waiter:GetMyFloor()
	local selectedDishChair, selectedDishChairFloor = nil
	
	local indices = Library.Functions.RandomIndices(Library.Variables.MyBakery.floors)
	
	if true then
		for i, index in ipairs(indices) do
			if index == myFloor.floorLevel then
				table.remove(indices, i)
				table.insert(indices, 1, myFloor.floorLevel)
				break
			end
		end
	end
	
	for _, index in ipairs(indices) do
		local thisFloor = Library.Variables.MyBakery.floors[index]
		local dishIndices = Library.Functions.RandomIndices(thisFloor.dishChairs)
		for _, dishIndex in ipairs(dishIndices) do
			local dishChair = thisFloor.dishChairs[dishIndex]
			if dishChair.isDeleted or dishChair.stateData.flaggedByWaiterForDishPickup or not dishChair.stateData.dish or dishChair.stateData.dish.isDeleted then
				continue
			end
			selectedDishChair = dishChair
			selectedDishChairFloor = dishChair:GetMyFloor()
			break
		end
		if selectedDishChair then
			break
		end
	end
	
	if not selectedDishChair then
		return false
	end

	local dishwashers = myFloor:GatherDishwashersOnAnyFloor()
	if #dishwashers == 0 then return false end
	
	local dishChair = selectedDishChair
	dishChair.stateData.flaggedByWaiterForDishPickup = true
	
	local dishwasher = dishwashers[math.random(#dishwashers)]
	dishwasher.stateData.dishWasherTargetCount += 1

	dishChair.stateData.dish.flaggedDishwasherUID = dishwasher.UID

	waiter.state = "WalkingToPickupDish"
	
	waiter:WalkToNewFloor(dishChair:GetMyFloor(), function()
		
		if dishChair.isDeleted or not dishChair.stateData.dish then
			dishwasher.stateData.dishWasherTargetCount -= 1
			waiter.state = "Idle"
			return
		end
		
		waiter:WalkToPoint(dishChair.xVoxel, dishChair.yVoxel, dishChair.zVoxel, function()
			
			if dishChair.isDeleted or not dishChair.stateData.dish then
				dishwasher.stateData.dishWasherTargetCount -= 1
				waiter.state = "Idle"
				return
			end
			
			dishChair.stateData.flaggedByWaiterForDishPickup = false
			
			if not dishChair.stateData.dish or dishChair.stateData.dish.isDeleted then
				dishwasher.stateData.dishWasherTargetCount -= 1
				waiter.state = "Idle"
				return
			end
			
			if dishChair.stateData.dish and dishChair.stateData.dish.model then
				
				for i, dishChairEntry in ipairs(selectedDishChairFloor.dishChairs) do
					if dishChairEntry == selectedDishChair then
						table.remove(selectedDishChairFloor.dishChairs, i)
						break
					end
				end
				
				dishChair.stateData.dish:CleanupInteract()
				
				if dishChair.stateData.dish.model and dishChair.stateData.dish.model.PrimaryPart then
					local dishSounds = {5205173686, 5205173942}
					Library.SFX.Play(dishSounds[math.random(#dishSounds)], dishChair.stateData.dish.model:GetPrimaryPartCFrame().p)
				end
				
				dishChair.stateData.dish:MoneyPickedUp()
				dishChair.stateData.dish:DestroyModel()
				dishChair.stateData.dish = nil
				
				waiter:HoldDirtyDish()

			end
			
			waiter:FaceEntity(dishChair)

			if dishwasher.isDeleted then
				waiter:StopLoadedAnimation("hold")
				if waiter.stateData.heldDish then
					waiter.stateData.heldDish = waiter.stateData.heldDish:Destroy()
				end
				waiter.state = "Idle"
				return
			end
			

			waiter:WalkToNewFloor(dishwasher:GetMyFloor(), function()
				
				if dishwasher.isDeleted then
					waiter:StopLoadedAnimation("hold")
					if waiter.stateData.heldDish then
						waiter.stateData.heldDish = waiter.stateData.heldDish:Destroy()
					end
					waiter.state = "Idle"
					return
				end
				
				waiter:WalkToPoint(dishwasher.xVoxel, dishwasher.yVoxel, dishwasher.zVoxel, function()

					waiter:DropFood()
					
					if dishwasher.isDeleted then
						waiter.state = "Idle"
						return
					end
					dishwasher:AddDish()
					
					waiter:FaceEntity(dishwasher)

					waiter:ResetAllStates()
		
				end)
			end)
		end)
	end)
	
	return true
	
end

local Original_CheckForCustomerOrder = Waiter.CheckForCustomerOrder
Waiter.CheckForCustomerOrder = function(waiter)
	if not FastWaiter then return Original_CheckForCustomerOrder(waiter) end
	
	local myFloor = waiter:GetMyFloor()
	
	local waitingCustomer = myFloor:GetCustomerWaitingToOrder()
	
	if not waitingCustomer then
		
		local indices = Library.Functions.RandomIndices(Library.Variables.MyBakery.floors)
		for _, index in ipairs(indices) do
			local floor = Library.Variables.MyBakery.floors[index]
			if floor ~= myFloor then
				if not floor:HasAtLeastOneIdleStateOfClass("Waiter") then
					waitingCustomer = floor:GetCustomerWaitingToOrder()
					if waitingCustomer then
						break
					end
				end
			end
		end
		
		if not waitingCustomer then
			return false
		end
	end
	
	waiter.state = "WalkingToTakeOrder"

	local customerGroup = {waitingCustomer}
	for _, customerPartner in ipairs(waitingCustomer.stateData.queueGroup) do
		if customerPartner.state == "WaitingToOrder" and not customerPartner.waiterIsAttendingToFoodOrder then
			table.insert(customerGroup, customerPartner)
		end
	end	

	for _, seatedCustomer in ipairs(customerGroup) do
		seatedCustomer.waiterIsAttendingToFoodOrder = true
	end
	
	local function untagGroup()
		for _, seatedCustomer in ipairs(customerGroup) do
			seatedCustomer.waiterIsAttendingToFoodOrder = false
		end
	end
	
	local firstCustomer = customerGroup[1]
	local groupTable = waiter:EntityTable()[firstCustomer.stateData.tableUID]
	if not groupTable or groupTable.isDeleted then
		waiter.state = "Idle"
		return
	end
	local tx, ty, tz = groupTable.xVoxel, groupTable.yVoxel, groupTable.zVoxel
	
	local customerFloor = firstCustomer:GetMyFloor()
	waiter:WalkToNewFloor(customerFloor, function()
		if firstCustomer.leaving or firstCustomer.isDeleted then
			waiter.state = "Idle"
			return
		end
		waiter:WalkToPoint(tx, ty, tz, function()
			
			if firstCustomer.isDeleted or firstCustomer.leaving then
				waiter.state = "Idle"
				return
			end
			
			local orderStand = customerFloor:FindOrderStandOnAnyFloor()
			if not orderStand then
				Library.Print("CRITICAL: NO ORDER STAND FOUND!", true)
				untagGroup()
				waiter.state = "Idle"
				waiter:TimedEmoji("ConcernedEmoji", 2)
				return
			end
			
			local firstCustomer = customerGroup[1]
			if firstCustomer then
				firstCustomer:StopGroupEmoji()
				firstCustomer:CleanupGroupInteract()
			end
						
			local groupOrder = {}
			local tookOrdersFrom = {}
			for _, seatedCustomer in ipairs(customerGroup) do
				if seatedCustomer.state == "WaitingToOrder" then
					table.insert(tookOrdersFrom, seatedCustomer)
					groupOrder[seatedCustomer.UID] = Library.Food.RandomFoodChoice(seatedCustomer.UID, seatedCustomer.ID, seatedCustomer:IsRichCustomer(), seatedCustomer:IsPirateCustomer(), seatedCustomer.isNearTree)
					seatedCustomer.state = "WaitingForFood"
					seatedCustomer:StopChat()
				end
			end
			
			-- if no orders are taken, abort
			if #tookOrdersFrom == 0 then
				waiter.state = "Idle"
				return
			end
			
			-- take order animation
			waiter:PlayLoadedAnimation("write")
			for _, customer in ipairs(customerGroup) do
				waiter:FaceEntity(customer)
			end
			waiter:StopLoadedAnimation("write")
			
			waiter.state = "WalkingToDropoffOrder"
			
			waiter:WalkToNewFloor(orderStand:GetMyFloor(), function()
				
				if orderStand.isDeleted then
					for _, customer in ipairs(customerGroup) do
						customer:ForcedToLeave()
					end
					waiter.state = "Idle"
					return
				end
				
				waiter:WalkToPoint(orderStand.xVoxel, orderStand.yVoxel, orderStand.zVoxel, function()
					
					if orderStand.isDeleted then
						for _, customer in ipairs(customerGroup) do
							customer:ForcedToLeave()
						end
						waiter.state = "Idle"
						return
					end
					
					-- deposit each of the orders
					for _, orderedCustomer in ipairs(tookOrdersFrom) do
						if orderedCustomer.isDeleted then
							continue
						end
						orderedCustomer:ChangeToWaitingForFoodState(groupOrder[orderedCustomer.UID])
						orderStand:AddFoodToQueue(groupOrder[orderedCustomer.UID])
					end
					
					
					Library.Network.Fire("AwardWaiterExperienceForTakingOrderWithVerification", waiter.UID)

					waiter:FaceEntity(orderStand)

					waiter.state = "Idle"
					
				end)
			end)
			
		end)
	end)
	
	return true
	
end

local Original_RandomFoodChoice = Food.RandomFoodChoice
Food.RandomFoodChoice = function(customerOwnerUID, customerOwnerID, isRichCustomer, isPirateCustomer, isNearTree)
    if GoldFood then
		local spoof = Food.new("45", customerOwnerUID, customerOwnerID, true, true)
		spoof.IsGold = true
		return spoof
	end
	
	return Original_RandomFoodChoice(customerOwnerUID, customerOwnerID, isRichCustomer, isPirateCustomer, isNearTree)
end

local Original_DropPresent = Customer.DropPresent
Customer.DropPresent = function(gift) 
	if AutoGift then
		local character = Player.Character or Player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
		
		local UID = Library.Network.Invoke("Santa_RequestPresentUID", gift.UID)
		Library.Network.Fire("Santa_PickUpGift", UID, humanoidRootPart.Position + Vector3.new(1,0,0))
	else 
		Original_DropPresent(gift)
	end
end

local Original_CheckForFoodDelivery = Waiter.CheckForFoodDelivery
Waiter.CheckForFoodDelivery = function(waiter)
	if not GoldFood then 
		return Original_CheckForFoodDelivery(waiter)
	end
	
	local myFloor = waiter:GetMyFloor()
	local readyStands = myFloor:GatherOrderStandsWithDeliveryReady()
	if #readyStands == 0 then		
		local indices = Library.Functions.RandomIndices(Library.Variables.MyBakery.floors)
		for _, index in ipairs(indices) do
			local floor = Library.Variables.MyBakery.floors[index]
			if floor ~= myFloor and not floor:HasAtLeastOneIdleStateOfClass("Waiter") then
				readyStands = floor:GatherOrderStandsWithDeliveryReady()
				if #readyStands > 0 then break end
			end		
		end
		
		if #readyStands == 0 then
			return false
		end
	end
	
	local orderStand = readyStands[math.random(#readyStands)]
	if not orderStand then
		return false
	end
	
	orderStand.stateData.foodReadyTargetCount = orderStand.stateData.foodReadyTargetCount + 1
	waiter.state = "WalkingToPickupFood"
	waiter:WalkToNewFloor(orderStand:GetMyFloor(), function()
		if orderStand.isDeleted then
			waiter.state = "Idle"
			return
		end
		
		waiter:WalkToPoint(orderStand.xVoxel, orderStand.yVoxel, orderStand.zVoxel, function()
			if orderStand.isDeleted then
				waiter.state = "Idle"
				return
			end
			
			orderStand.stateData.foodReadyTargetCount = orderStand.stateData.foodReadyTargetCount - 1
			if #orderStand.stateData.foodReadyList == 0 then
				waiter.state = "Idle"
				return
			end
			
			local selectedFoodOrder = orderStand.stateData.foodReadyList[1]
			selectedFoodOrder.isGold = true
			
			table.remove(orderStand.stateData.foodReadyList, 1)

			selectedFoodOrder:DestroyPopupListItemUI()
			local customerOfOrder = waiter:EntityTable()[selectedFoodOrder.customerOwnerUID]
			if not customerOfOrder then
				Library.Print("CRITICAL: customer owner of food not found", true)
				waiter.state = "Idle"
				return false
			end
			waiter:FaceEntity(orderStand)
			waiter:HoldFood(selectedFoodOrder.ID, selectedFoodOrder.isGold)
			waiter.state = "WalkingToDeliverFood"
			if not customerOfOrder.isDeleted then
				waiter:WalkToNewFloor(customerOfOrder:GetMyFloor(), function()
					waiter:WalkToPoint(customerOfOrder.xVoxel, customerOfOrder.yVoxel, customerOfOrder.zVoxel, function()
						waiter:DropFood()
						if customerOfOrder.isDeleted then
							Library.Print("CRITICAL: walked to customer, but they were forced to leave.  aborting", true)
							waiter.state = "Idle"
							return
						end
						customerOfOrder:ChangeToEatingState()
						waiter:FaceEntity(customerOfOrder)
						Library.Network.Fire("AwardWaiterExperienceForDeliveringOrderWithVerification", waiter.UID)
						waiter.state = "Idle"
					end)
				end)
				return
			end
			waiter.state = "Idle"
			waiter.stateData.heldDish = waiter.stateData.heldDish:Destroy()
		end)
	end)
	
	return true
end

local Original_ChangeToWaitForOrderState = Customer.ChangeToWaitForOrderState
Customer.ChangeToWaitForOrderState = function(customer)
	if not FastOrder then 
		Original_ChangeToWaitForOrderState(customer) 
		return
	end

	if customer.state ~= "WalkingToSeat" then return end
	
	local seatLeaf = customer:EntityTable()[customer.stateData.seatUID]
	local tableLeaf = customer:EntityTable()[customer.stateData.tableUID]
			
	if seatLeaf.isDeleted or tableLeaf.isDeleted then
		customer:ForcedToLeave()
		return
	end
	
	customer:SetCustomerState("ThinkingAboutOrder")
	customer:SitInSeat(seatLeaf).Completed:Connect(function()
	
		customer.humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		customer.xVoxel = seatLeaf.xVoxel
		customer.zVoxel = seatLeaf.zVoxel
		
		coroutine.wrap(function()
			wait(0.05)
			customer:ReadMenu()
			wait(0.1)
			
			if customer.isDeleted or customer.state ~= "ThinkingAboutOrder" then return end
			
			customer:StopReadingMenu()
			customer:SetCustomerState("DecidedOnOrder")
			
			local myGroup = {customer}
			for _, partner in ipairs(customer.stateData.queueGroup) do
				if not partner.isDeleted then
					table.insert(myGroup, partner)
				end
			end
			local foundUndecidedMember = false
			for _, groupMember in ipairs(myGroup) do
				if groupMember.state ~= "DecidedOnOrder" then
					foundUndecidedMember = true
					break
				end
			end
			
			if not foundUndecidedMember then
				for _, groupMember in ipairs(myGroup) do
					groupMember:ReadyToOrder()
				end
			end
		end)()
	end)
end

local Original_WalkThroughWaypoints = Entity.WalkThroughWaypoints
Entity.WalkThroughWaypoints = function(entity, voxelpoints, waypoints, undefined1, undefined2)
	if entity:BelongsToMyBakery() then
		if TeleportNPC then
			TeleportThroughWaypoints(entity, voxelpoints, waypoints)
			return
		elseif FastNPC and entity.humanoid then 
			entity.humanoid.WalkSpeed = NPCSpeed
		elseif not FastNPC and entity.humanoid and entity.data and entity.data.walkSpeed then
			entity.humanoid.WalkSpeed = entity.data.walkSpeed
		end
	end
	
	Original_WalkThroughWaypoints(entity, voxelpoints, waypoints, undefined1, undefined2)
end

function TeleportThroughWaypoints(entity, voxelpoints, waypoints)
    entity:PlayLoadedAnimation("walking")
	
	if #voxelpoints == 0 then
		return
	end
	
	if not entity:BelongsToMyBakery() and entity.stateData.walkingThroughWaypoints then
		repeat wait() until entity.isDeleted or not entity.stateData.walkingThroughWaypoints
		if entity.isDeleted then
			return
		end
	end
	if not entity:BelongsToMyBakery() then
		entity.stateData.walkingThroughWaypoints = true
	end
	
	-- replication fix?
	if not entity:BelongsToMyBakery() then
		entity.model.HumanoidRootPart.Anchored = false
	end
	
	local wayPoint = waypoints[#waypoints]
	local voxelPoint = voxelpoints[#waypoints]
	
	
	if wayPoint and voxelPoint and voxelPoint["x"] and voxelPoint["y"] then
		entity.model.HumanoidRootPart.CFrame = CFrame.new(wayPoint) * CFrame.new(0, 2, 0)
		local oldX, oldZ = entity.xVoxel, entity.zVoxel

		entity.xVoxel = voxelPoint.x
		entity.zVoxel = voxelPoint.y

		if entity:BelongsToMyBakery() then
			entity:GetMyFloor():BroadcastNPCPositionChange(entity, oldX, oldZ)
		end
	else
		for i, v in ipairs(waypoints) do
			entity.model.HumanoidRootPart.CFrame = CFrame.new(v) * CFrame.new(0, 2, 0)
			--entity.humanoid.MoveToFinished:Wait()
			local oldX, oldZ = entity.xVoxel, entity.zVoxel
			entity.xVoxel = voxelpoints[i].x
			entity.zVoxel = voxelpoints[i].y
			

			if entity:BelongsToMyBakery() then
				entity:GetMyFloor():BroadcastNPCPositionChange(entity, oldX, oldZ)
			end
		end	
	end
	
	if not entity:BelongsToMyBakery() then
		entity.stateData.walkingThroughWaypoints = false
	end
		
	entity:StopLoadedAnimation("walking")
	entity:PlayLoadedAnimation("idle")
end

local Debris = workspace:WaitForChild("__DEBRIS")
Debris.ChildAdded:Connect(function(ch)
    task.wait()
	local children = ch:GetChildren()
    if OptimizedMode and (ch.Name == "host" or (children and #children == 1 and typeof(children[1]) == "Instance" and children[1].ClassName == "Sound"))  then
        ch:Destroy()
    end
end)

-------------------------//
--// Rayfield Initialization
-------------------------//
getgenv().SecureMode = true
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/rafacasari/Rayfield/main/source'))()
assert(Rayfield, "Oopps! Rayfield has not been loaded. Maybe try re-joining?") 

--// GET OUT OF HERE YOUR FVCKING LOSER, DON'T RENAME MY SCRIPT, YOU DON'T EVEN KNOW HOW TO PRINT HELLO WORLD YOUR FVCKING ASSHOLE
local Window = Rayfield:CreateWindow({
   Name = "My Restaurant! | Script by Rafa (discord.gg/MilkUp)",
   LoadingTitle = "My Restaurant!",
   LoadingSubtitle = "by Rafa (discord.gg/MilkUp)",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil,
      FileName = "MyRestaurant"
   }
})

-------------------------//
--// Farm Category
-------------------------//
local FarmTab = Window:CreateTab("Farm")

local InstantSection = FarmTab:CreateSection("Instant Options")
local FastOrderToggle = FarmTab:CreateToggle({
   Name = "Instant Order",
   CurrentValue = true,
   Flag = "FastOrder",
   Callback = function(Value)
		FastOrder = Value
		
		if Value then
			for v, i in pairs(Debris:GetChildren()) do
				local children = i:GetChildren()
				if OptimizedMode and (i.Name == "host" or (children and #children == 1 and typeof(children[1]) == "Instance" and children[1].ClassName == "Sound"))  then
					i:Destroy()
				end
			end
		end
   end
})

local FastWaiterToggle = FarmTab:CreateToggle({
   Name = "Instant Waiter",
   CurrentValue = false,
   Flag = "FastWaiter",
   Callback = function(Value)
		FastWaiter = Value
   end
})

local InstantCookToggle = FarmTab:CreateToggle({
	Name = "Instant Cook",
	CurrentValue = false,
	Flag = "InstantCook",
	Callback = function(Value) 
		InstantCook = Value
	end
})

local InstantEatToggle = FarmTab:CreateToggle({
	Name = "Instant Eat",
	CurrentValue = false,
	Flag = "InstantEat",
	Callback = function(Value) 
		InstantEat = Value
	end
})

local InstantWashToggle = FarmTab:CreateToggle({
	Name = "Instant Wash",
	CurrentValue = false,
	Flag = "InstantWash",
	Callback = function(Value) 
		InstantWash = Value
	end
})

local SettingsSection = FarmTab:CreateSection("Farm Options")
local OptimizedModeToggle = FarmTab:CreateToggle({
   Name = "Optimize Game",
   CurrentValue = false,
   Flag = "OptimizedMode",
   Callback = function(Value)
		OptimizedMode = Value
   end
})

local GoldFoodToggle = FarmTab:CreateToggle({
   Name = "Gold Food",
   CurrentValue = false,
   Flag = "GoldFood",
   Callback = function(Value)
		GoldFood = Value
   end
})

FarmTab:CreateParagraph({ Title="Force Best Customer", Content = "This option will force the best customer for each table like:\nBeach table is Lifeguard, UFO table is Alien, [...]\nThis is extremely efficient with Lifeguards/Beach tables ($150k per lifeguard)"})
local ForceCustomerToggle = FarmTab:CreateToggle({
   Name = "Force Best Customer",
   CurrentValue = false,
   Flag = "ForceCustomers",
   Callback = function(Value)
		ForceCustomers = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Royal VIP",
   CurrentValue = false,
   Flag = "ForceVIP",
   Callback = function(Value)
		ForceVIP = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Pirate",
   CurrentValue = false,
   Flag = "ForcePirate",
   Callback = function(Value)
		ForcePirate = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Youtuber",
   CurrentValue = false,
   Flag = "ForceYoutuber",
   Callback = function(Value)
		ForceYoutuber = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Headless",
   CurrentValue = false,
   Flag = "ForceHeadless",
   Callback = function(Value)
		ForceHeadless = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Corrupted VIP",
   CurrentValue = false,
   Flag = "ForceCorruptedVIP",
   Callback = function(Value)
		ForceCorruptedVIP = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Santa",
   CurrentValue = false,
   Flag = "ForceSanta",
   Callback = function(Value)
		ForceSanta = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Elf",
   CurrentValue = false,
   Flag = "ForceElf",
   Callback = function(Value)
		ForceElf = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Lifeguard",
   CurrentValue = false,
   Flag = "ForceLifeguard",
   Callback = function(Value)
		ForceLifeguard = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Alien",
   CurrentValue = false,
   Flag = "ForceAlien",
   Callback = function(Value)
		ForceAlien = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Princess",
   CurrentValue = false,
   Flag = "ForcePrincess",
   Callback = function(Value)
		ForcePrincess = Value
   end
})

FarmTab:CreateToggle({
   Name = "Force Superhero",
   CurrentValue = false,
   Flag = "ForceSuperHero",
   Callback = function(Value)
		ForceSuperHero = Value
   end
})

local SettingsSection = FarmTab:CreateSection("NPCs Options")
local TeleportNPCToggle = FarmTab:CreateToggle({
   Name = "NPC Teleport",
   CurrentValue = false,
   Flag = "TeleportNPC",
   Callback = function(Value)
		TeleportNPC = Value
   end
})

local FastNPCToggle = FarmTab:CreateToggle({
   Name = "Change NPC Walkspeed",
   CurrentValue = false,
   Flag = "FastNPC",
   Callback = function(Value)
		FastNPC = Value
   end
})

local NPCSpeedSlider = FarmTab:CreateSlider({
   Name = "NPC Walkspeed",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Walkspeed",
   CurrentValue = 100,
   Flag = "NPCSpeed",
   Callback = function(Value)
		NPCSpeed = Value
   end,
})


local TeleportTab = Window:CreateTab("Teleport")
local StoreTeleportsSection = TeleportTab:CreateSection("Store")
-- Store Teleports
function TeleportToPosition(position)

	local character = Player.Character or Player.CharacterAdded:Wait()
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if humanoidRootPart then
		humanoidRootPart.CFrame = position
	end
	
end

function CreateTeleport(teleportName, position) 
	local newButton = TeleportTab:CreateButton({
	   Name = teleportName,
	   Callback = function()
			TeleportToPosition(position)
	   end
	})
	
	newButton.UI.ElementIndicator.Text = "teleport"
	table.insert(StoreTeleports, newButton)
end

--CreateTeleport("Global Market", CFrame.new(Vector3.new(-400, 230, 1086)))
-- CreateTeleport("Appliances", CFrame.new(Vector3.new(-326, 230, 1130)))
-- CreateTeleport("Furniture", CFrame.new(Vector3.new(-474, 230, 1130)))
-- CreateTeleport("Floor and Light", CFrame.new(Vector3.new(-492, 255, 1175)))
-- CreateTeleport("Restaurant Themes", CFrame.new(Vector3.new(-310, 255, 1175)))
CreateTeleport("Daily Offers", CFrame.new(-97.3058167, 1611, 536.899536, -0.0209189299, -1.0223701e-07, -0.999781191, 1.16250276e-09, 1, -1.02283714e-07, 0.999781191, -3.3019143e-09, -0.0209189299))
CreateTeleport("Restaurant Themes", CFrame.new(-157.20842, 1611, 631.657166, -0.954549313, -3.4495919e-08, -0.298053086, -7.47909734e-09, 1, -9.1784834e-08, 0.298053086, -8.53839808e-08, -0.954549313))
CreateTeleport("Twitter Verify", CFrame.new(-375.098846, 1611, 500.056335, -0.150306463, 8.26021775e-08, 0.988639474, 1.4371575e-08, 1, -8.13664016e-08, -0.988639474, 1.97841032e-09, -0.150306463))

local PlayerTeleportsSection = TeleportTab:CreateSection("Player Restaurant")

-- local OwnBaseTeleport = TeleportTab:CreateButton({
	-- Name = Player.Name,
	-- Callback = function() 
	
		-- local character = Player.Character or Player.CharacterAdded:Wait()
		-- local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		-- if not humanoidRootPart then return end
		-- local MyBakery = Library.Variables.MyBakery
		-- local VoxelX, VoxelY, VoxelZ = Bakery.GetCustomerStartVoxel(MyBakery, 1, 1)
		-- local QueueX, QueueY, QueueZ = Bakery.GetCustomerQueueVoxel(MyBakery, -5, 1)
		-- local position = MyBakery.floors[1]:WorldPositionFromVoxel(VoxelX, VoxelY, VoxelZ)
		-- local lookAt = MyBakery.floors[1]:WorldPositionFromVoxel(QueueX, QueueY, QueueZ)
		
		-- humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, MyBakery.baseAngle, 0) * CFrame.new(2, 0, -10)
		-- humanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(180), 0)
	-- end
-- })
-- OwnBaseTeleport.UI.ElementIndicator.Text = "teleport"

function AddTeleportToPlayerBakery(player) 
	if not player then return end
	if PlayerTeleports[player] then
		RemoveTeleportToPlayerBakery(player)
	end
	
	PlayerTeleports[player] = TeleportTab:CreateButton({
	   Name = player.Name,
	   Callback = function()
			local playerBakery = Bakery.GetBakeryByOwner(player)
			local character = Player.Character or Player.CharacterAdded:Wait()
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if not humanoidRootPart then return end
			
			local VoxelX, VoxelY, VoxelZ = Bakery.GetCustomerStartVoxel(playerBakery, 1, 1)
			local position = playerBakery.floors[1]:WorldPositionFromVoxel(VoxelX, VoxelZ)
			
			function testtt(p73, offsetFromBakery)
				local bakerySize = 14
				if playerBakery.floors[1].isBiggerPlot then
					bakerySize = 16
				end
				
				if playerBakery.baseOrientation == 0 then
					return bakerySize / 2 - 1 + p73, 0 - offsetFromBakery + 1
				end
				if playerBakery.baseOrientation == 90 then
					return 0 - offsetFromBakery + 1, bakerySize / 2 + 2 - p73
				end
				if playerBakery.baseOrientation == 180 then
					return bakerySize / 2 + 2 - p73, bakerySize - 0 + offsetFromBakery;
				end
				return bakerySize - 0 + offsetFromBakery, bakerySize / 2 + 2 - p73;
			end
			
			local v236, v238 = testtt(1, 10)
			local v241 = playerBakery.floors[1]:WorldPositionFromVoxel(v236, v238);
			
			

			humanoidRootPart.CFrame = CFrame.new((CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, playerBakery.baseAngle, 0) * CFrame.new(2, 0, 0)).p, (CFrame.new(v241) * CFrame.Angles(0, playerBakery.baseAngle, 0) * CFrame.new(2, 0, 0)).p) * CFrame.new(0, 0, -10)
			humanoidRootPart.CFrame *= CFrame.new(2, 0, -10)
			-- humanoidRootPart.CFrame = CFrame.new(position + Vector3.new(0, 2, 0)) * CFrame.Angles(0, playerBakery.baseAngle, 0) * CFrame.new(rotateAngle, 0, 0)
			humanoidRootPart.CFrame *= CFrame.Angles(0, math.rad(180), 0)
	   end
	})
	
	PlayerTeleports[player].UI.ElementIndicator.Text = "teleport"
end


function RemoveTeleportToPlayerBakery(player)
	if PlayerTeleports[player] then
		PlayerTeleports[player]:DestroyMe()
		PlayerTeleports[player] = nil
	end
end

AddTeleportToPlayerBakery(game.Players.LocalPlayer)

-------------------------//
--// AUTOMATION
-------------------------//

local AutomationTab = Window:CreateTab("Automation")
local FarmAutomationSection = AutomationTab:CreateSection("Farm")
local AutoGiftToggle = AutomationTab:CreateToggle({
   Name = "Auto Collect Santa Gifts",
   CurrentValue = false,
   Flag = "AutoGift",
   Callback = function(Value)
		AutoGift = Value
		
		if Value and Workspace:FindFirstChild("__DEBRIS") then
			coroutine.wrap(function() 
				for _, object in pairs(Workspace.__DEBRIS:GetChildren()) do
					if object.Name == "SantaPresent" and object:FindFirstChild("SantaPresent") and object.SantaPresent:FindFirstChild("Activated") then
						pcall(function() 
							local activated = object.SantaPresent.Activated
							for _, connection in pairs(getconnections(activated.Event)) do
								connection:Fire()
								wait()
							end
						end)					
						wait(0.3)
					end
				end
			end)()
		end
   end
})

local function UseWell(wellUID, wellId)
    local event = "RequestWishingWellUsage"
    if wellId == "101" then
        event = "RequestHauntedWishingWellUsage"
    end
	
    Library.Network.Fire(event,wellUID)	
	wait(1)
end

coroutine.wrap(function() 
	while true do 
		if AutoInteract then 
			local bakeryData = Library.Variables.UIDData
			if not bakeryData then return end
		
			for i,v in pairs(bakeryData["Furniture"]) do
				local ID = v.ID
				
				-- Wishing Wells
				if ID and table.find(Wells,ID) and v.ClassName == "Furniture" and not FurnituresCooldowns[v.UID] then
					task.spawn(function()
						local event = "GetWishingWellRefreshTime"
						if ID == "101" then
							event = "GetHauntedWishingWellRefreshTime"
						end
						
						local cooldown = Library.Network.Invoke(event, ID == "101" and v.UID or v.ID)
						
						if cooldown and cooldown == 0 and AutoInteract then
							UseWell(v.UID, ID)
							FurnituresCooldowns[v] = nil
						else
							FurnituresCooldowns[v] = tick() + cooldown
						end
					end)
				end
				
				-- Slot Machines
				if ID and table.find(Slots,ID) then
					task.spawn(function()
						local cooldown = Library.Network.Invoke("GetSlotRefreshTime")
						
						if cooldown and cooldown == 0 and AutoInteract then
							Library.Network.Fire("RequestSlotUsage", v.UID)
							FurnituresCooldowns[v] = nil
							wait(0.5)
						else 
							FurnituresCooldowns[v] = tick() + cooldown
						end
					end)
				end
				
				wait()
			end	
			
			local currentTime = tick()
			-- Make sure that AutoInteract still enabled cause why not
			if AutoInteract then 
				for furniture, cooldown in pairs(FurnituresCooldowns) do 
					local ID = furniture.ID
					
					if cooldown and ID and currentTime >= cooldown then
						if table.find(Wells, ID) and furniture.ClassName == "Furniture" then
							task.spawn(function()
								local event = "GetWishingWellRefreshTime"
								if ID == "101" then
									event = "GetHauntedWishingWellRefreshTime"
								end
								
								-- local cooldown = Library.Network.Invoke(event, ID == "101" and furniture.UID or furniture.ID)
								if cooldown and tick() >= cooldown and AutoInteract then
									UseWell(furniture.UID, ID)
									FurnituresCooldowns[furniture] = nil
								end
							end)
						end
					
						-- COLLECT SLOTS OR UPDATE TIME
						if table.find(Slots, ID) and AutoInteract then
							if cooldown and tick() >= cooldown and AutoInteract then
								Library.Network.Fire("RequestSlotUsage", furniture.UID)
								wait(1)
								FurnituresCooldowns[furniture] = nil
							end
						end
					elseif not cooldown then
						FurnituresCooldowns[furniture] = nil
					end
				end
			end
		end
		wait(1)
	end
end)()

local AutoInteractToggle = AutomationTab:CreateToggle({
	Name = "Auto Slot Machine/Wishing Well",
	CurrentValue = false,
	Flag = "AutoInteract",
	Callback = function(Value) 
		AutoInteract = Value
	end
})


local TiersLayout = {
	Cook = Library.Shared.CookTierLayout, 
	Waiter = Library.Shared.WaiterTierLayout
}

function CheckIfCanBuy(className)
	local stats = Library.Stats.Get(true)
	if not stats then return end

	local allWorkers = Library.Variables.MyBakery:GetAllOfClassName(className)
	if not allWorkers then return end
	
	local level = Library.Experience.BakeryExperienceToLevel(Library.Variables.MyBakery.experience)
	
	for _, tier in pairs(TiersLayout[className]) do 
		local alreadyOwned = false
		for _, worker in pairs(allWorkers) do 
			if tier.Tier == worker.tier then 
				alreadyOwned = true
				break
			end
		end
		
		if not alreadyOwned then 
			if tier.BakeryLevelRequired <= level and tier.Cost < stats.Cash and AutoBuyWorkers then 
				Library.Network.Fire("RequestNPCPurchase", className, tier.Tier)
				wait(0.5)
			end
		end
	end
end


Library.Network.Fired("BakeryLevelUp"):Connect(function()
	if not AutoBuyWorkers then return end

	CheckIfCanBuy("Cook")
	CheckIfCanBuy("Waiter")
end)

local AutoBuyWorkersToggle = AutomationTab:CreateToggle({
	Name = "Auto Buy Workers",
	CurrentValue = false,
	Flag = "AutoBuyWorkers",
	Callback = function(Value) 
		AutoBuyWorkers = Value
		if Value then
			CheckIfCanBuy("Cook")
			CheckIfCanBuy("Waiter")
		end
	end
})

local BlacklistSection = AutomationTab:CreateSection("Blacklist") 
local AutomaticBlacklistToggle = AutomationTab:CreateToggle({
   Name = "Auto Blacklist",
   CurrentValue = false,
   Flag = "AutoBlacklist",
   Callback = function(Value)
		AutoBlacklist = Value
		
		if Value then 
			for _, player in pairs(Players:GetPlayers()) do 
				if player ~= Player and player and player.Name then
					Library.Network.Fire("BlacklistToggled", player.Name, true)
					wait(0.1)
				end
			end
		end
   end
})

local AutoCloseSection = AutomationTab:CreateSection("Close and Open Restaurant")
local _ = AutomationTab:CreateLabel("Useful if your Restaurant start to lag over time")

local AutoCloseTimeSlider = AutomationTab:CreateSlider({
   Name = "Close and Open Every",
   Range = {20, 3600},
   Increment = 10,
   Suffix = "Seconds",
   CurrentValue = 600,
   Flag = "AutoCloseEvery",
   Callback = function(Value)
		AutoCloseEvery = Value	
   end,
})

local AutoCloseToggle = AutomationTab:CreateToggle({
   Name = "Enabled",
   CurrentValue = false,
   Flag = "AutoCloseRestaurant",
   Callback = function(Value)
		if Value then
			LastTimeClose = os.time()
		end
		
		AutoCloseRestaurant = Value
   end
})

coroutine.wrap(function() 

	while true do 
		if AutoCloseRestaurant and LastTimeClose == 0 then
			LastTimeClose = os.time()
		end
	
		if AutoCloseRestaurant and os.time() > LastTimeClose + AutoCloseEvery then 
			
			local success, err = pcall(function() 
				Library.Variables.MyBakery:SetOpenStatus(false)
			end)
			
			wait(5)

			local _, err = pcall(function() 		
				Library.Variables.MyBakery:SetOpenStatus(true)
			end)
	
			LastTimeClose = os.time()
		end
	
		wait(1)
	end
end)()


-------------------------//
--// LAYOUT
-------------------------//
local SelectedFloor = 1

local LayoutTab = Window:CreateTab("Layout")

local CopyButton = nil
local PasteButton = nil

local FloorDropdown = LayoutTab:CreateDropdown({
   Name = "Select a floor",
   Options = { "Floor 1", "Floor 2", "Floor 3", "Floor 4", "Floor 5", "Floor 6", "Floor 7", "Floor 8", "Floor 9","Floor 10" },
   CurrentOption = "Floor 1",
   Flag = "SelectedFloor", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Option)
		local selectedFloor = string.sub(Option, 7)
		
		if selectedFloor and tonumber(selectedFloor) then
			SelectedFloor = tonumber(selectedFloor)
			
			if CopyButton then
				CopyButton:Set("Copy ".. Option .." to Clipboard")
			end
			
			if PasteButton then
				PasteButton:Set("Paste ".. Option .." from Text")
			end
	
		end
		
		UpdateCopyLayoutCost()
   end,
})

local CopySection = LayoutTab:CreateSection("Copy Options") 

local CopyLayoutCost = LayoutTab:CreateLabel("Cost: $0")

function UpdateCopyLayoutCost()
	if SelectedFloor and SelectedFloor >= 1 and SelectedFloor <= 10 then
		local MyBakery = Library.Variables.MyBakery
		if not MyBakery then 
			CopyLayoutCost:Set("Cost: $0")
			return 
		end
		
		if not SelectedFloor or not tonumber(SelectedFloor) or SelectedFloor < 1 or SelectedFloor > 10 then
			CopyLayoutCost:Set("Cost: $0")
			return 
		end
		
		local Floor = MyBakery.floors[SelectedFloor]
		if not Floor then 
			CopyLayoutCost:Set("Cost: $0")
			return 
		end
		

		local totalCost = 0
		
		function AddCost(v)
			if v and v.ID then 
				local item = Library.Directory.Furniture[v.ID]
				if item and item.baseCost and not item.offSale then 
					totalCost = totalCost + item.baseCost
				end
			end
		end
		
		for _, item in pairs(Floor.appliances) do 
			AddCost(item)
		end
		
		for _, item in pairs(Floor.furniture) do 
			AddCost(item)
		end
		
		CopyLayoutCost:Set("Cost: $" .. Library.Functions.Commas(totalCost))
	end

end

CopyButton = LayoutTab:CreateButton({
   Name = "Copy Floor 1 to Clipboard",
   Callback = function()
		if SelectedFloor and SelectedFloor >= 1 and SelectedFloor <= 10 then
			local MyBakery = Library.Variables.MyBakery
			if not MyBakery then return end
			
			local Floor = MyBakery.floors[SelectedFloor]
			if not Floor then return end
			
			function FurnitureToData(furniture)			
				return { 
					["X"] = furniture.xVoxel,
					["Y"] = furniture.yVoxel, 
					["Z"] = furniture.zVoxel,
					["Orientation"] = furniture.orientation
				}
			end
			
			local Items = {
				
			}
			
			for i, item in pairs(Floor.appliances) do 
				if item then
					if not Items[item.className] then 
						Items[item.className] = {}
					end
					
					if not Items[item.className][item.ID] then 
						Items[item.className][item.ID] = {}
					end
					
					
					table.insert(Items[item.className][item.ID], FurnitureToData(item))
				end
			end
			
			for i, item in pairs(Floor.furniture) do 
				if item then
					if not Items[item.className] then 
						Items[item.className] = {}
					end
					
					if not Items[item.className][item.ID] then 
						Items[item.className][item.ID] = {}
					end
					
					table.insert(Items[item.className][item.ID], FurnitureToData(item))
				end
			end
			
			setclipboard(HttpService:JSONEncode(Items))
		end
   end
})



local LayoutToCopy = ""
local PasteSection = LayoutTab:CreateSection("Paste Layout") 
local LayoutInput = LayoutTab:CreateInput({
   Name = "Layout to copy",
   PlaceholderText = "Paste Layout Here",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
		LayoutToCopy = Text
		pcall(function() 
			UpdatePastedLayoutCost()
		end)	
   end
})

-- local v107, v108 = v1.Network.Invoke("Build_RequestEntityPlacementFromInventory", u4.className, u4.ID, u4.floorLevel, u4.vx, u4.vy, u4.vz, u4.orient);
local PastedLayoutCost = LayoutTab:CreateLabel("Cost: $0")

function UpdatePastedLayoutCost()
	local data = HttpService:JSONDecode(LayoutToCopy)
	if not data then 
		PastedLayoutCost:Set("Cost: $0")
		return 
	end
	
	local totalPrice = 0
	for _, ids in pairs(data) do 
		for id, items in pairs(ids) do 
			local item = Library.Directory.Furniture[id]
			if item and item.baseCost and not item.offSale then 
				totalPrice = totalPrice + (item.baseCost * #items)
			end
		end
	end
	
	PastedLayoutCost:Set("Cost: $" .. Library.Functions.Commas(totalPrice))
	
end

local IsPastingLayout = false
local StopPasting = false

PasteButton = LayoutTab:CreateButton({
   Name = "Paste Floor 1 from Text",
   Callback = function()
		if SelectedFloor and SelectedFloor >= 1 and SelectedFloor <= 10 then
			if IsPastingLayout then 
				StopPasting = true
				return
			end
			
			local MyBakery = Library.Variables.MyBakery
			if not MyBakery then return end
			
			if not SelectedFloor or SelectedFloor > 10 or SelectedFloor < 1 then return end
			
			local floor = MyBakery.floors[SelectedFloor]
			if not floor then return end
			
			local inventory = Library.Inventory.Get()
			if not inventory then return end
			
			local data = HttpService:JSONDecode(LayoutToCopy)
			
			if not data then return end
			
			function SetText(text)
				while true do 
					if PasteButton then
						pcall(function() 
							PasteButton:Set(text)
						end)
					end
					break
				end
			end
			
			function Stop()
				IsPastingLayout = false
				StopPasting = false
				
				SetText("Paste Floor ".. SelectedFloor .." from Text")
			end
			
			IsPastingLayout = true
			SetText("Starting in 3...")
			 
			wait(1)
			if StopPasting then Stop() return end
			
			SetText("Starting in 2...") 
			wait(1)
			if StopPasting then Stop() return end
			
			SetText("Starting in 1...")
			 
			wait(1)
			if StopPasting then Stop() return end
			
			for className, ids in pairs(data) do 
				if StopPasting then break end
				if className and ids then
					for id, items in pairs(ids) do 
						if StopPasting then break end
						if id and items then 
							if StopPasting then break end
							
							local item = Library.Directory.Furniture[id]
							if not inventory[className] or not inventory[className][id] or inventory[className][id] < #items then	
								if item and Library.Stats.Get(true).Cash > item.baseCost and not item.offSale then 

									local currentItems = 0
									if inventory[className] and inventory[className][id] and inventory[className][id] then
										currentItems = inventory[className][id]
									end
									local quantityToBuy = #items - currentItems
						
									local attempts = 3
									while quantityToBuy > 0 do 
										local quantity = 1
										if quantityToBuy >= 3 then quantity = 3 end
										
										SetText("Buying " .. quantityToBuy .. "x ".. item.name)	
										
										local success, msg = Library.Network.Invoke("PurchaseGameItem", className, id, quantity)
										
										if success then 
											quantityToBuy = quantityToBuy - quantity
										else 
											attempts = attempts - 1
											if attempts <= 0 then break end
										end
										
										wait(0.3)
										
										if StopPasting then break end
									end

									inventory = Library.Inventory.Get()
								end
							end
							
							local quantityToPlace = #items
							
							if item and item.name and inventory and inventory[className] and inventory[className][id] and inventory[className][id] > 1 then
								if inventory[className][id] <= quantityToPlace then
									quantityToPlace = inventory[className][id]
								end
								SetText("Placing " .. item.name .. " (0/".. quantityToPlace .. ")")
								for currentId, furniture in pairs(items) do 
									if StopPasting then break end
										
									if furniture and furniture.X and furniture.Y and furniture.Z and furniture.Orientation and inventory and inventory[className] and inventory[className][id] and inventory[className][id] > 1 then 
										local x = tonumber(furniture.X)
										local y = tonumber(furniture.Y)
										local z = tonumber(furniture.Z)
										local o = tonumber(furniture.Orientation)
										
										SetText("Placing " .. item.name .. " (".. currentId .."/".. quantityToPlace .. ")")
										if x and y and z and o then
											local n, m = Library.Network.Invoke("Build_RequestEntityPlacementFromInventory", className, id, SelectedFloor, x, y, z, o)
										end
										wait(0.1)
									end
								end
							end
							
							
						
						end
					end
				end
			end
			

			Stop()
		end
   end
})

-------------------------//
--// Discord Webhook
-------------------------//
local webhookTab = Window:CreateTab("Webhook")
local WebhookEnabled = false
local WebhookURL = ""
local WebhookUpdateTime = 20
local WebhookLastTime = tick()
local AlreadyCompletedChefCat = false

function SendWebhook(skipError, receivedStats)
	local stats = receivedStats or Library.Stats.Get()
	if not stats then WebhookTryAgain(skipError) return end
	local statsString = ""
	
	if stats.ChefCatProgress then
		statsString = statsString .. string.format("**Chef Cat Progress:** %s/100,000\n", Library.Functions.Commas(stats.ChefCatProgress))
	end

	if stats.TimeSpentInGame then
		local timeSpentInGame = stats.TimeSpentInGame
		local totalTime = timeSpentInGame + math.floor(tick() - StartTick);
		local hours = 0
		local days = 0
		local minutes = 0
		if totalTime > 86400 then
			days = math.floor(totalTime / 86400)
			totalTime = totalTime % 86400
		end
		if totalTime > 3600 then
			hours = math.floor(totalTime / 3600)
			totalTime = totalTime % 3600
		end
		if totalTime > 60 then 
			minutes = math.floor(totalTime / 60)
			totalTime = totalTime % 60
		end
		local seconds = math.floor(totalTime)
		
		statsString = statsString .. "**Time Spent:** "
		if days > 0 then
			statsString = statsString .. string.format("%d days ", days)
		end
		
		if hours > 0 then
			statsString = statsString .. string.format("%d hours ", hours)
		end
		
		if minutes > 0 then
			statsString = statsString .. string.format("%d minutes ", minutes)
		end
		
		if seconds > 0 then
			statsString = statsString .. string.format("%d seconds ", seconds)
		end
		
		statsString = statsString .. "\n"
		
		--statsString = statsString .. string.format("**Time Spent:** %02d days, %02d hours and %02d minutes\n",  days, hours, (math.floor(totalTime / 60)))
	end

	if stats.ServedCustomers then
		statsString = statsString .. string.format("**Served Customers:** %s\n", Library.Functions.Commas(stats.ServedCustomers))
	end
		
	if stats.Cash then
		statsString = statsString .. string.format("**Current Cash:** $%s\n", Library.Functions.Commas(stats.Cash))
	end
	
	if stats.CashEarned then
		statsString = statsString .. string.format("**Total Cash Earned:** $%s\n", Library.Functions.Commas(stats.CashEarned))
	end
	
	local embed = {
			["title"] = "Update from your restaurant!",
			["color"] = tonumber(0x3ce42f),

			["fields"] = {
				{
					["name"] = "Restaurant Stats",
					["value"] = statsString,
					["inline"] = false
				}
			}
		}
		
	(syn and syn.request or http_request or http.request) {
		Url = WebhookURL;
		Method = 'POST';
		Headers = {
			['Content-Type'] = 'application/json';
		};
		Body = HttpService:JSONEncode({
			username = "My Restaurant!", 
			avatar_url = 'https://i.imgur.com/C1NnpBl.jpg',
			embeds = {embed} 
		})
	}

	WebhookLastTime = tick()
	
end

-- function SendHugeWebhook()

	-- local embed = {
			-- ["title"] = "BIG NEWS!",
			-- ["description"] = "Congrats, you have **served 100.000 customers** on My Restaurant and got a **Huge Chef Cat** in Pet Simulator X!", 
			-- ["color"] = tonumber(0x3ce42f),
			-- ["thumbnail"] = {
				-- ["url"] = "https://i.imgur.com/6cCss26.png"
			-- }
		-- }
		
	-- (syn and syn.request or http_request or http.request) {
		-- Url = WebhookURL;
		-- Method = 'POST';
		-- Headers = {
			-- ['Content-Type'] = 'application/json';
		-- };
		-- Body = HttpService:JSONEncode({
			-- username = "My Restaurant!", 
			-- avatar_url = 'https://i.imgur.com/C1NnpBl.jpg',
			-- embeds = {embed} 
		-- })
	-- }
-- end


function WebhookTryAgain(skipError)
	if skipError then print("Failed to send webhook!") return end
	print("Failed to send webhook! Trying again in 5 seconds!")
	wait(5)
	SendWebhook()
end

local WebhookToggle = webhookTab:CreateToggle({
   Name = "Enable Discord Webhook",
   CurrentValue = false,
   Flag = "WebhookEnabled",
   Callback = function(Value)
		WebhookEnabled = Value
		
		if Value then 
			WebhookLastTime = tick()
		end
   end
})

local WebhookURLInput = webhookTab:CreateInput({
   Name = "Webhook URL",
   PlaceholderText = "https://discord.com/api/webhooks/0/x",
   RemoveTextAfterFocusLost = false,
   Flag = "WebhookURL",
   CurrentValue = "",
   Callback = function(Text)
		WebhookURL = Text
   end
})

-- 
-- Range: 300, 7200
local WebhookUpdateTimeSlider = webhookTab:CreateSlider({
   Name = "Send every",
   Range = {10, 240},
   Increment = 1,
   Suffix = "Minutes",
   CurrentValue = 20,
   Flag = "WebhookUpdateTime",
   Callback = function(Value)
		WebhookUpdateTime = Value
   end,
})

webhookTab:CreateButton({
	Name = "Test Webhook!",
	Callback = function()
		SendWebhook(true)
	end
})

Rayfield:LoadConfiguration()

coroutine.wrap(function()
	WebhookLastTime = tick()
	-- local stats = Library.Stats.Get()
	-- while true do
		-- if stats then 
			-- if stats.ChefCatProgress and stats.ChefCatProgress >= 100000 then
				-- AlreadyCompletedChefCat = true 
			-- end
			-- break
		-- else 
			-- wait(3)
		-- end
	-- end
	

	while true do 
		-- local hasSendHugeWebhook = false
		-- if not AlreadyCompletedChefCat then 
			-- stats = Library.Stats.Get()
			-- if stats and stats.ChefCatProgress and stats.ChefCatProgress >= 100000 then
				-- pcall(function() 
					-- SendHugeWebhook()
				-- end)
				-- AlreadyCompletedChefCat = true
				-- hasSendHugeWebhook = true
				-- wait(10)
			-- end
		-- end
	
		if WebhookEnabled and WebhookURL and WebhookURL ~= "" and tick() >= WebhookLastTime + (WebhookUpdateTime * 60) then
			SendWebhook(false)
		end
		wait(5)
	end
end)()

-------------------------//
--// Players Handler
-------------------------//
for _, player in pairs(Players:GetPlayers()) do 
	if player ~= Player then
		AddTeleportToPlayerBakery(player)
		
		if AutoBlacklist and player and player.Name then
			Library.Network.Fire("BlacklistToggled", player.Name, true)
			wait(0.1)
		end
	end
end

Players.PlayerAdded:Connect(function(player)
	if player ~= Player then
		AddTeleportToPlayerBakery(player)
		
		if AutoBlacklist and player and player.Name then
			Library.Network.Fire("BlacklistToggled", player.Name, true)
		end
	end
end)

Players.PlayerRemoving:Connect(function(player) 
	RemoveTeleportToPlayerBakery(player)
end)

-------------------------//
--// Anti-AFK
-------------------------//
task.spawn(function()
	if getconnections then
		for i,v in next, getconnections(game.Players.LocalPlayer.Idled) do
			v:Disable()
		end
	end
end)
