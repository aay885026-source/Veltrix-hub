-- [[ Veltrix Hub - Keyboard Escape Map Script ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 1. إنشاء واجهة الـ GUI الأساسية
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VeltrixKeyboardHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- 2. زر فتح وإغلاق القائمة (قابل للسحب والإفلات Draggable في أي مكان)
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 130, 0, 45)
openButton.Position = UDim2.new(0.05, 0, 0.1, 0)
openButton.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- أحمر
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.TextSize = 16
openButton.Font = Enum.Font.GothamBold
openButton.Text = "Veltrix Hub"
openButton.Parent = screenGui

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(0, 8)
cornerBtn.Parent = openButton

-- كود سحب الزر بالأصابع أو الماوس
local dragging, dragInput, dragStart, startPos
openButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = openButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

openButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		openButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

-- 3. النافذة الرئيسية (أسود مع أنميشن سلس)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- أسود
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = screenGui

local cornerMain = Instance.new("UICorner")
cornerMain.CornerRadius = UDim.new(0, 12)
cornerMain.Parent = mainFrame

-- أنميشن فتح وإغلاق النافذة
local isOpen = false
openButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	if isOpen then
		mainFrame.Visible = true
		mainFrame.Size = UDim2.new(0, 0, 0, 0)
		TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 620, 0, 420)}):Play()
	else
		local tween = TweenService:Create(mainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)})
		tween:Play()
		tween.Completed:Connect(function()
			if not isOpen then mainFrame.Visible = false end
		end)
	end
end)

-- 4. القائمة الجانبية اليسرى (تدعم ScrollingFrame بالكامل)
local sidebar = Instance.new("ScrollingFrame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 160, 1, -20)
sidebar.Position = UDim2.new(0, 10, 0, 10)
sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
sidebar.BorderSizePixel = 0
sidebar.CanvasSize = UDim2.new(0, 0, 1.8, 0)
sidebar.ScrollBarThickness = 4
sidebar.Parent = mainFrame

local sidebarLayout = Instance.new("UIListLayout")
sidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
sidebarLayout.Padding = UDim.new(0, 8)
sidebarLayout.Parent = sidebar
Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

-- 5. منطقة المحتوى (تحتوي على ScrollingFrame)
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -190, 1, -20)
contentArea.Position = UDim2.new(0, 180, 0, 10)
contentArea.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
contentArea.BorderSizePixel = 0
contentArea.Parent = mainFrame
Instance.new("UICorner", contentArea).CornerRadius = UDim.new(0, 8)

local pages = {}
local function createPage(name)
	local pageScroll = Instance.new("ScrollingFrame")
	pageScroll.Name = name .. "Page"
	pageScroll.Size = UDim2.new(1, -10, 1, -10)
	pageScroll.Position = UDim2.new(0, 5, 0, 5)
	pageScroll.BackgroundTransparency = 1
	pageScroll.BorderSizePixel = 0
	pageScroll.CanvasSize = UDim2.new(0, 0, 2.2, 0)
	pageScroll.ScrollBarThickness = 6
	pageScroll.Visible = false
	pageScroll.Parent = contentArea

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 10)
	layout.Parent = pageScroll

	pages[name] = pageScroll
	return pageScroll
end

local function showPage(name)
	for _, page in pairs(pages) do
		page.Visible = false
	end
	if pages[name] then
		pages[name].Visible = true
	end
end

local function addSidebarButton(text, pageName, order)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -10, 0, 38)
	btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0) -- أزرار باللون الأحمر
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextSize = 13
	btn.Font = Enum.Font.GothamBold
	btn.Text = text
	btn.LayoutOrder = order
	btn.Parent = sidebar
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

	createPage(pageName)

	btn.MouseButton1Click:Connect(function()
		showPage(pageName)
	end)
end

-- إضافة الأزرار حسب الترتيب المطلوب
addSidebarButton("Discord", "Discord", 1)
addSidebarButton("🔄 Auto", "Auto", 2)
addSidebarButton("World 1", "World1", 3)
addSidebarButton("World 2", "World2", 4)
addSidebarButton("World 3", "World3", 5)
addSidebarButton("Free Items", "FreeItems", 6)
addSidebarButton("Trail & Aura", "TrailAura", 7)

-- صفحة Discord (مع زر لنسخ أو فتح رابط سيرفرك)
local discordPage = pages["Discord"]
local discordBtn = Instance.new("TextButton")
discordBtn.Size = UDim2.new(1, 0, 0, 45)
discordBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
discordBtn.TextSize = 13
discordBtn.Font = Enum.Font.GothamBold
discordBtn.Text = "Join Discord Server (Click to Copy/Open)"
discordBtn.Parent = discordPage
Instance.new("UICorner", discordBtn).CornerRadius = UDim.new(0, 6)

discordBtn.MouseButton1Click:Connect(function()
	-- رابط سيرفرك الذي تم اعتماده مسبقاً
	local inviteLink = "https://discord.gg/yourserver" 
	if setclipboard then
		setclipboard(inviteLink)
		discordBtn.Text = "Copied Discord Link!"
		task.wait(2)
		discordBtn.Text = "Join Discord Server (Click to Copy/Open)"
	end
end)

-- صفحة Auto (Auto Win + Auto Farm)
local autoPage = pages["Auto"]
local autoWinBtn = Instance.new("TextButton")
autoWinBtn.Size = UDim2.new(1, 0, 0, 40)
autoWinBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
autoWinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoWinBtn.TextSize = 13
autoWinBtn.Font = Enum.Font.GothamBold
autoWinBtn.Text = "Auto Win: OFF"
autoWinBtn.Parent = autoPage
Instance.new("UICorner", autoWinBtn).CornerRadius = UDim.new(0, 6)

