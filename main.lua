-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- Check if GUI already exists
if PlayerGui:FindFirstChild("SnapInsideGui") then
    return
end

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SnapInsideGui"
screenGui.Parent = PlayerGui
screenGui.ResetOnSpawn = false

-- Create Draggable TextButton
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)
button.Position = UDim2.new(0.5, -100, 0.8, 0)
button.Text = "Snap Under + Q + Face"
button.Active = true
button.Draggable = true
button.Parent = screenGui

-- Function to get nearest player
local function getNearestPlayer()
    local character = Player.Character
    if not character then return nil end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local nearestPlayer = nil
    local shortestDistance = math.huge

    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= Player and otherPlayer.Character then
            local otherHRP = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            if otherHRP then
                local distance = (hrp.Position - otherHRP.Position).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    nearestPlayer = otherPlayer
                end
            end
        end
    end

    return nearestPlayer
end

-- Function to snap under the nearest player, face them, and press Q
local function snapUnderAndFaceTarget()
    local nearestPlayer = getNearestPlayer()
    if nearestPlayer and nearestPlayer.Character then
        local character = Player.Character or Player.CharacterAdded:Wait()
        local hrp = character:WaitForChild("HumanoidRootPart")
        local targetHRP = nearestPlayer.Character:FindFirstChild("HumanoidRootPart")
        if targetHRP then
            -- Safe offset under the target (1.5 studs down)
            local offset = Vector3.new(0, -1.5, 0)
            hrp.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)

            -- Simulate pressing Q
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

            -- Stay under target and continuously face them for 0.5 seconds
            local followTime = 0.5
            local elapsed = 0
            local deltaTime = 0.03
            while elapsed < followTime do
                if targetHRP.Parent then
                    -- Snap to position under target and face them
                    hrp.CFrame = CFrame.new(targetHRP.Position + offset, targetHRP.Position)
                end
                elapsed = elapsed + deltaTime
                wait(deltaTime)
            end

            -- Do NOT return to original position
        else
            warn("Nearest player does not have a HumanoidRootPart.")
        end
    else
        warn("No nearby players found.")
    end
end

-- Connect button click
button.MouseButton1Click:Connect(snapUnderAndFaceTarget)
