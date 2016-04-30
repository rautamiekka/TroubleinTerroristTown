#pragma semicolon 1

#define DEBUG

#include <sourcemod>
#include <sdktools>
#include <ttt>
#include <config_loader>

#pragma newdecls required

#define PLUGIN_NAME TTT_PLUGIN_NAME ... " - Overlays"

public Plugin myinfo =
{
	name = PLUGIN_NAME,
	author = TTT_PLUGIN_AUTHOR,
	description = TTT_PLUGIN_DESCRIPTION,
	version = TTT_PLUGIN_VERSION,
	url = TTT_PLUGIN_URL
};

char g_sTraitorIcon[PLATFORM_MAX_PATH] = "";
char g_sDetectiveIcon[PLATFORM_MAX_PATH] = "";
char g_sInnocentIcon[PLATFORM_MAX_PATH] = "";
char g_sConfigFile[PLATFORM_MAX_PATH] = "";

char g_soverlayDWin[PLATFORM_MAX_PATH] = "";
char g_soverlayTWin[PLATFORM_MAX_PATH] = "";
char g_soverlayIWin[PLATFORM_MAX_PATH] = "";

bool g_bEndwithD;
bool g_bEndOverlay = false;

float g_fDelay;

public void OnPluginStart()
{
	BuildPath(Path_SM, g_sConfigFile, sizeof(g_sConfigFile), "configs/ttt/config.cfg");
	Config_Setup("TTT", g_sConfigFile);
	
	g_bEndwithD = Config_LoadBool("ttt_end_with_detective", false, "Allow the round to end if Detectives remain alive. 0 = Disabled (default). 1 = Enabled.");
	g_fDelay = Config_LoadFloat("ttt_after_round_delay", 7.0, "The amount of seconds to use for round-end delay. Use 0.0 for default.");

	BuildPath(Path_SM, g_sConfigFile, sizeof(g_sConfigFile), "configs/ttt/overlay.cfg");
	Config_Setup("TTT-Overlay", g_sConfigFile);
	
	Config_LoadString("ttt_overlay_detective", "darkness/ttt/overlayDetective", "The overlay to display for detectives during the round.", g_sDetectiveIcon, sizeof(g_sDetectiveIcon));
	Config_LoadString("ttt_overlay_traitor", "darkness/ttt/overlayTraitor", "The overlay to display for detectives during the round.", g_sTraitorIcon, sizeof(g_sTraitorIcon));
	Config_LoadString("ttt_overlay_inno", "darkness/ttt/overlayInnocent", "The overlay to display for detectives during the round.", g_sInnocentIcon, sizeof(g_sInnocentIcon));
	
	Config_LoadString("ttt_overlay_detective_win", "overlays/ttt/detectives_win", "The overlay to display when detectives win.", g_soverlayDWin, sizeof(g_soverlayDWin));
	Config_LoadString("ttt_overlay_traitor_win", "overlays/ttt/traitors_win", "The overlay to display when traitors win.", g_soverlayTWin, sizeof(g_soverlayTWin));
	Config_LoadString("ttt_overlay_inno_win", "overlays/ttt/innocents_win", "The overlay to display when innocent win.", g_soverlayIWin, sizeof(g_soverlayIWin));

	HookEvent("round_prestart", Event_RoundStartPre, EventHookMode_Pre);
}

public void OnMapStart()
{
	char buffer[PLATFORM_MAX_PATH];
	
	Format(buffer, sizeof(buffer), "materials/%s.vmt", g_sDetectiveIcon);
	AddFileToDownloadsTable(buffer);

	Format(buffer, sizeof(buffer), "materials/%s.vtf", g_sDetectiveIcon);
	AddFileToDownloadsTable(buffer);

	PrecacheDecal(g_sDetectiveIcon, true);
	
	Format(buffer, sizeof(buffer), "materials/%s.vmt", g_sTraitorIcon);
	AddFileToDownloadsTable(buffer);

	Format(buffer, sizeof(buffer), "materials/%s.vtf", g_sTraitorIcon);
	AddFileToDownloadsTable(buffer);

	PrecacheDecal(g_sTraitorIcon, true);
	
	Format(buffer, sizeof(buffer), "materials/%s.vmt", g_sInnocentIcon);
	AddFileToDownloadsTable(buffer);

	Format(buffer, sizeof(buffer), "materials/%s.vtf", g_sInnocentIcon);
	AddFileToDownloadsTable(buffer);

	PrecacheDecal(g_sInnocentIcon, true);

	Format(buffer, sizeof(buffer), "materials/%s.vmt", g_soverlayTWin);
	AddFileToDownloadsTable(buffer);

	Format(buffer, sizeof(buffer), "materials/%s.vtf", g_soverlayTWin);
	AddFileToDownloadsTable(buffer);

	PrecacheDecal(g_soverlayTWin, true);
	
	Format(buffer, sizeof(buffer), "materials/%s.vmt", g_soverlayIWin);
	AddFileToDownloadsTable(buffer);

	Format(buffer, sizeof(buffer), "materials/%s.vtf", g_soverlayIWin);
	AddFileToDownloadsTable(buffer);

	PrecacheDecal(g_soverlayIWin, true);

	if(g_bEndwithD)
	{
		Format(buffer, sizeof(buffer), "materials/%s.vmt", g_soverlayDWin);
		AddFileToDownloadsTable(buffer);

		Format(buffer, sizeof(buffer), "materials/%s.vtf", g_soverlayDWin);
		AddFileToDownloadsTable(buffer);

		PrecacheDecal(g_soverlayDWin, true);
	}

}

public Action Event_RoundStartPre(Event event, const char[] name, bool dontBroadcast)
{
	ShowOverlayToAll("");
}

public void TTT_OnRoundEnd(int winner)
{
	if(g_fDelay > 0.0)
	{
		g_bEndOverlay = true;
		CreateTimer(g_fDelay, Delay_Timer);
	}
	
	LoopValidClients(client){
		switch(winner)
		{
			case TTT_TEAM_DETECTIVE:
			{
				ShowOverlayToClient(client,  g_soverlayDWin);
			}
			case TTT_TEAM_INNOCENT:
			{
				ShowOverlayToClient(client,  g_soverlayIWin);
			}
			case TTT_TEAM_TRAITOR:
			{
				ShowOverlayToClient(client,  g_soverlayTWin);
			}
		}
	}
}

public Action Delay_Timer(Handle timer, any data)
{
	g_bEndOverlay = false;
}

public void TTT_OnClientGetRole(int client, int role)
{
	if(IsPlayerAlive(client))
		AssignOverlay(client);
}

public void TTT_OnUpdate()
{	
	if(g_bEndOverlay)
		return;
	
	LoopValidClients(i)
		if(IsPlayerAlive(i))
			AssignOverlay(i);
}

public void AssignOverlay(int client)
{
	if(TTT_IsClientValid(client))
	{
		switch(TTT_GetClientRole(client))
		{
			case TTT_TEAM_TRAITOR:
			{
				ShowOverlayToClient(client,  g_sTraitorIcon);
			}
			case TTT_TEAM_DETECTIVE:
			{
				ShowOverlayToClient(client, g_sDetectiveIcon);
			}
			case TTT_TEAM_INNOCENT:
			{
				ShowOverlayToClient(client, g_sInnocentIcon);
			}
			default:
			{
				ShowOverlayToClient(client, "");
			}
		}
	}
}