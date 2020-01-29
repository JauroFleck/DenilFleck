enum POLICE_INFO {
	sSQL,
	sPatente,
	sPrisoes,
	sIngresso
};

new sInfo[MAX_PLAYERS][POLICE_INFO];
new CountyCopSkins[] = { 288,283,282,302,309,310,311 };
new Articles[] = { 6,4,5,4,3,2,4,4,3,2,4,4,2,3,1,3,1,3,1,5,1 };

#define MAX_VIATURAS 				2

new Viatura[MAX_VIATURAS];

CMD:capturar(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	new j = 0, s = GetPlayerSkin(playerid);
	for(; j < sizeof(CountyCopSkins); j++) {
		if(s == CountyCopSkins[j]) break;
	}
	if(j == sizeof(CountyCopSkins)) return Advert(playerid, "Você deve estar fardado.");
	new vid;
	if(sscanf(params, "ii", j, vid)) return AdvertCMD(playerid, "/Capturar [ID] [IDV da Viatura]");
	if(!IsPlayerConnected(j)) return Advert(playerid, "ID inválido.");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(j, 2.5, P[0], P[1], P[2])) return Advert(playerid, "Você só pode capturar pessoas próximas a você.");
	if(GetPlayerSpecialAction(j) != SPECIAL_ACTION_CUFFED) return Advert(playerid, "O suspeito deve estar algemado.");
	new i = 0;
	for(; i < MAX_VIATURAS; i++) {
		if(Viatura[i] == vid) break;
	}
	if(i == MAX_VIATURAS) return Advert(playerid, "Esse IDV não corresponde a uma viatura.");
	if(!IsVehicleInRangeOfPoint(Viatura[i], 5.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo à viatura.");
	SetPlayerSpecialAction(j, SPECIAL_ACTION_NONE);
	new seatid = 0;
	if(GetPlayerIDVehicleSeat(Viatura[i], 2) == -1) { seatid = 2;
	} else if(GetPlayerIDVehicleSeat(Viatura[i], 3) == -1) { seatid = 3;
	} else if(!seatid) return Advert(playerid, "Não há lugares suficientes nessa viatura para capturar mais um suspeito.");
	TogglePlayerControllable(j, false);
	PutPlayerInVehicle(j, Viatura[i], seatid);
	new str[144];
	format(str, 144, "Você foi capturado pelo oficial %s.", pName(playerid));
	Info(j, str);
	format(str, 144, "Você capturou o suspeito %s.", pName(j));
	Info(playerid, str);
	return 1;
}

CMD:algemar(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	new j = 0, s = GetPlayerSkin(playerid);
	for(; j < sizeof(CountyCopSkins); j++) {
		if(s == CountyCopSkins[j]) break;
	}
	if(j == sizeof(CountyCopSkins)) return Advert(playerid, "Você deve estar fardado.");
	if(sscanf(params, "i", j)) return AdvertCMD(playerid, "/Algemar [ID]");
	if(!IsPlayerConnected(j)) return Advert(playerid, "ID inválido.");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(j, 2.5, P[0], P[1], P[2])) return Advert(playerid, "Você só pode algemar pessoas próximas a você.");
	if(GetPlayerSpecialAction(j) == SPECIAL_ACTION_CUFFED) return Advert(playerid, "Esse indivíduo já está algemado.");
	SetPlayerSpecialAction(j, SPECIAL_ACTION_CUFFED);
	TogglePlayerControllable(j, false);
	new str[144];
	format(str, 144, "Você foi algemado pelo oficial %s.", pName(playerid));
	Info(j, str);
	format(str, 144, "Você algemou o suspeito %s.", pName(j));
	Info(playerid, str);
	return 1;
}

CMD:desalgemar(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	new j = 0, s = GetPlayerSkin(playerid);
	for(; j < sizeof(CountyCopSkins); j++) {
		if(s == CountyCopSkins[j]) break;
	}
	if(j == sizeof(CountyCopSkins)) return Advert(playerid, "Você deve estar fardado.");
	if(sscanf(params, "i", j)) return AdvertCMD(playerid, "/Desalgemar [ID]");
	if(!IsPlayerConnected(j)) return Advert(playerid, "ID inválido.");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(j, 2.5, P[0], P[1], P[2])) return Advert(playerid, "Você só pode desalgemar pessoas próximas a você.");
	if(GetPlayerSpecialAction(j) != SPECIAL_ACTION_CUFFED) return Advert(playerid, "Esse indivíduo não está algemado.");
	SetPlayerSpecialAction(j, SPECIAL_ACTION_NONE);
	TogglePlayerControllable(j, true);
	new str[144];
	format(str, 144, "Você foi desalgemado pelo oficial %s.", pName(playerid));
	Info(j, str);
	format(str, 144, "Você desalgemou o suspeito %s.", pName(j));
	Info(playerid, str);
	return 1;
}

