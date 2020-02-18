#define ANIM_NONE		0
#define ANIM_SIT1		1
#define ANIM_SIT3		2
#define ANIM_SIT4		3
#define ANIM_SIT5		4
#define ANIM_SIT6		5
#define ANIM_COWER		6
#define ANIM_FALL1		7
#define ANIM_FALL2		8
#define ANIM_HANDSUP	9
#define ANIM_TIRED		10
#define ANIM_LEAN		11

CMD:sentar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Sentar [1-6]");
	if(x == 3) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_IN", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 3"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT3;
	} else if(x == 1) {
		ApplyAnimation(playerid, "ped", "SEAT_down", 4.1, 0, 0, 0, 1, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 1"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT1;
	} else if(x == 2) {
		new Float:A;
		GetPlayerFacingAngle(playerid, A);
	    SetPlayerFacingAngle(playerid, A+180);
		ApplyAnimation(playerid, "ped", "SEAT_down", 4.1, 0, 0, 0, 1, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 1"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT1;
	} else if(x == 4) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_IN_L", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 4"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT4;
	} else if(x == 5) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_IN_R", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 5"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT5;
	} else if(x == 6) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_LOOP", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Clear"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_SIT6;
	} else AdvertCMD(playerid, "/Sentar [1-6]");
	return 1;
}

CMD:levantar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Levantar [1-7]");
	if(x == 1 || x == 2) {
		if(pInfo[playerid][pAnim] != ANIM_SIT1) return 1;
		ApplyAnimation(playerid, "ped", "SEAT_up", 4.1, 0, 0, 0, 0, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 3 && pInfo[playerid][pAnim] == ANIM_SIT3) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_OUT_180", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 4 && pInfo[playerid][pAnim] == ANIM_SIT4) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_OUT_L_180", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 5 && pInfo[playerid][pAnim] == ANIM_SIT5) {
		ApplyAnimation(playerid, "FOOD", "FF_SIT_OUT_R_180", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 6 && pInfo[playerid][pAnim] == ANIM_FALL1) {
		ApplyAnimation(playerid, "PED", "GETUP", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 7 && pInfo[playerid][pAnim] == ANIM_FALL2) {
		ApplyAnimation(playerid, "PED", "GETUP_FRONT", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else AdvertCMD(playerid, "/Levantar [1-7]");
	return 1;
}

CMD:cumprimento(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Cumprimento [1-6]");
	if(x == 1) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKAA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 2) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKBA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 3) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKCA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 4) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKDA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 5) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKEA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else if(x == 6) {
		ApplyAnimation(playerid, "GANGS", "HNDSHKFA", 4.1, false, false, false, false, 0, true);
		pInfo[playerid][pAnim] = ANIM_NONE;
	} else AdvertCMD(playerid, "/Cumprimento [1-6]");
	return 1;
}

CMD:desencostar(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	if(pInfo[playerid][pAnim] != ANIM_LEAN) return 1;
	ApplyAnimation(playerid, "GANGS", "LEANOUT", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:encostarse(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "GANGS", "LEANIDLE", 4.1, false, false, false, true, 0, true);
	Info(playerid, "Use "AMARELO"/Desencostar"BRANCO" para sair dessa posição.");
	pInfo[playerid][pAnim] = ANIM_LEAN;
	return 1;
}

CMD:togpapo(playerid, params[]) {
	new tog;
	if(sscanf(params, "i", tog)) return AdvertCMD(playerid, "/TogPapo [0-8]");
	if(tog == 0) {
		pInfo[playerid][pPapo] = 0;
		Info(playerid, "Animação de fala desativada.");
	} else if(tog <= 8) {
		new str[144];
		format(str, 144, "Animação de fala definida: %i.", tog);
		Info(playerid, str);
		pInfo[playerid][pPapo] = tog;
	} else AdvertCMD(playerid, "/TogPapo [0-8]");
	return 1;
}

CMD:fumar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "GANGS", "SMKCIG_PRTL", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:cair(playerid, params[]) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	new x;
	if(sscanf(params, "i", x)) return AdvertCMD(playerid, "/Cair [1-2]");
	if(x == 1) {
		ApplyAnimation(playerid, "PED", "FLOOR_HIT", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 6"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_FALL1;
	} else if(x == 2) {
		ApplyAnimation(playerid, "PED", "FLOOR_HIT_F", 4.1, false, false, false, true, 0, true);
		Info(playerid, "Use "AMARELO"/Levantar 7"BRANCO" para se levantar.");
		pInfo[playerid][pAnim] = ANIM_FALL2;
	} else AdvertCMD(playerid, "/Cair [1-2]");
	return 1;
}

CMD:chutar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "FIGHT_D", "FIGHTD_G", 4.1, false, true, true, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:acenar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "KISSING", "GFWAVE2", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:olhar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "ROADCROSS", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:taxi(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "IDLE_TAXI", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:xingar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "FUCKU", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:tchau(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "ENDCHAT_03", 4.1, false, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

CMD:handsup(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "HANDSUP", 4.1, false, false, false, true, 0, true);
	pInfo[playerid][pAnim] = ANIM_HANDSUP;
	return 1;
}

CMD:agachar(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "COWER", 4.1, false, false, false, true, 0, true);
	pInfo[playerid][pAnim] = ANIM_COWER;
	return 1;
}

CMD:cansado(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ApplyAnimation(playerid, "PED", "IDLE_TIRED", 4.1, true, false, false, false, 0, true);
	pInfo[playerid][pAnim] = ANIM_TIRED;
	return 1;
}

CMD:clear(playerid) {
	if(pInfo[playerid][pUSECMD_anim] || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return Advert(playerid, "Você não tem permissão para usar animações.");
	ClearAnimations(playerid);
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	pInfo[playerid][pAnim] = ANIM_NONE;
	return 1;
}

forward OnPlayerText@anim(playerid);
public OnPlayerText@anim(playerid) {
	if(pInfo[playerid][pPapo]) {
		if(pInfo[playerid][pPapo] == 1) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKA", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 2) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKB", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 3) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKC", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 4) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKD", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 5) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKE", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 6) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKF", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 7) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKG", 4.1, 0, 1, 1, 1, true);
		} else if(pInfo[playerid][pPapo] == 8) { ApplyAnimation(playerid, "GANGS", "PRTIAL_GNGTLKH", 4.1, 0, 1, 1, 1, true);
		}
	}
	return 0;
}