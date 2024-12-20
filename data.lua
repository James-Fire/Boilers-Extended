require("__LSlib_James_Fork__/LSlib")
local hit_effects = require ("__base__.prototypes.entity.hit-effects")
local sounds = require("__base__.prototypes.entity.sounds")
local util = require("__core__.lualib.util")

data.raw.boiler["boiler"].fast_replaceable_group = "boiler"
data.raw.boiler["heat-exchanger"].energy_consumption = "11.64MW"

local emmisions = data.raw.boiler["boiler"].energy_source.emissions_per_minute.pollution
local TierRecipes = { --Collect all the recipes so we can change ingredients later
	["T1"] = { "boiler" },
	["T2"] = { "heat-exchanger" },
	["T3"] = { },
}

if settings.startup["high-pressure-boilers"].value or settings.startup["extreme-pressure-boilers"].value then
	--T2 boiler, outputs 60 500C steam. Enough for 1 steam turbine
	local T2boileritem = table.deepcopy(data.raw.item["boiler"])
	T2boileritem.name = "boiler-2"
	T2boileritem.place_result = "boiler-2"
	
	local T2boiler = table.deepcopy(data.raw.boiler["boiler"])
	T2boiler.name = "boiler-2"
	T2boiler.minable.result = "boiler-2"
	T2boiler.target_temperature = 500
	T2boiler.energy_consumption = "5.82MW"
	T2boiler.energy_source.emissions_per_minute = { pollution = emmisions*1.9 }
	
	
	data:extend({T2boiler,T2boileritem,
		{
			type = "recipe",
			name = "boiler-2",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type="item", name="boiler", amount=1 },
			},
			results = {{type="item", name="boiler-2", amount=1}},
		},
		{
			type = "technology",
			name = "high-pressure-boilers",
			icon = "__base__/graphics/icons/boiler.png",
			icon_size = 64,
			prerequisites = {"fluid-handling", "advanced-material-processing"},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "boiler-2",
				},
			},
			unit = {
				count = 200,
				ingredients = data.raw.technology["nuclear-power"].unit.ingredients,
				time = data.raw.technology["nuclear-power"].unit.time,
			},
			order = "a",
		},
	})
	table.insert(TierRecipes["T2"], "boiler-2")
	LSlib.technology.moveRecipeUnlock("nuclear-power", "high-pressure-boilers", "steam-turbine")
	LSlib.technology.addPrerequisite("nuclear-power", "high-pressure-boilers")
	LSlib.technology.changeCount("nuclear-power", data.raw.technology["nuclear-power"].unit.count-200)
end
if settings.startup["extreme-pressure-boilers"].value then
	--T3 Boiler, outputs 120 500C steam. Enough for 2 steam turbines
	
	local T3boileritem = table.deepcopy(data.raw.item["boiler"])
	T3boileritem.name = "boiler-3"
	T3boileritem.place_result = "boiler-3"
	
	local T3boiler = table.deepcopy(data.raw.boiler["boiler-2"])
	T3boiler.name = "boiler-3"
	T3boiler.minable.result = "boiler-3"
	T3boiler.energy_consumption = "11.64MW"
	T3boiler.energy_source.emissions_per_minute = { pollution = emmisions*2.8 }
	
	data:extend({T3boiler,T3boileritem,
		{
			type = "recipe",
			name = "boiler-3",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type="item", name="boiler-2", amount=1 },
			},
			results = {{type="item", name="boiler-3", amount=1}},
		},
		{
			type = "technology",
			name = "extreme-pressure-boilers",
			icon = "__base__/graphics/icons/boiler.png",
			icon_size = 64,
			prerequisites = {"high-pressure-boilers"},
			effects = {
				{
					type = "unlock-recipe",
					recipe = "boiler-3",
				},
			},
			unit = {
				count = 300,
				ingredients = data.raw.technology["nuclear-fuel-reprocessing"].unit.ingredients,
				time = data.raw.technology["nuclear-fuel-reprocessing"].unit.time,
			},
			order = "a",
		},
	})
	table.insert(TierRecipes["T3"], "boiler-3")
	
	
	--T2 Heat Exchanger, just outputs more steam
	local heatexchanger = table.deepcopy(data.raw.boiler["heat-exchanger"])
	heatexchanger.name = "extreme-heat-exchanger"
	heatexchanger.minable.result = "extreme-heat-exchanger"
	heatexchanger.energy_consumption = "23.28MW" --tostring(util.split(data.raw.boiler["heat-exchanger"].energy_consumption, "M")[1]*2).."MW"
	heatexchanger.max_transfer = "4GW"
	
	
	local heatexchangeritem = table.deepcopy(data.raw.item["heat-exchanger"])
	heatexchangeritem.name = "extreme-heat-exchanger"
	heatexchangeritem.place_result = "extreme-heat-exchanger"
	
	data:extend({heatexchanger,heatexchangeritem,
		{
			type = "recipe",
			name = "extreme-heat-exchanger",
			enabled = false,
			energy_required = 1,
			ingredients = {	
				{ type="item", name="heat-exchanger", amount=1 },
				{ type="item", name="heat-pipe", amount=10 },
			},
			results = {{type="item", name="extreme-heat-exchanger", amount=1}},
		},
	})
	table.insert(TierRecipes["T3"], "extreme-heat-exchanger")
	LSlib.technology.addRecipeUnlock("extreme-pressure-boilers", "extreme-heat-exchanger")
	
