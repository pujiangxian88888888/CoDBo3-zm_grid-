/*
 * @Author: your name
 * @Date: 2020-11-04 09:54:40                                                                                                           
 * @LastEditTime: 2021-02-15 08:53:35
 * @LastEditors: Please set LastEditors
 * @Description: In User Settings Edit
 * @FilePath: \zm\zm_grid.gsc
 */
#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;

#using scripts\zm\_zm_perk_dying_wish; //BO4 MOD:DYING WISH
/*
CREDITS:
Treyarch / Activision
raptroes
Joshwoocool
Quentin
M5_Prodigy
DTZxPorter
Scobalula
NGcaudle
SPECICAL THANKS*/

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

#using scripts\zm\hitmarker; //add hitmark

#using scripts\shared\callbacks_shared;
#using scripts\zm\_zm_score;

//=====================the following custom perk from t6 and t7 is created by WARDOGSK39 and xSanchez78===========================

//// WARDOGSK93: Start
// 3arc Perks
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\wardog\perk\_wardog_perk_phd;
#using scripts\wardog\perk\_wardog_perk_tombstone;
#using scripts\wardog\perk\_wardog_perk_vulture;

// Core
#using scripts\wardog\wardog_addon;
#using scripts\wardog\wardog_callback;
#using scripts\wardog\perk\_wardog_perk_hud;
//// WARDOGSK93: End

//// xSanchez78: Start
// Whos Who
#using scripts\zm\_zm_perk_chugabud;
//// xSanchez78: End
//====================================thanks a lot=================================================================================



#using scripts\zm\ugxmods_timedgp;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	wardog_addon::pre_init();

	
	
	zm_usermap::main();

	wardog_addon::init();
	
	
	level.register_offhand_weapons_for_level_defaults_override = &offhand_weapon_overrride;
	level._zombie_custom_add_weapons = &custom_add_weapons;
	level.giveCustomCharacters = &giveCustomCharacters;
	level._chugabud_post_respawn_override_func = &chugabud_post_respawn_func;
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	wardog_addon::post_init();

	level.default_laststandpistol=GetWeapon("pistol_revolver38");                 //括号里面改动你想要的初始武器，武器代号在zm_levelcommon_weapons.csv这个文件里面
	level.default_solo_laststandpistol=GetWeapon("pistol_revolver38_upgraded");  //倒地时候的武器
    level.laststandpistol=level.default_laststandpistol;
    level.start_weapon=level.default_laststandpistol;

	level.pathdist_type = PATHDIST_ORIGINAL;

	level thread intro_credits(); //地图简报

	level thread Healthbar();	  //血条

	//thread soundEasterEggInit();  //音乐彩蛋

	level.dog_rounds_allowed = 0; //禁用狗关

	_INIT_ZCOUNTER();   //僵尸计数器

    callback::on_connect(&cash); //初始金钱

	level.pack_a_punch_camo_index=121;   //pap迷彩，121：启示录
	level.pack_a_punch_camo_index_number_variants=5;  //迷彩变种
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}


function _INIT_ZCOUNTER()
{
	ZombieCounterHuds = []; 
	ZombieCounterHuds["LastZombieText"] 	= "Zombie Left";
	ZombieCounterHuds["ZombieText"]		= "Zombie's Left";
	ZombieCounterHuds["LastDogText"]	= "Dog Left";
	ZombieCounterHuds["DogText"]		= "Dog's Left";
	ZombieCounterHuds["DefaultColor"]	= (1,1,1);
	ZombieCounterHuds["HighlightColor"]	= (1, 0.55, 0);
	ZombieCounterHuds["FontScale"]		= 1.5;
	ZombieCounterHuds["DisplayType"]	= 0; // 0 = Shows Total Zombies and Counts down, 1 = Shows Currently spawned zombie count

	ZombieCounterHuds["counter"] = createNewHudElement("left", "top", 2, 10, 1, 1.5);
	ZombieCounterHuds["text"] = createNewHudElement("left", "top", 2, 10, 1, 1.5);

	ZombieCounterHuds["counter"] hudRGBA(ZombieCounterHuds["DefaultColor"], 0);
	ZombieCounterHuds["text"] hudRGBA(ZombieCounterHuds["DefaultColor"], 0);

	level thread _THINK_ZCOUNTER(ZombieCounterHuds);
}

function _THINK_ZCOUNTER(hudArray)
{
	level endon("end_game");
	for(;;)
	{
		level waittill("start_of_round");
		level _ROUND_COUNTER(hudArray);
		hudArray["counter"] SetValue(0);
		hudArray["text"] thread hudMoveTo((2, 10, 0), 4);
		
		hudArray["counter"] thread hudRGBA(hudArray["DefaultColor"], 0, 1);
		hudArray["text"] SetText("End of round"); 
		hudArray["text"] thread hudRGBA(hudArray["DefaultColor"], 0, 3);
	}
}

