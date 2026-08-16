local ProductionArtSpec = {}

local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end

local palette = {
	colors = {
		cream = rgb(244, 232, 210),
		creamDeep = rgb(222, 203, 173),
		stone = rgb(207, 190, 157),
		stoneDark = rgb(153, 132, 102),
		slate = rgb(83, 57, 94),
		slateLight = rgb(118, 81, 128),
		timber = rgb(126, 76, 42),
		timberDark = rgb(72, 43, 32),
		timberLight = rgb(176, 124, 75),
		blue = rgb(74, 132, 169),
		blueDark = rgb(45, 83, 115),
		rose = rgb(194, 116, 142),
		lavender = rgb(151, 119, 188),
		green = rgb(78, 132, 86),
		greenLight = rgb(121, 177, 117),
		greenDark = rgb(57, 94, 64),
		sage = rgb(138, 164, 117),
		gold = rgb(213, 166, 70),
		metal = rgb(47, 61, 75),
		glass = rgb(105, 177, 197),
		water = rgb(74, 177, 213),
		canvas = rgb(232, 215, 181),
		marketRed = rgb(182, 83, 84),
		marketGold = rgb(216, 166, 72),
		soil = rgb(86, 59, 40),
		paper = rgb(247, 244, 234),
		warmLight = rgb(255, 224, 155),
	},
}

local function c(name, shape, size, position, color, material, role, extra)
	local item = {
		name = name,
		shape = shape,
		size = size,
		position = position,
		color = color,
		material = material,
		role = role,
	}
	if extra then
		for key, value in extra do
			item[key] = value
		end
	end
	return item
end

local assets = {}

assets["town-hall"] = {
	displayName = "TinyWorld_TownHall_v1",
	qualityTier = "hero",
	components = {
		c("Foundation", "beveledBox", { 34, 1.2, 28 }, { 0, 0.6, 0 }, "stone", "stone", "civic-foundation", { bevel = 0.55 }),
		c("MainBody", "beveledBox", { 30, 9.5, 24 }, { 0, 5.35, 0 }, "cream", "plaster", "civic-body", { bevel = 0.85 }),
		c("MainRoof", "hipRoof", { 34, 5.2, 28 }, { 0, 10.1, 0 }, "slate", "slate", "civic-roof"),
		c("ClockTower", "beveledBox", { 9, 9, 9 }, { 0, 14.4, -1.5 }, "creamDeep", "stone", "civic-clock-tower", { bevel = 0.65 }),
		c("ClockTowerRoof", "hipRoof", { 11, 4, 11 }, { 0, 18.9, -1.5 }, "slateLight", "slate", "civic-clock-roof"),
		c("ClockFace", "cylinder", { 5.2, 0.55, 5.2 }, { 0, 15.1, 3.1 }, "paper", "paint", "civic-clock-face", { rotation = { 90, 0, 0 }, segments = 20 }),
		c("ClockHub", "cylinder", { 0.7, 0.8, 0.7 }, { 0, 15.1, 3.45 }, "gold", "metal", "civic-clock-hub", { rotation = { 90, 0, 0 }, segments = 12 }),
		c("PorticoRoof", "gableRoof", { 16, 3.3, 8 }, { 0, 9, 13.2 }, "slateLight", "slate", "civic-portico-roof"),
		c("PorticoColumnL", "frustum", { 1.45, 7.4, 1.45 }, { -5.2, 4.6, 14.1 }, "stone", "stone", "civic-portico-column", { segments = 8, topScale = 0.76 }),
		c("PorticoColumnR", "frustum", { 1.45, 7.4, 1.45 }, { 5.2, 4.6, 14.1 }, "stone", "stone", "civic-portico-column", { segments = 8, topScale = 0.76 }),
		c("FrontDoor", "panel", { 5.2, 6.6, 0.55 }, { 0, 4.25, 12.35 }, "timberDark", "wood", "civic-entry", { bevel = 0.22 }),
		c("WindowFrameL", "windowSet", { 5.5, 4.2, 0.45 }, { -8.2, 5.5, 12.45 }, "timberDark", "wood", "civic-window-frame"),
		c("WindowGlassL", "panel", { 4.55, 3.25, 0.16 }, { -8.2, 5.5, 12.3 }, "glass", "glass", "civic-window-glass", { transparency = 0.32 }),
		c("WindowFrameR", "windowSet", { 5.5, 4.2, 0.45 }, { 8.2, 5.5, 12.45 }, "timberDark", "wood", "civic-window-frame"),
		c("WindowGlassR", "panel", { 4.55, 3.25, 0.16 }, { 8.2, 5.5, 12.3 }, "glass", "glass", "civic-window-glass", { transparency = 0.32 }),
	},
}

