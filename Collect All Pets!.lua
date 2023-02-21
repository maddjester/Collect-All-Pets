print("loading --")
local ws = game:GetService("Workspace")
local lp = game:GetService("Players").LocalPlayer

local chr = lp.Character
local noid = chr:FindFirstChild("Humanoid")
local part = chr:FindFirstChild("HumanoidRootPart")

local Areas = ws.Areas:GetChildren()
local areas = {"Meadow","Forest","Desert","Arctic","Beach","Mountains","Jungle","Main","Tba8","Tba9"}
local AreaBarriers = ws.AreaBarriers
local Camera = ws.Camera
local Hatcher = lp.PlayerGui.ScreenGui.Hatcher
local Crystals = ws.Crystals

local function keyPress(str, secnds)
    local secnds = secnds or 0.1
    if str then
        local event = game:GetService("VirtualInputManager")
        event:SendKeyEvent(true, str, false, game)
        task.wait(secnds)
        event:SendKeyEvent(false, str, false, game)
    end
end

local function tweenTo(pos)
    if pos then
        local dist = (pos - part.Position)
        local timeDelay = (dist / noid.WalkSpeed)

        if noid.Sit then noid.Sit = not noid.Sit end;
        local tween_s = game:GetService("TweenService")
        local tweeninfo = TweenInfo.new(timeDelay, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
        local newPos = pos + Vector3.new(0, 6, -1)
        local cf = CFrame.new(newPos)
        local animation = tween_s:Create(part, tweeninfo, {CFrame = cf})
        keypress(0x57)
        animation:Play()
        task.wait(timeDelay)
        keyrelease(0x57)
        animation:Cancel()
        animation:Destroy()
    end
end

local function buyEgg(index)
    local Event = game:GetService("ReplicatedStorage").Remotes.BuyEgg
    Event:FireServer(index)
end

local function claimReward()
    local Event = game:GetService("ReplicatedStorage").Remotes.ClaimQuestReward
    Event:FireServer()
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

local function getSuperArea()
    local Super = Crystals.Super
    local c = nil
    for _, v in pairs(Super:GetChildren()) do
        -- print(i, v)
        if v.Time.Value > 0 then
            c = v.Area.Value
            return c
        end
    end
end

local function getProgress()
    local g, p = 0, 0
    if getSuperArea() then
        local superFrame = lp.PlayerGui.ScreenGui.Main.Top.SuperCrystalFrame

    end
    if lp.QuestGoal and lp.QuestProgress then
        g, p = lp.QuestGoal.Value, lp.QuestProgress.Value
        return g, p
    end
end

local function getPetNames()
    local pets = require(game:GetService("ReplicatedStorage").DB.Pets)
    local p = {}
    for i, v in pets do
        table.insert(p, i)
    end
    return p
end

local function closeHatcher()
    if Camera.CameraType ~= "Custom" and Hatcher.Visible then
        keyPress("E", 0.2)
    end
end

local function checkExotics(questArea)
    local areaName = Areas[questArea].Name
    local areaCrystals = Crystals[areaName]
    for i, v in pairs(areaCrystals:GetDescendants()) do
        -- print(i, v)
        if v.Name == "Base" and v.Position then
            print("Found Exotic Crystal!")
            tweenTo(v.Position)
            keyPress("R")
            task.wait(5)
        end
    end
end

local function autoQuest()
    if getgenv().QUEST then
        local questCompleted = 0

        while task.wait(5) do
            if not getgenv().QUEST then break end;
            if not part then repeat task.wait(1) until part end
            closeHatcher()

            local inArea, questArea = getAreas() -- Get updated values for current area and quest area
            if getSuperArea() ~= nil then
                questArea = getSuperArea()
            end

            local nextArea = nextArea(inArea, questArea) -- Figure out which direction to travel positon +1, -1
            -- print("Next Area =", nextArea)
            if nextArea == 0 and questArea == 0 then -- Set next area to first area to avoid timeout if questArea is 0
                nextArea = 1
            end
            if inArea == questArea then -- Farm until questArea changes
                checkExotics(questArea)
                local totProg, myProg = getProgress() -- Get Updated values for progress
                if myProg == totProg then -- Claim reward if quest is complete
                    claimReward()
                    questCompleted = questCompleted + 1
                    print("Quests Completed --", questCompleted)
                    if getgenv().ALWAYSEQUIPBEST then
                        keyPress("R")
                    end
                end
                print("Current Quest Progress/Goal --", myProg.."/"..totProg)
            elseif inArea ~= nextArea and nextArea > 0 then -- Move to next area if not in the questArea
                local pos = Areas[nextArea].Position
                print("Moving to:", areas[nextArea])
                tweenTo(pos)
            end
            print("Current Area:", areas[inArea], "Target Area:", areas[questArea])
        end
    end
end

-- GUI Configuration

local library = loadstring(game:HttpGet(('https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wall%20v3')))()
local w = library:CreateWindow("Collect All Pets!")
local b = w:CreateFolder("Questing")
local c = w:CreateFolder("Pets & Eggs")
local d = w:CreateFolder("Badges")
local z = w:CreateFolder("Gui")

getgenv().QUEST = false

b:Toggle("Auto Quest", function(bool)
    getgenv().QUEST = bool
    print("Auto Quest:", bool)
    if bool then
        task.spawn(function()
            autoQuest()
        end)
    end
end)

local function tpTo(place)
    local result = nil
    for i, area in pairs(areas) do
        -- print(area)
        if area == place then
            result = Areas[i]
            if result then
                print("Teleport to:", result.Name, result.Position)
                lp.Character:MoveTo(result.Position)
            end
        end
    end
end

b:Dropdown("Teleport to Area", areas, false, function(place)
    tpTo(place)
end)

getgenv().ALWAYSEQUIPBEST = false
c:Toggle("Always Equip Best Pets", function(bool)
    getgenv().ALWAYSEQUIPBEST = bool
end)
c:Button("Equip Best Pets",function()
    keyPress("R")
end)

c:Dropdown("Select type",{"Common","Unommon","Rare","Epic","Legendary"}, true, function(eggType)
    getgenv().EGGTYPE = eggType
end)
getgenv().EGGTYPE = nil
c:Button("Buy Egg",function()
    local eggNum = {
        ["Common"] = 1,
        ["Unommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5
    }
    local eggPrice = {
        ["Common"] = 7500,
        ["Uncommon"] = 35000,
        ["Rare"] = 160000,
        ["Epic"] = 750000,
        ["Legendary"] = 3500000
    }
    local type = getgenv().EGGTYPE
    local playerGold = lp.Gold.Value
    if type then
        if playerGold >= eggPrice[type] then
            buyEgg(eggNum[type])
            task.wait(3)
            closeHatcher()
            print("Bought a", type, "egg!")
        else
            print("Not enough gold to buy", type, "egg.")
        end
    else
        print("No egg type selected.")
    end
end)

d:Toggle("Get Badges", function(bool)
    local cDestroyed = lp.Badge_CrystalsDestroyed
    local goldGamePass = lp.HasGoldGamePass
    local hasFuseAllGamePass = lp.HasFuseAllGamePass
    local autoCalcify = lp.AutoCalcify
    local HasPetEquipGamePass = lp.HasPetEquipGamePass
    local AutoFuse = lp.AutoFuse
    local AutoEquip = lp.AutoEquip
    local InRebirthArea = lp.InRebirthArea

    goldGamePass.Value = bool
    hasFuseAllGamePass.Value = bool
    autoCalcify.Value = bool
    HasPetEquipGamePass.Value = bool
    AutoFuse.Value = bool
    AutoEquip.Value = bool
    InRebirthArea.Value = bool
    local oldVal = cDestroyed.Value
    if bool then
        if cDestroyed.Value < 99999 then
            cDestroyed.Value = 99999
        end
    else
        cDestroyed.Value = oldVal
    end
end)

z:Label("Right Ctrl = Hide/Show Gui",{
    TextSize = 14; -- Self Explaining
    TextColor = Color3.fromRGB(255,255,255); -- Self Explaining
    BgColor = Color3.fromRGB(69,69,69); -- Self Explaining 
})
z:DestroyGui()
print("loaded --")