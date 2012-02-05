include("CAF/Core/shared/tool_manifest.lua")

TOOL			= ToolObj:Create()
TOOL.Category		= "CAF"
TOOL.Mode			= "startup_tool"
TOOL.Name			= "CAF Tools Startup"
TOOL.Command		= nil
TOOL.ConfigName		= nil
TOOL.AddToMenu 		= false
if (CLIENT and GetConVarNumber("CAF_UseTab") == 1) then TOOL.Tab = "Custom Addon Framework" end


function TOOL:LeftClick( trace )
	if ( !trace.Entity:IsValid() ) then return false end
	if (CLIENT) then return true end
	
	//for something else
	
	return true
end

function TOOL:RightClick( trace )
	if ( !trace.Entity:IsValid() ) then return false end
	if (CLIENT) then return true end
	
	//for something else
	
	return true
end

function TOOL:Reload( trace )
	if ( !trace.Entity:IsValid() ) then return false end
	if (CLIENT) then return true end
	
	//for something else
	
	return true
end