--[[
    Roblox Client-Side Info & Utilities GUI
    Hiển thị PlaceVersion, JobID, cho phép tham gia JobID, sao chép JobID, và hop server.
]]

local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CoreGui = game:GetService("CoreGui")

-- --- Cấu hình ---
local TOGGLE_KEY = Enum.KeyCode.F2
local GUI_TITLE = "Thông tin Server"
local IS_MINIMIZED = false
local storedMainFrameHeight = 0

-- --- Tạo GUI ---
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "InfoGui_Screen_VN_v2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local guiParent = CoreGui
if gethui then
    guiParent = gethui()
    ScreenGui.Parent = guiParent
elseif syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = guiParent
else
    ScreenGui.Parent = guiParent
end

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
MainFrame.BorderColor3 = Color3.fromRGB(80, 80, 100)
MainFrame.BorderSizePixel = 1
MainFrame.Size = UDim2.new(0, 230, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Active = true
MainFrame.Visible = true
MainFrame.ClipsDescendants = true

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.FillDirection = Enum.FillDirection.Vertical
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Top

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Parent = MainFrame
TitleBar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
TitleBar.Size = UDim2.new(1, 0, 0, 25)
TitleBar.LayoutOrder = 0

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = TitleBar
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(1, -55, 1, 0)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
TitleLabel.TextSize = 16
TitleLabel.Text = GUI_TITLE
TitleLabel.TextXAlignment = Enum.TextXAlignment.Center

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "CloseButton"
CloseButton.Parent = TitleBar
CloseButton.Size = UDim2.new(0, 25, 1, 0)
CloseButton.Position = UDim2.new(1, -25, 0, 0)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseButton.Font = Enum.Font.SourceSansBold
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Text = "X"
CloseButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Name = "MinimizeButton"
MinimizeButton.Parent = TitleBar
MinimizeButton.Size = UDim2.new(0, 25, 1, 0)
MinimizeButton.Position = UDim2.new(1, -50, 0, 0) -- Bên trái nút Close
MinimizeButton.BackgroundColor3 = Color3.fromRGB(80, 80, 100)
MinimizeButton.Font = Enum.Font.SourceSansBold
MinimizeButton.TextColor3 = Color3.fromRGB(220, 220, 220)
MinimizeButton.TextSize = 18
MinimizeButton.Text = "_"

local contentElements = {}

local function createInfoLabel(textPrefix, order)
    local container = Instance.new("Frame")
    container.Parent = MainFrame
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -10, 0, 20)
    container.LayoutOrder = order
    table.insert(contentElements, container)

    local label = Instance.new("TextLabel")
    label.Parent = container
    label.Name = textPrefix:gsub("[^%w]", "") .. "Label"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.SourceSans
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Text = textPrefix
    return label
end

local function createStyledButton(text, order, onClick)
    local button = Instance.new("TextButton")
    button.Parent = MainFrame
    button.Name = text:gsub("[^%w]", "") .. "Button"
    button.Size = UDim2.new(1, -10, 0, 28)
    button.Font = Enum.Font.SourceSansSemibold
    button.TextColor3 = Color3.fromRGB(230, 230, 230)
    button.TextSize = 14
    button.BackgroundColor3 = Color3.fromRGB(70, 70, 85)
    button.BorderColor3 = Color3.fromRGB(100, 100, 120)
    button.BorderSizePixel = 1
    button.LayoutOrder = order
    button.Text = text
    if onClick then
        button.MouseButton1Click:Connect(onClick)
    end
    table.insert(contentElements, button)
    return button
end

local function createStyledTextBox(placeholder, order)
    local textbox = Instance.new("TextBox")
    textbox.Parent = MainFrame
    textbox.Name = placeholder:gsub("[^%w]", "") .. "TextBox"
    textbox.Size = UDim2.new(1, -10, 0, 28)
    textbox.Font = Enum.Font.SourceSans
    textbox.TextColor3 = Color3.fromRGB(220, 220, 220)
    textbox.PlaceholderText = placeholder
    textbox.PlaceholderColor3 = Color3.fromRGB(150,150,150)
    textbox.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    textbox.BorderColor3 = Color3.fromRGB(100, 100, 120)
    textbox.BorderSizePixel = 1
    textbox.ClearTextOnFocus = true
    textbox.LayoutOrder = order
    table.insert(contentElements, textbox)
    return textbox
end

-- Hiển thị PlaceVersion
local PlaceVersionLabel = createInfoLabel("PlaceVersion: " .. tostring(game.PlaceVersion), 1)
game:GetPropertyChangedSignal("PlaceVersion"):Connect(function()
    PlaceVersionLabel.Text = "PlaceVersion: " .. tostring(game.PlaceVersion)
end)

-- Hiển thị JobID
local currentJobId = game.JobId
local JobIdLabel = createInfoLabel("JobID: " .. (currentJobId or "N/A"), 2)
game:GetPropertyChangedSignal("JobId"):Connect(function()
    currentJobId = game.JobId
    JobIdLabel.Text = "JobID: " .. (currentJobId or "N/A")
end)

-- Ô nhập JobID và các nút hành động
local JobIdInput = createStyledTextBox("Nhập JobID để tham gia", 3)

