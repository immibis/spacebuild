
TOOL.Category = '(Life Support)'
TOOL.Name = '#Storage Devices'
TOOL.Command = nil
TOOL.ConfigName = ''
if (CLIENT and GetConVarNumber("RD_UseLSTab") == 1) then TOOL.Tab = "Life Support" end

TOOL.ClientConVar['type'] = 'air_tank'
TOOL.ClientConVar['model'] = 'models/props_c17/canister01a.mdl'

cleanup.Register('storagedevice')

if ( CLIENT ) then
	language.Add( 'Tool_receptacles_name', 'Life Support Storage Devices' )
	language.Add( 'Tool_receptacles_desc', 'Create Storage Devices attached to any surface.' )
	language.Add( 'Tool_receptacles_0', 'Left-Click: Spawn a Device.  Right-Click: Repair Device.' )

	language.Add( 'Undone_receptacles', 'Storage Device Undone' )
	language.Add( 'Cleanup_receptacles', 'LS: Storage Device' )
	language.Add( 'Cleaned_receptacles', 'Cleaned up all Storage Devices' )
	language.Add( 'SBoxLimit_receptacles', 'Maximum Storage Devices Reached' )
end

if not ( RES_DISTRIB == 2 ) then Error("Please Install Resource Distribution 2 Addon.'" ) return end

local receptacles = {}
if (SERVER) then
	receptacles.air_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if ( model == "models/props_c17/canister01a.mdl" ) then
			maxhealth = 600
			mass = 20
			RD_AddResource(ent, "air", 6000)
		elseif ( model == "models/props_c17/canister_propane01a.mdl" ) then
			maxhealth = 1200
			mass = 200
			RD_AddResource(ent, "air", 12000)
		elseif ( model == "models/props_wasteland/coolingtank02.mdl" ) then
			maxhealth = 3000
			mass = 500
			RD_AddResource(ent, "air", 30000)
		end
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.coolant_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props_junk/PropaneCanister001a.mdl") then
			maxhealth = 300
			mass = 20
			RD_AddResource(ent, "coolant", 4000)
		elseif (model == "models/props_borealis/bluebarrel001.mdl") then
			maxhealth = 600
			mass = 200
			RD_AddResource(ent, "coolant", 12000)
		elseif (model == "models/props/de_nuke/coolingtank.mdl") then
			maxhealth = 1000
			mass = 1000
			RD_AddResource(ent, "coolant", 30000)
		end
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.energy_cell = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/Items/car_battery01.mdl") then
			maxhealth = 100
			mass = 20
			RD_AddResource(ent, "energy", 4000)
		elseif (model == "models/props_c17/substation_stripebox01a.mdl") then
			maxhealth = 4000
			mass = 1000
			RD_AddResource(ent, "energy", 50000)
		elseif (model == "models/props/de_nuke/NuclearFuelContainer.mdl") then
			maxhealth = 9000
			mass = 4000
			RD_AddResource(ent, "energy", 100000)
		end
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.res_cache = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props_lab/powerbox01a.mdl") then
			maxhealth = 1000
			mass = 150
			RD_AddResource(ent, "air", 6000)
			RD_AddResource(ent, "energy", 6000)
			RD_AddResource(ent, "coolant", 6000)
		elseif (model == "models/props_c17/substation_transformer01a.mdl") then
			maxhealth = 2400
			mass = 2000
			RD_AddResource(ent, "air", 30000)
			RD_AddResource(ent, "energy", 30000)
			RD_AddResource(ent, "coolant", 30000)
		elseif (model == "models/props_wasteland/cargo_container01.mdl") then
			maxhealth = 3000
			mass = 5000
			RD_AddResource(ent, "air", 80000)
			RD_AddResource(ent, "energy", 80000)
			RD_AddResource(ent, "coolant", 80000)
		end
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.water_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props_junk/PropaneCanister001a.mdl") then
			maxhealth = 300
			mass = 20
			RD_AddResource(ent, "water", 1000)
		elseif (model == "models/props_borealis/bluebarrel001.mdl") then
			maxhealth = 600
			mass = 200
			RD_AddResource(ent, "water", 6000)
		elseif (model == "models/props/de_nuke/fuel_cask.mdl") then
			maxhealth = 2000
			mass = 2000
			RD_AddResource(ent, "water", 24000)
		end
		rtable.mass = mass
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.hvywater_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props_c17/FurnitureBoiler001a.mdl") then
			maxhealth = 800
			mass = 40
			RD_AddResource(ent, "heavy water", 800)
		elseif (model == "models/props/de_nuke/PowerPlantTank.mdl") then
			maxhealth = 1300
			mass = 100
			RD_AddResource(ent, "heavy water", 1200)
		elseif (model == "models/props_wasteland/horizontalcoolingtank04.mdl") then
			maxhealth = 3000
			mass = 1000
			RD_AddResource(ent, "heavy water", 5000)
		end
		rtable.mass = mass
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end

	receptacles.terra_juice_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props/de_train/Barrel.mdl") then
			maxhealth = 600
			mass = 100
			RD_AddResource(ent, "terrajuice", 1000)
		elseif (model == "models/props/de_train/Pallet_Barrels.mdl") then
			maxhealth = 1200
			mass = 600
			RD_AddResource(ent, "terrajuice", 6000)
		elseif (model == "models/props_wasteland/coolingtank01.mdl") then
			maxhealth = 3000
			mass = 1500
			RD_AddResource(ent, "terrajuice", 9000)
		end
		rtable.mass = mass
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end
	
	receptacles.steam_tank = function( ply, ent, system_type, system_class, model )
		local rtable, maxhealth, mass = {}, 0, 0
		if (model == "models/props_junk/PropaneCanister001a.mdl") then
			maxhealth = 300
			mass = 20
			RD_AddResource(ent, "steam", 1000)
		elseif (model == "models/props_borealis/bluebarrel001.mdl") then
			maxhealth = 600
			mass = 200
			RD_AddResource(ent, "steam", 6000)
		elseif (model == "models/props_trainstation/train002.mdl") then
			maxhealth = 900
			mass = 1000
			RD_AddResource(ent, "steam", 9000)
		end
		rtable.mass = mass
		LS_RegisterEnt(ent, "Storage")
		return rtable, maxhealth, mass
	end
