if not isrbxactive() then repeat task.wait(1) until isrbxactive() end;

local lp = game:GetService("Players").LocalPlayer
local chr = lp.Character
local noid = chr:WaitForChild("Humanoid")
local part = chr:WaitForChild("HumanoidRootPart")

print("++")
getgenv().SCRIPT = true
local questCompleted = 0

local function tweenTo(pos)
    if type(pos) == "vector" then
        local tween_s = game:GetService("TweenService")
        local tweeninfo = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
        local pos = pos + Vector3.new(0, 6, 0)
        local cf = CFrame.new(pos)
        local animation = tween_s:Create(part, tweeninfo, {CFrame = cf})
        if not part then repeat task.wait(1) until part end;
        part.CanCollide = false
        part.Anchored = false
        if noid.Sit then noid.Sit = not noid.Sit end;

        animation:Play()
        task.wait(7)
        animation:Cancel()
        animation:Destroy()
    end
end

local function keyPress(str)
    if str then
        local event = game:GetService("VirtualInputManager")
        event:SendKeyEvent(true, str, false, game)
        event:SendKeyEvent(false, str, false, game)
    end
end

local function mouseClick(x, y)
    if x and y then
        local event = game:GetService("VirtualInputManager")
        event:SendMouseButtonEvent(x, y, 1, true)
        task.wait(0.2)
        event:SendMouseButtonEvent(x, y, 1, false)
    end
end

local function buyEgg(index, count)
    local d = {
        [1] = {["Name"] = "Common", ["Price"] = 7500},
        [2] = {["Name"] = "Unommon", ["Price"] = 35000},
        [3] = {["Name"] = "Rare", ["Price"] = 160000},
        [4] = {["Name"] = "Epic", ["Price"] = 750000},
        [5] = {["Name"] = "Legendary", ["Price"] = 3500000}
    }
    if type(d[index]) == "table" then
        local name = d[index].Name
        local price = d[index].Price
        print(name)
        for i = 1, count do
            local Event = game:GetService("ReplicatedStorage").Remotes.BuyEgg
            Event:FireServer(index)
            print("Bought", name, "egg", "Cost:l", price)
            task.wait(2)
            keyPress("E")
        end
    end
end

local function claimReward()
    local Event = game:GetService("ReplicatedStorage").Remotes.ClaimQuestReward
    Event:FireServer()
    task.wait(5)
    keyPress("E")
end

local function getWaypoints()
    local Areas = game:GetService("Workspace").Areas
    local names, positions = {}, {}
    for i, c in pairs(Areas:GetChildren()) do
        if c then
            if c.Name and c.Position then
                --print(c.Name, c.Position)
                table.insert(names, c.Name)
                table.insert(positions, c.Position)
            end
        end
    end
    return names, positions
end

local function nextArea(area, area2)
    if area == area2 then return 0 end;      
    local i = 1
    if area > area2 then i = -i end;
    local result = area + i
    return result
end

local function getAreas()
    local a, q = 0, 0
    if lp.Area.Value and lp.QuestArea.Value then
        a, q = lp.Area.Value, lp.QuestArea.Value
        if q == 0 then q = 1 end;
        return a, q
    end
end

local function getProgress()
    local g, p = 0, 0
    if lp.QuestGoal and lp.QuestProgress then
        g, p = lp.QuestGoal.Value, lp.QuestProgress.Value
        return g, p
    end
end

local function returnPets(n)
    local petFrame = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Main.Pets.PetsContainer.ScrollingFrame
    local r = {"Common","Uncommon","Rare","Epic","Legendary","Prodigious","Ascended","Mythical"}
    
    print("Searching for", r[n], "pets...")
    local results = {}
    local index = 1
    for i, v in pairs(petFrame:GetDescendants()) do
        if v.Name == "RarityLabel" then
            if v.Text == r[n] then
                local name = v.Parent.NameLabel.Text:gsub(" ","_")
                table.insert(results, index, name)
            end
        end
    end
    return results
end

local function fireFuse(args)
    local args = args or {}
    local Event = game:GetService("ReplicatedStorage").Remotes.FusePets
    Event:FireServer(args)
    task.wait(5)
end

local function fuseAll(n)
    local names = returnPets(n)
    local payload = {}
    local last
    local logtable = {}

    for _, log in pairs(names) do
        local index = log
        logtable[index] = (logtable[index] or 0) + 1
    end
    print("Found", #names, "pets to Fuse")

    for k, v in pairs(logtable) do
        print(k, v)
        local pet = {["Pet"] = k, ["Index"] = v}
        table.insert(payload, pet)
    end

    local final = {}
    for i = 1, 5 do
        table.insert(final, i, payload[i])
    end
end

local function autoQuest()
    if getgenv().SCRIPT then
        lp.Badge_CrystalsDestroyed.Value = 99999 -- Gold magnet hack (working as of 2/15/2023)

        while task.wait(7) do
            if not getgenv().SCRIPT then break end;
            local inArea, questArea = getAreas() -- Get updated values for current area and quest area
            -- print(inArea, questArea)
            local areas, v3s = getWaypoints() -- Get list of area names and vector3 positions
            -- print(#areas, #v3s)
            local nextArea = nextArea(inArea, questArea) -- Figure out which direction to travel
            -- print(nextArea)
            if nextArea == 0 and questArea == 0 then -- Set next area to first area to avoid timeout if questArea is 0
                nextArea = 1 
            end

            if inArea == questArea then -- Farm until questArea changes
                local totProg, myProg = getProgress()
                print("Waiting --", myProg.."/"..totProg)

                if myProg == totProg then
                    claimReward()
                    keyPress("E")
                    questCompleted = questCompleted + 1
                    print("Quests Completed --", questCompleted)
                end

            elseif inArea ~= nextArea then -- Move to next area if not in the questArea
                print("In -->", areas[inArea], "Moving to -->", areas[nextArea])
                tweenTo(v3s[nextArea])
            end

            print("In -->", areas[inArea], "Quest -->", areas[questArea])
        end
    end
end

autoQuest()
print("--")
noid.Health = 0
