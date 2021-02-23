#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_dying_wish.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace dying_wish;

REGISTER_SYSTEM( "dying_wish", &__init__, undefined )

function __init__()
{
	// register custom functions for hud/lua
	zm_perks::register_perk_clientfields( DYING_WISH_SPECIALTY, &perk_client_field_func, &perk_code_callback_func );
	zm_perks::register_perk_effects( DYING_WISH_SPECIALTY, DYING_WISH_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( DYING_WISH_SPECIALTY, &init_perk );
}

function init_perk()
{
	if( IS_TRUE(level.enable_magic) )
	{
		//add client fx if needed here	
	}	
}

function perk_client_field_func()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_DYING_WISH, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 
}

function perk_code_callback_func()
{
}