assets["starter-home"] = {
	displayName = "TinyWorld_StarterHome_v1",
	qualityTier = "hero",
	components = {
		c("Foundation", "beveledBox", { 31.5, 1.2, 25.5 }, { 0, 0.6, 0 }, "stone", "stone", "home-foundation", { bevel = 0.55 }),
		c("Floor", "beveledBox", { 30, 0.65, 24 }, { 0, 1.15, 0 }, "timber", "woodPlanks", "home-floor", { bevel = 0.2 }),
		c("BackWall", "beveledBox", { 30, 9, 0.8 }, { 0, 5.6, -11.6 }, "cream", "plaster", "home-wall", { bevel = 0.3 }),
		c("LeftWall", "beveledBox", { 0.8, 9, 24 }, { -14.6, 5.6, 0 }, "cream", "plaster", "home-wall", { bevel = 0.3 }),
		c("RightWall", "beveledBox", { 0.8, 9, 24 }, { 14.6, 5.6, 0 }, "cream", "plaster", "home-wall", { bevel = 0.3 }),
		c("FrontWallL", "beveledBox", { 11.5, 9, 0.8 }, { -9.2, 5.6, 11.6 }, "cream", "plaster", "home-front-wall", { bevel = 0.3 }),
		c("FrontWallR", "beveledBox", { 11.5, 9, 0.8 }, { 9.2, 5.6, 11.6 }, "cream", "plaster", "home-front-wall", { bevel = 0.3 }),
		c("MainRoof", "gableRoof", { 33, 5.2, 27 }, { 0, 10.1, 0 }, "slate", "slate", "home-roof"),
		c("Chimney", "beveledBox", { 2.6, 5.5, 2.6 }, { 8.4, 12, -3.2 }, "stoneDark", "brick", "home-chimney", { bevel = 0.28 }),
		c("PorchDeck", "beveledBox", { 13, 0.55, 6 }, { 0, 1.5, 14.2 }, "timber", "woodPlanks", "home-porch", { bevel = 0.3 }),
		c("PorchRoof", "gableRoof", { 14.5, 2.6, 7 }, { 0, 7.7, 14.1 }, "slateLight", "slate", "home-porch-roof"),
		c("PorchPostL", "frustum", { 0.85, 5.7, 0.85 }, { -5, 4.5, 15.5 }, "timberLight", "wood", "home-porch-post", { segments = 8, topScale = 0.78 }),
		c("PorchPostR", "frustum", { 0.85, 5.7, 0.85 }, { 5, 4.5, 15.5 }, "timberLight", "wood", "home-porch-post", { segments = 8, topScale = 0.78 }),
		c("FrontDoor", "panel", { 4.8, 6.5, 0.55 }, { 0, 4.55, 12.15 }, "timberDark", "wood", "home-front-door", { bevel = 0.24 }),
		c("WindowFrameL", "windowSet", { 5.2, 4, 0.4 }, { -8.5, 5.6, 12.25 }, "timberDark", "wood", "home-window-frame"),
		c("WindowGlassL", "panel", { 4.3, 3.15, 0.14 }, { -8.5, 5.6, 12.1 }, "glass", "glass", "home-window-glass", { transparency = 0.34 }),
		c("WindowFrameR", "windowSet", { 5.2, 4, 0.4 }, { 8.5, 5.6, 12.25 }, "timberDark", "wood", "home-window-frame"),
		c("WindowGlassR", "panel", { 4.3, 3.15, 0.14 }, { 8.5, 5.6, 12.1 }, "glass", "glass", "home-window-glass", { transparency = 0.34 }),
		c("SideWindowFrame", "windowSet", { 4.6, 3.6, 0.4 }, { 14.95, 5.4, -2.8 }, "timberDark", "wood", "home-side-window-frame", { rotation = { 0, 90, 0 } }),
		c("SideWindowGlass", "panel", { 3.75, 2.8, 0.14 }, { 14.8, 5.4, -2.8 }, "glass", "glass", "home-side-window-glass", { rotation = { 0, 90, 0 }, transparency = 0.34 }),
	},
}