function _ROUND_COUNTER(hudArray)
{
	level endon("end_of_round");
	lastCount = 0;
	numberToString = "";

	hudArray["counter"] thread hudRGBA(hudArray["DefaultColor"], 1.0, 1);
	hudArray["text"] thread hudRGBA(hudArray["DefaultColor"], 1.0, 1);
	hudArray["text"] SetText(hudArray["ZombieText"]);
	if(level flag::get("dog_round"))
	{
		hudArray["text"] SetText(hudArray["DogText"]);
	}
		
	for(;;)
	{
		zm_count = (zombie_utility::get_current_zombie_count() + level.zombie_total);
		if(hudArray["DisplayType"] == 1) 
		{
			zm_count = zombie_utility::get_current_zombie_count();
		}
		
		if(zm_count == 0)
		{
			wait(1); 
		    continue;
	    }
		hudArray["counter"] SetValue(zm_count);
		if(lastCount != zm_count)
		{
			lastCount = zm_count;
			numberToString = "" + zm_count;
			hudArray["text"] thread hudMoveTo((10 + (4 * numberToString.Size), 10, 0), 4);
			if(zm_count == 1 && !level flag::get("dog_round")) 
			{
                hudArray["text"] SetText(hudArray["LastZombieText"]);
			}
			
			else if(zm_count == 1 && level flag::get("dog_round")) 
			{
				hudArray["text"] SetText(hudArray["LastDogText"]);
			}
			

			hudArray["counter"].color = hudArray["HighlightColor"]; 
			hudArray["counter"].fontscale = (hudArray["FontScale"] + 0.5);
			hudArray["text"].color = hudArray["HighlightColor"]; 
			hudArray["text"].fontscale = (hudArray["FontScale"] + 0.5);
			hudArray["counter"] thread hudRGBA(hudArray["DefaultColor"], 1, 0.5); 
			hudArray["counter"] thread hudFontScale(hudArray["FontScale"], 0.5);
			hudArray["text"] thread hudRGBA(hudArray["DefaultColor"], 1, 0.5); 
			hudArray["text"] thread hudFontScale(hudArray["FontScale"], 0.5);
		}
		wait(0.1);
	}
}

function createNewHudElement(xAlign, yAlign, posX, posY, foreground, fontScale)
{
	hud = newHudElem();
	hud.horzAlign = xAlign; 
	hud.alignX = xAlign;
	hud.vertAlign = yAlign; 
	hud.alignY = yAlign;
	hud.x = posX; 
	hud.y = posY;
	hud.foreground = foreground;
	hud.fontscale = fontScale;
	return hud;
}

function hudRGBA(newColor, newAlpha, fadeTime)
{
	if(isDefined(fadeTime))
	{
		self FadeOverTime(fadeTime);
	}

	self.color = newColor;
	self.alpha = newAlpha;
}

function hudFontScale(newScale, fadeTime)
{
	if(isDefined(fadeTime))
	{
		self ChangeFontScaleOverTime(fadeTime);
	}

	self.fontscale = newScale;
}

function hudMoveTo(posVector, fadeTime) 
{
	initTime = GetTime();
	hudX = self.x;
	hudY = self.y;
	hudVector = (hudX, hudY, 0);
	while(hudVector != posVector)
	{
		time = GetTime();
		hudVector = VectorLerp(hudVector, posVector, (time - initTime) / (fadeTime * 1000));
		self.x = hudVector[0];
		self.y = hudVector[1];
		wait(0.0001);
	}
}



function Healthbar()  //血条
{
    self endon( "disconnect" );

    x = 80;
    y = 40;

    self.health_bar = newClientHudElem( self );
    self.health_bar.x = x + 80;
    self.health_bar.y = y + 2;
    self.health_bar.alignx = "left";
    self.health_bar.aligny = "top";
    self.health_bar.horzalign = "fullscreen";
    self.health_bar.vertalign = "fullscreen";
    self.health_bar.alpha = 1;
    self.health_bar.foreground = 1;
    self.health_bar setshader( "black", 1, 8 );
    self.health_text = newClientHudElem( self );
    self.health_text.x = x + 80;
    self.health_text.y = y;
    self.health_text.alignx = "left";
    self.health_text.aligny = "top";
    self.health_text.horzalign = "fullscreen";
    self.health_text.vertalign = "fullscreen";
    self.health_text.alpha = 1;
    self.health_text.fontscale = 1;
    self.health_text.foreground = 1;
    if ( !isDefined( self.maxhealth ) || self.maxhealth <= 0 )
    {
        self.maxhealth = 100;
    }
    for ( ;; )
    {
        wait 0.05;
        width = ( self.health / self.maxhealth ) * 300;
        width = int( max( width, 1 ) );
        self.health_bar setshader( "black", width, 8 );
        self.health_text setvalue( self.health );
    }
}

function cash()
{
	self zm_score::add_to_player_score(49500);
}