end

if settings.startup["electric-boilers"].value then
	--Boiler that uses electricity
	local electricboileritem = table.deepcopy(data.raw.item["boiler"])
	electricboileritem.name = "electric-boiler"
	electricboileritem.place_result = "electric-boiler"
	
	local electricboiler = table.deepcopy(data.raw.boiler["boiler"])
	electricboiler.name = "electric-boiler"
	electricboiler.minable.result = "electric-boiler"
	electricboiler.energy_source = {
		type = "electric",
		usage_priority = "secondary-input",
		emissions_per_minute = { pollution = 1 },
		light_flicker = {
			color = {0,0,0},
			minimum_intensity = 0.6,
			maximum_intensity = 0.95
		},
	}
	
	data:extend({electricboiler,electricboileritem,
		{
			type = "recipe",
			name = "electric-boiler",
			enabled = false,
			energy_required = 1,
			ingredients = {
				{ type="item", name="boiler", amount=1 },
			},
			results = {{type="item", name="electric-boiler", amount=1}},
		},
	})
	table.insert(TierRecipes["T1"], "electric-boiler")
	LSlib.technology.addRecipeUnlock("electric-energy-distribution-1", "electric-boiler")


	if settings.startup["high-pressure-boilers"].value or settings.startup["extreme-pressure-boilers"].value then
		--T2 Electric Boiler
		local T2electricboileritem = table.deepcopy(data.raw.item["boiler"])
		T2electricboileritem.name = "electric-boiler-2"
		T2electricboileritem.place_result = "electric-boiler-2"
		
		local T2electricboiler = table.deepcopy(data.raw.boiler["electric-boiler"])
		T2electricboiler.name = "electric-boiler-2"
		T2electricboiler.minable.result = "electric-boiler-2"
		T2electricboiler.target_temperature = 500
		T2electricboiler.energy_consumption = "5.82MW"
		
		data:extend({T2electricboiler,T2electricboileritem,
			{
				type = "recipe",
				name = "electric-boiler-2",
				enabled = false,
				energy_required = 1,
				ingredients = {
					{ type="item", name="electric-boiler", amount=1 },
				},
				results = {{type="item", name="electric-boiler-2", amount=1}},
			},
		})
		table.insert(TierRecipes["T2"], "electric-boiler-2")

		LSlib.technology.addRecipeUnlock("high-pressure-boilers", "electric-boiler-2")
	end
	if settings.startup["extreme-pressure-boilers"].value then
		--T3 Electric Boiler
		local T3electricboileritem = table.deepcopy(data.raw.item["boiler"])
		T3electricboileritem.name = "electric-boiler-3"
		T3electricboileritem.place_result = "electric-boiler-3"
		
		local T3electricboiler = table.deepcopy(data.raw.boiler["electric-boiler-2"])
		T3electricboiler.name = "electric-boiler-3"
		T3electricboiler.minable.result = "electric-boiler-3"
		T3electricboiler.energy_consumption = "11.64MW"
		
		data:extend({T3electricboiler,T3electricboileritem,
			{
				type = "recipe",
				name = "electric-boiler-3",
				enabled = false,
				energy_required = 1,
				ingredients = {
					{ type="item", name="electric-boiler-2", amount=1 },
				},
				results = {{type="item", name="electric-boiler-3", amount=1}},
			},
		})
		table.insert(TierRecipes["T3"], "electric-boiler-3")
	
		LSlib.technology.addRecipeUnlock("extreme-pressure-boilers", "electric-boiler-3")
	end
end

