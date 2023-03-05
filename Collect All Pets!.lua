if not game:IsLoaded() then print("loading --"); game.Loaded:Wait() end;
local ws = game:GetService("Workspace")
local lp = game:GetService("Players").LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local chr = lp.Character
local noid = chr:FindFirstChild("Humanoid")
local part = chr:FindFirstChild("HumanoidRootPart")
local screenGui = lp.PlayerGui.ScreenGui
local showCase = screenGui.Hatcher.Showcase
local ContinueButton = showCase.ContinueButton
local equipBest = screenGui.Main.Pets.EquipFrame.EquipBestButton
local Areas = ws.Areas:GetChildren()
local areas = {"Meadow","Forest","Desert","Arctic","Beach","Mountains","Jungle","Main","Grotto","Grove"}
local Crystals = ws.Crystals
local TweenService  = game:GetService("TweenService")
local noclipE = true
local antifall = true

local function getRarity()
    local CheckList = lp.PlayerGui.ScreenGui.Main.Left.Checklist
    local t
    for _, v in pairs(CheckList:GetDescendants()) do
        if v.Name == "Checkmark" then
            if not v.Check.Visible then
                -- print(v.Parent.RarityLabel.Text)
                t = v.Parent.RarityLabel.Text
                if t == "Ascended" or t == "Mythical"  then
                    t = "Common"
                end
            end
        end
    end
    return t
end

local function buySlot(area)
    local Event = game:GetService("ReplicatedStorage").Remotes.BuyPetEquipSlot
    Event:FireServer(area)
end

local function autoSlots()
    while true do
        if not getgenv().SLOTS then break end;
        for i = 1, 5 do
            buySlot(i)
        end
        task.wait(10)
    end
end

local function buyEgg(index)
    local Event = game:GetService("ReplicatedStorage").Remotes.BuyEgg
    if ws.Camera.CameraType ~= "Custom" and showCase.Visible then
        pcall(function()
            firesignal(ContinueButton.Activated)
            task.wait(0.1)
        end)
    end
    Event:FireServer(index)
end

local function fireRebirth()
    local Event = game:GetService("ReplicatedStorage").UI.Remotes.OnRebirth
    Event:FireServer()
end

local function autoDiscover()
    local rndNum = math.random(1, 6)
    local rarities = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Prodigious"] = 6,
        ["Ascended"] = rndNum,
        ["Mythical"] = rndNum
    }
    while true do
        if not getgenv().DISCOVER then break end;
        local r = getRarity()
        if r and rarities[r] then
            -- print(rarities[r])
            buyEgg(rarities[r])
            task.wait(2)
        else
            if getgenv().REBIRTH then
                fireRebirth()
            end
        end
        task.wait(1)
    end
end

local function antiIdle()
    task.wait(3)
    lp.Idled:connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
end

local function shuffleObjs(t)
    local shuffled = {}
    for _, v in ipairs(t) do
        local pos = math.random(1, #shuffled+1)
        table.insert(shuffled, pos, v)
    end
    return shuffled
end

local function noclip()
    for i, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("BasePart") and v.CanCollide == true then
            v.CanCollide = false
            game.Players.LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0,0,0)
        end
    end
end

local function removeBarriers()
    local AreaBarriers = ws.AreaBarriers
    for i, v in pairs(AreaBarriers:GetDescendants()) do
        if v.Name == "Part" or v.Name == "Wall" then
            v.Transparency = 1
            v.CanCollide = false
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

local function clickSlots()
    local modifier = {
        "PetSlot_1",
        "PetSlot_2",
        "PetSlot_3",
        "PetSlot_4",
        "PetSlot_5",
    }
    for i = 1, #modifier do
        local slot = lp.PlayerGui.ScreenGui.Main.Pets.FuseFrame[modifier[i]]
        pcall(function()
            firesignal(slot.Button.Activated)
            task.wait(0.1)
        end)
    end
end

local Pets = lp.PlayerGui.ScreenGui.Main.Pets
local container = Pets.PetsContainer.ScrollingFrame
local fuseBtn = Pets.FuseFrame.FuseButton
local FuseFrame = Pets.FuseFrame
local fuseTab = Pets.FuseButton

local filterList = Pets.FilterFrame.Inset.List
local petsBtn = lp.PlayerGui.ScreenGui.Main.Bottom.PetsButton
local fuseLabel = Pets.FuseFrame.FuseButton.FuseLabel

local function fusePets()
    local filters = {}
    for _, f in pairs(filterList:GetChildren()) do
        if f.Name ~= "Equipped" and f.ClassName == "ImageButton" then
            table.insert(filters, f)
        end
    end

    while true do
        if not getgenv().FUSE then break end;
        for _, f in pairs(filters) do
            pcall(function()
                firesignal(f.Activated)
                task.wait(0.1)
            end)
            if not FuseFrame.Visible then
                pcall(function()
                    firesignal(fuseTab.Activated)
                    task.wait(0.1)
                end)
            end
            if Pets and not Pets.Visible then
                pcall(function()
                    firesignal(petsBtn.Activated)
                    task.wait(0.1)
                end)
            end
            clickSlots()
            local pets = shuffleObjs(container:GetChildren())
            for _, v in ipairs(pets) do
                if not getgenv().FUSE then break end;
                if fuseLabel.Text == "Fuse" then break end;
                if v.ClassName == "TextButton" then
                    pcall(function()
                        firesignal(v.Activated)
                        task.wait(0.1)
                    end)
                end
            end
            if fuseLabel.Text == "Fuse" then
                firesignal(fuseBtn.Activated)
                repeat task.wait(1) until ContinueButton.Parent.Visible
                task.wait(1)
                pcall(function()
                    firesignal(ContinueButton.Activated)
                    task.wait(0.1)
                end)
            else
                clickSlots()
            end
        end
        task.wait(1)
    end
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
        -- print(i, v)
        if v.Active.Value then
            if v.Area.Value <= lp.UnlockedArea.Value then
                a = v.Area.Value
            end
        end
    end
    return a
