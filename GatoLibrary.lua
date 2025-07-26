-- Gato Hub V5 Library
-- Biblioteca para criação de interfaces gráficas no Roblox
-- Carregável via loadstring

local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Configuração mínima
local Config = {
    Theme = "Dark",
    FloatingButtonPosition = {X = 20, Y = 100}
}

local Keybinds = {}
local CONFIG_FILE = "gato_hub_v5_config.json"
local KEYBINDS_FILE = "gato_hub_keybinds.json"

-- Temas
local Themes = {
    Dark = {
        Primary = Color3.fromRGB(25, 25, 25),
        Secondary = Color3.fromRGB(35, 35, 35),
        Accent = Color3.fromRGB(40, 40, 40),
        Highlight = Color3.fromRGB(255, 255, 100),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 255, 0),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 165, 0)
    },
    Blue = {
        Primary = Color3.fromRGB(30, 30, 60),
        Secondary = Color3.fromRGB(40, 40, 80),
        Accent = Color3.fromRGB(50, 50, 100),
        Highlight = Color3.fromRGB(100, 150, 255),
        Text = Color3.fromRGB(255, 255, 255),
        Success = Color3.fromRGB(0, 255, 0),
        Error = Color3.fromRGB(255, 100, 100),
        Warning = Color3.fromRGB(255, 165, 0)
    }
}

local CurrentTheme = Themes[Config.Theme] or Themes.Dark

-- Variáveis globais
local Tabs = {}
local UIVisible = true
local floatingDragging = false
local dragging = false

-- Criação do ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GatoHubV5"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

-- Botão flutuante
local FloatingButton = Instance.new("TextButton")
FloatingButton.Name = "FloatingToggle"
FloatingButton.Size = UDim2.new(0, 60, 0, 60)
FloatingButton.Position = UDim2.new(0, Config.FloatingButtonPosition.X, 0, Config.FloatingButtonPosition.Y)
FloatingButton.BackgroundColor3 = CurrentTheme.Secondary
FloatingButton.BorderSizePixel = 0
FloatingButton.Text = "🐱"
FloatingButton.TextColor3 = CurrentTheme.Highlight
FloatingButton.Font = Enum.Font.GothamBold
FloatingButton.TextSize = 24
FloatingButton.ZIndex = 1000
FloatingButton.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(0, 30)
FloatingCorner.Parent = FloatingButton

local FloatingShadow = Instance.new("ImageLabel")
FloatingShadow.Name = "FloatingShadow"
FloatingShadow.BackgroundTransparency = 1
FloatingShadow.Position = UDim2.new(0, Config.FloatingButtonPosition.X + 30, 0, Config.FloatingButtonPosition.Y + 30)
FloatingShadow.Size = UDim2.new(0, 70, 0, 70)
FloatingShadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
FloatingShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
FloatingShadow.ImageTransparency = 0.3
FloatingShadow.ScaleType = Enum.ScaleType.Slice
FloatingShadow.SliceCenter = Rect.new(12, 12, 276, 276)
FloatingShadow.ZIndex = FloatingButton.ZIndex - 1
FloatingShadow.Parent = ScreenGui

-- Janela principal
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 500, 0, 450)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -225)
MainFrame.BackgroundColor3 = CurrentTheme.Primary
MainFrame.BorderSizePixel = 0
MainFrame.ZIndex = 10
MainFrame.Visible = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.BackgroundTransparency = 1
Shadow.Position = MainFrame.Position
Shadow.Size = MainFrame.Size + UDim2.new(0, 20, 0, 20)
Shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(12, 12, 276, 276)
Shadow.ZIndex = MainFrame.ZIndex - 1
Shadow.Parent = ScreenGui

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = CurrentTheme.Secondary
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 11
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = CurrentTheme.Secondary
TitleFix.BorderSizePixel = 0
TitleFix.ZIndex = 11
TitleFix.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.Text = "🐱 Gato Hub V5.0"
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3 = CurrentTheme.Highlight
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 24
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 12
TitleLabel.Parent = TitleBar

