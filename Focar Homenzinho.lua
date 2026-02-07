 --// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// VARIÁVEIS
local focusedPlayer = nil
local lastClick = 0
local cooldown = 5
local connection = nil

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "FocusGui"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 500)
main.Position = UDim2.new(0.5, -210, 0.5, -250)
main.BackgroundColor3 = Color3.fromRGB(25,25,25)
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true

Instance.new("UICorner", main).CornerRadius = UDim.new(0, 18)

--// TÍTULO
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 50)
title.BackgroundTransparency = 1
title.Text = "🎯 PLAYER FOCUS"
title.Font = Enum.Font.GothamBold
title.TextSize = 22
title.TextColor3 = Color3.fromRGB(255,255,255)

--// SEARCH
local search = Instance.new("TextBox", main)
search.PlaceholderText = "🔎 Procurar jogador..."
search.Size = UDim2.new(1, -20, 0, 40)
search.Position = UDim2.new(0, 10, 0, 60)
search.BackgroundColor3 = Color3.fromRGB(35,35,35)
search.TextColor3 = Color3.new(1,1,1)
search.Font = Enum.Font.Gotham
search.TextSize = 14
search.ClearTextOnFocus = false
Instance.new("UICorner", search).CornerRadius = UDim.new(0, 12)

--// LISTA
local list = Instance.new("ScrollingFrame", main)
list.Position = UDim2.new(0, 10, 0, 110)
list.Size = UDim2.new(1, -20, 0, 260)
list.CanvasSize = UDim2.new(0,0,0,0)
list.ScrollBarImageTransparency = 0.3
list.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", list)
layout.Padding = UDim.new(0, 6)

--// BOTÃO FOCUS
local focusBtn = Instance.new("TextButton", main)
focusBtn.Size = UDim2.new(1, -20, 0, 45)
focusBtn.Position = UDim2.new(0, 10, 1, -110)
focusBtn.Text = "FOCUS 👀"
focusBtn.Font = Enum.Font.GothamBold
focusBtn.TextSize = 18
focusBtn.TextColor3 = Color3.new(1,1,1)
focusBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)
Instance.new("UICorner", focusBtn).CornerRadius = UDim.new(0, 14)

--// BOTÃO STOP
local stopBtn = Instance.new("TextButton", main)
stopBtn.Size = UDim2.new(1, -20, 0, 45)
stopBtn.Position = UDim2.new(0, 10, 1, -55)
stopBtn.Text = "STOP 🤬"
stopBtn.Font = Enum.Font.GothamBold
stopBtn.TextSize = 18
stopBtn.TextColor3 = Color3.new(1,1,1)
stopBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
Instance.new("UICorner", stopBtn).CornerRadius = UDim.new(0, 14)

--// MENSAGEM COOLDOWN
local warn = Instance.new("TextLabel", gui)
warn.Size = UDim2.new(0, 420, 0, 50)
warn.Position = UDim2.new(0.5, -210, 0.1, 0)
warn.BackgroundColor3 = Color3.fromRGB(170,0,0)
warn.TextColor3 = Color3.new(1,1,1)
warn.Font = Enum.Font.GothamBold
warn.TextSize = 16
warn.Text = "Espere meu mano, você esta apressado demais!!!"
warn.Visible = false
Instance.new("UICorner", warn).CornerRadius = UDim.new(0, 14)

--// FUNÇÃO COOLDOWN
local function canClick()
	if tick() - lastClick < cooldown then
		warn.Visible = true
		task.delay(2, function()
			warn.Visible = false
		end)
		return false
	end
	lastClick = tick()
	return true
end

--// CRIAR BOTÃO DE JOGADOR
local function createPlayerButton(player)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -5, 0, 40)
	btn.Text = player.Name
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 15
	btn.TextColor3 = Color3.new(1,1,1)
	btn.BackgroundColor3 = Color3.fromRGB(40,40,40)
	btn.Parent = list
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 12)

	btn.MouseButton1Click:Connect(function()
		focusedPlayer = player
	end)
end

--// ATUALIZAR LISTA
--// ATUALIZAR LISTA (FIX)
local function refresh()
	for _,child in pairs(list:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			if search.Text == "" or string.find(p.Name:lower(), search.Text:lower()) then
				createPlayerButton(p)
			end
		end
	end

	task.wait()
	list.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end


search:GetPropertyChangedSignal("Text"):Connect(refresh)
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)
search:GetPropertyChangedSignal("Text"):Connect(refresh)


--// FOCUS
focusBtn.MouseButton1Click:Connect(function()
	if not canClick() then return end
	if not focusedPlayer then return end

	rotating = true

	if rotateConnection then
		rotateConnection:Disconnect()
	end

	rotateConnection = RunService.RenderStepped:Connect(function()
		if not rotating then return end

		local myChar = LocalPlayer.Character
		local targetChar = focusedPlayer.Character

		if myChar and targetChar then
			local myHRP = myChar:FindFirstChild("HumanoidRootPart")
			local targetHRP = targetChar:FindFirstChild("HumanoidRootPart")

			if myHRP and targetHRP then
				local camPos = Camera.CFrame.Position
				Camera.CameraType = Enum.CameraType.Custom
				Camera.CFrame = CFrame.lookAt(camPos, targetHRP.Position)
			end
		end
	end)
end)


--// STOP
stopBtn.MouseButton1Click:Connect(function()
	if not canClick() then return end

	rotating = false

	if rotateConnection then
		rotateConnection:Disconnect()
		rotateConnection = nil
	end

	Camera.CameraType = Enum.CameraType.Custom
end)

local rotating = false
local rotateConnection
