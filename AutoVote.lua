-- Script AutoVote VELOCIDAD EXTREMA (Z Toggle)
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local TargetUser = "iubirea_Tha156"
local scriptActivo = false
local cachedButton = nil

-- Crear Interfaz Flotante
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoVoteGUI"
screenGui.ResetOnSpawn = false

pcall(function() screenGui.Parent = CoreGui end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 90)
mainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
statusLabel.Position = UDim2.new(0, 0, 0.08, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "AHORA: OFF (Tecla 'Z')"
statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.85, 0, 0.38, 0)
toggleButton.Position = UDim2.new(0.075, 0, 0.52, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.Text = "ACTIVAR (Z)"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

local function toggleState()
    scriptActivo = not scriptActivo
    if scriptActivo then
        statusLabel.Text = "AHORA: ON (Tecla 'Z')"
        statusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
        toggleButton.Text = "DESACTIVAR (Z)"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    else
        statusLabel.Text = "AHORA: OFF (Tecla 'Z')"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleButton.Text = "ACTIVAR (Z)"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        cachedButton = nil -- Limpiar memoria al desactivar
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.Z then
        toggleState()
    end
end)

toggleButton.MouseButton1Click:Connect(toggleState)

-- Busca el botón una sola vez
local function findTargetButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    for _, label in pairs(playerGui:GetDescendants()) do
        if (label:IsA("TextLabel") or label:IsA("TextButton")) and string.find(string.lower(label.Text), string.lower(TargetUser)) then
            return label:FindFirstAncestorOfClass("TextButton") 
                or label:FindFirstAncestorOfClass("ImageButton") 
                or label.Parent
        end
    end
    return nil
end

-- Ráfaga instantánea de clics por frame
local function spamClick(guiObject)
    local absolutePosition = guiObject.AbsolutePosition
    local absoluteSize = guiObject.AbsoluteSize
    local clickX = absolutePosition.X + (absoluteSize.X / 2)
    local clickY = absolutePosition.Y + (absoluteSize.Y / 2) + 36
    
    -- Dispara 5 clics de golpe en el mismo fotograma
    for i = 1, 5 do
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
        VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
    end
    
    pcall(function()
        for _, conn in pairs(getconnections(guiObject.MouseButton1Click)) do conn:Fire() end
        for _, conn in pairs(getconnections(guiObject.TouchTap)) do conn:Fire() end
    end)
end

-- Bucle de máxima prioridad (RenderStepped)
RunService.RenderStepped:Connect(function()
    if not scriptActivo then return end
    
    -- Si no tenemos el botón guardado o se destruyó, lo buscamos
    if not cachedButton or not cachedButton:IsDescendantOf(game) then
        cachedButton = findTargetButton()
    end
    
    -- Si el botón existe en pantalla, le hace ráfaga de clics
    if cachedButton then
        pcall(function()
            spamClick(cachedButton)
        end)
    end
end)
