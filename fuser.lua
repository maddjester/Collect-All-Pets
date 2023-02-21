local function getPets()
    local Frame = game:GetService("Players").suuuupersimp.PlayerGui.ScreenGui.Main.Pets.PetsContainer.ScrollingFrame
    local t = {}
    for i, v in pairs(Frame:GetDescendants()) do
        if v.ClassName == "TextLabel" and v.Name == "NameLabel" then
            local Name = string.gsub(v.Text, " ", "_")
            table.insert(t, Name)
            --print(Name)
        end
    end
    table.sort(t)
    local A_1 = {}
    for i = 1, 5 do
        local Pet = table.remove(t, 1)
        local Index = 1
        local p = {}
        p.Pet = Pet
        p.Index = Index
        table.insert(A_1, p)
    end
    print("Total Pets:", #t)
    return A_1
end
local Event = game:GetService("ReplicatedStorage").Remotes.FusePets
Event:FireServer(A_1)
