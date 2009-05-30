
include( "CreationMenu/manifest.lua" )

local PANEL = {}

/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Init()

	self:Populate()

end


/*---------------------------------------------------------
   Name: Paint
---------------------------------------------------------*/
function PANEL:Populate()

	local tabs = spawnmenu.GetCreationTabs()
	
	for k, v in SortedPairsByMemberValue( tabs, "Order" ) do
		self:AddSheet( k, v.Function(), v.Icon, nil, nil, v.Tooltip )
	end

end

vgui.Register( "CreationMenu", PANEL, "DPropertySheet" )