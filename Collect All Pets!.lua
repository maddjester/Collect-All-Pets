if not game:IsLoaded() then print("loading --"); game.Loaded:Wait() end;
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

local TweenService  = game:GetService("TweenService")
local noclipE = true
local antifall = true

local function noclip()
    for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end

local function moveto(obj, speed)
    local info = TweenInfo.new(((game.Players.LocalPlayer.Character.HumanoidRootPart.Position - obj.Position).Magnitude)/ speed,Enum.EasingStyle.Linear)
    local tween = TweenService:Create(game.Players.LocalPlayer.Character.HumanoidRootPart, info, {CFrame = obj})

    if not game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
        antifall = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.HumanoidRootPart)
        antifall.Velocity = Vector3.new(0,0,0)
        noclipE = game:GetService("RunService").Stepped:Connect(noclip)
        tween:Play()
    end
        
    tween.Completed:Connect(function()
        antifall:Destroy()
        noclipE:Disconnect()
    end)
end

local function keyPress(str, secnds)
    local secnds = secnds or 0.1
    if str then
        local event = game:GetService("VirtualInputManager")
        event:SendKeyEvent(true, str, false, game)
        task.wait(secnds)
        event:SendKeyEvent(false, str, false, game)
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

local function claimDailyEgg()
    local Event = game:GetService("ReplicatedStorage").Remotes.ClaimDailyEgg
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
    local a = nil
    for i, v in pairs(Super:GetChildren()) do
        print(i, v)
        if v.Active.Value then
            if v.Area.Value <= lp.UnlockedArea.Value then
                a = v.Area.Value
            end
        end
    end
    return a
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

local function checkExotics(questArea)
    local areaName = Areas[questArea].Name
    local areaCrystals = Crystals[areaName]
    for _, v in pairs(areaCrystals:GetDescendants()) do
        -- print(i, v)
        if v.Name == "Base" and v.Position then
            print("Found Exotic Crystal!")
            pcall(function()
                moveto(v.CFrame + Vector3.new(0,6,0), 50)
            end)
            task.wait(5)
            keyPress("R")
            task.wait(10)
        end
    end
end

local function autoQuest()
    if getgenv().QUEST then
        local questCompleted = 0

        while task.wait(1) do
            if not getgenv().QUEST then break end;
            if not part then repeat task.wait(1) until part end;
            if noid.Sit then noid.Sit = not noid.Sit end;
            if Camera.CameraType ~= "Custom" or Hatcher.Visible then
                keyPress("E", 0.2)
            end

            local inArea, questArea = getAreas() -- Get updated values for current area and quest area

            if getSuperArea() and getgenv().SUPER then
                questArea = getSuperArea()
            end

            local nextArea = nextArea(inArea, questArea) -- Figure out which direction to travel positon +1, -1
            -- print("Next Area =", nextArea)
            if nextArea == 0 and questArea == 0 then -- Set next area to first area to avoid timeout if questArea is 0
                nextArea = 1
            end

            if inArea == questArea then -- Farm until questArea changes
                local totProg, myProg = getProgress() -- Get Updated values for progress
                if myProg == totProg then -- Claim reward if quest is complete
                    claimReward()
                    questCompleted = questCompleted + 1
                    print("Quests Completed --", questCompleted)
                    if getgenv().ALWAYSEQUIPBEST then
                        keyPress("R")
                    end
                end
                if getgenv().EXOTIC then
                    checkExotics(questArea)
                end
                print("Quest Progress/Goal --", myProg.."/"..totProg)
            elseif inArea ~= nextArea and nextArea > 0 then -- Move to next area if not in the questArea
                pcall(function()
                    moveto(Areas[nextArea].CFrame + Vector3.new(0,6,0), 50)
                end)
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
local z = w:CreateFolder("Server/Gui")

getgenv().QUEST = false

b:Toggle("Auto-Quest Complete", function(bool)
    getgenv().QUEST = bool
    print("Auto-Quest Complete:", bool)
    if bool then
        task.spawn(function()
            autoQuest()
        end)
    end
end)

getgenv().SUPER = false

b:Toggle("Go to Super Crystals", function(bool)
    getgenv().SUPER = bool
    print("Auto-Super Crystal:", bool)
end)

getgenv().EXOTIC = false

