/*------------------------------------------------
	SPACEBUILD 3 GAMEMODE
	
		Based on Spacebuild 2
		Made by the Spacebuild Dev Team

------------------------------------------------*/

GM.Name 	= "Spacebuild 3"
GM.Author 	= "Spacebuild Dev Team"
GM.Email 	= ""
GM.Website 	= "http://snakesvx.blogdns.com"

//include("include.lua") => Not working
//AddCSLuaFile("include.lua")=> Not working

DeriveGamemode("sandbox")

GM.IsSpacebuildDerived = true

GM.affected = {
	"prop_physics",
	"prop_ragdoll",
	"npc_grenade_frag",
	"npc_grenade_bugbait",
	"npc_satchel",
	"grenade_ar2",
	"crossbow_bolt",
	"phys_magnet",
	"prop_vehicle_airboat",
	"prop_vehicle_jeep",
	"prop_vehicle_prisoner_pod"
}