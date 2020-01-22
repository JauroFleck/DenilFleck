stock DF_SetPlayerVirtualWorld(playerid, worldid) {
	CallLocalFunction("OnPlayerVirtualWorldChange", "iii", playerid, worldid, GetPlayerVirtualWorld(playerid));
	return SetPlayerVirtualWorld(playerid, worldid);
}

forward OnPlayerVirtualWorldChange(playerid, newworldid, oldworldid);

#if defined _ALS_SetPlayerVirtualWorld
    #undef SetPlayerVirtualWorld
#else
    #define _ALS_SetPlayerVirtualWorld
#endif
#define SetPlayerVirtualWorld DF_SetPlayerVirtualWorld