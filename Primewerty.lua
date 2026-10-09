-- RickPrime V3: меню (перетаскивание + замок) + открывашка (перетаскивание + уважает замок) + звук портала
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

-- 2) ПЕРЕТАСКИВАНИЕ МЕНЮ + ЗАМОК (переменная injMenuLocked — общая для всего меню)
local menuDragCode = [[

	-- [INJECT] перетаскивание меню (за шапку) + общая блокировка
	local injMenuLocked = false
	local injDragging = false
	local injDragStart, injStartPos

	local injLockBtn = Instance.new("TextButton")
	injLockBtn.Name = "MenuLockBtn"
	injLockBtn.Size = UDim2.new(0, 28, 0, 28)
	injLockBtn.Position = UDim2.new(1, -32, 0, 1)
	injLockBtn.Text = "🔓"
	injLockBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
	injLockBtn.TextColor3 = Color3.fromRGB(0, 255, 40)
	injLockBtn.Font = Enum.Font.GothamBold
	injLockBtn.TextSize = 15
	injLockBtn.BorderSizePixel = 0
	injLockBtn.ZIndex = 60
	injLockBtn.Parent = mainFrame
	local injLc = Instance.new("UICorner")
	injLc.CornerRadius = UDim.new(0, 6)
	injLc.Parent = injLockBtn

	injLockBtn.MouseButton1Click:Connect(function()
		injMenuLocked = not injMenuLocked
		injLockBtn.Text = injMenuLocked and "🔒" or "🔓"
	end)

	mainFrame.InputBegan:Connect(function(input)
		if injMenuLocked then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local ap = mainFrame.AbsolutePosition
			local inTitleBar = input.Position.Y < ap.Y + 32 and input.Position.X < ap.X + mainFrame.AbsoluteSize.X - 36
			if inTitleBar then
				injDragging = true
				injDragStart = input.Position
				injStartPos = mainFrame.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						injDragging = false
					end
				end)
			end
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if not injDragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - injDragStart
			mainFrame.Position = UDim2.new(injStartPos.X.Scale, injStartPos.X.Offset + delta.X, injStartPos.Y.Scale, injStartPos.Y.Offset + delta.Y)
		end
	end)
]]

local r2
src, r2 = src:gsub("mainCorner%.Parent = mainFrame", "mainCorner.Parent = mainFrame" .. menuDragCode, 1)

-- 3) ПЕРЕТАСКИВАНИЕ ОТКРЫВАШКИ (заблокировано вместе с меню)
local toggleDragCode = [[

	-- [INJECT] перетаскивание открывашки (уважает общий замок)
	local injTbDragging = false
	local injTbMoved = false
	local injTbStart, injTbPos

	toggleButton.InputBegan:Connect(function(input)
		if injMenuLocked then return end
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

-- 4) драг не нажимает открывашку
local r4
src, r4 = src:gsub(
	"setGuiVisible%(not mainFrame%.Visible%)",
	"if not injTbMoved then setGuiVisible(not mainFrame.Visible) end",
	1
)

if r1 == 0 then warn("[RickPrime] звук портала: не вставлено") end
if r2 == 0 then warn("[RickPrime] меню: не вставлено") end
if r3 == 0 then warn("[RickPrime] открывашка: не вставлено") end
if r4 == 0 then warn("[RickPrime] защита от нажатия: не вставлено") end

loadstring(src)()