local function shopAsset(displayName, accent, rolePrefix)
	return {
		displayName = displayName,
		qualityTier = "hero",
		components = {
			c("Foundation", "beveledBox", { 32, 1.1, 26 }, { 0, 0.55, 0 }, "stone", "stone", rolePrefix .. "-foundation", { bevel = 0.5 }),
			c("Body", "beveledBox", { 30, 9.5, 24 }, { 0, 5.3, 0 }, "cream", "plaster", rolePrefix .. "-body", { bevel = 0.75 }),
			c("Roof", "gableRoof", { 34, 5, 28 }, { 0, 10, 0 }, accent, "slate", rolePrefix .. "-roof"),
			c("Awning", "panel", { 18, 0.45, 5.5 }, { 0, 7.5, 13.2 }, "canvas", "fabric", rolePrefix .. "-awning", { rotation = { 7, 0, 0 }, bevel = 0.18 }),
			c("Door", "panel", { 4.5, 6.5, 0.5 }, { 0, 4.3, 12.25 }, "timberDark", "wood", rolePrefix .. "-door", { bevel = 0.22 }),
			c("WindowFrameL", "windowSet", { 6.5, 4.8, 0.4 }, { -8.5, 5.5, 12.35 }, "timberDark", "wood", rolePrefix .. "-window-frame"),
			c("WindowGlassL", "panel", { 5.45, 3.8, 0.14 }, { -8.5, 5.5, 12.2 }, "glass", "glass", rolePrefix .. "-window-glass", { transparency = 0.3 }),
			c("WindowFrameR", "windowSet", { 6.5, 4.8, 0.4 }, { 8.5, 5.5, 12.35 }, "timberDark", "wood", rolePrefix .. "-window-frame"),
			c("WindowGlassR", "panel", { 5.45, 3.8, 0.14 }, { 8.5, 5.5, 12.2 }, "glass", "glass", rolePrefix .. "-window-glass", { transparency = 0.3 }),
			c("Sign", "panel", { 10, 2, 0.45 }, { 0, 9.2, 12.7 }, accent, "wood", rolePrefix .. "-sign", { bevel = 0.3 }),
		},
	}
end

assets["village-shop"] = shopAsset("TinyWorld_VillageShop_v1", "blueDark", "shop")
assets["home-store"] = shopAsset("TinyWorld_HomeStore_v1", "rose", "home-store")

assets["courier-depot"] = {
	displayName = "TinyWorld_CourierDepot_v1",
	qualityTier = "hero",
	components = {
		c("Foundation", "beveledBox", { 30, 1.1, 24 }, { 0, 0.55, 0 }, "stone", "stone", "courier-foundation", { bevel = 0.5 }),
		c("Body", "beveledBox", { 28, 9, 22 }, { 0, 5.05, 0 }, "creamDeep", "plaster", "courier-body", { bevel = 0.7 }),
		c("Roof", "gableRoof", { 32, 4.8, 26 }, { 0, 9.55, 0 }, "blueDark", "slate", "courier-roof"),
		c("LoadingAwning", "panel", { 14, 0.48, 6 }, { 0, 7.1, 12.7 }, "blue", "fabric", "courier-loading-awning", { rotation = { 8, 0, 0 }, bevel = 0.2 }),
		c("LoadingDoor", "panel", { 8, 6.5, 0.5 }, { 0, 4.25, 11.25 }, "timberDark", "wood", "courier-loading-door", { bevel = 0.25 }),
		c("RouteBoard", "panel", { 5.5, 4, 0.45 }, { -9, 4.8, 11.6 }, "blueDark", "wood", "courier-route-board", { bevel = 0.25 }),
	},
}

