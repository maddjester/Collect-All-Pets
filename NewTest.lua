local lp = game:GetService("Players").LocalPlayer
local Areas = game:GetService("Workspace").Areas
local part = lp.Character:FindFirstChild("HumanoidRootPart")
local myArea = lp.Area.Value

local function positions()
    local areas = {}
    for i, v in pairs(Areas:GetChildren()) do
        --print(i, v)
        if v.Name ~= "Main" then
            table.insert(areas, i, v)
        end
    end
    return areas
end

local function findTarget(dist)
    local target = nil
    if lp.Character and part then
        local areas = Areas:GetChildren()
        local p = positions()
        if p then
            for i, prt in pairs(p) do
                print(i, prt)
                print(areas[myArea])
                if prt ~= areas[myArea] then
                    if (prt.Position - part.Position).Magnitude < dist then
                        dist = (prt.Position - part.Position).Magnitude
                        target = prt
                    end
                end
            end
        end
    end
    return target
end

local function tweenTo(pos)
    local tween_s = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new(7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0)
    local newPos = pos + Vector3.new(0, 6, 0)
    local cf = CFrame.new(pos) 
    if part then
        local animation = tween_s:Create(part, tweeninfo, {CFrame = cf})
        if not part then repeat task.wait(1) until part end;
        part.CanCollide = false
        part.Anchored = false

        animation:Play()
        keypress(0x45)
        task.wait(7)
        keyrelease(0x45)
        animation:Cancel()
        animation:Destroy()
    end
end

getgenv().TOGGLE = true

while wait(1) do
    if not getgenv().TOGGLE then break end;
    local target = findTarget(500)
    if target then
        tweenTo(target.Position)
    end
end