function intro_credits()
{
    thread creat_simple_intro_hud("Test String Large",50,100,3,5);
    thread creat_simple_intro_hud("Test String Small",50,75,2,5);
    //thread creat_simple_intro_hud("Map Created by Pujiangxian88888888",50,50,2,5);
}

function creat_simple_intro_hud( text, align_x, align_y,font_scale,fade_time)
{
	hud=newHudElem();
	hud.foreground=true;
	hud.fontscale=font_scale;
	hud.sort=1;
	hud.hidewheninmeun=false;
	hud.align_x="left";
	hud.align_y="bottom";
	hud.horzAlign="left";
	hud.vertAlign="bottom";
	hud.x=align_x;
	hud.y=hud.y-align_y;
	hud.alpha=1;
	hud SetText(text);
	wait(8);
	hud FadeOverTime(fade_time);
	hud.alpha=0;
	wait(fade_time);
	hud Destroy();
}

//======================================================================================================================================

function offhand_weapon_overrride()
{
	level.zombie_lethal_grenade_player_init = GetWeapon("frag_grenade");
	level.zombie_melee_weapon_player_init = level.weaponBaseMelee;
	level.zombie_equipment_player_init = undefined;

	zm_utility::register_lethal_grenade_for_level("frag_grenade");
	zm_utility::register_melee_weapon_for_level(level.weaponBaseMelee.name);
	zm_utility::register_tactical_grenade_for_level("cymbal_monkey");
	zm_utility::register_tactical_grenade_for_level("octobomb");
}

function giveCustomCharacters()
{
	if(isdefined(level.hotjoin_player_setup) && [[level.hotjoin_player_setup]]("c_zom_farmgirl_viewhands" ))
		return;

	self DetachAll();
	if(!isdefined(self.characterIndex))
		self.characterIndex = zm_usermap::assign_lowest_unused_character_index();

	self.favorite_wall_weapons_list = [];
	self.talks_in_danger = false;

	self SetCharacterBodyType(self.characterIndex);
	self SetCharacterBodyStyle(0);
	self SetCharacterHelmetStyle(0);

	switch(self.characterIndex)
	{
		case 0:
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon("frag_grenade");
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon("bouncingbetty");
			self.whos_who_shader = "c_zom_der_dempsey_mpc_fb";
			break;

		case 1:
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon("870mcs");
			self.whos_who_shader = "c_zom_der_nikolai_mpc_fb";
			break;

		case 3:
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size] = GetWeapon("hk416");
			self.whos_who_shader = "c_zom_der_takeo_mpc_fb";
			break;

		case 2:
			self.talks_in_danger = true;
			level.rich_sq_player = self;
			level.sndRadioA = self;
			self.favorite_wall_weapons_list[self.favorite_wall_weapons_list.size ] = GetWeapon("pistol_standard");
			self.whos_who_shader = "c_zom_der_richtofen_mpc_fb";
			break;
	}

	self SetMoveSpeedScale(1);
	self SetSprintDuration(4);
	self SetSprintCooldown(0);

	self thread zm_usermap::set_exert_id();
}

function chugabud_post_respawn_func( v_new_player_position )
{
	weapon_powerup_array = [];
	keys = GetArrayKeys(level.zombie_powerups);

	for(i = 0; i < keys.size; i++)
	{
		if(isdefined(level._custom_powerups) && isdefined(level._custom_powerups[keys[i]]) && isdefined(level._custom_powerups[keys[i]].weapon_countdown))
			weapon_powerup_array[weapon_powerup_array.size] = keys[i];
	}

	weapon_powerup = undefined;

	if(isdefined(self.loadout))
	{
		for(i = 0; i < self.loadout.weapons.size; i++)
		{
			for(j = 0; j < weapon_powerup_array.size; j++)
			{
				if(self.loadout.weapons[i]["weapon"] == level.zombie_powerup_weapon[weapon_powerup_array[j]])
				{
					weapon_powerup = weapon_powerup_array[j];
					break;
				}
			}
		}
	}
	if(isdefined(weapon_powerup))
	{
		level thread zm_powerups::weapon_powerup_remove(self, weapon_powerup + "_time_over", weapon_powerup, false);

		weapons = [];
		index = 0;

		for(i = 0; i < self.loadout.weapons.size; i++)
		{
			if(self.loadout.weapons[i]["weapon"] == level.zombie_powerup_weapon[weapon_powerup])
				continue;

			weapons[index] = self.loadout.weapons[i];
			index++;
		}

		self.loadout.weapons = weapons;
		if(isdefined(self._zombie_weapon_before_powerup) && isdefined(self._zombie_weapon_before_powerup[weapon_powerup]))
		{
			current_weapon = self._zombie_weapon_before_powerup[weapon_powerup];

			for(i = 0; i < self.loadout.weapons.size; i++)
			{
				if(self.loadout.weapons[i]["weapon"] == current_weapon || self.loadout.weapons[i]["weapon"].altWeapon == current_weapon)
				{
					self.loadout.current_weapon = i;
					break;
				}
			}
		}
	}
}