assets["workshop"] = {
	displayName = "TinyWorld_Workshop_v1",
	qualityTier = "hero",
	components = {
		c("Foundation", "beveledBox", { 32, 1.1, 25 }, { 0, 0.55, 0 }, "stoneDark", "stone", "workshop-foundation", { bevel = 0.5 }),
		c("Body", "beveledBox", { 30, 9, 23 }, { 0, 5.05, 0 }, "blueDark", "paint", "workshop-body", { bevel = 0.7 }),
		c("Roof", "gableRoof", { 34, 4.5, 27 }, { 0, 9.55, 0 }, "slate", "slate", "workshop-roof"),
		c("GarageDoor", "panel", { 11, 7, 0.55 }, { 4.5, 4.45, 11.8 }, "metal", "metal", "workshop-garage-door", { bevel = 0.25 }),
		c("EntryDoor", "panel", { 4.5, 6.4, 0.5 }, { -8.5, 4.2, 11.8 }, "timber", "wood", "workshop-entry", { bevel = 0.22 }),
		c("Workbench", "beveledBox", { 8, 1, 3 }, { -8, 3, 8.5 }, "timber", "woodPlanks", "workshop-bench", { bevel = 0.3 }),
	},
}

local function marketStall(displayName, canopyColor, stockLeft, stockRight)
	return {
		displayName = displayName,
		qualityTier = "hero",
		components = {
			c("Counter", "beveledBox", { 11, 1.2, 4.5 }, { 0, 3.2, 0 }, "timber", "woodPlanks", "market-counter", { bevel = 0.35 }),
			c("PostL", "frustum", { 0.8, 5.5, 0.8 }, { -4.7, 3.1, -1.5 }, "timberDark", "wood", "market-post", { segments = 8, topScale = 0.82 }),
			c("PostR", "frustum", { 0.8, 5.5, 0.8 }, { 4.7, 3.1, -1.5 }, "timberDark", "wood", "market-post", { segments = 8, topScale = 0.82 }),
			c("Canopy", "gableRoof", { 13, 2.5, 8 }, { 0, 7.1, 0 }, canopyColor, "fabric", "market-canopy"),
			c("StockL", "beveledBox", { 3, 1.5, 3 }, { -3, 4.5, 0 }, stockLeft, "wood", "market-stock", { bevel = 0.28 }),
			c("StockR", "beveledBox", { 3, 1.5, 3 }, { 3, 4.5, 0 }, stockRight, "wood", "market-stock", { bevel = 0.28 }),
		},
	}
end
assets["market-stall-a"] = marketStall("TinyWorld_MarketStall_A_v1", "marketRed", "greenLight", "marketGold")
assets["market-stall-b"] = marketStall("TinyWorld_MarketStall_B_v1", "marketGold", "blue", "rose")

assets["fountain"] = {
	displayName = "TinyWorld_Fountain_v1",
	qualityTier = "hero",
	components = {
		c("OuterBasin", "cylinder", { 18, 1.5, 18 }, { 0, 0.75, 0 }, "stone", "marble", "fountain-basin", { segments = 24 }),
		c("InnerWater", "cylinder", { 15.5, 0.35, 15.5 }, { 0, 1.45, 0 }, "water", "water", "fountain-water", { segments = 24, transparency = 0.18 }),
		c("Pedestal", "frustum", { 4.2, 5.2, 4.2 }, { 0, 4, 0 }, "stoneDark", "marble", "fountain-pedestal", { segments = 12, topScale = 0.62 }),
		c("UpperBowl", "cylinder", { 7.5, 0.8, 7.5 }, { 0, 6.7, 0 }, "stone", "marble", "fountain-upper-bowl", { segments = 20 }),
		c("Spout", "frustum", { 1.8, 3.8, 1.8 }, { 0, 8.6, 0 }, "stoneDark", "marble", "fountain-spout", { segments = 12, topScale = 0.45 }),
		c("WaterArcN", "waterArc", { 7, 3.7, 0.28 }, { 0, 7.7, 0 }, "water", "water", "fountain-water-arc", { segments = 12, transparency = 0.12 }),
		c("WaterArcE", "waterArc", { 7, 3.7, 0.28 }, { 0, 7.7, 0 }, "water", "water", "fountain-water-arc", { segments = 12, transparency = 0.12, rotation = { 0, 90, 0 } }),
	},
}