-- Botões de controle
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -40, 0.5, -15)
CloseButton.Text = "✕"
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 16
CloseButton.BorderSizePixel = 0
CloseButton.ZIndex = 12
CloseButton.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 15)
CloseCorner.Parent = CloseButton

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 30, 0, 30)
MinimizeButton.Position = UDim2.new(1, -80, 0.5, -15)
MinimizeButton.Text = "—"
MinimizeButton.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.BorderSizePixel = 0
MinimizeButton.ZIndex = 12
MinimizeButton.Parent = TitleBar

local MinimizeCorner = Instance.new("UICorner")
MinimizeCorner.CornerRadius = UDim.new(0, 15)
MinimizeCorner.Parent = MinimizeButton

-- Container de abas
local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Position = UDim2.new(0, 15, 0, 60)
TabContainer.Size = UDim2.new(1, -30, 0, 40)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.ScrollBarThickness = 4
TabContainer.ScrollBarImageColor3 = CurrentTheme.Highlight
TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
TabContainer.ScrollingDirection = Enum.ScrollingDirection.X
TabContainer.ZIndex = 11
TabContainer.Parent = MainFrame

local TabLayout = Instance.new("UIListLayout")
TabLayout.Padding = UDim.new(0, 5)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabLayout.Parent = TabContainer

TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabContainer.CanvasSize = UDim2.new(0, TabLayout.AbsoluteContentSize.X + 20, 0, 40)
end)

-- Container de conteúdo
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Position = UDim2.new(0, 15, 0, 110)
ContentFrame.Size = UDim2.new(1, -30, 1, -125)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 8
ContentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentFrame.ZIndex = 11
ContentFrame.Parent = MainFrame

local ContentLayout = Instance.new("UIListLayout")
ContentLayout.Padding = UDim.new(0, 10)
ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
ContentLayout.Parent = ContentFrame

ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
end)

-- Variáveis para controle de abas
local CurrentTab = nil

-- Funções de gerenciamento de configurações
local function LoadConfig()
    if isfile and readfile and isfile(CONFIG_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(CONFIG_FILE))
        end)
        if success and type(data) == "table" then
            for key, value in pairs(data) do
                Config[key] = value
            end
        end
    end
end

local function SaveConfig()
    if writefile then
        pcall(function()
            writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        end)
    end
end

local function LoadKeybinds()
    if isfile and readfile and isfile(KEYBINDS_FILE) then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile(KEYBINDS_FILE))
        end)
        if success and type(data) == "table" then
            for key, value in pairs(data) do
                Keybinds[key] = Enum.KeyCode[value] or Keybinds[key]
            end
        end
    end
end

local function SaveKeybinds()
    if writefile then
        pcall(function()
            local keybindsToSave = {}
            for key, value in pairs(Keybinds) do
                keybindsToSave[key] = value.Name
            end
            writefile(KEYBINDS_FILE, HttpService:JSONEncode(keybindsToSave))
        end)
    end
end

-- Função para alternar visibilidade da UI
local function ToggleUI()
    if UIVisible then
        MainFrame.Visible = false
        Shadow.Visible = false
        UIVisible = false
        FloatingButton.Text = "👁️"
    else
        MainFrame.Visible = true
        Shadow.Visible = true
        UIVisible = true
        FloatingButton.Text = "🐱"
    end
end

-- Configuração do botão flutuante
FloatingButton.MouseButton1Click:Connect(function()
    if not floatingDragging then
        ToggleUI()
    end
end)

local floatingDragStart = nil
local floatingStartPos = nil
local floatingDragInput = nil

FloatingButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        floatingDragging = true
        floatingDragStart = input.Position
        floatingStartPos = FloatingButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                floatingDragging = false
                Config.FloatingButtonPosition.X = FloatingButton.AbsolutePosition.X
                Config.FloatingButtonPosition.Y = FloatingButton.AbsolutePosition.Y
                SaveConfig()
            end
        end)
    end)
end

FloatingButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        floatingDragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == floatingDragInput and floatingDragging then
        local delta = input.Position - floatingDragStart
        local newPos = UDim2.new(floatingStartPos.X.Scale, floatingStartPos.X.Offset + delta.X, floatingStartPos.Y.Scale, floatingStartPos.Y.Offset + delta.Y)
        FloatingButton.Position = newPos
        FloatingShadow.Position = UDim2.new(0, newPos.X.Offset + 30, 0, newPos.Y.Offset + 30)
    end
end)

FloatingButton.MouseEnter:Connect(function()
    TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 66, 0, 66),
        BackgroundColor3 = CurrentTheme.Accent
    }):Play()
    TweenService:Create(FloatingShadow, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 76, 0, 76),
        ImageTransparency = 0.2
    }):Play()
end)

FloatingButton.MouseLeave:Connect(function()
    TweenService:Create(FloatingButton, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 60, 0, 60),
        BackgroundColor3 = CurrentTheme.Secondary
    }):Play()
    TweenService:Create(FloatingShadow, TweenInfo.new(0.2), {
        Size = UDim2.new(0, 70, 0, 70),
        ImageTransparency = 0.3
    }):Play()
end)

-- Configuração de arrastar a janela
local dragInput = nil
local dragStart = nil
local startPos = nil

local function updateInput(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    Shadow.Position = MainFrame.Position
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateInput(input)
    end
end)

-- Funções de criação de UI
local function CreateNotification(text, color)
    local notification = Instance.new("Frame")
    notification.Size = UDim2.new(0, 300, 0, 60)
    notification.Position = UDim2.new(1, -320, 0, 20)
    notification.BackgroundColor3 = color or CurrentTheme.Secondary
    notification.BorderSizePixel = 0
    notification.ZIndex = 15
    notification.Parent = ScreenGui
    
    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 8)
    notifCorner.Parent = notification
    
    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 1, 0)
    notifText.Position = UDim2.new(0, 10, 0, 0)
    notifText.Text = text
    notifText.TextColor3 = CurrentTheme.Text
    notifText.BackgroundTransparency = 1
    notifText.Font = Enum.Font.Gotham
    notifText.TextSize = 14
    notifText.TextWrapped = true
    notifText.ZIndex = 15
    notifText.Parent = notification
    
    notification:TweenPosition(UDim2.new(1, -320, 0, 20), "Out", "Quad", 0.3, true)
    
    spawn(function()
        wait(3)
        notification:TweenPosition(UDim2.new(1, 20, 0, 20), "In", "Quad", 0.3, true, function()
            notification:Destroy()
        end)
    end)
end

local function ClearContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("GuiObject") and child ~= ContentLayout then
            child:Destroy()
        end
    end
end