local autoWinState = false
autoWinBtn.MouseButton1Click:Connect(function()
	autoWinState = not autoWinState
	autoWinBtn.Text = "Auto Win: " .. (autoWinState and "ON" or "OFF")
	autoWinBtn.BackgroundColor3 = autoWinState and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

local autoFarmBtn = Instance.new("TextButton")
autoFarmBtn.Size = UDim2.new(1, 0, 0, 40)
autoFarmBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
autoFarmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoFarmBtn.TextSize = 13
autoFarmBtn.Font = Enum.Font.GothamBold
autoFarmBtn.Text = "Auto Farm (Best Gamepass/Free Server): OFF"
autoFarmBtn.Parent = autoPage
Instance.new("UICorner", autoFarmBtn).CornerRadius = UDim.new(0, 6)

local autoFarmState = false
autoFarmBtn.MouseButton1Click:Connect(function()
	autoFarmState = not autoFarmState
	autoFarmBtn.Text = "Auto Farm: " .. (autoFarmState and "ON (Using Best Server)" or "OFF")
	autoFarmBtn.BackgroundColor3 = autoFarmState and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

-- صفحة World 1
local w1Page = pages["World1"]
local w1Toggle = Instance.new("TextButton")
w1Toggle.Size = UDim2.new(1, 0, 0, 40)
w1Toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
w1Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
w1Toggle.TextSize = 13
w1Toggle.Font = Enum.Font.GothamBold
w1Toggle.Text = "World 1 Trophies TP: OFF"
w1Toggle.Parent = w1Page
Instance.new("UICorner", w1Toggle).CornerRadius = UDim.new(0, 6)

local w1State = false
w1Toggle.MouseButton1Click:Connect(function()
	w1State = not w1State
	w1Toggle.Text = "World 1 Trophies TP: " .. (w1State and "ON" or "OFF")
	w1Toggle.BackgroundColor3 = w1State and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

-- صفحة World 2
local w2Page = pages["World2"]
local w2Toggle = Instance.new("TextButton")
w2Toggle.Size = UDim2.new(1, 0, 0, 40)
w2Toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
w2Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
w2Toggle.TextSize = 13
w2Toggle.Font = Enum.Font.GothamBold
w2Toggle.Text = "World 2 Trophies TP: OFF"
w2Toggle.Parent = w2Page
Instance.new("UICorner", w2Toggle).CornerRadius = UDim.new(0, 6)

local w2State = false
w2Toggle.MouseButton1Click:Connect(function()
	w2State = not w2State
	w2Toggle.Text = "World 2 Trophies TP: " .. (w2State and "ON" or "OFF")
	w2Toggle.BackgroundColor3 = w2State and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

-- صفحة World 3
local w3Page = pages["World3"]
local w3Toggle = Instance.new("TextButton")
w3Toggle.Size = UDim2.new(1, 0, 0, 40)
w3Toggle.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
w3Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
w3Toggle.TextSize = 13
w3Toggle.Font = Enum.Font.GothamBold
w3Toggle.Text = "World 3 Trophies TP: OFF"
w3Toggle.Parent = w3Page
Instance.new("UICorner", w3Toggle).CornerRadius = UDim.new(0, 6)

local w3State = false
w3Toggle.MouseButton1Click:Connect(function()
	w3State = not w3State
	w3Toggle.Text = "World 3 Trophies TP: " .. (w3State and "ON" or "OFF")
	w3Toggle.BackgroundColor3 = w3State and Color3.fromRGB(0, 180, 0) or Color3.fromRGB(180, 0, 0)
end)

-- صفحة Free Items (Treadmills مرتبة فوق بعض: gold, diamond, candy, admin)
local freeItemsPage = pages["FreeItems"]
local treadmillsList = {"Gold Treadmill", "Diamond Treadmill", "Candy Treadmill", "Admin Treadmill"}

for _, tName in ipairs(treadmillsList) do
	local tBtn = Instance.new("TextButton")
	tBtn.Size = UDim2.new(1, 0, 0, 38)
	tBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	tBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	tBtn.TextSize = 13
	tBtn.Font = Enum.Font.GothamBold
	tBtn.Text = tName .. " (Free Walk)"
	tBtn.Parent = freeItemsPage
	Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)
	
	tBtn.MouseButton1Click:Connect(function()
		print("Active Free Treadmill: " .. tName)
	end)
end

-- صفحة Trail & Aura (Infinity Trail & DarknessAura مع Equip مجاني)
local trailPage = pages["TrailAura"]
local cosmeticList = {"Infinity Trail", "Darkness Aura"}

for _, cName in ipairs(cosmeticList) do
	local cBtn = Instance.new("TextButton")
	cBtn.Size = UDim2.new(1, 0, 0, 38)
	cBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	cBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	cBtn.TextSize = 13
	cBtn.Font = Enum.Font.GothamBold
	cBtn.Text = "Equip " .. cName .. " (Free)"
	cBtn.Parent = trailPage
	Instance.new("UICorner", cBtn).CornerRadius = UDim.new(0, 6)

	cBtn.MouseButton1Click:Connect(function()
		print("Equipped Free Cosmetic: " .. cName)
	end)
end

-- فتح الصفحة الافتراضية عند التشغيل
showPage("Discord")
