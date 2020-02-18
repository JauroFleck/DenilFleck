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

stock DF_GivePlayerMoney(playerid, money) {
    pInfo[playerid][pMoney] += money;
    return GivePlayerMoney(playerid, money);
}

#if defined _ALS_GivePlayerMoney
    #undef GivePlayerMoney
#else
    #define _ALS_GivePlayerMoney
#endif
#define GivePlayerMoney DF_GivePlayerMoney

stock DF_ResetPlayerMoney(playerid) {
    pInfo[playerid][pMoney] = 0;
    return ResetPlayerMoney(playerid);
}

#if defined _ALS_ResetPlayerMoney
    #undef ResetPlayerMoney
#else
    #define _ALS_ResetPlayerMoney
#endif
#define ResetPlayerMoney DF_ResetPlayerMoney

stock DF_GetPlayerMoney(playerid) return pInfo[playerid][pMoney];

#if defined _ALS_GetPlayerMoney
    #undef GetPlayerMoney
#else
    #define _ALS_GetPlayerMoney
#endif
#define GetPlayerMoney DF_GetPlayerMoney