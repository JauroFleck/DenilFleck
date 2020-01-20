#define ANIM_NONE		0
#define ANIM_SIT1		1
#define ANIM_SIT2		2
#define ANIM_SIT3		3
#define ANIM_SIT4		4

CMD:sentar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim]) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Sentar [1-4]");
	if(x == 4) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_IN", 4.1, false, false, false, true, 0, false);
		pInfo[playerid][pAnim] = ANIM_SIT4;
	} else {
		Advert(playerid, "Até o momento temos apenas o "AMARELO"/Sentar 4"BRANCO".");
	}
	return 1;
}

CMD:clear(playerid) {
	if(pInfo[playerid][pUSECMD_anim]) return Advert(playerid, "Você não tem permissão para usar animações.");
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}