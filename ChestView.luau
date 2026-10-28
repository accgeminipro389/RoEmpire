--!nonstrict
-- The cosmetic crate's chest (RoEmpire's own chest art) drawn in a ViewportFrame, shared
-- by the opening show (CrateOpening), the title screen's crate button (CrateButton) and the Locker's crate
-- card. build() makes the camera and the parts; pose() places them from a pose table:
--   y (studs), yaw / roll / pitch (radians), sq (squash, + = flat), s (scale), lid (degrees).
-- idle() is the small views' life: a bob, and every `every` seconds a wiggle with the lid cracking.
local IS_ROBLOX = typeof(game) == "Instance"
local Model: any = if IS_ROBLOX
	then require((game :: any):GetService("ReplicatedStorage"):WaitForChild("Airfront").Assets.CrateModel)
	else (require :: any)("../../shared/Assets/CrateModel")

local ChestView = {}

ChestView.Model = Model
-- the camera (studs): the closed chest takes about 60% of a square viewport's width
ChestView.CAM_FOV = 28
ChestView.CAM_CF = CFrame.lookAt(Vector3.new(0, 6.2, -18), Vector3.new(0, 2.3, 0))
ChestView.BASE_YAW = math.rad(24)
ChestView.AMBIENT = Color3.fromRGB(150, 146, 150)
ChestView.IMAGE = "rbxassetid://84444802536218"
ChestView.IMAGE_SIZE = 0.78

local function v3(t: { number }): Vector3
	return Vector3.new(t[1], t[2], t[3])
end
ChestView.v3 = v3

--- A fresh pose (the chest at rest, closed).
function ChestView.rest(): { [string]: number }
	return { y = 0, yaw = 0, roll = 0, pitch = 0, sq = 0, s = 1, lid = 0 }
end

--- The camera and the chest's parts inside `vpf` (its lighting set too). Returns the chest record.
function ChestView.build(vpf: ViewportFrame): any
	vpf.Ambient = ChestView.AMBIENT
	vpf.LightColor = Color3.fromRGB(255, 244, 228)
	vpf.LightDirection = Vector3.new(0.45, -1, 0.55)
	local cam = Instance.new("Camera")
	cam.FieldOfView = ChestView.CAM_FOV
	cam.CFrame = ChestView.CAM_CF
	cam.Parent = vpf
	vpf.CurrentCamera = cam
	local img = Instance.new("ImageLabel")
	img.Name = "Chest2D"
	img.BackgroundTransparency = 1
	img.Image = ChestView.IMAGE
	img.ScaleType = Enum.ScaleType.Fit
	img.AnchorPoint = Vector2.new(0.5, 0.5)
	img.Position = UDim2.fromScale(0.5, 0.55)
	img.Size = UDim2.fromScale(ChestView.IMAGE_SIZE, ChestView.IMAGE_SIZE)
	img.ZIndex = vpf.ZIndex
	img.Parent = vpf
	local chest = { parts = {}, img = img, vpf = vpf }
	return chest
end

function ChestView.root_cf(P: any): CFrame
	return CFrame.new(0, P.y, 0) * CFrame.Angles(0, ChestView.BASE_YAW + P.yaw, 0) * CFrame.Angles(P.pitch, 0, P.roll)
end

--- Place the chest's parts from pose P (squash in the parts' own axes, the lid about its hinge).
function ChestView.pose(chest: any, P: any)
	local sy = (1 - P.sq) * P.s
	local sxz = (1 + P.sq * 0.55) * P.s
	local img = chest.img
	img.Rotation = math.deg(P.roll + P.yaw * 0.5)
	img.ImageTransparency = chest.vpf.ImageTransparency
	img.Size = UDim2.fromScale(ChestView.IMAGE_SIZE * sxz, ChestView.IMAGE_SIZE * sy)
	img.Position = UDim2.fromScale(0.5, 0.55 - P.y * 0.06 - P.lid * 0.002)
end

--- Viewport px (from its centre, y down) of a chest-space point in pose P, for a square viewport of
--- side `side` px.
function ChestView.project(P: any, p: Vector3, side: number): Vector2
	local c = ChestView.CAM_CF:PointToObjectSpace(ChestView.root_cf(P) * p)
	local th = math.tan(math.rad(ChestView.CAM_FOV / 2))
	local depth = math.max(-c.Z, 0.1)
	local half = side * 0.5
	return Vector2.new(c.X / (depth * th) * half, -c.Y / (depth * th) * half)
end

--- The small views' idle at time t (seconds): a bob, a wiggle with a lid crack every `every` seconds
--- (`strength` 0..1 scales it). Returns how open the lid's crack is (0..1), for a light leak.
function ChestView.idle(P: any, t: number, every: number, strength: number?): number
	local k0 = strength or 1
	P.y = math.sin(t * 2.4) * 0.08
	local phase = t % every
	local k = phase / 0.42
	if k < 1 then
		local wig = math.sin(k * math.pi * 3) * (1 - k) * math.rad(6) * k0
		P.roll = wig
		P.yaw = wig * 0.6
		P.lid = math.sin(k * math.pi) * 8 * k0
		return math.sin(k * math.pi)
	end
	P.roll, P.yaw, P.lid = 0, 0, 0
	return 0
end

return ChestView
