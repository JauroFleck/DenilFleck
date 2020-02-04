#define ANIM_NONE		0
#define ANIM_SIT1		1
#define ANIM_SIT3		2

CMD:sentar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim]) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Sentar [1-3]");
	if(x == 3) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_IN", 4.1, false, false, false, true, 0, false);
		Info(playerid, "Use "AMARELO"/Clear"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT3;
	} else if(x == 1) {
		ApplyAnimation(playerid, "ped", "SEAT_down", 4.1, 0, 0, 0, 1, 0, 1);
		Info(playerid, "Use "AMARELO"/Levantar 1"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT1;
	} else if(x == 2) {
		new Float:A;
		GetPlayerFacingAngle(playerid, A);
	    SetPlayerFacingAngle(playerid, A+180);
		ApplyAnimation(playerid, "ped", "SEAT_down", 4.1, 0, 0, 0, 1, 0, 1);
		Info(playerid, "Use "AMARELO"/Levantar 1"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT1;
	} else AdvertCMD(playerid, "/Sentar [1-3]");
	return 1;
}

CMD:levantar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim]) return Advert(playerid, "Você não tem permissão para usar animações.");
	if(pInfo[playerid][pAnim] != ANIM_SIT1 && pInfo[playerid][pAnim] != ANIM_SIT3) return 1;
	ApplyAnimation(playerid, "ped", "SEAT_up", 4.1, 0, 0, 0, 0, 0, 1);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:clear(playerid) {
	if(pInfo[playerid][pUSECMD_anim]) return Advert(playerid, "Você não tem permissão para usar animações.");
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}