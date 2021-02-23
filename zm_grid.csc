#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//=================================================================================================================================================

#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\wardog\perk\_wardog_perk_phd;
#using scripts\wardog\perk\_wardog_perk_tombstone;
#using scripts\wardog\perk\_wardog_perk_vulture;

#insert scripts\zm\_zm_perks.gsh;
#using scripts\wardog\wardog_addon;

// Whos Who
#using scripts\zm\_zm_perk_chugabud;

#using scripts\zm\_zm_perk_dying_wish;

#define SNOW_FX "dlc0/factory/fx_snow_player_os_factory"

#precache( "client_fx", SNOW_FX );

function main()
{
    luiLoad( "ui.uieditor.menus.hud.t7hud_zm_custom" );

	zm_usermap::main();

	include_weapons();
	
	util::waitforclient( 0 );

	callback::on_localplayer_spawned( &on_localplayer_spawned );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function on_localplayer_spawned( localClientNum )
{
    if( self == GetLocalPlayer( localClientNum ) ) 
        self thread falling_snow(localClientNum);
}
 
function falling_snow(localClientNum)
{
    self endon( "disconnect" );
    self endon( "entityshutdown" );
    self endon( "death" );
    while(1)
    {
        PlayFX( localClientNum, SNOW_FX, self.origin );
        wait 0.3; //Change this to increase or decrease the snow intensity (Higher = Slower )
    }
}