b:Toggle("Go to Exotic Crystals", function(bool)
    getgenv().EXOTIC = bool
    print("Auto-Exotic Crystal:", bool)
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

c:Toggle("Auto-Claim Daily Egg", function(bool)
    getgenv().QUEST = bool
    print("Auto-Claim Daily Egg:", bool)
    if bool then
        task.spawn(function()
            claimDailyEgg()
        end)
    end
end)

getgenv().ALWAYSEQUIPBEST = false

c:Toggle("Always Equip Best Pets", function(bool)
    getgenv().ALWAYSEQUIPBEST = bool
    print("Always Equip Best Pets:", bool)
end)

c:Button("Equip Best Pets",function()
    keyPress("R")
end)

c:Dropdown("Select type",{"Common","Uncommon","Rare","Epic","Legendary"}, true, function(eggType)
    getgenv().EGGTYPE = eggType
    print("Selected Type:", eggType)
end)

getgenv().EGGTYPE = nil

c:Button("Buy Egg", function()
    local eggNum = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
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
            task.spawn(function()
                buyEgg(eggNum[type])
                print("Bought a", type, "egg!")
            end)
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
    print("Get Badges:", bool)
end)

z:Label("Right Ctrl = Hide/Show Gui",{
    TextSize = 14; -- Self Explaining
    TextColor = Color3.fromRGB(255,255,255); -- Self Explaining
    BgColor = Color3.fromRGB(69,69,69); -- Self Explaining 
})

local function redeemCodes()
    local codes = {
        "ItsAlwaysADesert",
        "Mountaineer",
        "SticksAndStonesAndLevers",
        "ThingsThatHaveWaves",
        "ArcticMoon",
        "ConcaveForward",
        "StrobeLight",
        "FourCrystals",
        "TooMuchBalanceChanges",
        "OverEasy",
        "FiveNewCodes",
        "Stadium",
        "Electromagnetism",
        "Ocean",
        "NotEnoughDrops",
        "ToPointOh",
        "Buttertom_1m",
        "FromTheMachine",
        "Amebas ",
        "MrPocket ",
        "FusionIndy ",
        "LookOut ",
        "Sub2PHMittens ",
        "Chocolatemilk ",
        "Meerkat ",
        "CommonLoon ",
        "Unihorns ",
        "Viper_Toffi ",
        "CrazyDiamond ",
        "eaglenight222 ",
        "GenAutoCalc ",
        "Plasmatic_void",
        "Metallic",
        "OneOutOfEight",
        "MusketeersAndAmigos",
        "OneZero",
        "AndIThinkToMyself",
        "SeasonsAndAMovie",
        "LookOut",
        "InfiniteLoop",
        "BurgersAndFries",
        "ProsperousGrounds",
        "Mountin",
        "DuneBuggy ",
        "FFR",
        "FinalForm ",
        "Shinier",
        "Massproduction",
        "GlitteringGold",
        "FastTyper",
        "ItsTheGrotto",
        "shipwrecked",
        "NewCode",
        "ItsAChicken",
        "SpeedPlayzTree",
        "ImFlying",
        "WhoLetTheDogsOut",
        "ItsAlwaysADesert",
        "DuelingDragons",
        "FewAndFarBetween",
        "KlausWasHere",
        "ShinyHunting",
        "TooManyDrops",
        "TheGreatCodeInTheSky",
        "PillarsOfCreation",
        "TreeSauce",
        "TillFjalls",
        "Orion",
        "HorseWithNoName",
        "IfYouAintFirst",
        "MemoryLeak",
        "SecretCodeWasHere",
        "Taikatalvi",
        "Brrrrr",
        "Click",
        "4815162342",
        "Erdentempel",
        "FirstCodeEver",
        "Groupie"
    }
    for _, code in pairs(codes) do
        local A_1 = code
        print(A_1)
        local Event = game:GetService("ReplicatedStorage").Remotes.RedeemCode
        Event:FireServer(A_1)
    end
    print(unpack(codes))
    print("Codes redeemed!")
end

z:Button("Redeem Codes", function()
    redeemCodes()
end)
z:Button("Server Hop", function()
    local module = loadstring(game:HttpGet"https://raw.githubusercontent.com/LeoKholYt/roblox/main/lk_serverhop.lua")()
    if game and module then
        print("Hopping...")
        module:Teleport(game.PlaceId)
    end
end)

z:DestroyGui()
print("loaded --")