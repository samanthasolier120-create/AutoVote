-- Script AutoVote Ultra-Rápido con Toggle de Tecla "O" para Delta
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local TargetUser = "iubirea_Tha156"
local scriptActivo = false

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
statusLabel.Text = "AHORA: OFF (Tecla 'O')"
statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = mainFrame

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.85, 0, 0.38, 0)
toggleButton.Position = UDim2.new(0.075, 0, 0.52, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
toggleButton.Text = "ACTIVAR (O)"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- Función para Activar/Desactivar
local function toggleState()
    scriptActivo = not scriptActivo
    if scriptActivo then
        statusLabel.Text = "AHORA: ON (Tecla 'O')"
        statusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
        toggleButton.Text = "DESACTIVAR (O)"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    else
        statusLabel.Text = "AHORA: OFF (Tecla 'O')"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleButton.Text = "ACTIVAR (O)"
        toggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end

-- Detectar la tecla "O" del teclado
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    -- Si no estás escribiendo en el chat y presiones 'O'
    if not gameProcessed and input.KeyCode == Enum.KeyCode.O then
        toggleState()
    end
end)

-- También funciona haciendo clic en la pantalla por si estás en móvil
toggleButton.MouseButton1Click:Connect(toggleState)

-- Función ultra-rápida de clic
local function clickGUIElement(guiObject)
    local absolutePosition = guiObject.AbsolutePosition
    local absoluteSize = guiObject.AbsoluteSize
    
    local clickX = absolutePosition.X + (absoluteSize.X / 2)
    local clickY = absolutePosition.Y + (absoluteSize.Y / 2) + 36
    
    -- Disparo instantáneo de clics
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, true, game, 1)
    VirtualInputManager:SendMouseButtonEvent(clickX, clickY, 0, false, game, 1)
    
    pcall(function()
        for _, conn in pairs(getconnections(guiObject.MouseButton1Click)) do conn:Fire() end
        for _, conn in pairs(getconnections(guiObject.TouchTap)) do conn:Fire() end
    end)
end

-- Bucle a máxima velocidad (RenderStepped)
RunService.RenderStepped:Connect(function()
    if not scriptActivo then return end
    
    pcall(function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            for _, label in pairs(playerGui:GetDescendants()) do
                if (label:IsA("TextLabel") or label:IsA("TextButton")) and string.find(string.lower(label.Text), string.lower(TargetUser)) then
                    local btn = label:FindFirstAncestorOfClass("TextButton") 
                             or label:FindFirstAncestorOfClass("ImageButton") 
                             or label.Parent
                    
                    if btn then
                        clickGUIElement(btn)
                    end
                end
            end
        end
    end)
end)