end

local function getProgress()
    local g, p = 0, -1
    if lp.QuestGoal and lp.QuestProgress then
        g, p = lp.QuestGoal.Value, lp.QuestProgress.Value
    end
    return g, p
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
                task.wait(4)
                firesignal(equipBest.Activated)
            end)
        end
    end
end

local function collectHiddenEggs()
    local Eggs = ws.HiddenEggs
    for i, v in pairs(Eggs:GetChildren()) do
        if v.Area.Value <= lp.UnlockedArea.Value then
            if ws.Camera.CameraType ~= "Custom" and showCase.Visible then
                task.wait(1)
                pcall(function()
                    firesignal(ContinueButton.Activated)
                    task.wait(0.1)
                end)
            end
            firetouchinterest(v, part, 0)
            task.wait(0.3)
            firetouchinterest(v, part, 1)
            print("Found:", v.Name)
        end
    end
end

local function autoQuest()
    if getgenv().QUEST then
        local questCompleted = 0
        antiIdle()

        while task.wait(2) do
            if not getgenv().QUEST then break end;
            if not part then repeat task.wait(1) until part end;
            if noid.Sit then noid.Sit = not noid.Sit end;
            if ws.Camera.CameraType ~= "Custom" and showCase.Visible then
                task.wait(1)
                pcall(function()
                    firesignal(ContinueButton.Activated)
                    task.wait(0.1)
                end)
            end
            local inArea, questArea = getAreas() -- Get updated values for current area and quest area
            if getSuperArea() and getgenv().SUPER then
                questArea = getSuperArea()
            end
            local nextArea = nextArea(inArea, questArea) -- Figure out which direction to travel positon +1, -1
            -- print("Next Area =", nextArea)
            if inArea == questArea then -- Farm until questArea changes
                local totProg, myProg = getProgress() -- Get Updated values for progress
                if myProg == totProg then -- Claim reward if quest is complete
                    claimReward()
                    questCompleted = questCompleted + 1
                    print("Quests Completed --", questCompleted)
                    if getgenv().ALWAYSEQUIPBEST then
                        firesignal(equipBest.Activated)
                    end
                end
                if getgenv().DAILY then
                    claimDailyEgg()
                end
                if getgenv().EXOTIC then
                    checkExotics(questArea)
                end
                print("Progress/Goal --", myProg, "/", totProg)
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
local b = w:CreateFolder("Area & Questing")
local c = w:CreateFolder("Pets")
local e = w:CreateFolder("Eggs")
local d = w:CreateFolder("Badges & Barriers")
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

getgenv().ALWAYSEQUIPBEST = false
c:Toggle("Always Equip Best Pets", function(bool)
    getgenv().ALWAYSEQUIPBEST = bool
    print("Always Equip Best Pets:", bool)
end)

getgenv().FUSE = false
c:Toggle("Auto-Fuse", function(bool)
    getgenv().FUSE = bool
    print("Auto-Fuse:", bool)
    if bool then
        task.spawn(function()
            fusePets()
        end)
    end
end)

getgenv().DISCOVER = false
c:Toggle("Auto-Discover", function(bool)
    getgenv().DISCOVER = bool
    print("Auto-Discover:", bool)
    if bool then
        task.spawn(function()
            autoDiscover()
        end)
    end
end)

getgenv().REBIRTH = false
c:Toggle("Auto-Rebirth", function(bool)
    getgenv().REBIRTH = bool
    print("Auto-Rebirth:", bool)
end)

getgenv().SLOTS = false
c:Toggle("Auto-Buy Pet Slots", function(bool)
    getgenv().SLOTS = bool
    print("Auto-Buy Pet Slots:", bool)
    if bool then
        task.spawn(function()
            autoSlots()
        end)
    end
end)

c:Button("Equip Best Pets",function()
    firesignal(equipBest.Activated)
end)

getgenv().DAILY = false
e:Toggle("Auto-Claim Daily Egg", function(bool)
    getgenv().DAILY = bool
    if bool then
        task.spawn(function()
            claimDailyEgg()
        end)
    end
    print("Auto-Daily Egg:", bool)
end)

e:Button("Collect Hidden Eggs",function()
    collectHiddenEggs()
end)

e:Dropdown("Select type",{"Common","Uncommon","Rare","Epic","Legendary","Prodigious"}, true, function(eggType)
    getgenv().EGGTYPE = eggType
    print("Selected Type:", eggType)
end)

getgenv().EGGTYPE = nil
e:Button("Buy Egg", function()
    local eggNum = {
        ["Common"] = 1,
        ["Uncommon"] = 2,
        ["Rare"] = 3,
        ["Epic"] = 4,
        ["Legendary"] = 5,
        ["Prodigious"] = 6,
    }
    local eggPrice = {
        ["Common"] = 7500,
        ["Uncommon"] = 35000,
        ["Rare"] = 160000,
        ["Epic"] = 750000,
        ["Legendary"] = 3500000,
        ["Prodigious"] = 7500000
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

d:Button("Remove Barriers", function()
    removeBarriers()
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