assets["portal-clockwork"] = {
	displayName = "TinyWorld_Portal_Clockwork_v1",
	qualityTier = "hero",
	components = {
		c("Platform", "beveledBox", { 22, 0.8, 10 }, { 0, 0.4, 0 }, "stoneDark", "stone", "portal-platform", { bevel = 0.55 }),
		c("Arch", "archSegment", { 20, 19, 4 }, { 0, 9.8, 0 }, "lavender", "stone", "portal-arch", { segments = 14, thickness = 2.2 }),
		c("Threshold", "panel", { 12.5, 13, 0.35 }, { 0, 7.5, 0.25 }, "glass", "glass", "portal-threshold", { bevel = 0.25, transparency = 0.45 }),
		c("ClockworkRing", "cylinder", { 6.2, 0.65, 6.2 }, { 0, 16.5, 2.15 }, "gold", "metal", "portal-clockwork-emblem", { rotation = { 90, 0, 0 }, segments = 16 }),
		c("ClockworkHub", "cylinder", { 1.6, 0.85, 1.6 }, { 0, 16.5, 2.55 }, "metal", "metal", "portal-clockwork-hub", { rotation = { 90, 0, 0 }, segments = 12 }),
	},
}

local function tree(displayName, trunkHeight, trunkWidth, crownA, crownB, colorA, colorB)
	return {
		displayName = displayName,
		qualityTier = "supporting",
		components = {
			c("Trunk", "frustum", { trunkWidth, trunkHeight, trunkWidth }, { 0, trunkHeight / 2, 0 }, "timberDark", "wood", "tree-trunk", { segments = 8, topScale = 0.56 }),
			c("CrownA", "ellipsoid", crownA.size, crownA.position, colorA, "foliage", "tree-crown", { segments = 10, rings = 5 }),
			c("CrownB", "ellipsoid", crownB.size, crownB.position, colorB, "foliage", "tree-crown-highlight", { segments = 9, rings = 4 }),
		},
	}
end
assets["tree-a"] = tree("TinyWorld_Tree_A_v1", 8, 2.2, { size = { 9.5, 8, 8.5 }, position = { 0, 10.5, 0 } }, { size = { 6, 5.5, 6 }, position = { 2.8, 12.2, -1.2 } }, "green", "greenLight")
assets["tree-b"] = tree("TinyWorld_Tree_B_v1", 9, 2.3, { size = { 10.5, 6.5, 9 }, position = { -1.2, 10.5, 0 } }, { size = { 8, 7, 7 }, position = { 2.2, 13.8, -0.8 } }, "greenDark", "green")
assets["tree-c"] = tree("TinyWorld_Tree_C_v1", 7, 1.8, { size = { 7.5, 6, 7 }, position = { 0, 9, 0 } }, { size = { 5.5, 5, 5.5 }, position = { -2, 11, 1.2 } }, "sage", "greenLight")

assets["lantern"] = {
	displayName = "TinyWorld_Lantern_v1",
	qualityTier = "supporting",
	components = {
		c("Post", "frustum", { 0.55, 6.2, 0.55 }, { 0, 3.1, 0 }, "metal", "metal", "lantern-post", { segments = 8, topScale = 0.75 }),
		c("Housing", "beveledBox", { 1.8, 1.9, 1.8 }, { 0, 6.6, 0 }, "metal", "metal", "lantern-housing", { bevel = 0.22 }),
		c("Glow", "beveledBox", { 1.2, 1.25, 1.2 }, { 0, 6.6, 0 }, "warmLight", "glass", "lantern-glass", { bevel = 0.16, transparency = 0.18 }),
		c("Cap", "hipRoof", { 2.3, 1.1, 2.3 }, { 0, 7.65, 0 }, "metal", "metal", "lantern-cap"),
	},
}

