-- Script Ultra-Rápido con UI para Delta
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local MyUserId = LocalPlayer.UserId
local MyAvatarImage = "rbxthumb://type=AvatarHeadShot&id=" .. MyUserId .. "&w=150&h=150"

local scriptActivo = false
local cachedButton = nil

-- Crear Interfaz Gráfica (GUI)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoVoteGUI"
screenGui.ResetOnSpawn = false

-- Asignar GUI al CoreGui para evitar que desaparezca si el personaje muere
pcall(function()
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Marco principal flotante
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 100)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Puedes arrastrar la ventana por la pantalla
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

-- Texto de Estado
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
statusLabel.Position = UDim2.new(0, 0, 0.1, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "ESTADO: DESACTIVADO"
statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
statusLabel.TextSize = 14
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.Parent = mainFrame

-- Botón de Activar/Desactivar
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0.8, 0, 0.35, 0)
toggleButton.Position = UDim2.new(0.1, 0, 0.55, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "ACTIVAR"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.TextSize = 14
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = toggleButton

-- Función de cambio de estado
toggleButton.MouseButton1Click:Connect(function()
    scriptActivo = not scriptActivo
    
    if scriptActivo then
        statusLabel.Text = "ESTADO: ACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(60, 255, 60)
        toggleButton.Text = "DESACTIVAR"
        toggleButton.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    else
        statusLabel.Text = "ESTADO: DESACTIVADO"
        statusLabel.TextColor3 = Color3.fromRGB(255, 60, 60)
        toggleButton.Text = "ACTIVAR"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        cachedButton = nil
    end
end)

-- Lógica para buscar el botón de voto
local function getMyButton()
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then return nil end
    
    for _, element in pairs(playerGui:GetDescendants()) do
        if element:IsA("ImageLabel") or element:IsA("ImageButton") then
            if string.find(tostring(element.Image), tostring(MyUserId)) or element.Image == MyAvatarImage then
                return element:FindFirstAncestorOfClass("ImageButton") 
                    or element:FindFirstAncestorOfClass("TextButton") 
                    or (element:IsA("ImageButton") and element)
            end
        end
    end
    return nil
end

-- Bucle de votación automática
RunService.RenderStepped:Connect(function()
    if not scriptActivo then return end
    
    if not cachedButton or not cachedButton:IsDescendantOf(game) then
        cachedButton = getMyButton()
    end
    
    if cachedButton then
        pcall(function()
            for _, conn in pairs(getconnections(cachedButton.MouseButton1Click)) do
                conn:Fire()
            end
            for _, conn in pairs(getconnections(cachedButton.MouseButton1Down)) do
                conn:Fire()
            end
        end)
    end
end)