local function CreateToggle(text, configKey, callback)
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(1, 0, 0, 45)
    toggleFrame.BackgroundColor3 = CurrentTheme.Accent
    toggleFrame.BorderSizePixel = 0
    toggleFrame.ZIndex = 11
    toggleFrame.Parent = ContentFrame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 8)
    toggleCorner.Parent = toggleFrame
    
    local toggleLabel = Instance.new("TextLabel")
    toggleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    toggleLabel.Position = UDim2.new(0, 15, 0, 0)
    toggleLabel.Text = text
    toggleLabel.TextColor3 = CurrentTheme.Text
    toggleLabel.BackgroundTransparency = 1
    toggleLabel.Font = Enum.Font.Gotham
    toggleLabel.TextSize = 16
    toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
    toggleLabel.ZIndex = 12
    toggleFrame.Parent = toggleFrame
    
    local toggleSwitch = Instance.new("Frame")
    toggleSwitch.Size = UDim2.new(0, 50, 0, 25)
    toggleSwitch.Position = UDim2.new(1, -65, 0.5, -12.5)
    toggleSwitch.BackgroundColor3 = Config[configKey] and CurrentTheme.Success or Color3.fromRGB(100, 100, 100)
    toggleSwitch.BorderSizePixel = 0
    toggleSwitch.ZIndex = 12
    toggleSwitch.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(0, 12.5)
    switchCorner.Parent = toggleSwitch
    
    local switchButton = Instance.new("Frame")
    switchButton.Size = UDim2.new(0, 21, 0, 21)
    switchButton.Position = Config[configKey] and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
    switchButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    switchButton.BorderSizePixel = 0
    switchButton.ZIndex = 12
    switchButton.Parent = toggleSwitch
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10.5)
    buttonCorner.Parent = switchButton
    
    local clickDetector = Instance.new("TextButton")
    clickDetector.Size = UDim2.new(1, 0, 1, 0)
    clickDetector.BackgroundTransparency = 1
    clickDetector.Text = ""
    clickDetector.ZIndex = 12
    clickDetector.Parent = toggleFrame
    
    clickDetector.MouseButton1Click:Connect(function()
        Config[configKey] = not Config[configKey]
        
        local newColor = Config[configKey] and CurrentTheme.Success or Color3.fromRGB(100, 100, 100)
        local newPosition = Config[configKey] and UDim2.new(1, -23, 0.5, -10.5) or UDim2.new(0, 2, 0.5, -10.5)
        
        TweenService:Create(toggleSwitch, TweenInfo.new(0.3), {BackgroundColor3 = newColor}):Play()
        TweenService:Create(switchButton, TweenInfo.new(0.3), {Position = newPosition}):Play()
        
        SaveConfig()
        if callback then callback(Config[configKey]) end
    end)
    
    return toggleFrame
end

local function CreateSlider(text, configKey, min, max, step, callback)
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = UDim2.new(1, 0, 0, 65)
    sliderFrame.BackgroundColor3 = CurrentTheme.Accent
    sliderFrame.BorderSizePixel = 0
    sliderFrame.ZIndex = 11
    sliderFrame.Parent = ContentFrame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 8)
    sliderCorner.Parent = sliderFrame
    
    local sliderLabel = Instance.new("TextLabel")
    sliderLabel.Size = UDim2.new(0.6, 0, 0, 25)
    sliderLabel.Position = UDim2.new(0, 15, 0, 5)
    sliderLabel.Text = text
    sliderLabel.TextColor3 = CurrentTheme.Text
    sliderLabel.BackgroundTransparency = 1
    sliderLabel.Font = Enum.Font.Gotham
    sliderLabel.TextSize = 16
    sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
    sliderLabel.ZIndex = 12
    sliderLabel.Parent = sliderFrame
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.3, 0, 0, 25)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 5)
    valueLabel.Text = tostring(Config[configKey] or min)
    valueLabel.TextColor3 = CurrentTheme.Highlight
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 16
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 12
    valueLabel.Parent = sliderFrame
    
    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -30, 0, 8)
    sliderTrack.Position = UDim2.new(0, 15, 1, -20)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.ZIndex = 12
    sliderTrack.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(0, 4)
    trackCorner.Parent = sliderTrack
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((Config[configKey] or min - min) / (max - min), 0, 1, 0)
    sliderFill.Position = UDim2.new(0, 0, 0, 0)
    sliderFill.BackgroundColor3 = CurrentTheme.Highlight
    sliderFill.BorderSizePixel = 0
    sliderFill.ZIndex = 12
    sliderFill.Parent = sliderTrack
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, 4)
    fillCorner.Parent = sliderFill
    
    local sliderButton = Instance.new("TextButton")
    sliderButton.Size = UDim2.new(0, 20, 0, 20)
    sliderButton.Position = UDim2.new((Config[configKey] or min - min) / (max - min), -10, 0.5, -10)
    sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sliderButton.Text = ""
    sliderButton.BorderSizePixel = 0
    sliderButton.ZIndex = 12
    sliderButton.Parent = sliderTrack
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 10)
    buttonCorner.Parent = sliderButton
    
    local dragging = false
    
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouseX = input.Position.X
            local trackX = sliderTrack.AbsolutePosition.X
            local trackWidth = sliderTrack.AbsoluteSize.X
            local percent = math.clamp((mouseX - trackX) / trackWidth, 0, 1)
            local value = math.floor(((min + ((max - min) * percent)) / step + 0.5) * step)
            value = math.clamp(value, min, max)
            
            Config[configKey] = value
            valueLabel.Text = tostring(value)
            
            TweenService:Create(sliderButton, TweenInfo.new(0.1), {Position = UDim2.new(percent, -10, 0.5, -10)}):Play()
            TweenService:Create(sliderFill, TweenInfo.new(0.1), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
            
            SaveConfig()
            if callback then callback(value) end
        end
    end)
    
    return sliderFrame