CMD:procurar(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	new j = 0, s = GetPlayerSkin(playerid);
	for(; j < sizeof(CountyCopSkins); j++) {
		if(s == CountyCopSkins[j]) break;
	}
	if(j == sizeof(CountyCopSkins)) return Advert(playerid, "Você deve estar fardado.");
	new a;
	if(sscanf(params, "ii", j, a)) return AdvertCMD(playerid, "/Procurar [ID] [Número do Artigo]");
	if(!IsPlayerConnected(j)) return Advert(playerid, "ID inválido.");
	if(a < 1 || a > sizeof(Articles)) return Advert(playerid, "Artigo inválido.");
	new str[144];
	format(str, 144, "Você está sendo procurado por infringir o artigo %i°.", a);
	Info(j, str);
	format(str, 144, "Você colocou o suspeito %s na lista de procurados por infringir o artigo %i°.", pName(j), a);
	Info(playerid, str);
	SetPlayerWantedLevel(j, Articles[a-1]);
	return 1;
}

CMD:tprisao(playerid) {
	if(!pInfo[playerid][ptPrisao]) return Advert(playerid, "Você não está preso.");
	new str[144];
	format(str, 144, "Você está condenado por mais %i minutos de prisão. (( IN CHARACTER ))", pInfo[playerid][ptPrisao]);
	Info(playerid, str);
	return 1;
}

CMD:prender(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo uma viatura.");
	new i = 0;
	for(; i < MAX_VIATURAS; i++) {
		if(IsPlayerInVehicle(playerid, Viatura[i])) break;
	}
	if(i == MAX_VIATURAS) return Advert(playerid, "Você deve estar conduzindo uma viatura.");
	if(!IsVehicleInRangeOfPoint(Viatura[i], 3.0, 612.0064,-587.4871,16.9460)) return Advert(playerid, "Há um lugar correto para uso desse comando.");
	new j = 0, s = GetPlayerSkin(playerid);
	for(; j < sizeof(CountyCopSkins); j++) {
		if(s == CountyCopSkins[j]) break;
	}
	if(j == sizeof(CountyCopSkins)) return Advert(playerid, "Você deve estar fardado.");
	if(sscanf(params, "i", j)) return AdvertCMD(playerid, "/Prender [ID]");
	if(!IsPlayerConnected(j)) return Advert(playerid, "ID inválido.");
	if(!IsPlayerInVehicle(j, Viatura[i])) return Advert(playerid, "O indivíduo deve estar na sua viatura.");
	if(!GetPlayerWantedLevel(j)) return Advert(playerid, "O indivíduo não é procurado pela polícia.");
	new str[144];
	format(str, 144, "Você foi preso pelo oficial da justiça %s.", pName(playerid));
	Info(j, str);
	format(str, 144, "Você prendeu o infrator %s.", pName(j));
	Info(playerid, str);
	SetPlayerInterior(j, 10);
	SetPlayerFacingAngle(j, 0.0);
	Streamer_UpdateEx(j, 214.8972,108.5615,999.0156, -1, -1, -1, 1500);
	pInfo[j][ptPrisao] = (40*GetPlayerWantedLevel(j));
	SetPlayerWantedLevel(j, 0);
	TogglePlayerControllable(j, true);
	return 1;
}

