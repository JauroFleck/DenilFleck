new baseballbat;

forward OnPlayerConnect@bbliquor(playerid);
public OnPlayerConnect@bbliquor(playerid) {
	RemoveBuildingForPlayer(playerid, 1514, 253.179, -54.500, 1.460, 0.250);
	return 1;
}

forward OnPlayerDisconnect@bbliquor(playerid);
public OnPlayerDisconnect@bbliquor(playerid) {
	if(baseballbat == -(playerid+1)) {
		baseballbat = CreateDynamicObject(336, 253.395584, -55.293014, 0.726329, 29.000003, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
	}
	return 1;
}

CMD:taco(playerid) {
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, 252.7868,-54.8284,1.5776)) return Advert(playerid, "Não há nenhum taco de beisebol por perto.");
	if(baseballbat > 0) {
		new weap, ammo;
		GetPlayerWeaponData(playerid, 1, weap, ammo);
		if(weap) return Advert(playerid, "Você já está segurando uma arma branca e não pode pegar o taco de beisebol.");
		Alert(playerid, "Certifique-se de ter usado "AMARELO"/Me"BRANCO" para executar essa ação.");
		DestroyDynamicObject(baseballbat);
		baseballbat = -(playerid+1);
		GivePlayerWeapon(playerid, 5, 1);
	} else {
		new weap[12][2];
		GetPlayerWeaponData(playerid, 1, weap[0][0], weap[0][1]);
		if(weap[0][0] != 5) return Advert(playerid, "Você não está segurando nenhum taco de beisebol para guardar no balcão.");
		Alert(playerid, "Certifique-se de ter usado "AMARELO"/Me"BRANCO" para executar essa ação.");
		baseballbat = CreateDynamicObject(336, 253.395584, -55.293014, 0.726329, 29.000003, 0.000000, 0.000000, -1, -1, -1, 300.00, 300.00);
		for(new i = 0; i < 12; i++) {
			GetPlayerWeaponData(playerid, i, weap[i][0], weap[i][1]);
		}
		ResetPlayerWeapons(playerid);
		for(new i = 0; i < 12; i++) {
			if(i == 1) continue;
			GivePlayerWeapon(playerid, weap[i][0], weap[i][1]);
		}
	}
	return 1;
}