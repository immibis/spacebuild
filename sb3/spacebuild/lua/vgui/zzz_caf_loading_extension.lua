surface.CreateFont( "ariel", 14, 500, true, false, "caf_loading_screen" ) 
-- +- 40 lines max!
local lines = {
			"You are using the Custom Addon Framework.",
			"",
			"To open the CAF menu:",
			"",
			"1) Type Main_CAF_Menu in console",
			"2) Check the Custom Addon Framework TAB for ",
			"   a button called Open Main Menu",
			"",
			"SnakeSVx",
			"",
			"Important notice for DEVS:",
			"",
			"CAF 2.0 is currently being developed.",
			"It will contain many changes in some",
			"areas compared to this version of CAF.",
			"",
			"Curious as to what CAF Addons are available?",
			"Check out the official wiki at",
			"http://archive.snakesvx.net/index.php/",
			"module_Wiki2/title_Help_Info_SVN"
		}

timer.Simple(1, 
	function() 
		if(not GetLoadPanel) then
			return;
		end
		
		local Loading = GetLoadPanel();
		local FONT = "caf_loading_screen";
		local COLOR = Color( 255, 255, 255, 255 )
		local BGColor = Color(0,0,0,200)
		local Black = Color(0,0, 0, 255)
		local oldpaint = Loading.Paint
		
		function Loading:Paint()
			oldpaint(Loading);
			
			surface.SetDrawColor( 0, 0, 0, 150 );
			local wide = self:GetWide();
			local tall = self:GetTall();
			local top = math.floor(tall/2) - 256;
			local left = 64
			draw.RoundedBox( 8, left , top,  256, 512, BGColor)
			draw.DrawText( "Custom Addon Framework",	FONT,  left + 8 , top + 8 , COLOR,0 )
			draw.RoundedBox( 0, left , top + 24,  256, 1, Black)
			local tmp_top = top + 40;
			
			for k, v in pairs(lines) do
				draw.DrawText( v,	FONT,  left + 8 , tmp_top , COLOR ,0 )
				tmp_top = tmp_top + 14;
			end
		end
		
		
		/*if not dframe then
				dframe = vgui.Create("DFrame")
				dframe:SetDeleteOnClose(true) 
				dframe:SetDraggable( false ) 
				dframe:SetTitle("CAF Loading Screen")
				dframe:SetPos(left,  top);
				dframe:SetSize(256, 512);
				
				local ContentPanel = vgui.Create( "DPropertySheet", dframe )
				ContentPanel:StretchToParent( 4, 26, 4, 4 )
				ContentPanel:AddSheet( "Info", GetInfoPanel(ContentPanel), "gui/silkicons/page", true, true )
				
				dframe:MakePopup()
			end*/
			
			
			--require("Json");
		/*local function GetInfoPanel(frame)
			local panel = vgui.Create("DPanel", frame)
			panel:StretchToParent( 0, 40, 0, 0 )
			--
			local mylist = vgui.Create("DListView", panel)
			mylist:SetMultiSelect(false)
			mylist:SetPos(1,1)
			mylist:SetSize(panel:GetWide()- 2, panel:GetTall()-2)
			local colum =  mylist:AddColumn( "")
			colum:SetFixedWidth(5)
			local colum1 =  mylist:AddColumn( "About")
			colum1:SetFixedWidth(mylist:GetWide() - 5)
			mylist.SortByColumn = function()
			end
			----------
			--Text--
			----------
			for k, v in pairs(lines) do
				mylist:AddLine( "", v )
			end
			--
			return panel
		end
		
		local wide = ScrW();
		local tall = ScrH();
		local top = math.floor(tall/2) - 256;
		local left = 64

		local dframe = nil;*/
		/*local oldOnDeactivate = Loading.OnDeactivate;
		function Loading:OnDeactivate()
			oldOnDeactivate(Loading);
			dframe:Close();
		end*/
		
		/*local oldSetVisible = Loading.SetVisible;
		Msg("OldSetVisible: " ..tostring(oldSetVisible).."\n");
		
		function Loading:SetVisible(visible)
			oldSetVisible(Loading, visible);
			if visible then
				dframe = vgui.Create("DFrame")
				dframe:SetDeleteOnClose() 
				dframe:SetDraggable( false ) 
				dframe:SetTitle("CAF Loading Screen")
				dframe:SetPos(left,  top);
				dframe:SetSize(256, 512);
				
				local ContentPanel = vgui.Create( "DPropertySheet", dframe )
				ContentPanel:StretchToParent( 4, 26, 4, 4 )
				ContentPanel:AddSheet( "Info", GetInfoPanel(ContentPanel), "gui/silkicons/page", true, true )
				
				dframe:MakePopup()
			elseif dframe then
				dframe:Close();
			end
		end*/
		
		
	end
);
