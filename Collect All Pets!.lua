print("loading --")
local lp = game:GetService("Players").LocalPlayer
local chr = lp.Character
local noid = chr:FindFirstChild("Humanoid")
local part = chr:FindFirstChild("HumanoidRootPart")
local Areas = game:GetService("Workspace").Areas
local AreaBarriers = game:GetService("Workspace").AreaBarriers

local function tweenTo(pos)
    if not part then repeat task.wait(1) until part end;
    part.CanCollide = false
    part.Anchored = false
    if noid.Sit then noid.Sit = not noid.Sit end;

    local tween_s = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new(5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, false, 0)
    --local newPos = pos + Vector3.new(0, 6, 0)
    local charCF = lp.Character:GetPrimaryPartCFrame()
    local dir = ((pos - charCF.Position) * Vector3.new(1, 0, 1)) + Vector3.new(0, charCF.Position.Y, 0)
    local newCF = CFrame.lookAt(charCF.Position + dir, Vector3.new(0, 1, 0))
    --local cf = CFrame.new(newPos)
    local animation = tween_s:Create(part, tweeninfo, {CFrame = newCF})
    keypress(0x57)
    animation:Play()
    task.wait(5)
    keyrelease(0x57)
    animation:Cancel()
    animation:Destroy()
end

local function getWaypoints()
    local areas = Areas:GetChildren()
    local names, positions = {}, {}
    for i, c in pairs(areas) do
        if c then
            if c.Name and c.Position then
                --print(c.Name, c.Position)
                if c.Name ~= "Main" then
                    table.insert(names, c.Name)
                    table.insert(positions, c.Position)
                    for i2, b in pairs(AreaBarriers:GetDescendants()) do
                        if b == "Model" then
                            if c.Name == areas[b.Area.Value] then
                                table.insert(positions, b.Wall.Position)
                            end
                        end
                    end
                end
            end
        end
    end
    return names, positions
end

local function keyPress(str)
    if str then
        local event = game:GetService("VirtualInputManager")
        event:SendKeyEvent(true, str, false, game)
        task.wait()
        event:SendKeyEvent(false, str, false, game)
    end
end


local function buyEggs(index, count)
    for i = 1, count do
        local Event = game:GetService("ReplicatedStorage").Remotes.BuyEgg
        Event:FireServer(index)
        task.wait(2)
        keyPress("E")
        print(index)
    end
end

local function claimReward()
    local Event = game:GetService("ReplicatedStorage").Remotes.ClaimQuestReward
    Event:FireServer()
    task.wait(2)
    keyPress("E")
    task.wait(10)
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
        local questCompleted = 0
        if lp.Badge_CrystalsDestroyed.Value < 99999 then
            lp.Badge_CrystalsDestroyed.Value = 99999 -- Magnet hack
        end

        while task.wait(5) do
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
                if myProg == totProg then
                    claimReward()
                    keyPress("E")
                    questCompleted = questCompleted + 1
                    print("Quests Completed --", questCompleted)
                end
                print("Quest completed/total --", myProg.."/"..totProg)
            elseif inArea ~= nextArea then -- Move to next area if not in the questArea
                print("In -->", areas[inArea], "Moving to -->", areas[nextArea])
                tweenTo(v3s[nextArea])
            end

            print("In -->", areas[inArea], "Quest -->", areas[questArea])
        end
    end
end
getgenv().SCRIPT = false
local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()
local w = library:CreateWindow("collect all pets") -- Creates the window
local b = w:CreateFolder("Farming") -- Creates the folder(U will put here your buttons,etc)

b:Toggle("Auto Quest",function(bool)
    getgenv().SCRIPT = bool
    print("Auto Quest:", bool)
    if bool then
        autoQuest()
    end
end)
b:Dropdown("Teleport to Area",getWaypoints(),true,function(area)
    local envs = {
        [1] = "Meadow",
        [2] = "Forest"
    }
    tweenTo(Areas[area].Position)
end)
local eggNum = {
    ["Common"] = 1,
    ["Unommon"] = 2,
    ["Rare"] = 3,
    ["Epic"] = 4,
    ["Legendary"] = 5,
}
b:Dropdown("Buy 5 Eggs",{"Common","Unommon","Rare","Epic","Legendary"},true,function(eggType)
    
    buyEggs(eggNum[eggType], 5)
    print("Bought 5 of", eggType)
end)

b:Button("Reset Character",function()
    game:GetService("Players").LocalPlayer.Character:FindFirstChild("Humanoid").Health = 0
end)

b:DestroyGui()
print("loaded --")