if settings.startup["fluid-boilers"].value then
	--Boiler that burns fluid
	local fluidboileritem = table.deepcopy(data.raw.item["boiler"])
	fluidboileritem.name = "fluid-boiler"
	fluidboileritem.place_result = "fluid-boiler"
	
	local fluidboiler = table.deepcopy(data.raw.boiler["boiler"])
	fluidboiler.name = "fluid-boiler"
	fluidboiler.minable.result = "fluid-boiler"
	fluidboiler.energy_source = {
		burns_fluid = true,
		scale_fluid_usage = true,
		type = "fluid",
		emissions_per_minute = { pollution = 30 },
		light_flicker = {
			color = {0,0,0},
			minimum_intensity = 0.6,
			maximum_intensity = 0.95
		},
		fluid_box = {
			volume = 1000,
			pipe_connections = {
				{ flow_direction = "input", direction = defines.direction.north, position = { 0, 0.75 } },
			},
			pipe_covers = pipecoverspictures(),
			pipe_picture = assembler2pipepictures(),
			production_type = "input",
		},
	}
	
	
	data:extend({fluidboiler,fluidboileritem,
		{
			type = "recipe",
			name = "fluid-boiler",
			enabled = false,
			energy_required = 1,
			ingredients = {	
				{ type="item", name="boiler", amount=1 },
			},
			results = {{type="item", name="fluid-boiler", amount=1}},
		},
	})
	table.insert(TierRecipes["T1"], "fluid-boiler")
	LSlib.technology.addRecipeUnlock("fluid-handling", "fluid-boiler")

	if settings.startup["high-pressure-boilers"].value or settings.startup["extreme-pressure-boilers"].value then
		--T2 Fluid Boiler
		local T2fluidboileritem = table.deepcopy(data.raw.item["boiler"])
		T2fluidboileritem.name = "fluid-boiler-2"
		T2fluidboileritem.place_result = "fluid-boiler-2"
		
		local T2fluidboiler = table.deepcopy(data.raw.boiler["fluid-boiler"])
		T2fluidboiler.name = "fluid-boiler-2"
		T2fluidboiler.minable.result = "fluid-boiler-2"
		T2fluidboiler.target_temperature = 500
		T2fluidboiler.energy_consumption = "5.82MW"
		T2fluidboiler.energy_source.emissions_per_minute = { pollution = emmisions*1.9 }
		
		
		data:extend({T2fluidboiler,T2fluidboileritem,
			{
				type = "recipe",
				name = "fluid-boiler-2",
				enabled = false,
				energy_required = 1,
				ingredients = {	
					{ type="item", name="fluid-boiler", amount=1 },
				},
				results = {{type="item", name="fluid-boiler-2", amount=1}},
			},
		})
		table.insert(TierRecipes["T2"], "fluid-boiler-2")
		LSlib.technology.addRecipeUnlock("high-pressure-boilers", "fluid-boiler-2")
	end
	if settings.startup["extreme-pressure-boilers"].value then
		--T3 Fluid Boiler
		local T3fluidboileritem = table.deepcopy(data.raw.item["boiler"])
		T3fluidboileritem.name = "fluid-boiler-3"
		T3fluidboileritem.place_result = "fluid-boiler-3"
		
		local T3fluidboiler = table.deepcopy(data.raw.boiler["fluid-boiler-2"])
		T3fluidboiler.name = "fluid-boiler-3"
		T3fluidboiler.minable.result = "fluid-boiler-3"
		T3fluidboiler.energy_consumption = "11.64MW"
		T3fluidboiler.energy_source.emissions_per_minute = { pollution = emmisions*2.8 }
		
		
		data:extend({T3fluidboiler,T3fluidboileritem,
			{
				type = "recipe",
				name = "fluid-boiler-3",
				enabled = false,
				energy_required = 1,
				ingredients = {	
					{ type="item", name="fluid-boiler-2", amount=1 },
				},
				results = {{type="item", name="fluid-boiler-3", amount=1}},
			},
		})
		table.insert(TierRecipes["T3"], "fluid-boiler-3")
	
		LSlib.technology.addRecipeUnlock("extreme-pressure-boilers", "fluid-boiler-3")
	end
end
if(mods["space-age"]) then
	--Do space age tech tech
	LSlib.technology.addPrerequisite("extreme-pressure-boilers", "tungsten-carbide") --Extreme Pressure Boilers require Tungsten Carbide