end

local function CreateDropdown(text, configKey, options, callback)
    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Size = UDim2.new(1, 0, 0, 45)
    dropdownFrame.BackgroundColor3 = CurrentTheme.Accent
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.ZIndex = 11
    dropdownFrame.Parent = ContentFrame
    
    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 8)
    dropdownCorner.Parent = dropdownFrame
    
    local dropdownLabel = Instance.new("TextLabel")
    dropdownLabel.Size = UDim2.new(0.4, 0, 1, 0)
    dropdownLabel.Position = UDim2.new(0, 15, 0, 0)
    dropdownLabel.Text = text
    dropdownLabel.TextColor3 = CurrentTheme.Text
    dropdownLabel.BackgroundTransparency = 1
    dropdownLabel.Font = Enum.Font.Gotham
    dropdownLabel.TextSize = 16
    dropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
    dropdownLabel.ZIndex = 12
    dropdownLabel.Parent = dropdownFrame
    
    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Size = UDim2.new(0.55, -15, 0, 30)
    dropdownButton.Position = UDim2.new(0.45, 0, 0.5, -15)
    dropdownButton.Text = Config[configKey] or options[1]
    dropdownButton.TextColor3 = CurrentTheme.Text
    dropdownButton.BackgroundColor3 = CurrentTheme.Secondary
    dropdownButton.Font = Enum.Font.Gotham
    dropdownButton.TextSize = 14
    dropdownButton.BorderSizePixel = 0
    dropdownButton.ZIndex = 12
    dropdownButton.Parent = dropdownFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = dropdownButton
    
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.Text = "▼"
    arrow.TextColor3 = CurrentTheme.Highlight
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Gotham
    arrow.TextSize = 12
    arrow.ZIndex = 12
    arrow.Parent = dropdownButton
    
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(1, 0, 0, #options * 30)
    optionsFrame.Position = UDim2.new(0, 0, 1, 5)
    optionsFrame.BackgroundColor3 = CurrentTheme.Secondary
    optionsFrame.BorderSizePixel = 0
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 13
    optionsFrame.Parent = dropdownButton
    
    local optionsCorner = Instance.new("UICorner")
    optionsCorner.CornerRadius = UDim.new(0, 6)
    optionsCorner.Parent = optionsFrame
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
    optionsLayout.Parent = optionsFrame
    
    for _, option in ipairs(options) do
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, 0, 0, 30)
        optionButton.Text = option
        optionButton.TextColor3 = CurrentTheme.Text
        optionButton.BackgroundColor3 = CurrentTheme.Secondary
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.BorderSizePixel = 0
        optionButton.ZIndex = 13
        optionButton.Parent = optionsFrame
        
        optionButton.MouseEnter:Connect(function()
            optionButton.BackgroundColor3 = CurrentTheme.Accent
        end)
        
        optionButton.MouseLeave:Connect(function()
            optionButton.BackgroundColor3 = CurrentTheme.Secondary
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            Config[configKey] = option
            dropdownButton.Text = option
            optionsFrame.Visible = false
            arrow.Text = "▼"
            SaveConfig()
            if callback then callback(option) end
        end)
    end
    
    dropdownButton.MouseButton1Click:Connect(function()
        optionsFrame.Visible = not optionsFrame.Visible
        arrow.Text = optionsFrame.Visible and "▲" or "▼"
    end)
    
    return dropdownFrame
end

