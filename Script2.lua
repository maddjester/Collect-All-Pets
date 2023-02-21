local Frame = game:GetService("Players").suuuupersimp.PlayerGui.ScreenGui.Main.Pets.PetsContainer.ScrollingFrame
local types = {"Common","Unommon","Rare","Epic","Legendary","Prodigious","Ascended","Mythical"}

local function FusePets(A_1)
    local Event = game:GetService("ReplicatedStorage").Remotes.FusePets
    Event:FireServer(A_1)
end

local function buildPayload(dict)
    local last
    if dict then
        local tmp = {}
        for i = 1, 5 do
            tmp[i] = {}
            for _, v in pairs(dict) do
                if v then
                    local name = v.NameLabel.Text:gsub(" ", "_")
                    if name ~= last then
                        last = name
                        tmp[i].Pet = name
                        tmp[i].Index = 1
                    end
                end
            end
        end
        return tmp
    end
end

local function getPetObjects()
    local tmp = {}

    for i, t in pairs(types) do
        for i, v in pairs(Frame:GetDescendants()) do
            if v.ClassName == "TextLabel" then
                if v.Name == "RarityLabel" and v.Text and v.Text == t then
                    table.insert(tmp, v.Parent)
                end
            end  
        end
        if #tmp > 4 then
            print("Found", #tmp, t, "Pets")
            local A_1 = buildPayload(tmp)
            --print(A_1[1].Pet)
            FusePets(A_1)
        end
    end
end
getPetObjects()