assets["bench"] = {
	displayName = "TinyWorld_Bench_v1",
	qualityTier = "supporting",
	components = {
		c("Seat", "beveledBox", { 7, 0.65, 2.2 }, { 0, 2.1, 0 }, "timber", "woodPlanks", "bench-seat", { bevel = 0.28 }),
		c("Back", "panel", { 7, 2.5, 0.55 }, { 0, 3.25, -0.85 }, "timberLight", "woodPlanks", "bench-back", { rotation = { -8, 0, 0 }, bevel = 0.25 }),
		c("LegL", "frustum", { 0.65, 2, 0.65 }, { -2.5, 1, 0 }, "metal", "metal", "bench-leg", { segments = 8, topScale = 0.8 }),
		c("LegR", "frustum", { 0.65, 2, 0.65 }, { 2.5, 1, 0 }, "metal", "metal", "bench-leg", { segments = 8, topScale = 0.8 }),
	},
}

assets["planter"] = {
	displayName = "TinyWorld_Planter_v1",
	qualityTier = "supporting",
	components = {
		c("Pot", "frustum", { 3.5, 2.4, 3.5 }, { 0, 1.2, 0 }, "timber", "wood", "planter-pot", { segments = 10, topScale = 1.16 }),
		c("FoliageA", "ellipsoid", { 3.2, 3, 3.2 }, { 0, 3.2, 0 }, "green", "foliage", "planter-foliage", { segments = 8, rings = 4 }),
		c("FoliageB", "ellipsoid", { 2.2, 2.5, 2.2 }, { 1.1, 3.8, -0.4 }, "greenLight", "foliage", "planter-foliage", { segments = 8, rings = 4 }),
	},
}

assets["hedge"] = {
	displayName = "TinyWorld_HedgeSegment_v1",
	qualityTier = "background",
	components = {
		c("HedgeA", "ellipsoid", { 6, 3.4, 3.2 }, { -2, 1.7, 0 }, "greenDark", "foliage", "hedge-foliage", { segments = 8, rings = 4 }),
		c("HedgeB", "ellipsoid", { 6, 3.6, 3.2 }, { 2, 1.8, 0 }, "green", "foliage", "hedge-foliage", { segments = 8, rings = 4 }),
	},
}

assets["parcel-crates"] = {
	displayName = "TinyWorld_ParcelCrateSet_v1",
	qualityTier = "supporting",
	components = {
		c("CrateA", "beveledBox", { 3, 2.6, 3 }, { -2, 1.3, 0 }, "timber", "woodPlanks", "parcel-crate", { bevel = 0.28 }),
		c("CrateB", "beveledBox", { 2.6, 2.2, 2.6 }, { 1.5, 1.1, 0.8 }, "timberLight", "woodPlanks", "parcel-crate", { bevel = 0.25 }),
		c("Parcel", "beveledBox", { 2.5, 1.6, 2 }, { 1.2, 3.1, -0.5 }, "canvas", "fabric", "courier-parcel", { bevel = 0.22 }),
	},
}