local function CreateButton(text, callback)
    local buttonFrame = Instance.new("TextButton")
    buttonFrame.Size = UDim2.new(1, 0, 0, 45)
    buttonFrame.BackgroundColor3 = Color3.fromRGB(70, 50, 50)
    buttonFrame.Font = Enum.Font.GothamBold
    buttonFrame.TextSize = 16
    buttonFrame.Text = text
    buttonFrame.TextColor3 = CurrentTheme.Highlight
    buttonFrame.BorderSizePixel = 0
    buttonFrame.ZIndex = 11
    buttonFrame.Parent = ContentFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = buttonFrame
    
    buttonFrame.MouseEnter:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(90, 60, 60)}):Play()
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        TweenService:Create(buttonFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 50, 50)}):Play()
    end)
    
    buttonFrame.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    
    return buttonFrame
end

local function CreateKeybindSelector(text, keybindKey, callback)
    local keybindFrame = Instance.new("Frame")
    keybindFrame.Size = UDim2.new(1, 0, 0, 45)
    keybindFrame.BackgroundColor3 = CurrentTheme.Accent
    keybindFrame.BorderSizePixel = 0
    keybindFrame.ZIndex = 11
    keybindFrame.Parent = ContentFrame
    
    local keybindCorner = Instance.new("UICorner")
    keybindCorner.CornerRadius = UDim.new(0, 8)
    keybindCorner.Parent = keybindFrame
    
    local keybindLabel = Instance.new("TextLabel")
    keybindLabel.Size = UDim2.new(0.5, 0, 1, 0)
    keybindLabel.Position = UDim2.new(0, 15, 0, 0)
    keybindLabel.Text = text
    keybindLabel.TextColor3 = CurrentTheme.Text
    keybindLabel.BackgroundTransparency = 1
    keybindLabel.Font = Enum.Font.Gotham
    keybindLabel.TextSize = 16
    keybindLabel.TextXAlignment = Enum.TextXAlignment.Left
    keybindLabel.ZIndex = 12
    keybindLabel.Parent = keybindFrame
    
    local keybindButton = Instance.new("TextButton")
    keybindButton.Size = UDim2.new(0.45, -15, 0, 30)
    keybindButton.Position = UDim2.new(0.55, 0, 0.5, -15)
    keybindButton.Text = Keybinds[keybindKey] and Keybinds[keybindKey].Name or "None"
    keybindButton.TextColor3 = CurrentTheme.Text
    keybindButton.BackgroundColor3 = CurrentTheme.Secondary
    keybindButton.Font = Enum.Font.Gotham
    keybindButton.TextSize = 14
    keybindButton.BorderSizePixel = 0
    keybindButton.ZIndex = 12
    keybindButton.Parent = keybindFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = keybindButton
    
    local listening = false
    
    keybindButton.MouseButton1Click:Connect(function()
        if listening then return end
        
        listening = true
        keybindButton.Text = "Press any key..."
        keybindButton.BackgroundColor3 = CurrentTheme.Highlight
        
        local connection
        connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                connection:Disconnect()
                listening = false
                
                Keybinds[keybindKey] = input.KeyCode
                keybindButton.Text = input.KeyCode.Name
                keybindButton.BackgroundColor3 = CurrentTheme.Secondary
                
                SaveKeybinds()
                if callback then callback(input.KeyCode) end
                CreateNotification(text .. " keybind set to " .. input.KeyCode.Name, CurrentTheme.Success)
            end
        end)
        
        spawn(function()
            wait(5)
            if listening then
                connection:Disconnect()
                listening = false
                keybindButton.Text = Keybinds[keybindKey] and Keybinds[keybindKey].Name or "None"
                keybindButton.BackgroundColor3 = CurrentTheme.Secondary
            end
        end)
    end)
    
    return keybindFrame
end

