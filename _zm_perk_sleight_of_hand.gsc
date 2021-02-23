#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_util;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

/***************************** WARDOGSK93: Start *****************************/
#using scripts\wardog\wardog_addon;

#insert scripts\wardog\wardog_addon.gsh;
/***************************** WARDOGSK93: End *****************************/

#precache( "material", SLEIGHT_OF_HAND_SHADER );
#precache( "string", "ZOMBIE_PERK_FASTRELOAD" );
#precache( "fx", "zombie/fx_perk_sleight_of_hand_zmb" );

#namespace zm_perk_sleight_of_hand;

REGISTER_SYSTEM( "zm_perk_sleight_of_hand", &__init__, undefined )

// SLEIGHT OF HAND PERK ( SPEED COLA )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_sleight_of_hand_perk_for_level();
}

function enable_sleight_of_hand_perk_for_level()
{
	// register sleight of hand perk for level
	zm_perks::register_perk_basic_info( PERK_SLEIGHT_OF_HAND, "sleight", SLEIGHT_OF_HAND_PERK_COST, &"ZOMBIE_PERK_FASTRELOAD", GetWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( PERK_SLEIGHT_OF_HAND, &sleight_of_hand_precache );
	zm_perks::register_perk_clientfields( PERK_SLEIGHT_OF_HAND, &sleight_of_hand_register_clientfield, &sleight_of_hand_set_clientfield );
	zm_perks::register_perk_machine( PERK_SLEIGHT_OF_HAND, &sleight_of_hand_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( PERK_SLEIGHT_OF_HAND, SLEIGHT_OF_HAND_RADIANT_MACHINE_NAME, SLEIGHT_OF_HAND_MACHINE_LIGHT_FX );
	/***************************** WARDOGSK93: Start *****************************/
	zm_perks::register_perk_threads(PERK_SLEIGHT_OF_HAND, &give_perk, &take_perk);
	/***************************** WARDOGSK93: End *****************************/
}

function sleight_of_hand_precache()
{
	if( IsDefined(level.sleight_of_hand_precache_override_func) )
	{
		[[ level.sleight_of_hand_precache_override_func ]]();
		return;
	}

	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX]			= "zombie/fx_perk_sleight_of_hand_zmb";

	level.machine_assets[PERK_SLEIGHT_OF_HAND] = SpawnStruct();
	level.machine_assets[PERK_SLEIGHT_OF_HAND].weapon = GetWeapon( SLEIGHT_OF_HAND_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_SLEIGHT_OF_HAND].off_model = SLEIGHT_OF_HAND_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_SLEIGHT_OF_HAND].on_model = SLEIGHT_OF_HAND_MACHINE_ACTIVE_MODEL;

	addon_message = "hud|";
	addon_message += PERK_SLEIGHT_OF_HAND + "|";
	addon_message += "shader|";
	addon_message += SLEIGHT_OF_HAND_SHADER;

	wardog_addon::send_addon_message("Unknown", ADDON_NAME_PERK_HUD, addon_message);
}

function sleight_of_hand_register_clientfield()
{
	clientfield::register( "clientuimodel", PERK_CLIENTFIELD_SLEIGHT_OF_HAND, VERSION_SHIP, 2, "int" );
	clientfield::register("toplayer", "vulture_waypoint_speed", VERSION_SHIP, 2, "int");
}

function sleight_of_hand_set_clientfield( state )
{
	if(!wardog_addon::is_addon_enabled(ADDON_NAME_PERK_HUD))
		self clientfield::set_player_uimodel( PERK_CLIENTFIELD_SLEIGHT_OF_HAND, state );
	self clientfield::set_to_player("vulture_waypoint_speed", state);
}

function sleight_of_hand_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_speed_jingle";
	use_trigger.script_string = "speedcola_perk";
	use_trigger.script_label = "mus_perks_speed_sting";
	use_trigger.target = "vending_sleight";
	perk_machine.script_string = "speedcola_perk";
	perk_machine.targetname = "vending_sleight";
	if(IsDefined(bump_trigger))
	{
		bump_trigger.script_string = "speedcola_perk";
	}
}

/***************************** WARDOGSK93: Start *****************************/
function give_perk()
{
	addon_message = "hud|";
	addon_message += PERK_SLEIGHT_OF_HAND + "|";
	addon_message += "give";

	wardog_addon::send_addon_message("Unknown", ADDON_NAME_PERK_HUD, addon_message, self);
}

function take_perk(b_pause, str_perk, str_result)
{
	addon_message = "hud|";
	addon_message += PERK_SLEIGHT_OF_HAND + "|";
	addon_message += "take";

	wardog_addon::send_addon_message("Unknown", ADDON_NAME_PERK_HUD, addon_message, self);
}
/***************************** WARDOGSK93: End *****************************/
