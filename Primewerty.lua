local url = "https://raw.githubusercontent.com/rickandmorty63753882/IryexprimeV3/main/Iryexprimev3.lua"
local src = game:HttpGet(url)

-- 1) ЗВУК ПОРТАЛА
local soundCode = [[
	pcall(function()
		local ps = Instance.new("Sound")
		ps.SoundId = "rbxassetid://756847338"
		ps.Volume = 1
		ps.Parent = portal
		ps:Play()
		game:GetService("Debris"):AddItem(ps, 4)
	end)]]

local r1
src, r1 = src:gsub(
	"local portal, rotateConn = spawnPortalVisual%(position, normal, extra and extra%.slotLabel%)",
	"local portal, rotateConn = spawnPortalVisual(position, normal, extra and extra.slotLabel)\n" .. soundCode,
	1
)

-- 2) ПЕРЕТАСКИВАНИЕ МЕНЮ + ЗАМОК (в правом верхнем углу меню)
local menuDragCode = [[

	-- [INJECT] перетаскивание меню (за шапку) + блокировка
	do
		local UIS = game:GetService("UserInputService")
		local menuLocked = false
		local dragging = false
		local dragStart, startPos

		local menuLockBtn = Instance.new("TextButton")
		menuLockBtn.Name = "MenuLockBtn"
		menuLockBtn.Size = UDim2.new(0, 28, 0, 28)
		menuLockBtn.Position = UDim2.new(1, -32, 0, 1)
		menuLockBtn.Text = "🔓"
		menuLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
		menuLockBtn.TextColor3 = Color3.fromRGB(0, 255, 40)
		menuLockBtn.Font = Enum.Font.GothamBold
		menuLockBtn.TextSize = 15
		menuLockBtn.BorderSizePixel = 0
		menuLockBtn.ZIndex = 60
		menuLockBtn.Parent = mainFrame
		local lc = Instance.new("UICorner")
		lc.CornerRadius = UDim.new(0, 6)
		lc.Parent = menuLockBtn

		menuLockBtn.MouseButton1Click:Connect(function()
			menuLocked = not menuLocked
			menuLockBtn.Text = menuLocked and "🔒" or "🔓"
		end)

		mainFrame.InputBegan:Connect(function(input)
			if menuLocked then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local ap = mainFrame.AbsolutePosition
				local inTitleBar = input.Position.Y < ap.Y + 32 and input.Position.X < ap.X + mainFrame.AbsoluteSize.X - 36
				if inTitleBar then
					dragging = true
					dragStart = input.Position
					startPos = mainFrame.Position
					input.Changed:Connect(function()
						if input.UserInputState == Enum.UserInputState.End then
							dragging = false
						end
					end)
				end
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if not dragging then return end
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				local delta = input.Position - dragStart
				mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end)
	end
]]

local r2
src, r2 = src:gsub("mainCorner%.Parent = mainFrame", "mainCorner.Parent = mainFrame" .. menuDragCode, 1)

-- 3) ПЕРЕТАСКИВАНИЕ КНОПКИ-ОТКРЫВАШКИ
local toggleDragCode = [[

	-- [INJECT] перетаскивание круглой кнопки-открывашки
	local injTbDragging = false
	local injTbMoved = false
	local injTbStart, injTbPos

	toggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			injTbDragging = true
			injTbMoved = false
			injTbStart = input.Position
			injTbPos = toggleButton.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					injTbDragging = false
					task.delay(0.15, function() injTbMoved = false end)
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not injTbDragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - injTbStart
			if delta.Magnitude > 6 then injTbMoved = true end
			toggleButton.Position = UDim2.new(injTbPos.X.Scale, injTbPos.X.Offset + delta.X, injTbPos.Y.Scale, injTbPos.Y.Offset + delta.Y)
		end
	end)
]]

local r3
src, r3 = src:gsub("toggleCorner%.Parent = toggleButton", "toggleCorner.Parent = toggleButton" .. toggleDragCode, 1)

-- 4) драг не должен нажимать кнопку: клик-открывашка игнорирует сдвиг
local r4
src, r4 = src:gsub(
	"setGuiVisible%(not mainFrame%.Visible%)",
	"if not injTbMoved then setGuiVisible(not mainFrame.Visible) end",
	1
)

if r1 == 0 then warn("[RickPrime] звук портала: не вставлено") end
if r2 == 0 then warn("[RickPrime] перетаскивание меню: не вставлено") end
if r3 == 0 then warn("[RickPrime] перетаскивание открывашки: не вставлено") end
if r4 == 0 then warn("[RickPrime] защита от нажатия при драге: не вставлено") end

loadstring(src)()
