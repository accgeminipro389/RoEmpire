--!strict
local Layered = {}

Layered.STROKE_DARKEN = 0.55
Layered.GLOW_DARKEN = 0.72
Layered.GLOW_TRANSPARENCY = 0.25
Layered.BEVEL_ALPHA = 0.2
Layered.GLOSS_LOW = 0.06
Layered.GLOSS_HIGH = 0.13

local WHITE = Color3.new(1, 1, 1)

local function scaled(c: Color3, k: number): Color3
	return Color3.new(c.R * k, c.G * k, c.B * k)
end

local function lighten(c: Color3, t: number): Color3
	return c:Lerp(WHITE, t)
end

Layered.scaled = scaled
Layered.lighten = lighten

--- EasyVisuals' "Shine" (ReplicatedStorage.Airfront.Libs.EasyVisuals, from the Toolbox, checked
--- clean 2026-10-29): a light that keeps running across a buy button. Never fails the caller.
local EV: any = nil
function Layered.shine(frame: GuiObject, speed: number?)
	if typeof(game) ~= "Instance" then
		return nil
	end
	if EV == nil then
		local ok, m = pcall(function()
			return require((game :: any):GetService("ReplicatedStorage").Airfront.Libs.EasyVisuals)
		end)
		EV = if ok then m else false
	end
	if not EV then
		return nil
	end
	local ok, fx = pcall(EV.new, frame, "Shine", speed or 0.004, 1)
	return if ok then fx else nil
end

function Layered.stroke_color(base: Color3): Color3
	return scaled(base, Layered.STROKE_DARKEN)
end

local function child(parent: Instance, name: string, class_name: string): any
	local c = parent:FindFirstChild(name)
	if c == nil or c.ClassName ~= class_name then
		if c then
			c:Destroy()
		end
		c = Instance.new(class_name)
		c.Name = name
		if c:IsA("GuiObject") then
			c.BorderSizePixel = 0
			c.Active = false
		end
		c.Parent = parent
	end
	return c
end

local BEVELS = {
	{ "BevelL", UDim2.new(0, 0, 0, 0), function(t: number) return UDim2.new(0, t, 1, 0) end },
	{ "BevelT", UDim2.new(0, 0, 0, 0), function(t: number) return UDim2.new(1, 0, 0, t) end },
	{ "BevelR", UDim2.new(1, 0, 0, 0), function(t: number) return UDim2.new(0, t, 1, 0) end },
	{ "BevelB", UDim2.new(0, 0, 1, 0), function(t: number) return UDim2.new(1, 0, 0, t) end },
}

export type Opts = {
	radius_px: number,
	glow_blur: number?,
	bevel_px: number?,
	gloss: boolean?,
}

--- The same look on a plain GuiObject (no kit node: windows built from raw instances, like the
--- Starter Pack): its colour, the dark stroke, the glow, the two glosses and the bevel.
function Layered.apply_raw(frame: GuiObject, base: Color3, opts: Opts)
	local parts: { [Instance]: { [string]: number } } = {}
	local fake = {
		_part = function(_self: any, inst: Instance, prop: string, alpha: number)
			(inst :: any)[prop] = 1 - alpha
		end,
	}
	frame.BackgroundColor3 = base
	frame.BackgroundTransparency = 0
	for _, g in frame:GetChildren() do
		if g:IsA("UIGradient") then
			g:Destroy()
		end
	end
	local st = frame:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	st.Color = Layered.stroke_color(base)
	st.Transparency = 0
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	st.Parent = frame
	Layered.apply(fake, frame, base, opts)
	-- (the glow: a raw frame shows it at its own strength)
	local glow = frame:FindFirstChild("Glow")
	if glow then
		pcall(function()
			(glow :: any).Transparency = Layered.GLOW_TRANSPARENCY
		end)
	end
	local _ = parts
end

function Layered.apply(node: any, frame: GuiObject, base: Color3, opts: Opts)
	local shadow = child(frame, "Glow", "UIShadow")
	pcall(function()
		shadow.Color = scaled(base, Layered.GLOW_DARKEN)
		shadow.BlurRadius = UDim.new(opts.glow_blur or 0.3, 0)
		shadow.Offset = UDim2.new()
		shadow.Spread = UDim2.new()
	end)
	node:_part(shadow, "Transparency", 1 - Layered.GLOW_TRANSPARENCY)

	local ui = child(frame, "UI", "Frame") :: Frame
	ui.BackgroundTransparency = 1
	ui.Size = UDim2.fromScale(1, 1)
	ui.Position = UDim2.new()
	ui.ClipsDescendants = true
	ui.ZIndex = frame.ZIndex
	local uc = child(ui, "UICorner", "UICorner") :: UICorner
	uc.CornerRadius = UDim.new(0, opts.radius_px)

	local gloss = opts.gloss ~= false
	local low = child(ui, "GlossLow", "Frame") :: Frame
	local high = child(ui, "GlossHigh", "Frame") :: Frame
	for _, g in { low, high } do
		g.Visible = gloss
		g.ZIndex = frame.ZIndex
		g.Size = UDim2.fromScale(1.115, 1.574)
		local gc = child(g, "UICorner", "UICorner") :: UICorner
		gc.CornerRadius = UDim.new(1, 0)
	end
	low.Position = UDim2.fromScale(-0.0574, -0.658)
	high.Position = UDim2.fromScale(-0.0574, -1.1576)
	low.BackgroundColor3 = lighten(base, Layered.GLOSS_LOW)
	high.BackgroundColor3 = lighten(base, Layered.GLOSS_HIGH)
	node:_part(low, "BackgroundTransparency", if gloss then 1 else 0)
	node:_part(high, "BackgroundTransparency", if gloss then 1 else 0)

	local t = math.max(1, opts.bevel_px or 2)
	for _, b in BEVELS do
		local f = child(ui, b[1], "Frame") :: Frame
		f.BackgroundColor3 = WHITE
		f.AnchorPoint = if b[1] == "BevelR" then Vector2.new(1, 0) elseif b[1] == "BevelB" then Vector2.new(0, 1) else Vector2.zero
		f.Position = b[2]
		f.Size = b[3](t)
		f.ZIndex = frame.ZIndex
		node:_part(f, "BackgroundTransparency", Layered.BEVEL_ALPHA)
	end
end

function Layered.clear(node: any, frame: GuiObject)
	for _, name in { "Glow", "UI" } do
		local c = frame:FindFirstChild(name)
		if c then
			node:_drop_part(c)
			for _, d in c:GetDescendants() do
				node:_drop_part(d)
			end
			c:Destroy()
		end
	end
end

return Layered
