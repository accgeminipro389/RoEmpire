--!strict
-- RoEmpire's UI is square (the owner's kit: no rounded corners; 2026-10-29). Every UICorner under
-- the player's GUI is set to 0, now and whenever one is added or a script sets it again, except
-- true circles and pills (a radius of half the size or more: country balls, dots, the price
-- stickers, the glosses of Layered).
local SquareCorners = {}

local ZERO = UDim.new(0, 0)
local hooked: { [UICorner]: boolean } = setmetatable({}, { __mode = "k" }) :: any

local function round_on_purpose(c: UICorner): boolean
	return c.CornerRadius.Scale >= 0.45
end

local function square(c: UICorner)
	if not round_on_purpose(c) and c.CornerRadius ~= ZERO then
		c.CornerRadius = ZERO
	end
end

local function hook(inst: Instance)
	if not inst:IsA("UICorner") then
		return
	end
	local c = inst :: UICorner
	if hooked[c] then
		return
	end
	hooked[c] = true
	square(c)
	c:GetPropertyChangedSignal("CornerRadius"):Connect(function()
		square(c)
	end)
end

function SquareCorners.watch(root: Instance)
	for _, d in root:GetDescendants() do
		hook(d)
	end
	root.DescendantAdded:Connect(hook)
end

return SquareCorners