CMD:farda(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return Advert(playerid, "Apenas oficiais da justiça podem fazer isso.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.0, 274.2937,122.2063,1004.6172)) return Advert(playerid, "Você deve estar no vestiário da delegacia.");
	if(!pInfo[playerid][pSkin]) return Advert(playerid, "A skin 0 (CJ) não é permitida no servidor.");
	new i = 0, s = GetPlayerSkin(playerid);
	for(; i < sizeof(CountyCopSkins); i++) {
		if(s == CountyCopSkins[i]) break;
	}
	if(i == sizeof(CountyCopSkins)) {
		if(sscanf(params, "i", i)) return AdvertCMD(playerid, "/Farda [1-7]");
		if(i < 0 || i > sizeof(CountyCopSkins)) return AdvertCMD(playerid, "/Farda [1-7]");
		pInfo[playerid][pSkin] = s;
		SetPlayerSkin(playerid, CountyCopSkins[i-1]);
		GivePlayerWeapon(playerid, 24, 30);
		GivePlayerWeapon(playerid, 3, 1);
	} else {
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		ResetPlayerWeapons(playerid);
	}
	return 1;
}

CMD:setcop(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new i;
	if(sscanf(params, "i", i)) return AdvertCMD(playerid, "/SetCop [ID]");
	if(!IsPlayerConnected(i)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O %s tornou você policial.", Staff(playerid));
	Info(i, str);
	format(str, 144, "Você tornou %s policial.", pName(i));
	Info(playerid, str);
	sInfo[i][sSQL] = 1;
	sInfo[i][sPatente] = 5;
	return 1;
}

CMD:m(playerid, params[]) return cmd_megafone(playerid, params);

CMD:megafone(playerid, params[]) {
	if(!sInfo[playerid][sSQL]) return 1;
	if(isnull(params)) return AdvertCMD(playerid, "(/M)egafone [Voz]");
	new Float:P[6], str[144];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		GetPlayerPos(i, P[3], P[4], P[5]);
		new Float:D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
		if(D > (ACTION_RANGE*3.5)) continue;
		new color = floatround(255.0 - 153.0*D/(ACTION_RANGE*3.5));
		color = (color*0x1000000 + color*0x10000 + color*0x100 + 0xAA);
		format(str, 144, "(Megafone) %s: "BRANCO"%s", pName(playerid), params);
		SendClientMessage(i, color, str);
	}
	return 1;
}

forward OnGameModeInit@rcsd();
public OnGameModeInit@rcsd() {
	Viatura[0] = CreateVehicle(596, 613.1500, -596.8196, 16.9551, 270.0000, 0, 1, 0);
	Viatura[1] = CreateVehicle(596, 613.1500, -601.5782, 16.9508, 270.0000, 0, 1, 0);
	for(new i = 0; i < MAX_VIATURAS; i++) { vInfo[Viatura[i]][vChave] = CLOC_RCSD; vInfo[Viatura[i]][vSQL] = -1; }
	return 1;
}

forward OnPlayerConnect@rcsd(playerid);
public OnPlayerConnect@rcsd(playerid) {
	RemoveBuildingForPlayer(playerid, 1771, 216.6484, 108.4219, 998.6719, 0.25);

	RemoveBuildingForPlayer(playerid, 1294, 632.5781, -583.5938, 19.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 630.7266, -578.7734, 15.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 780, 628.1953, -557.3438, 15.3359, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 630.2188, -564.2500, 15.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 632.8438, -545.6016, 19.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 629.5781, -547.2188, 15.1328, 0.25);

	RemoveBuildingForPlayer(playerid, 12855, 622.945, -577.062, 21.812, 0.250);
	RemoveBuildingForPlayer(playerid, 13250, 622.945, -577.062, 21.812, 0.250);
	/*RemoveBuildingForPlayer(playerid, 13250, 622.9453, -577.0625, 21.8125, 0.25); redcounty roleplay
	RemoveBuildingForPlayer(playerid, 13484, 738.3984, -553.9844, 21.9609, 0.25);
	RemoveBuildingForPlayer(playerid, 12855, 622.9453, -577.0625, 21.8125, 0.25);
	RemoveBuildingForPlayer(playerid, 1687, 625.0156, -579.7188, 25.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 1522, 626.5313, -571.0078, 16.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 632.5781, -583.5938, 19.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 630.7266, -578.7734, 15.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 1687, 611.0000, -562.9531, 25.9297, 0.25);
	RemoveBuildingForPlayer(playerid, 780, 628.1953, -557.3438, 15.3359, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 630.2188, -564.2500, 15.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 1691, 622.4922, -552.9141, 20.5234, 0.25);
	RemoveBuildingForPlayer(playerid, 781, 629.5781, -547.2188, 15.1328, 0.25);
	RemoveBuildingForPlayer(playerid, 780, 604.0156, -542.3438, 15.0703, 0.25);
	RemoveBuildingForPlayer(playerid, 1290, 1643.2969, -1042.1719, 28.9219, 0.25);*/
	return 1;
}

stock ResetSheriffVar(playerid) {
	sInfo[playerid][sSQL] = 0;
	sInfo[playerid][sPatente] = 0;
	sInfo[playerid][sPrisoes] = 0;
	sInfo[playerid][sIngresso] = 0;
	return 1;
}