local function CreateParagraph(icon, title, text, colorKey)
    local paragraphFrame = Instance.new("Frame")
    paragraphFrame.Size = UDim2.new(1, 0, 0, 100)
    paragraphFrame.BackgroundColor3 = Config[colorKey] == "Blue" and Color3.fromRGB(50, 50, 150) or
                                      Config[colorKey] == "Green" and Color3.fromRGB(50, 150, 50) or
                                      Config[colorKey] == "Red" and Color3.fromRGB(150, 50, 50) or
                                      CurrentTheme.Accent
    paragraphFrame.BorderSizePixel = 0
    paragraphFrame.ZIndex = 11
    paragraphFrame.BackgroundTransparency = 1
    paragraphFrame.Parent = ContentFrame
    
    local paragraphCorner = Instance.new("UICorner")
    paragraphCorner.CornerRadius = UDim.new(0, 8)
    paragraphCorner.Parent = paragraphFrame
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 40, 0, 40)
    iconLabel.Position = UDim2.new(0, 10, 0, 10)
    iconLabel.Text = icon
    iconLabel.TextColor3 = CurrentTheme.Highlight
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 24
    iconLabel.ZIndex = 12
    iconLabel.TextTransparency = 1
    iconLabel.Parent = paragraphFrame
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -60, 0, 20)
    titleLabel.Position = UDim2.new(0, 50, 0, 10)
    titleLabel.Text = title
    titleLabel.TextColor3 = CurrentTheme.Text
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.ZIndex = 12
    titleLabel.TextTransparency = 1
    titleLabel.Parent = paragraphFrame
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, -60, 0, 50)
    textLabel.Position = UDim2.new(0, 50, 0, 30)
    textLabel.Text = text
    textLabel.TextColor3 = CurrentTheme.Text
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextXAlignment = Enum.TextXAlignment.Left
    textLabel.TextWrapped = true
    textLabel.ZIndex = 12
    textLabel.TextTransparency = 1
    textLabel.Parent = paragraphFrame
    
    spawn(function()
        wait(0.2)
        TweenService:Create(paragraphFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
        TweenService:Create(iconLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(titleLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(textLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
    end)
    
    return paragraphFrame
end

local function CreateTab(name, callback)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(0, 120, 1, 0)
    tabButton.Text = name
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 14
    tabButton.BackgroundColor3 = CurrentTheme.Secondary
    tabButton.TextColor3 = CurrentTheme.Text
    tabButton.BorderSizePixel = 0
    tabButton.TextTransparency = 1
    tabButton.BackgroundTransparency = 1
    tabButton.ZIndex = 12
    tabButton.Parent = TabContainer
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabButton
    
    table.insert(Tabs, tabButton)
    
    spawn(function()
        wait(0.4 + (#Tabs * 0.1))
        TweenService:Create(tabButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            TextTransparency = 0,
            BackgroundTransparency = 0
        }):Play()
    end)
    
    tabButton.MouseEnter:Connect(function()
        if CurrentTab ~= tabButton then
            TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Accent}):Play()
        end
    end)
    
    tabButton.MouseLeave:Connect(function()
        if CurrentTab ~= tabButton then
            TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
        end
    end)
    
    tabButton.MouseButton1Click:Connect(function()
        if CurrentTab == tabButton then
            ToggleUI()
            return
        end
        
        if CurrentTab then
            TweenService:Create(CurrentTab, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Secondary}):Play()
        end
        
        CurrentTab = tabButton
        TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Highlight}):Play()
        
        ClearContent()
        if callback then callback() end
    end)
    
    return tabButton
end

-- Configuração dos botões de controle
MinimizeButton.MouseButton1Click:Connect(ToggleUI)
CloseButton.MouseButton1Click:Connect(ToggleUI)

-- Retornar funções para uso externo
return {
    CreateTab = CreateTab,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateDropdown = CreateDropdown,
    CreateButton = CreateButton,
    CreateKeybindSelector = CreateKeybindSelector,
    CreateParagraph = CreateParagraph,
    CreateNotification = CreateNotification,
    LoadConfig = LoadConfig,
    SaveConfig = SaveConfig,
    LoadKeybinds = LoadKeybinds,
    SaveKeybinds = SaveKeybinds,
    Config = Config,
    Keybinds = Keybinds,
    CurrentTheme = CurrentTheme,
    Tabs = Tabs
}