local JoinJobIdButton = createStyledButton("Tham gia JobID", 4, function()
    local targetJobId = JobIdInput.Text
    if targetJobId and targetJobId:match("%S") then
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, LocalPlayer)
        end)
        if not success then warn("Lỗi khi tham gia JobID:", err) end
        JobIdInput.Text = ""
    end
end)

local CopyJobIdButton = createStyledButton("Sao chép JobID", 5, function()
    if currentJobId then
        if setclipboard then
            setclipboard(currentJobId)
            CopyJobIdButton.Text = "Đã sao chép!"
            task.delay(1.5, function() if CopyJobIdButton then CopyJobIdButton.Text = "Sao chép JobID" end end)
        else
            CopyJobIdButton.Text = "Lỗi Clipboard!"
            task.delay(1.5, function() if CopyJobIdButton then CopyJobIdButton.Text = "Sao chép JobID" end end)
            warn("Hàm 'setclipboard' không tồn tại.")
        end
    else
        CopyJobIdButton.Text = "Không có JobID!"
        task.delay(1.5, function() if CopyJobIdButton then CopyJobIdButton.Text = "Sao chép JobID" end end)
    end
end)

local HopServerButton = createStyledButton("Hop Server (random)", 6, function()
    local success, err = pcall(function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
    if not success then warn("Lỗi khi chuyển server:", err) end
end)


-- Hàm điều chỉnh chiều cao MainFrame tự động
local function adjustMainFrameHeight()
    if IS_MINIMIZED then
        MainFrame.Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, TitleBar.AbsoluteSize.Y)
    else
        task.wait()
        local calculatedHeight = TitleBar.AbsoluteSize.Y
        local totalPadding = UIListLayout.Padding.Offset * (#contentElements)
        
        for _, element in ipairs(contentElements) do
            if element.Visible then
                 calculatedHeight = calculatedHeight + element.AbsoluteSize.Y
            end
        end
        calculatedHeight = calculatedHeight + totalPadding + UIListLayout.Padding.Offset
        
        MainFrame.Size = UDim2.new(MainFrame.Size.X.Scale, MainFrame.Size.X.Offset, 0, calculatedHeight)
        storedMainFrameHeight = calculatedHeight
    end
end

-- Xử lý nút Thu Nhỏ / Mở Rộng
MinimizeButton.MouseButton1Click:Connect(function()
    IS_MINIMIZED = not IS_MINIMIZED
    if IS_MINIMIZED then
        MinimizeButton.Text = "□" 
        if storedMainFrameHeight == 0 then
             task.wait()
             local calculatedHeight = TitleBar.AbsoluteSize.Y
             local totalPadding = UIListLayout.Padding.Offset * (#contentElements)
             for _, element in ipairs(contentElements) do
                 calculatedHeight = calculatedHeight + element.AbsoluteSize.Y
             end
             calculatedHeight = calculatedHeight + totalPadding + UIListLayout.Padding.Offset
             storedMainFrameHeight = calculatedHeight
        end
    else
        MinimizeButton.Text = "_"
    end

    for _, element in ipairs(contentElements) do
        element.Visible = not IS_MINIMIZED
    end
    adjustMainFrameHeight()
end)


-- --- Logic kéo thả cho MainFrame
local dragging = false
local dragInputObj
local dragStartPos
local frameStartPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if input.Position.Y > MinimizeButton.AbsolutePosition.Y and input.Position.Y < (MinimizeButton.AbsolutePosition.Y + MinimizeButton.AbsoluteSize.Y) then
            if input.Position.X > MinimizeButton.AbsolutePosition.X and input.Position.X < (CloseButton.AbsolutePosition.X + CloseButton.AbsoluteSize.X) then
                 return
            end
        end

        dragging = true
        dragInputObj = input
        dragStartPos = input.Position
        frameStartPos = MainFrame.Position

        local inputChangedConnection
        local inputEndedConnection

        inputChangedConnection = UserInputService.InputChanged:Connect(function(changedInput)
            if changedInput.UserInputType == Enum.UserInputType.MouseMovement or changedInput.UserInputType == Enum.UserInputType.Touch then
                if dragging and dragInputObj then
                    local delta = changedInput.Position - dragStartPos
                    MainFrame.Position = UDim2.new(
                        frameStartPos.X.Scale, frameStartPos.X.Offset + delta.X,
                        frameStartPos.Y.Scale, frameStartPos.Y.Offset + delta.Y
                    )
                end
            end
        end)
        
        inputEndedConnection = UserInputService.InputEnded:Connect(function(endInput)
            if endInput == dragInputObj then
                dragging = false
                if inputChangedConnection then inputChangedConnection:Disconnect() end
                if inputEndedConnection then inputEndedConnection:Disconnect() end
            end
        end)
    end
end)

-- --- Ẩn/Hiện GUI ---
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == TOGGLE_KEY then
        MainFrame.Visible = not MainFrame.Visible
        if MainFrame.Visible and IS_MINIMIZED then
        elseif MainFrame.Visible and not IS_MINIMIZED then
            adjustMainFrameHeight()
        end
    end
end)

-- Khởi tạo chiều cao
task.wait(0.2)
adjustMainFrameHeight()
if MainFrame.Size.Y.Offset > 0 then
    storedMainFrameHeight = MainFrame.Size.Y.Offset
end

print("Info GUI (PLM) đã tải. Nhấn " .. TOGGLE_KEY.Name .. " để ẩn/hiện.")