end

local receptacle_models = {
	{ 'Small Air Tank', 'models/props_c17/canister01a.mdl', 'air_tank' },
	{ 'Large Air Tank', 'models/props_c17/canister_propane01a.mdl', 'air_tank' },
	{ 'Huge Air Tank', 'models/props_wasteland/coolingtank02.mdl', 'air_tank' },
	{ 'Small Coolant Tank', 'models/props_junk/PropaneCanister001a.mdl', 'coolant_tank' },
	{ 'Large Coolant Tank', 'models/props_borealis/bluebarrel001.mdl', 'coolant_tank' },
	{ 'Huge Coolant Tank', 'models/props/de_nuke/coolingtank.mdl', 'coolant_tank' },
	{ 'Small Water Tank', 'models/props_junk/PropaneCanister001a.mdl', 'water_tank' },
	{ 'Large Water Tank', 'models/props_borealis/bluebarrel001.mdl', 'water_tank' },
	{ 'Huge Water Tank', 'models/props/de_nuke/fuel_cask.mdl', 'water_tank' },
	{ 'Small Steam Tank', 'models/props_junk/PropaneCanister001a.mdl', 'steam_tank' },
	{ 'Large Steam Tank', 'models/props_borealis/bluebarrel001.mdl', 'steam_tank' },
	{ 'Huge Steam Tank', 'models/props_trainstation/train002.mdl', 'steam_tank' },
	{ 'Small Heavy Water Tank', 'models/props_c17/FurnitureBoiler001a.mdl', 'hvywater_tank' },
	{ 'Large Heavy Water Tank', 'models/props/de_nuke/powerplanttank.mdl', 'hvywater_tank' },
	{ 'Huge Heavy Water Tank', 'models/props_wasteland/horizontalcoolingtank04.mdl', 'hvywater_tank' },
	{ 'Small Energy Cell', 'models/Items/car_battery01.mdl', 'energy_cell' },
	{ 'Large Energy Cell', 'models/props_c17/substation_stripebox01a.mdl', 'energy_cell' },
	{ 'Huge Energy Cell', 'models/props/de_nuke/NuclearFuelContainer.mdl', 'energy_cell' },
	{ 'Small Resource Cache', 'models/props_lab/powerbox01a.mdl', 'res_cache' },
	{ 'Large Resource Cache', 'models/props_c17/substation_transformer01a.mdl', 'res_cache' },
	{ 'Huge Resource Cache', 'models/props_wasteland/cargo_container01.mdl', 'res_cache' },
	{ 'Small Terrajuice Tank', 'models/props/de_train/Barrel.mdl', 'terra_juice_tank' },
	{ 'Large Terrajuice Tank', 'models/props/de_train/Pallet_Barrels.mdl', 'terra_juice_tank' },
	{ 'Huge Terrajuice Tank', 'models/props_wasteland/coolingtank01.mdl', 'terra_juice_tank' }
}

RD2_ToolRegister( TOOL, receptacle_models, nil, "receptacles", 30, receptacles )
