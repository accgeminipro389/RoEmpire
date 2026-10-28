--!strict
local RS = game:GetService("ReplicatedStorage")
local Art = require(RS:WaitForChild("Airfront"):WaitForChild("Assets"):WaitForChild("Countryball")) :: any
local Balls = require(RS:WaitForChild("Airfront"):WaitForChild("Assets"):WaitForChild("CountryballFlags")) :: any

local Countryball = {}
Countryball.__index = Countryball

Countryball.BOB_HZ = 1.6
Countryball.BOB_AMP = 0.06
Countryball.SQUASH = 0.05
Countryball.EYE_W = 0.24
Countryball.EYE_H = 0.34
Countryball.EYE_GAP = 0.13
Countryball.EYE_Y = 0.42

local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)

export type Ball = {
	holder: Frame,
	body: Frame,
	scaler: UIScale,
	eyes: ImageLabel,
	drawn: Frame,
	outline: UIStroke,
	mood: string,
	px: number,
	phase: number,
	flag: string,
}

local function drawn_eye(parent: Instance, name: string, x: number): Frame
	local e = Instance.new("Frame")
	e.Name = name
	e.AnchorPoint = Vector2.new(0.5, 0.5)
	e.Position = UDim2.fromScale(x, 0.5)
	e.Size = UDim2.fromScale(Countryball.EYE_W / (Countryball.EYE_W * 2 + Countryball.EYE_GAP), 1)
	e.BackgroundColor3 = WHITE
	e.BorderSizePixel = 0
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = e
	local s = Instance.new("UIStroke")
	s.Color = BLACK
	s.Thickness = 1
	s.Parent = e
	e.Parent = parent
	return e
end

function Countryball.new(parent: Instance, order: number): Ball
	local holder = Instance.new("Frame")
	holder.Name = "Ball"
	holder.BackgroundTransparency = 1
	holder.LayoutOrder = order
	holder.Size = UDim2.fromOffset(0, 0)
	holder.ZIndex = 21

	local body = Instance.new("Frame")
	body.Name = "Body"
	body.AnchorPoint = Vector2.new(0.5, 1)
	body.Position = UDim2.fromScale(0.5, 1)
	body.Size = UDim2.fromScale(1, 1)
	body.BorderSizePixel = 0
	body.ZIndex = 21
	body.Parent = holder
	local bc = Instance.new("UICorner")
	bc.CornerRadius = UDim.new(1, 0)
	bc.Parent = body
	local outline = Instance.new("UIStroke")
	outline.Color = BLACK
	outline.LineJoinMode = Enum.LineJoinMode.Round
	outline.Parent = body
	local scaler = Instance.new("UIScale")
	scaler.Parent = body

	local eyes = Instance.new("ImageLabel")
	eyes.Name = "Eyes"
	eyes.BackgroundTransparency = 1
	eyes.AnchorPoint = Vector2.new(0.5, 0.5)
	eyes.Position = UDim2.fromScale(0.5, Countryball.EYE_Y)
	eyes.Size = UDim2.fromScale(0.82, 0.82)
	eyes.ScaleType = Enum.ScaleType.Fit
	eyes.ZIndex = 22
	eyes.Visible = false
	eyes.Parent = body

	local drawn = Instance.new("Frame")
	drawn.Name = "DrawnEyes"
	drawn.BackgroundTransparency = 1
	drawn.AnchorPoint = Vector2.new(0.5, 0.5)
	drawn.Position = UDim2.fromScale(0.5, Countryball.EYE_Y)
	drawn.Size = UDim2.fromScale(Countryball.EYE_W * 2 + Countryball.EYE_GAP, Countryball.EYE_H)
	drawn.ZIndex = 22
	drawn.Parent = body
	local half = Countryball.EYE_W / (Countryball.EYE_W * 2 + Countryball.EYE_GAP) / 2
	drawn_eye(drawn, "L", half).ZIndex = 22
	drawn_eye(drawn, "R", 1 - half).ZIndex = 22

	holder.Parent = parent
	local b: Ball = {
		holder = holder,
		body = body,
		scaler = scaler,
		eyes = eyes,
		drawn = drawn,
		outline = outline,
		mood = "",
		px = -1,
		phase = math.random() * math.pi * 2,
		flag = "",
	}
	Countryball.set_mood(b, "neutral")
	return b
end

--- The flag code of an owner's ball: a nation's own flag (map manifest, by name), else the one
--- the match dealt the player (cosmetics.ball).
function Countryball.code_for(st: any, id: number): string?
	local cz = st.cosmetics and st.cosmetics[id]
	if cz ~= nil and cz.ball ~= nil then
		return cz.ball
	end
	local m = st.map
	if m == nil or m.nations == nil then
		return nil
	end
	if st._ball_names ~= m then
		st._ball_names = m
		local t = {}
		for _, n in m.nations do
			if n.name and n.flag then
				t[n.name] = n.flag
			end
		end
		st._ball_flags = t
	end
	return st._ball_flags[st:owner_name(id)]
end

function Countryball.set_color(b: Ball, c: Color3)
	b.body.BackgroundColor3 = c
end

function Countryball.set_flag(b: Ball, code: string?)
	local c = string.lower(code or "")
	if c == b.flag then
		return
	end
	b.flag = c
	local e = Balls.balls[c]
	local atlas = if e then Balls.atlases[e.atlas] else nil
	local img = b.body:FindFirstChild("Flag") :: ImageLabel?
	if atlas == nil or atlas == "" then
		if img then
			img:Destroy()
		end
		b.body.BackgroundTransparency = 0
		b.outline.Enabled = true
		return
	end
	if img == nil then
		local i = Instance.new("ImageLabel")
		i.Name = "Flag"
		i.BackgroundTransparency = 1
		i.Size = UDim2.fromScale(1, 1)
		i.ZIndex = 21
		i.Parent = b.body
		img = i
	end
	local f = img :: ImageLabel
	f.Image = atlas
	f.ImageRectOffset = Vector2.new(e.x, e.y)
	f.ImageRectSize = Vector2.new(Balls.size, Balls.size)
	b.body.BackgroundTransparency = 1
	b.outline.Enabled = false
end

function Countryball.set_size(b: Ball, px: number)
	if px == b.px then
		return
	end
	b.px = px
	b.holder.Size = UDim2.fromOffset(px, px)
	local t = math.max(1, px * 0.06)
	b.outline.Thickness = t
	for _, e in b.drawn:GetChildren() do
		local s = e:FindFirstChildOfClass("UIStroke")
		if s then
			s.Thickness = math.max(1, t * 0.6)
		end
	end
end

function Countryball.set_mood(b: Ball, mood: string)
	if mood == b.mood then
		return
	end
	b.mood = mood
	local id = Art.eyes[mood] or ""
	if id == "" then
		id = Art.eyes.neutral or ""
	end
	b.eyes.Image = id
	b.eyes.Visible = id ~= ""
	b.drawn.Visible = id == ""
end

function Countryball.step(b: Ball, now: number)
	local m = b.mood
	local hz = if m == "scared" then 4.0 elseif m == "happy" or m == "smug" then 2.2 else Countryball.BOB_HZ
	local s = math.sin(now * hz * math.pi * 2 + b.phase)
	local air = math.max(0, s)
	local sq = math.max(0, -s) * Countryball.SQUASH
	b.body.Position = UDim2.fromScale(0.5, 1 - air * Countryball.BOB_AMP)
	b.body.Size = UDim2.fromScale(1 + sq, 1 - sq + air * Countryball.SQUASH * 0.5)
end

return Countryball
