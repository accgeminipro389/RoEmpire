-- The Arsenal's art (Data/Arsenal): white interface masks and the shop cards' renders (its
-- structures' map plates and glyphs are in Assets/MapSprites with every other structure's).
return {
	ui = {
		artillery = "rbxassetid://129962050975056",
		airfield = "rbxassetid://93161184929593",
		railgun = "rbxassetid://80259865103214",
		mega = "rbxassetid://129076365242890",
		scatter = "rbxassetid://73314694929508",
		reinforce = "rbxassetid://80150583838975",
		airstrike = "rbxassetid://97597884564003",
		slug = "rbxassetid://74359376650198",
		star = "rbxassetid://123717027950196",
		lock = "rbxassetid://115477224449087",
		reload = "rbxassetid://98646122722253",
		arsenal = "rbxassetid://100317438832041",
	},
	--- the shop cards' item renders (Data/Arsenal item key -> image; models of military hardware
	--- generated in Studio, photographed and cut out by tools/assets/make_arsenal_renders.py):
	--- { id, w, h }
	renders = {
		airfield = { id = "rbxassetid://74538130984294", w = 384, h = 384 },
		artillery = { id = "rbxassetid://89238641812813", w = 384, h = 384 },
		mega = { id = "rbxassetid://109777721780597", w = 384, h = 384 },
		railgun = { id = "rbxassetid://114557627794316", w = 384, h = 384 },
		reinforce = { id = "rbxassetid://116672517749724", w = 384, h = 384 },
		reload2x = { id = "rbxassetid://72068076425946", w = 384, h = 384 },
		scatter = { id = "rbxassetid://114458279755345", w = 384, h = 384 },
		stars2x = { id = "rbxassetid://135307802659750", w = 384, h = 384 },
	},
}
