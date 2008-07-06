function AddLua(filename)
	local tmp = string.Explode("/", string.lower(filename))
	local parts = string.Explode("_", tmp[#tmp])
	
	if SERVER then
		if (parts[1] == "sh") or (parts[1] == "shared.lua") then
			include(filename)
			return AddCSLuaFile(filename)
		elseif parts[1] == "cl" then
			return AddCSLuaFile(filename)
		elseif (parts[1] == "sv") or (parts[1] == "init.lua") then
			return include(filename)
		end
		
		ErrorNoHalt("Unknown file: ",filename,"\n")
		PrintTable(tmp)
		PrintTable(parts)
		Error("Unable to determine if shared, serverside, or clientside.\n")
		
		return
	elseif CLIENT then
		if (parts[1] == "sh") or (parts[1] == "cl") or (parts[1] == "shared.lua") then
			return include(filename)
		elseif (parts[1] == "sv") or (parts[1] == "init.lua") then //others, just to keep the system happy
			return
		end
		
		ErrorNoHalt("Unknown file: ",filename,"\n")
		PrintTable(tmp)
		PrintTable(parts)
		Error("Unable to determine if shared, serverside, or clientside.\n")
		
		return
	else
		Error("Apparently we're God as we're not the client or the server.\n")
	end
end

AddLua("scoreboard/cl_sb_scoreboard.lua")
AddLua("spacebuild/sh_spacebuild.lua")

