--[[
	Champagne UI Library
	A reusable Roblox GUI library, styled after the "Topography" aesthetic
	(dark background, subtle tiled texture, purple accent glow, rounded corners)
	but structured as a component library like a typical Window/Tab/Section framework.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Camera = workspace.CurrentCamera
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()

local v2 = Vector2.new
local udim2, udim = UDim2.new, UDim.new
local rgb = Color3.fromRGB

-- ============================================================
-- THEME (carried over from the original Topography script)
-- ============================================================
local Colors = {
	Background   = rgb(10, 10, 10),
	Surface      = rgb(26, 26, 26),
	SurfaceHover = rgb(34, 34, 34),
	Border       = rgb(42, 42, 42),
	BorderHover  = rgb(58, 58, 58),
	Text         = rgb(255, 255, 255),
	SubText      = rgb(136, 136, 136),
	TextDim      = rgb(90, 90, 90),
	Accent       = rgb(168, 85, 247),
	AccentHover  = rgb(147, 51, 234),
	Circle       = rgb(255, 255, 255),
}

local FONT = Enum.Font.Gotham
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium
local TEXTURE_ID = "rbxassetid://123573051940980"

-- ============================================================
-- LIBRARY CORE
-- ============================================================
local Library = {
	Flags = {},
	Connections = {},
	TweenSpeed = 0.15,
	TweenStyle = Enum.EasingStyle.Quint,
}
Library.__index = Library

function Library:Create(class, props)
	local obj = Instance.new(class)
	for k, val in pairs(props) do
		obj[k] = val
	end
	if class == "TextButton" then
		obj.AutoButtonColor = false
	end
	return obj
end

function Library:Tween(obj, props, time)
	local tween = TweenService:Create(obj, TweenInfo.new(time or Library.TweenSpeed, Library.TweenStyle), props)
	tween:Play()
	return tween
end

function Library:Connection(signal, callback)
	local conn = signal:Connect(callback)
	table.insert(Library.Connections, conn)
	return conn
end

function Library:Round(num, decimal)
	local mult = 10 ^ (decimal or 0)
	return math.floor(num * mult + 0.5) / mult
end

function Library:Unload()
	if Library.ScreenGui then
		Library.ScreenGui:Destroy()
	end
	for _, conn in ipairs(Library.Connections) do
		conn:Disconnect()
	end
end

-- Adds the subtle tiled-texture background, top glow, and hairline edge
-- used by the original Topography frame.
local function ApplyBackgroundFlourish(frame)
	local Background = Library:Create("ImageLabel", {
		Parent = frame,
		Size = udim2(1, 0, 1, 0),
		BackgroundColor3 = Colors.Background,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		Image = TEXTURE_ID,
		ImageTransparency = 0.93,
		ScaleType = Enum.ScaleType.Tile,
		TileSize = udim2(0, 256, 0, 256),
		ClipsDescendants = true,
		ZIndex = 0,
	})
	Library:Create("UICorner", { Parent = Background, CornerRadius = udim(0, 14) })
	Library:Create("UIStroke", { Parent = Background, Color = Colors.Border, Thickness = 1 })

	local Glow = Library:Create("Frame", {
		Parent = Background,
		Size = udim2(1, 0, 0, 120),
		BackgroundColor3 = Colors.Accent,
		BackgroundTransparency = 0.95,
		BorderSizePixel = 0,
	})
	Library:Create("UIGradient", {
		Parent = Glow,
		Rotation = 90,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.15),
			NumberSequenceKeypoint.new(0.5, 0.8),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	local Edge = Library:Create("Frame", {
		Parent = Background,
		Size = udim2(1, 0, 0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	})
	Library:Create("UIGradient", {
		Parent = Edge,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0.85),
			NumberSequenceKeypoint.new(1, 1),
		}),
	})

	return Background
end

local function Draggify(handle, target)
	local dragging, dragStart, startPos

	Library:Connection(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position

			local changedConn
			changedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					changedConn:Disconnect()
				end
			end)
		end
	end)

	Library:Connection(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			target.Position = udim2(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ============================================================
-- WINDOW
-- ============================================================
function Library:Window(props)
	props = props or {}

	local Existing = PlayerGui:FindFirstChild("Champagne")
	if Existing then
		Existing:Destroy()
	end

	local Window = {
		Name = props.Name or "Champagne",
		Subtitle = props.Subtitle or "Minimal Roblox interface inspired by modern web design.",
		Size = props.Size or udim2(0, 520, 0, 320),
		Tabs = {},
		CurrentTab = nil,
	}

	Library.ScreenGui = Library:Create("ScreenGui", {
		Name = "Champagne",
		Parent = PlayerGui,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
	})

	Window.Frame = Library:Create("Frame", {
		Parent = Library.ScreenGui,
		Size = Window.Size,
		Position = udim2(0.5, -Window.Size.X.Offset / 2, 0.5, -Window.Size.Y.Offset / 2),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Active = true,
	})
	Library.Main = Window.Frame

	ApplyBackgroundFlourish(Window.Frame)

	Window.Title = Library:Create("TextLabel", {
		Parent = Window.Frame,
		Position = udim2(0, 28, 0, 24),
		Size = udim2(1, -56, 0, 28),
		BackgroundTransparency = 1,
		Text = Window.Name,
		Font = FONT,
		TextSize = 26,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = Colors.Text,
	})

	Window.SubtitleLabel = Library:Create("TextLabel", {
		Parent = Window.Frame,
		Position = udim2(0, 28, 0, 56),
		Size = udim2(1, -56, 0, 20),
		BackgroundTransparency = 1,
		Text = Window.Subtitle,
		Font = FONT,
		TextSize = 15,
		TextColor3 = Colors.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Window.Divider = Library:Create("Frame", {
		Parent = Window.Frame,
		Position = udim2(0, 28, 0, 95),
		Size = udim2(1, -56, 0, 1),
		BackgroundColor3 = Colors.Border,
		BorderSizePixel = 0,
	})

	Window.Version = Library:Create("TextLabel", {
		Parent = Window.Frame,
		AnchorPoint = v2(1, 1),
		Position = udim2(1, -18, 1, -14),
		Size = udim2(0, 150, 0, 20),
		BackgroundTransparency = 1,
		Text = props.Version or "v1.0",
		Font = FONT,
		TextSize = 13,
		TextColor3 = Colors.SubText,
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	-- Sidebar for tabs (icon + label, like the original library)
	Window.Sidebar = Library:Create("Frame", {
		Parent = Window.Frame,
		Position = udim2(0, 20, 0, 110),
		Size = udim2(0, 90, 1, -140),
		BackgroundColor3 = Colors.Surface,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Window.Sidebar, CornerRadius = udim(0, 10) })
	Library:Create("UIStroke", { Parent = Window.Sidebar, Color = Colors.Border, Thickness = 1 })

	Window.TabHolder = Library:Create("Frame", {
		Parent = Window.Sidebar,
		Position = udim2(0.5, 0, 0, 10),
		AnchorPoint = v2(0.5, 0),
		Size = udim2(1, -16, 1, -20),
		BackgroundTransparency = 1,
	})
	Library:Create("UIListLayout", {
		Parent = Window.TabHolder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		Padding = udim(0, 10),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	Window.Content = Library:Create("Frame", {
		Parent = Window.Frame,
		Position = udim2(0, 122, 0, 110),
		Size = udim2(1, -142, 1, -140),
		BackgroundTransparency = 1,
	})

	Draggify(Window.Frame, Window.Frame)

	-- entrance animation, like the original script
	local finalSize, finalPos = Window.Size, Window.Frame.Position
	Window.Frame.Size = udim2(finalSize.X.Scale, finalSize.X.Offset - 40, finalSize.Y.Scale, finalSize.Y.Offset - 30)
	Window.Frame.Position = udim2(finalPos.X.Scale, finalPos.X.Offset + 20, finalPos.Y.Scale, finalPos.Y.Offset + 15)
	Library:Tween(Window.Frame, { Size = finalSize, Position = finalPos }, 0.3)

	return setmetatable(Window, Library)
end

-- ============================================================
-- TAB
-- ============================================================
function Library:Tab(props)
	props = props or {}
	local Tab = {
		Name = props.Name or "Tab",
		Active = false,
		Window = self,
	}

	Tab.Button = Library:Create("TextButton", {
		Parent = self.TabHolder,
		Size = udim2(1, 0, 0, 44),
		BackgroundColor3 = Colors.Surface,
		BorderSizePixel = 0,
		Text = "",
	})
	Library:Create("UICorner", { Parent = Tab.Button, CornerRadius = udim(0, 8) })
	Tab.Stroke = Library:Create("UIStroke", { Parent = Tab.Button, Color = Colors.Border, Thickness = 1 })

	Tab.Label = Library:Create("TextLabel", {
		Parent = Tab.Button,
		Size = udim2(1, -8, 1, 0),
		BackgroundTransparency = 1,
		Text = Tab.Name,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Colors.SubText,
		TextWrapped = true,
	})

	Tab.Page = Library:Create("ScrollingFrame", {
		Parent = self.Content,
		Size = udim2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Colors.Accent,
		CanvasSize = udim2(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	Library:Create("UIListLayout", { Parent = Tab.Page, Padding = udim(0, 12), SortOrder = Enum.SortOrder.LayoutOrder })
	Library:Create("UIPadding", {
		Parent = Tab.Page,
		PaddingTop = udim(0, 4),
		PaddingBottom = udim(0, 10),
		PaddingRight = udim(0, 10),
	})

	function Tab:Activate()
		if self.Active then return end
		local window = self.Window
		if window.CurrentTab then
			window.CurrentTab.Page.Visible = false
			Library:Tween(window.CurrentTab.Button, { BackgroundColor3 = Colors.Surface })
			Library:Tween(window.CurrentTab.Stroke, { Color = Colors.Border })
			Library:Tween(window.CurrentTab.Label, { TextColor3 = Colors.SubText })
			window.CurrentTab.Active = false
		end
		self.Page.Visible = true
		Library:Tween(self.Button, { BackgroundColor3 = Colors.SurfaceHover })
		Library:Tween(self.Stroke, { Color = Colors.Accent })
		Library:Tween(self.Label, { TextColor3 = Colors.Text })
		self.Active = true
		window.CurrentTab = self
	end

	Tab.Button.MouseEnter:Connect(function()
		if not Tab.Active then
			Library:Tween(Tab.Button, { BackgroundColor3 = Colors.SurfaceHover })
		end
	end)
	Tab.Button.MouseLeave:Connect(function()
		if not Tab.Active then
			Library:Tween(Tab.Button, { BackgroundColor3 = Colors.Surface })
		end
	end)
	Tab.Button.MouseButton1Click:Connect(function()
		Tab:Activate()
	end)

	table.insert(self.Tabs, Tab)
	if not self.CurrentTab then
		Tab:Activate()
	end

	return setmetatable(Tab, Library)
end

-- ============================================================
-- SECTION
-- ============================================================
function Library:Section(props)
	props = props or {}
	local Section = { Name = props.Name or "Section" }

	Section.Frame = Library:Create("Frame", {
		Parent = self.Page,
		Size = udim2(1, 0, 0, 0),
		BackgroundColor3 = Colors.Surface,
		BorderSizePixel = 0,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	Library:Create("UICorner", { Parent = Section.Frame, CornerRadius = udim(0, 10) })
	Library:Create("UIStroke", { Parent = Section.Frame, Color = Colors.Border, Thickness = 1 })

	Section.Header = Library:Create("Frame", {
		Parent = Section.Frame,
		Size = udim2(1, 0, 0, 36),
		BackgroundTransparency = 1,
	})
	Section.Label = Library:Create("TextLabel", {
		Parent = Section.Header,
		AnchorPoint = v2(0, 0.5),
		Position = udim2(0, 16, 0.5, 0),
		Size = udim2(1, -32, 1, 0),
		BackgroundTransparency = 1,
		Text = Section.Name,
		Font = FONT_BOLD,
		TextSize = 15,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Section.List = Library:Create("Frame", {
		Parent = Section.Frame,
		Position = udim2(0, 0, 0, 36),
		Size = udim2(1, 0, 0, 0),
		BackgroundTransparency = 1,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	Library:Create("UIListLayout", { Parent = Section.List, Padding = udim(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
	Library:Create("UIPadding", {
		Parent = Section.List,
		PaddingLeft = udim(0, 10),
		PaddingRight = udim(0, 10),
		PaddingBottom = udim(0, 12),
	})

	return setmetatable(Section, Library)
end

-- ============================================================
-- TOGGLE
-- ============================================================
function Library:Toggle(props)
	props = props or {}
	local Toggle = {
		Name = props.Name or "Toggle",
		Flag = props.Flag or props.Name or "Toggle",
		Default = props.Default or false,
		Callback = props.Callback or function() end,
		Value = props.Default or false,
	}
	Library.Flags[Toggle.Flag] = Toggle.Value

	Toggle.Frame = Library:Create("TextButton", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 36),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
		Text = "",
	})
	Library:Create("UICorner", { Parent = Toggle.Frame, CornerRadius = udim(0, 8) })
	Toggle.Stroke = Library:Create("UIStroke", { Parent = Toggle.Frame, Color = Colors.Border, Thickness = 1 })

	Toggle.Label = Library:Create("TextLabel", {
		Parent = Toggle.Frame,
		Position = udim2(0, 12, 0, 0),
		Size = udim2(0.65, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Toggle.Name,
		Font = FONT_MED,
		TextSize = 14,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Toggle.Switch = Library:Create("Frame", {
		Parent = Toggle.Frame,
		AnchorPoint = v2(1, 0.5),
		Position = udim2(1, -10, 0.5, 0),
		Size = udim2(0, 40, 0, 20),
		BackgroundColor3 = Colors.SurfaceHover,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Toggle.Switch, CornerRadius = udim(1, 0) })
	Library:Create("UIStroke", { Parent = Toggle.Switch, Color = Colors.Border, Thickness = 1 })

	Toggle.Circle = Library:Create("Frame", {
		Parent = Toggle.Switch,
		AnchorPoint = v2(0, 0.5),
		Position = udim2(0, 3, 0.5, 0),
		Size = udim2(0, 14, 0, 14),
		BackgroundColor3 = Colors.Circle,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Toggle.Circle, CornerRadius = udim(1, 0) })

	function Toggle:Set(val)
		Toggle.Value = val
		Library.Flags[Toggle.Flag] = val
		Library:Tween(Toggle.Switch, { BackgroundColor3 = val and Colors.Accent or Colors.SurfaceHover })
		Library:Tween(Toggle.Switch.UIStroke, { Color = val and Colors.AccentHover or Colors.Border })
		Library:Tween(Toggle.Circle, {
			Position = val and udim2(1, -17, 0.5, 0) or udim2(0, 3, 0.5, 0),
		})
		Toggle.Callback(val)
	end

	Toggle.Frame.MouseButton1Click:Connect(function()
		Toggle:Set(not Toggle.Value)
	end)
	Toggle.Frame.MouseEnter:Connect(function()
		Library:Tween(Toggle.Frame, { BackgroundColor3 = Colors.SurfaceHover })
	end)
	Toggle.Frame.MouseLeave:Connect(function()
		Library:Tween(Toggle.Frame, { BackgroundColor3 = Colors.Background })
	end)

	Toggle:Set(Toggle.Default)
	return setmetatable(Toggle, Library)
end

-- ============================================================
-- SLIDER
-- ============================================================
function Library:Slider(props)
	props = props or {}
	local Slider = {
		Name = props.Name or "Slider",
		Flag = props.Flag or props.Name or "Slider",
		Min = tonumber(props.Min) or 0,
		Max = tonumber(props.Max) or 100,
		Decimal = tonumber(props.Decimal) or 0,
		Suffix = props.Suffix or "",
		Callback = props.Callback or function() end,
		Dragging = false,
	}
	Slider.Default = math.clamp(tonumber(props.Default) or Slider.Min, Slider.Min, Slider.Max)
	Slider.Value = Slider.Default
	Library.Flags[Slider.Flag] = Slider.Value

	Slider.Frame = Library:Create("Frame", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 56),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Slider.Frame, CornerRadius = udim(0, 8) })
	Library:Create("UIStroke", { Parent = Slider.Frame, Color = Colors.Border, Thickness = 1 })

	Slider.Label = Library:Create("TextLabel", {
		Parent = Slider.Frame,
		Position = udim2(0, 12, 0, 8),
		Size = udim2(0.6, 0, 0, 18),
		BackgroundTransparency = 1,
		Text = Slider.Name,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Slider.ValueLabel = Library:Create("TextBox", {
		Parent = Slider.Frame,
		AnchorPoint = v2(1, 0),
		Position = udim2(1, -12, 0, 8),
		Size = udim2(0, 60, 0, 18),
		BackgroundTransparency = 1,
		Text = tostring(Slider.Value) .. Slider.Suffix,
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Colors.Accent,
		TextXAlignment = Enum.TextXAlignment.Right,
		ClearTextOnFocus = true,
	})

	Slider.Track = Library:Create("TextButton", {
		Parent = Slider.Frame,
		Position = udim2(0, 12, 0, 34),
		Size = udim2(1, -24, 0, 6),
		BackgroundColor3 = Colors.SurfaceHover,
		BorderSizePixel = 0,
		Text = "",
	})
	Library:Create("UICorner", { Parent = Slider.Track, CornerRadius = udim(1, 0) })

	Slider.Fill = Library:Create("Frame", {
		Parent = Slider.Track,
		Size = udim2(0, 0, 1, 0),
		BackgroundColor3 = Colors.Accent,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Slider.Fill, CornerRadius = udim(1, 0) })

	function Slider:Set(val)
		local num = tonumber(val)
		if not num then
			Slider.ValueLabel.Text = tostring(Slider.Value) .. Slider.Suffix
			return
		end
		num = math.clamp(Library:Round(num, Slider.Decimal), Slider.Min, Slider.Max)
		Slider.Value = num
		Library.Flags[Slider.Flag] = num
		Slider.ValueLabel.Text = tostring(num) .. Slider.Suffix

		local range = Slider.Max - Slider.Min
		local percent = range > 0 and ((num - Slider.Min) / range) or 0
		Library:Tween(Slider.Fill, { Size = udim2(math.clamp(percent, 0, 1), 0, 1, 0) }, 0.12)
		Slider.Callback(num)
	end

	Slider.Track.MouseButton1Down:Connect(function()
		Slider.Dragging = true
		local function update()
			if not Slider.Dragging then return end
			local mouseX = UserInputService:GetMouseLocation().X
			local absPos, absSize = Slider.Track.AbsolutePosition.X, Slider.Track.AbsoluteSize.X
			if absSize <= 0 then return end
			local relative = math.clamp((mouseX - absPos) / absSize, 0, 1)
			Slider:Set(Slider.Min + (Slider.Max - Slider.Min) * relative)
		end
		update()
		local moveConn, endConn
		moveConn = UserInputService.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then update() end
		end)
		endConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				Slider.Dragging = false
				moveConn:Disconnect()
				endConn:Disconnect()
			end
		end)
	end)

	Slider.ValueLabel.FocusLost:Connect(function()
		local text = Slider.ValueLabel.Text:gsub(Slider.Suffix, "")
		local num = tonumber(text)
		if num then
			Slider:Set(num)
		else
			Slider.ValueLabel.Text = tostring(Slider.Value) .. Slider.Suffix
		end
	end)

	task.defer(function() Slider:Set(Slider.Default) end)
	return setmetatable(Slider, Library)
end

-- ============================================================
-- BUTTON  (styled after the original Launch/Settings buttons)
-- ============================================================
function Library:Button(props)
	props = props or {}
	local Button = {
		Name = props.Name or "Button",
		Callback = props.Callback or function() end,
	}

	Button.Frame = Library:Create("TextButton", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 40),
		BackgroundColor3 = props.Primary and Colors.Accent or Colors.Surface,
		BorderSizePixel = 0,
		Text = "",
	})
	Library:Create("UICorner", { Parent = Button.Frame, CornerRadius = udim(0, 8) })
	if not props.Primary then
		Library:Create("UIStroke", { Parent = Button.Frame, Color = Colors.Border, Thickness = 1 })
	end

	Button.Label = Library:Create("TextLabel", {
		Parent = Button.Frame,
		Size = udim2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Button.Name,
		Font = FONT_BOLD,
		TextSize = 14,
		TextColor3 = props.Primary and Color3.new(1, 1, 1) or Colors.Text,
	})

	local baseColor = props.Primary and Colors.Accent or Colors.Surface
	local hoverColor = props.Primary and Colors.AccentHover or Colors.SurfaceHover

	Button.Frame.MouseEnter:Connect(function()
		Library:Tween(Button.Frame, { BackgroundColor3 = hoverColor, Size = udim2(1, 0, 0, 42) })
	end)
	Button.Frame.MouseLeave:Connect(function()
		Library:Tween(Button.Frame, { BackgroundColor3 = baseColor, Size = udim2(1, 0, 0, 40) })
	end)
	Button.Frame.MouseButton1Click:Connect(function()
		Button.Callback()
	end)

	return setmetatable(Button, Library)
end

-- ============================================================
-- TEXTBOX
-- ============================================================
function Library:Textbox(props)
	props = props or {}
	local Textbox = {
		Name = props.Name or "Textbox",
		Flag = props.Flag or props.Name or "Textbox",
		Default = props.Default or "",
		PlaceHolder = props.PlaceHolder or "Type here...",
		Callback = props.Callback or function() end,
		Value = props.Default or "",
	}
	Library.Flags[Textbox.Flag] = Textbox.Value

	Textbox.Frame = Library:Create("Frame", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 56),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Textbox.Frame, CornerRadius = udim(0, 8) })
	Library:Create("UIStroke", { Parent = Textbox.Frame, Color = Colors.Border, Thickness = 1 })

	Textbox.Label = Library:Create("TextLabel", {
		Parent = Textbox.Frame,
		Position = udim2(0, 12, 0, 6),
		Size = udim2(1, -24, 0, 18),
		BackgroundTransparency = 1,
		Text = Textbox.Name,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Textbox.Box = Library:Create("Frame", {
		Parent = Textbox.Frame,
		Position = udim2(0, 12, 0, 28),
		Size = udim2(1, -24, 0, 22),
		BackgroundColor3 = Colors.SurfaceHover,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Textbox.Box, CornerRadius = udim(0, 6) })
	Library:Create("UIStroke", { Parent = Textbox.Box, Color = Colors.Border, Thickness = 1 })

	Textbox.Input = Library:Create("TextBox", {
		Parent = Textbox.Box,
		Position = udim2(0, 6, 0, 0),
		Size = udim2(1, -12, 1, 0),
		BackgroundTransparency = 1,
		Text = Textbox.Default,
		PlaceholderText = Textbox.PlaceHolder,
		PlaceholderColor3 = Colors.TextDim,
		Font = FONT,
		TextSize = 13,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		ClearTextOnFocus = false,
	})

	function Textbox:Set(val)
		Textbox.Value = val
		Library.Flags[Textbox.Flag] = val
		Textbox.Input.Text = val
		Textbox.Callback(val)
	end

	Textbox.Input.FocusLost:Connect(function()
		Textbox:Set(Textbox.Input.Text)
	end)

	return setmetatable(Textbox, Library)
end

-- ============================================================
-- LABEL
-- ============================================================
function Library:Label(props)
	props = props or {}
	local Label = { Name = props.Name or "Label" }

	Label.Frame = Library:Create("Frame", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 22),
		BackgroundTransparency = 1,
	})
	Label.Text = Library:Create("TextLabel", {
		Parent = Label.Frame,
		Size = udim2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Label.Name,
		Font = FONT_MED,
		TextSize = 13,
		TextColor3 = Colors.SubText,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	function Label:Set(text)
		Label.Name = text
		Label.Text.Text = text
	end

	return setmetatable(Label, Library)
end

-- ============================================================
-- KEYBIND
-- ============================================================
function Library:Keybind(props)
	props = props or {}
	local Keybind = {
		Name = props.Name or "Keybind",
		Flag = props.Flag or props.Name or "Keybind",
		Default = props.Default or Enum.KeyCode.E,
		Callback = props.Callback or function() end,
		Binding = false,
	}
	Keybind.Key = Keybind.Default
	Library.Flags[Keybind.Flag] = Keybind.Key

	Keybind.Frame = Library:Create("Frame", {
		Parent = self.List,
		Size = udim2(1, 0, 0, 36),
		BackgroundColor3 = Colors.Background,
		BorderSizePixel = 0,
	})
	Library:Create("UICorner", { Parent = Keybind.Frame, CornerRadius = udim(0, 8) })
	Library:Create("UIStroke", { Parent = Keybind.Frame, Color = Colors.Border, Thickness = 1 })

	Keybind.Label = Library:Create("TextLabel", {
		Parent = Keybind.Frame,
		Position = udim2(0, 12, 0, 0),
		Size = udim2(0.6, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Keybind.Name,
		Font = FONT_MED,
		TextSize = 14,
		TextColor3 = Colors.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
	})

	Keybind.Button = Library:Create("TextButton", {
		Parent = Keybind.Frame,
		AnchorPoint = v2(1, 0.5),
		Position = udim2(1, -10, 0.5, 0),
		Size = udim2(0, 70, 0, 22),
		BackgroundColor3 = Colors.SurfaceHover,
		BorderSizePixel = 0,
		Text = "",
	})
	Library:Create("UICorner", { Parent = Keybind.Button, CornerRadius = udim(0, 6) })
	Library:Create("UIStroke", { Parent = Keybind.Button, Color = Colors.Border, Thickness = 1 })

	Keybind.KeyLabel = Library:Create("TextLabel", {
		Parent = Keybind.Button,
		Size = udim2(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Text = Keybind.Key.Name == "Unknown" and "NONE" or Keybind.Key.Name,
		Font = FONT_BOLD,
		TextSize = 12,
		TextColor3 = Colors.Accent,
	})

	function Keybind:Set(key)
		Keybind.Key = key
		Library.Flags[Keybind.Flag] = key
		Keybind.KeyLabel.Text = key.Name == "Unknown" and "NONE" or key.Name
		Keybind.Callback(key)
	end

	Keybind.Button.MouseButton1Click:Connect(function()
		Keybind.Binding = true
		Keybind.KeyLabel.Text = "..."
		local connection
		connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.Keyboard then
				Keybind:Set(input.KeyCode)
				Keybind.Binding = false
				connection:Disconnect()
			end
		end)
	end)

	return setmetatable(Keybind, Library)
end

return Library
