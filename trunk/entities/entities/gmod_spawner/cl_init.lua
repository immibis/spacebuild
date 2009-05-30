
ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include('shared.lua')

function ENT:Draw()

	self.Entity:DrawModel()
end

local function OnUndo()

	GAMEMODE:AddNotify( "Undone Prop", NOTIFY_UNDO, 2 )
end

usermessage.Hook( "UndoSpawnerProp", OnUndo )  


