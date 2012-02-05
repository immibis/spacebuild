local RD = {}

local status = false

/**
	The Constructor for this Custom Addon Class
*/
function RD.__Construct()
	status = true
	return true , "No Implementation yet"
end

/**
	The Destructor for this Custom Addon Class
*/
function RD.__Destruct()
	return false , "Can't disable"
end

/**
	Get the required Addons for this Addon Class
*/
function RD.GetRequiredAddons()
	return {"Resource Distribution"}
end

/**
	Get the Boolean Status from this Addon Class
*/
function RD.GetStatus()
	return status
end

/**
	Get the Version of this Custom Addon Class
*/
function RD.GetVersion()
	return 0.5, "Release"
end

/**
	Get any custom options this Custom Addon Class might have
*/
function RD.GetExtraOptions()
	return {}
end

/**
	Get the Custom String Status from this Addon Class
*/
function RD.GetCustomStatus()
	return "Not Implemented Yet"
end

function RD.AddResourcesToSend()
	
end
CAF.RegisterAddon("PetrolSystem Entities", RD, "3")