assets["starter-interior-kit"] = {
	displayName = "TinyWorld_StarterInteriorKit_v1",
	qualityTier = "hero",
	components = {
		c("Ceiling", "panel", { 28, 0.45, 22 }, { 0, 9.1, 0 }, "creamDeep", "wood", "home-ceiling", { bevel = 0.18 }),
		c("LivingRug", "panel", { 9, 0.15, 6 }, { -6, 1.55, 4 }, "blue", "fabric", "home-rug", { bevel = 0.3 }),
		c("SofaSeat", "beveledBox", { 7.5, 1.3, 3.2 }, { -7, 2.3, 6 }, "blue", "fabric", "home-sofa", { bevel = 0.55 }),
		c("SofaBack", "beveledBox", { 7.5, 3, 1.1 }, { -7, 3.7, 4.9 }, "blueDark", "fabric", "home-sofa", { bevel = 0.45 }),
		c("SofaArmL", "beveledBox", { 1, 2.2, 3.2 }, { -10.3, 2.9, 6 }, "blueDark", "fabric", "home-sofa", { bevel = 0.4 }),
		c("SofaArmR", "beveledBox", { 1, 2.2, 3.2 }, { -3.7, 2.9, 6 }, "blueDark", "fabric", "home-sofa", { bevel = 0.4 }),
		c("CoffeeTable", "beveledBox", { 5, 0.65, 3 }, { -6, 2.25, 1.5 }, "timber", "woodPlanks", "home-coffee-table", { bevel = 0.3 }),
		c("BedBase", "beveledBox", { 7.5, 1.2, 5 }, { -8, 2, -6 }, "timberDark", "wood", "home-bed", { bevel = 0.42 }),
		c("BedMattress", "beveledBox", { 7, 1, 4.6 }, { -8, 2.9, -5.8 }, "paper", "fabric", "home-bed", { bevel = 0.55 }),
		c("BedBlanket", "panel", { 7.1, 0.3, 2.6 }, { -8, 3.45, -5 }, "rose", "fabric", "home-bed-blanket", { bevel = 0.28 }),
		c("Wardrobe", "beveledBox", { 4.5, 7, 2 }, { -12, 5, -1.5 }, "timber", "wood", "home-wardrobe", { bevel = 0.35 }),
		c("KitchenCounter", "beveledBox", { 9, 3.2, 2.4 }, { 7.5, 3.1, -8.5 }, "creamDeep", "wood", "home-kitchen-counter", { bevel = 0.38 }),
		c("KitchenTop", "beveledBox", { 9.4, 0.5, 2.7 }, { 7.5, 4.95, -8.5 }, "stoneDark", "stone", "home-kitchen-worktop", { bevel = 0.25 }),
		c("CookerFront", "panel", { 3.2, 2.7, 0.4 }, { 6.5, 3, -7.1 }, "metal", "metal", "home-cooker", { bevel = 0.22 }),
		c("DiningTop", "beveledBox", { 6, 0.65, 4 }, { 6, 3.7, 2 }, "timber", "woodPlanks", "home-dining-table", { bevel = 0.32 }),
		c("DiningLeg", "frustum", { 1.1, 3.2, 1.1 }, { 6, 2, 2 }, "timberDark", "wood", "home-dining-table", { segments = 8, topScale = 0.75 }),
		c("ChairA", "beveledBox", { 2.3, 0.55, 2.3 }, { 2.3, 2.5, 2 }, "timberLight", "wood", "home-chair", { bevel = 0.28 }),
		c("ChairB", "beveledBox", { 2.3, 0.55, 2.3 }, { 9.7, 2.5, 2 }, "timberLight", "wood", "home-chair", { bevel = 0.28 }),
		c("Bath", "beveledBox", { 6, 2.4, 3.5 }, { 8, 2.8, 7.3 }, "paper", "marble", "home-bath", { bevel = 0.7 }),
		c("StorageShelf", "beveledBox", { 4, 6.5, 1.6 }, { 12, 4.6, -1.5 }, "timber", "wood", "home-storage", { bevel = 0.3 }),
		c("CurtainL", "panel", { 1.4, 4.2, 0.25 }, { -10.8, 5.5, 11.2 }, "rose", "fabric", "home-curtain", { bevel = 0.18 }),
		c("CurtainR", "panel", { 1.4, 4.2, 0.25 }, { 10.8, 5.5, 11.2 }, "rose", "fabric", "home-curtain", { bevel = 0.18 }),
	},
}

ProductionArtSpec.schemaVersion = 1
ProductionArtSpec.specVersion = "art-r4-v1"
ProductionArtSpec.palette = palette
ProductionArtSpec.assets = assets

function ProductionArtSpec.get(role: string)
	return assets[role]
end

return ProductionArtSpec
