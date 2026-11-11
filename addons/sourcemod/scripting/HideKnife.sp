#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <zombiereloaded>

#pragma newdecls required

public Plugin myinfo =
{
    name = "Magical disappeareance cuttaroo",
    author = "Original by d0ck3r for CS:S, cleaned by Jim McKenzie for CS:GO",
    description = "Makes the knives being held by zombies disappear so they don't look like gangsta muggers.",
    version = "1.0.2",
    url = ""
};

bool lateLoad = false;

public void OnMapStart()
{
    if (lateLoad == true)
    {
        return;
    }
    
    for (int client = 1; client <= MaxClients; client++)
    {
        if (!IsClientInGame(client))
        {
            continue;
        }
        OnClientPutInServer(client);
    }
    lateLoad = true;
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
}

public void OnPostThinkPost(int client)
{    
    // If the player isn't alive we don't cate
    if (!IsPlayerAlive(client))
    {
        return;
    }
    
    // We don't care if he isn't a zombie either
    if (!ZR_IsClientZombie(client))
    {
        return;
    }

    // We get the knife
    int entity = GetPlayerWeaponSlot(client, 2); 
    
    // If the knife exist then we go on
    if (IsValidEdict(entity))
    {
        int renderOffset = GetEntSendPropOffs(entity, "m_clrRender");
        SetEntData(entity, renderOffset + 3, 0, 4, true);
    }
}
