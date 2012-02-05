/*******************************************************************************************************
	This code is part of the CDS core and shouldn't be removed!
	This code will load all Weapon Types and Attacks into CDS.
*******************************************************************************************************/

/*******************************************************************************************************
	DON'T EDIT FROM HERE
*******************************************************************************************************/

local files = file.Find("/../materials/cds/*")
for k,v in pairs(files) do
	resource.AddFile("materials/cds/" .. v)
end

local files = file.Find("/../materials/cds/sprites/*")
for k,v in pairs(files) do
	resource.AddFile("materials/cds/sprites/" .. v)
end

local Files = file.FindInLua("cds_types/*.lua")
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_types/"..File)
	if(!ErrorCheck) then
		ErrorOffStuff(PCallError)
	else
		Msg("Loaded: Successfully\n")
	end
end

local Files = file.FindInLua("cds_attacks/*.lua")
for k, File in ipairs(Files) do
	Msg("Loading: "..File.."...")
	local ErrorCheck, PCallError = pcall(include, "cds_attacks/"..File)
	if(!ErrorCheck) then
		ErrorOffStuff(PCallError)
	else
		Msg("Loaded Successfully\n")
	end
end