end
--Do recipes, standardizing boiler costs
for i, tiers in pairs(TierRecipes) do  --Do stuff to all boilers
	for j, boilers in pairs(tiers) do
		LSlib.recipe.addIngredient(boilers, "steel-plate", 10)
		LSlib.recipe.addIngredient(boilers, "pipe", 10)
		if boilers:find("fluid", 1, true) then --Only to fluid boilers
			LSlib.recipe.editIngredient(boilers, "pipe", "pipe", 2)
		elseif boilers:find("electric", 1, true) then --Only to electric boilers
			LSlib.recipe.addIngredient(boilers, "electronic-circuit", 5)
			LSlib.recipe.addIngredient(boilers, "copper-cable", 30)
		elseif boilers:find("boiler", 1, true) then --Only to normal boilers
		
		elseif boilers:find("exchanger", 1, true) then --Only to heat exchangers
		
		end
	end
end
for i, boilers in pairs(TierRecipes["T1"]) do --Do stuff to all T1 boilers
	LSlib.recipe.editIngredient(boilers, "steel-plate", "iron-plate", 1) --T1 boilers use iron, to keep it simple
end
for i, boilers in pairs(TierRecipes["T2"]) do --Do stuff to all T2 boilers

end
for i, boilers in pairs(TierRecipes["T3"]) do --Do stuff to all T3 boilers
	if(mods["space-age"]) then
		LSlib.recipe.editIngredient(boilers, "steel-plate", "tungsten-carbide", 1) --T3 boilers use tungsten carbide, if Space Age is active
	end
end
--[[
if settings.startup["thermal-boilers"].value then
	--Boiler that outputs heat instead of steam
	local fluidboileritem = table.deepcopy(data.raw.item["boiler"])
	fluidboileritem.name = "thermal-boiler"
	fluidboileritem.place_result = "thermal-boiler"
	data:extend({fluidboileritem,
	{
    type = "reactor",
    name = "thermal-boiler",
    icon  = "__base__/graphics/icons/boiler.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "thermal-boiler"},
    max_health = 500,
    corpse = "boiler-remnants",
    dying_explosion = "boiler-explosion",
    consumption = "1.8MW",
    neighbour_bonus = 0.25,
    energy_source = data.raw.boiler["boiler"].energy_source,
    collision_box = {{-1.29, -0.79}, {1.29, 0.79}},
    selection_box = {{-1.5, -1}, {1.5, 1}},
    damaged_trigger_effect = hit_effects.entity(),
    picture = data.raw.boiler["boiler"].structure,
    working_light_picture = data.raw.boiler["boiler"].fire_glow,

    --light = {intensity = 0.6, size = 9.9, shift = {0.0, 0.0}, color = {r = 0.0, g = 1.0, b = 0.0}},
    -- use_fuel_glow_color = false, -- should use glow color from fuel item prototype as light color and tint for working_light_picture
    -- default_fuel_glow_color = { 0, 1, 0, 1 } -- color used as working_light_picture tint for fuels that don't have glow color defined

    heat_buffer =
    {
      max_temperature = 1000,
      specific_heat = "10MJ",
      max_transfer = "10GW",
      minimum_glow_temperature = 350,
      connections =
      {
        {
          position = {-0.5, -1},
          direction = defines.direction.north
        },
        {
          position = {0.5, -1},
          direction = defines.direction.east
        },
        {
          position = {0.5, 1},
          direction = defines.direction.east
        },
        {
          position = {2, 2},
          direction = defines.direction.south
        },
        {
          position = {-0.5, 1},
          direction = defines.direction.south
        },
        {
          position = {-0.5, -1},
          direction = defines.direction.east
        },
        {
          position = {-0.5, 1},
          direction = defines.direction.east
        },
      },
    },
		light = { intensity = 0.3, size = 3, shift = { 0.0, 0.0 }, color = { r = 1.0, g = 0.9, b = 0.7 } },
		use_fuel_glow_color = true,
		--lower_layer_picture = lower_layer_picture(""),
		--connection_patches_connected = connection_patches_connected(""),
		--connection_patches_disconnected = connection_patches_disconnected(""),
		vehicle_impact_sound = sounds.generic_impact,
		open_sound = sounds.machine_open,
		close_sound = sounds.machine_close,
		working_sound = data.raw.boiler["boiler"].working_sound
	},
	})
	--LSlib.technology.addPrerequisite("nuclear-power", "high-pressure-boilers")
	if settings.startup["high-pressure-boilers"].value or settings.startup["extreme-pressure-boilers"].value then
		--T2 Heat boiler

	end
	if settings.startup["extreme-pressure-boilers"].value then
		--T3 heat boiler
	
	end
end
]]