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
    version = "1.0.3",
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
        // This runs on every tick for every zombie: look the offset up once.
        // m_clrRender belongs to CBaseEntity, so it is the same for every knife.
        static int renderOffset = -1;
        if (renderOffset == -1)
        {
            renderOffset = GetEntSendPropOffs(entity, "m_clrRender");
        }

        // The client ignores the alpha with the default render mode (RENDER_NORMAL):
        // the knife needs RENDER_TRANSCOLOR to disappear. The owner's view model is
        // another entity, so the zombie still sees its own knife.
        if (GetEntityRenderMode(entity) != RENDER_TRANSCOLOR)
        {
            SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
        }

        // m_clrRender is a color32 (r, g, b, a): write the alpha byte only, so the
        // bytes after it are left untouched. Only write when it changes, to avoid
        // flagging the entity for networking on every tick.
        if (GetEntData(entity, renderOffset + 3, 1) != 0)
        {
            SetEntData(entity, renderOffset + 3, 0, 1, true);
        }
    }
}
