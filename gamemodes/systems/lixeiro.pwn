#define MAX_GROUTES					2

enum GROUTE_INFO {
	grouteRoute,
	groutePoint,
	grouteVehicle,
	groutePartner[2],
	grouteInvite[2]
};

new PortaoLixeiro;
new PrensadorLixeiro[3];
new LixosPrensados[4];
new TempoAlavanca;
new gRoute[MAX_PLAYERS][GROUTE_INFO];
new EquipamentoLixeiro[MAX_PLAYERS];
new SegurandoLixo[MAX_PLAYERS];

new Float:TrashmasterCoord[33][3] = {
	{-253.6772,-255.8471,1.9401},
	{45.7753,-212.0638,1.9906},
	{135.5013,-175.8848,1.9858},
	{169.1390,-74.4438,1.9811},
	{196.5030,-23.6437,1.9626},
	{235.0823,-1.6074,2.7472},
	{311.6930,70.7819,3.3765},
	{693.5814,311.2798,20.4300},
	{780.4825,324.7198,20.4152},
	{1347.5950,456.4907,20.4348},
	{1409.3807,426.1729,20.3966},
	{1407.7792,392.4290,20.2340},
	{1411.8530,278.7025,20.1038},
	{1374.5239,215.2556,19.9381},
	{1359.0920,221.3151,19.9569},
	{1356.1122,270.1260,19.9487},
	{1333.2399,308.5667,19.9533},
	{1328.1985,330.4626,19.9698},
	{1302.5205,377.1851,19.9663},
	{1281.3877,360.6626,19.9566},
	{1201.0493,287.3060,19.9548},
	{1238.0898,264.4830,19.9556},
	{1217.4039,207.7886,19.9556},
	{1225.9812,198.3091,19.9534},
	{1253.1438,186.7994,19.9535},
	{335.6599,-84.0800,1.9652},
	{290.5455,-69.2006,1.9702},
	{280.7111,-138.6890,1.9808},
	{258.8734,-209.2855,1.9801},
	{230.1584,-255.5734,1.9793},
	{184.9711,-188.3519,1.9763},
	{89.2562,-208.9505,1.9901},
	{-109.7369,-190.1962,2.3417}
};

new Float:CollectorCoord[33][3] = {
	{-245.8641,-247.7202,1.4297},
	{48.1901,-221.7903,1.5781},
	{160.1313,-174.5387,1.5781},
	{184.5832,-93.7164,1.5391},
	{202.7852,-31.1872,1.5781},
	{244.0366,6.7028,2.5733},
	{339.6124,54.7466,3.6326},
	{705.7021,307.3568,20.2344},
	{786.4628,338.4495,20.1932},
	{1361.0321,460.2427,19.9238},
	{1411.5295,413.5587,19.7578},
	{1409.0640,386.1351,19.5860},
	{1417.7697,271.3600,19.5618},
	{1370.2734,201.0962,19.5547},
	{1362.1915,230.7802,19.5669},
	{1348.6187,286.6668,19.5615},
	{1336.9691,318.6588,20.2649},
	{1314.7251,348.4896,19.5547},
	{1289.7655,387.3855,19.5614},
	{1271.4320,358.8564,19.5547},
	{1204.9977,275.6563,19.5547},
	{1245.7676,247.2218,19.5547},
	{1203.8190,180.6064,20.5170},
	{1240.6663,214.9767,19.5547},
	{1274.5212,188.6162,19.5701},
	{335.2597,-64.5805,1.5576},
	{282.8643,-63.2665,1.5781},
	{259.6389,-134.0797,1.5781},
	{254.0491,-200.5194,1.5781},
	{251.3376,-264.2376,1.5836},
	{195.6885,-179.7582,1.5781},
	{80.2579,-198.2030,1.5751},
	{-114.5527,-184.2323,1.8848}
};

CMD:alavanca(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.5, 42.1226,-1182.9768,7.2392)) {
		if(TempoAlavanca > gettime()) return Advert(playerid, "Aguarde até que a máquina termine o processamento de trituração.");
		TempoAlavanca = gettime() + 10;
		MoveDynamicObject(PrensadorLixeiro[0], 41.402507, -1185.573364, 6.849194, 0.4, 0.000000, 270.000000, 0.000000);
		MoveDynamicObject(PrensadorLixeiro[1], 42.028755, -1186.045532, 7.831899, 0.2228354, 138.499969, 0.000000, 180.000000);
		MoveDynamicObject(PrensadorLixeiro[2], 40.488750, -1186.045532, 7.831899, 0.2228354, 138.499969, 0.000000, 180.000000);
		SetTimer("SubirPrensa", 5500, false);
		SetTimer("PrensarLixo", 2000, false);
		PlaySoundAround(1135, 41.402507, -1185.573364, 6.849194);
		return 1;
	}
	return 1;
}

CMD:depositarlixo(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.5, 38.9333,-1185.5408,7.2092)) {
		if(TempoAlavanca > gettime()) return Advert(playerid, "Aguarde até que a máquina termine o processamento de trituração.");
		if(!SegurandoLixo[playerid]) return Advert(playerid, "Você deve estar segurando uma sacola de lixo.");
		new i = 0, Float:CoordLixos[4][3] = {
			{40.853633, -1185.760009, 7.342659},
			{41.943630, -1185.760009, 7.342659},
			{40.853633, -1184.669677, 7.342659},
			{41.863647, -1184.669677, 7.342659}
		};
		for(; i < 4; i++) {
			if(!LixosPrensados[i]) {
				LixosPrensados[i] = CreateDynamicObject(1265, CoordLixos[i][0], CoordLixos[i][1], CoordLixos[i][2], 0.0, 0.0, 0.0);
				RemovePlayerAttachedObject(playerid, 0);
				SegurandoLixo[playerid] = 0;
				break;
			}
		}
		if(i == 4) return Advert(playerid, "A prensa está lotada. Use a alavanca para prensar o lixo e esvaziá-la.");
	}
	return 1;
}

CMD:equipamento(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 22.2973,-1172.4701,7.2392)) {
		if(pInfo[playerid][pBus] != BUSID_GARBAGE) return Advert(playerid, "Apenas os funcionários tem acesso às gavetas.");
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!bInfo[BUSID_GARBAGE][bVehicles][i]) continue;
			if(pInfo[playerid][pSQL] == vInfo[GetVehicleIDBySQL(bInfo[BUSID_GARBAGE][bVehicles][i])][vChave]) {
				Advert(playerid, "Para ser coletor você deve devolver a chave do caminhão na gaveta.");
				return 1;
			}
		}
		if(!EquipamentoLixeiro[playerid]) {
			SetPlayerAttachedObject(playerid, 1, 19904, 1, 0.045, 0.045, 0.0, 0.0, 90.0, 180.0);
			EditAttachedObject(playerid, 1);
			EquipamentoLixeiro[playerid] = 1;
			Act(playerid, "retira um par de luvas de borracha e um colete das gavetas, vestindo seu equipamento.");
			Info(playerid, "Coloque o colete na posição mais conveniente. Instruções a seguir:");
			Info(playerid, "Para mover a câmera use espaço. Caso tenha terminado a edição clique no botão para salvar.");
		} else {
			RemovePlayerAttachedObject(playerid, 1);
			EquipamentoLixeiro[playerid] = 0;
			Act(playerid, "remove suas luvas de borracha junto ao colete utilizado e os guarda em uma gaveta de descarte.");
		}
	}
	return 1;
}

CMD:dlixo(playerid) {
	if(!SegurandoLixo[playerid]) return 1;
	new Float:P[6];
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pBus] != BUSID_GARBAGE) continue;
		if(!gRoute[i][groutePoint]) continue;
		for(new j = 0; j < 2; j++) {
			if(gRoute[i][groutePartner][j] == playerid+1) {
				GetVehiclePos(gRoute[i][grouteVehicle], P[0], P[1], P[2]);
				GetVehicleZAngle(gRoute[i][grouteVehicle], P[3]);
				GetXYInFrontOfXY(P[0], P[1], 4.5, (P[3]+180.0), P[4], P[5]);
				if(!IsPlayerInRangeOfPoint(playerid, 2.0, P[4], P[5], P[2])) return Advert(playerid, "Você deve estar na caçamba do caminhão de lixo.");
				RemovePlayerAttachedObject(playerid, 0);
				SegurandoLixo[playerid] = 0;
				return 1;
			}
		}
	}
	return 1;
}

CMD:plixo(playerid) {
	if(SegurandoLixo[playerid]) return 1;
	new Float:P[6];
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pBus] != BUSID_GARBAGE) continue;
		if(!gRoute[i][groutePoint]) continue;
		for(new j = 0; j < 2; j++) {
			if(gRoute[i][groutePartner][j] == playerid+1) {
				if(gRoute[i][groutePoint] < 34) return 1;
				if(gRoute[i][groutePoint] >= 44) {
					Info(playerid, "Último lixo do caminhão retirado.");
					Info(i, "Último lixo do caminhão retirado.");
					GivePlayerMoney(playerid, 180);
					GivePlayerMoney(i, 180);
					if(j == 0) {
						if(gRoute[i][groutePartner][1]) {
							GivePlayerMoney(gRoute[i][groutePartner][1]-1, 180);
							Info(gRoute[i][groutePartner][1]-1, "Último lixo do caminhão retirado.");
						}
					} else {
						if(gRoute[i][groutePartner][0]) {
							GivePlayerMoney(gRoute[i][groutePartner][0]-1, 180);
							Info(gRoute[i][groutePartner][0]-1, "Último lixo do caminhão retirado.");
						}
					}
					gRoute[i][groutePoint] = 0;
					gRoute[i][grouteRoute] = 0;
					gRoute[i][grouteVehicle] = 0;
					gRoute[i][groutePartner][0] = 0;
					gRoute[i][groutePartner][1] = 0;
					gRoute[i][grouteInvite][0] = 0;
					gRoute[i][grouteInvite][1] = 0;
					return 1;
				}
				gRoute[i][groutePoint]++;
				GetVehiclePos(gRoute[i][grouteVehicle], P[0], P[1], P[2]);
				GetVehicleZAngle(gRoute[i][grouteVehicle], P[3]);
				GetXYInFrontOfXY(P[0], P[1], 4.5, (P[3]+180.0), P[4], P[5]);
				if(!IsPlayerInRangeOfPoint(playerid, 2.0, P[4], P[5], P[2])) return Advert(playerid, "Você deve estar na caçamba do caminhão de lixo.");
				//SetPlayerAttachedObject(playerid, 0);
				SegurandoLixo[playerid] = 1;
				return 1;
			}
		}
	}
	return 1;
}

Dialog:CollectorsQuant(playerid, response, listitem, inputtext[]) {
	new str[150], Float:P[6], vid = gRoute[playerid][grouteVehicle];
	if(!IsPlayerInVehicle(playerid, vid)) return Advert(playerid, "Você precisa estar dentro do seu caminhão de lixo.");
	GetVehiclePos(vid, P[0], P[1], P[2]);
	GetVehicleZAngle(vid, P[3]);
	GetXYInFrontOfXY(P[0], P[1], 4.5, (P[3]+180.0), P[4], P[5]);
	for(new j = 0, p; j < MAX_PLAYERS; j++) {
		if(!IsPlayerConnected(j)) continue;
		if(pInfo[j][pBus] != BUSID_GARBAGE) continue;
		if(!EquipamentoLixeiro[j]) continue;
		p = 0;
		for(new k = 0; k < MAX_PLAYERS; k++) {
			if(!IsPlayerConnected(k)) continue;
			if(gRoute[k][groutePartner][0] == j+1 || gRoute[k][groutePartner][1] == j+1) { p = 1; break; }
		}
		if(p) continue;
		if(IsPlayerInRangeOfPoint(j, 2.0, P[4], P[5], P[2])) {
			format(str, 150, "%s%s\n", str, pName(j));
		}
	}
	if(isnull(str)) return Advert(playerid, "Os coletores a serem chamados devem estar usando equipamento e estarem na traseira do caminhão.");
	else if(response) { Dialog_Show(playerid, "Select1Collector", DIALOG_STYLE_LIST, "Catadores disponíveis", str, "Selecionar", "Fechar"); }
	else { Dialog_Show(playerid, "Select2Collectors", DIALOG_STYLE_LIST, "Catadores disponíveis", str, "Selecionar", "Fechar"); }
	return 1;
}

Dialog:Select1Collector(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new Nickname[25];
	format(Nickname, 25, "%s", inputtext);
	SpaceToUnderline(Nickname);
	new id = GetPlayerIDByNickname(Nickname);
	if(id == -1) return Advert(playerid, "Esse player foi desconectado.");
	new str[150];
	format(str, 150, "O motorista %s está te convidando para fazer uma rota de coleta.\nDeseja aceitar o convite?", pName(playerid));
	Dialog_Show(id, "ConfirmCollector", DIALOG_STYLE_MSGBOX, "Convite para rota", str, "Aceitar", "Recusar");
	format(str, 144, "Foi enviado um convite para %s. Espere sua resposta.", pName(id));
	Info(playerid, str);
	pInfo[id][pDialogParam][0] = funcidx("dialog_ConfirmCollector");
	pInfo[id][pDialogParam][1] = playerid;
	gRoute[playerid][grouteInvite][0] = id+1;
	gRoute[playerid][grouteInvite][1] = 0;
	return 1;
}

Dialog:Select2Collectors(playerid, response, listitem, inputtext[]) {
	if(!response) {
		gRoute[playerid][grouteInvite][0] = 0;
		gRoute[playerid][grouteInvite][1] = 0;
	}
	new Nickname[25];
	format(Nickname, 25, "%s", inputtext);
	SpaceToUnderline(Nickname);
	new id = GetPlayerIDByNickname(Nickname);
	if(id == -1) return Advert(playerid, "Esse player foi desconectado.");
	if(!gRoute[playerid][grouteInvite][0]) {
		gRoute[playerid][grouteInvite][0] = -(id+1);
		new str[150], Float:P[6], vid = gRoute[playerid][grouteVehicle];
		if(!IsPlayerInVehicle(playerid, vid)) return Advert(playerid, "Você precisa estar dentro do seu caminhão de lixo.");
		GetVehiclePos(vid, P[0], P[1], P[2]);
		GetVehicleZAngle(vid, P[3]);
		GetXYInFrontOfXY(P[0], P[1], 4.5, (P[3]+180.0), P[4], P[5]);
		for(new j = 0, p; j < MAX_PLAYERS; j++) {
			if(!IsPlayerConnected(j)) continue;
			if(pInfo[j][pBus] != BUSID_GARBAGE) continue;
			if(!EquipamentoLixeiro[j]) continue;
			if(j == id) continue;
			p = 0;
			for(new k = 0; k < MAX_PLAYERS; k++) {
				if(!IsPlayerConnected(k)) continue;
				if(gRoute[k][groutePartner][0] == j+1 || gRoute[k][groutePartner][1] == j+1) { p = 1; break; }
			}
			if(p) continue;
			if(IsPlayerInRangeOfPoint(j, 2.0, P[4], P[5], P[2])) {
				format(str, 150, "%s%s\n", str, pName(j));
			}
		}
		if(isnull(str)) return Advert(playerid, "Os coletores a serem chamados devem estar usando equipamento e estarem na traseira do caminhão.");
		else Dialog_Show(playerid, "Select2Collectors", DIALOG_STYLE_LIST, "Catadores disponíveis", str, "Selecionar", "Fechar");
	} else {
		gRoute[playerid][grouteInvite][0] *= -1;
		gRoute[playerid][grouteInvite][1] = id+1;
		pInfo[id][pDialogParam][0] = funcidx("dialog_ConfirmCollector");
		pInfo[id][pDialogParam][1] = playerid;
		pInfo[gRoute[playerid][grouteInvite][0]-1][pDialogParam][0] = funcidx("dialog_ConfirmCollector");
		pInfo[gRoute[playerid][grouteInvite][0]-1][pDialogParam][1] = playerid;
		new str[150];
		format(str, 144, "Foi enviado um convite para os catadores %s e %s. Aguarde a resposta.", pName(id), pName(gRoute[playerid][grouteInvite][0]-1));
		Info(playerid, str);
		format(str, 150, "O motorista %s está te convidando para fazer uma rota de coleta.\nDeseja aceitar o convite?", pName(playerid));
		Dialog_Show(id, "ConfirmCollector", DIALOG_STYLE_MSGBOX, "Convite para rota", str, "Aceitar", "Recusar");
		Dialog_Show(gRoute[playerid][grouteInvite][0]-1, "ConfirmCollector", DIALOG_STYLE_MSGBOX, "Convite para rota", str, "Aceitar", "Recusar");
	}
	return 1;
}

Dialog:ConfirmCollector(playerid, response, listitem, inputtext[]) {
	new idx = funcidx("dialog_ConfirmCollector");
	if(pInfo[playerid][pDialogParam][0] != idx) return ResetDialogParams(playerid);
	new id = pInfo[playerid][pDialogParam][1];
	if(!response) {
		new str[144];
		format(str, 144, "O catador %s recusou o convite de rota.", pName(playerid));
		Info(id, str);
		if(IsPlayerConnected(gRoute[id][grouteInvite][1]-1)) {
			Info(id, str);
			Dialog_Close(gRoute[id][grouteInvite][1]-1);
		}
		gRoute[id][grouteInvite][0] = 0;
		gRoute[id][grouteInvite][1] = 0;
		gRoute[id][groutePartner][0] = 0;
		gRoute[id][groutePartner][1] = 0;
	} else {
		if(!EquipamentoLixeiro[playerid]) {
			Info(id, "Seu parceiro está sem equipamento para coletar o lixo.");
			Info(playerid, "Você não pode ser catador de lixo sem os devidos equipamentos.");
		} else {
			new p = 0;
			for(new k = 0; k < MAX_PLAYERS; k++) {
				if(!IsPlayerConnected(k)) continue;
				if(gRoute[k][groutePartner][0] == playerid+1 || gRoute[k][groutePartner][1] == playerid+1) { p = 1; break; }
			}
			if(p) {
				Info(id, "Seu parceiro já foi convidado para outra rota.");
				Info(playerid, "Você não pode trabalhar em duas rotas ao mesmo tempo.");
			} else {
				if(gRoute[id][grouteInvite][0] == playerid+1) {
					if(!gRoute[id][grouteInvite][1]) {
						gRoute[id][grouteInvite][0] = 0;
						gRoute[id][groutePartner][0] = playerid+1;
						Success(id, "Seu parceiro de rota aceitou o convite.");
						Info(id, "Rota iniciada.");
						Info(playerid, "Rota iniciada.");
						pInfo[id][pCP] = CP_TRASHMASTER;
						gRoute[id][groutePoint] = 1;
						SetPlayerCheckpoint(id, TrashmasterCoord[0][0], TrashmasterCoord[0][1], TrashmasterCoord[0][2], 2.5);
					} else {
						if(!gRoute[id][groutePartner][1]) {
							gRoute[id][groutePartner][0] = -(playerid+1);
							Info(playerid, "Aguardando a resposta do outro catador.");
						} else {
							gRoute[id][grouteInvite][0] = 0;
							gRoute[id][grouteInvite][1] = 0;
							gRoute[id][groutePartner][0] = playerid+1;
							gRoute[id][groutePartner][1] *= -1;
							Success(id, "Seus parceiros de rota aceitaram o convite.");
							Info(playerid, "Rota iniciada.");
							Info(gRoute[id][groutePartner][1]-1, "Rota iniciada.");
							Info(id, "Rota iniciada.");
							pInfo[id][pCP] = CP_TRASHMASTER;
							gRoute[id][groutePoint] = 1;
							SetPlayerCheckpoint(id, TrashmasterCoord[0][0], TrashmasterCoord[0][1], TrashmasterCoord[0][2], 2.5);
						}
					}
				} else if(gRoute[id][grouteInvite][1] == playerid+1) {
					if(!gRoute[id][groutePartner][0]) {
						gRoute[id][groutePartner][1] = -(playerid+1);
						Info(playerid, "Aguardando a resposta do outro catador.");
					} else {
						gRoute[id][grouteInvite][0] = 0;
						gRoute[id][grouteInvite][1] = 0;
						gRoute[id][groutePartner][1] = playerid+1;
						gRoute[id][groutePartner][0] *= -1;
						Success(id, "Seus parceiros de rota aceitaram o convite.");
						Info(playerid, "Rota iniciada.");
						Info(gRoute[id][groutePartner][0]-1, "Rota iniciada.");
						Info(id, "Rota iniciada.");
						pInfo[id][pCP] = CP_TRASHMASTER;
						gRoute[id][groutePoint] = 1;
						SetPlayerCheckpoint(id, TrashmasterCoord[0][0], TrashmasterCoord[0][1], TrashmasterCoord[0][2], 2.5);
					}
				}
			}
		}
	}
	return ResetDialogParams(playerid);
}

forward OnPlayerEnterCheckpoint@lixeiro(playerid);
public OnPlayerEnterCheckpoint@lixeiro(playerid) {
	if(pInfo[playerid][pCP] == CP_TRASHMASTER) {
		if(!IsPlayerInVehicle(playerid, gRoute[playerid][grouteVehicle])) return Advert(playerid, "Você precisa estar conduzindo o caminhão de lixo da empresa.");
		DisablePlayerCheckpoint(playerid);
		pInfo[playerid][pCP] = CP_NONE;
		for(new j = 0; j < 2; j++) {
			if(gRoute[playerid][groutePartner][j]) {
				SetPlayerCheckpoint(gRoute[playerid][groutePartner][j]-1, CollectorCoord[gRoute[playerid][groutePoint]-1][0], CollectorCoord[gRoute[playerid][groutePoint]-1][1], CollectorCoord[gRoute[playerid][groutePoint]-1][2], 1.5);
				pInfo[gRoute[playerid][groutePartner][j]-1][pCP] = CP_GARBAGE;
			}
		}
	} else if(pInfo[playerid][pCP] == CP_GARBAGE) {
		if(SegurandoLixo[playerid]) return Advert(playerid, "Antes deposite seu lixo no caminhão usando "AMARELO"/dLixo"BRANCO".");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][pBus] != BUSID_GARBAGE) continue;
			if(!gRoute[i][groutePoint]) continue;
			if(gRoute[i][groutePartner][0] == playerid+1) {
				DisablePlayerCheckpoint(playerid);
				pInfo[playerid][pCP] = CP_NONE;
				if(gRoute[i][groutePartner][1]) {
					if(pInfo[gRoute[i][groutePartner][1]-1][pCP] == CP_NONE) {
						gRoute[i][groutePoint]++;
						if(gRoute[i][groutePoint] == 34) {
							Info(i, "Agora leve o caminhão de volta para a coletora a fim de terminar o serviço.");
							Info(playerid, "Quando o caminhão chegar de volta para a coletora, despeje o lixo do caminhão.");
							Info(gRoute[i][groutePartner][1]-1, "Quando o caminhão chegar de volta para a coletora, despeje o lixo do caminhão.");
						} else {
							SetPlayerCheckpoint(i, TrashmasterCoord[gRoute[i][groutePoint]-1][0], TrashmasterCoord[gRoute[i][groutePoint]-1][1], TrashmasterCoord[gRoute[i][groutePoint]-1][2], 2.5);
							pInfo[i][pCP] = CP_TRASHMASTER;
							SegurandoLixo[playerid] = 1;
							//SetPlayerAttachedObject();
							//ApplyAnimation();
						}
					}
				} else {
					gRoute[i][groutePoint]++;
					if(gRoute[i][groutePoint] == 34) {
						Info(i, "Agora leve o caminhão de volta para a coletora a fim de terminar o serviço.");
						Info(playerid, "Quando o caminhão chegar de volta para a coletora, despeje o lixo do caminhão.");
					} else {
						SetPlayerCheckpoint(i, TrashmasterCoord[gRoute[i][groutePoint]-1][0], TrashmasterCoord[gRoute[i][groutePoint]-1][1], TrashmasterCoord[gRoute[i][groutePoint]-1][2], 2.5);
						pInfo[i][pCP] = CP_TRASHMASTER;
						SegurandoLixo[playerid] = 1;
						//SetPlayerAttachedObject();
						//ApplyAnimation();
					}
				}
				break;
			} else if(gRoute[i][groutePartner][1] == playerid+1) {
				DisablePlayerCheckpoint(playerid);
				pInfo[playerid][pCP] = CP_NONE;
				if(pInfo[gRoute[i][groutePartner][0]-1][pCP] == CP_NONE) {
					gRoute[i][groutePoint]++;
					if(gRoute[i][groutePoint] == 34) {
						Info(i, "Agora leve o caminhão de volta para a coletora a fim de terminar o serviço.");
						Info(playerid, "Quando o caminhão chegar de volta para a coletora, despeje o lixo do caminhão.");
						Info(gRoute[i][groutePartner][0]-1, "Quando o caminhão chegar de volta para a coletora, despeje o lixo do caminhão.");
					} else {
						SetPlayerCheckpoint(i, TrashmasterCoord[gRoute[i][groutePoint]-1][0], TrashmasterCoord[gRoute[i][groutePoint]-1][1], TrashmasterCoord[gRoute[i][groutePoint]-1][2], 2.5);
						pInfo[i][pCP] = CP_TRASHMASTER;
						SegurandoLixo[playerid] = 1;
						//SetPlayerAttachedObject();
						//ApplyAnimation();
					}
				}
				break;
			}
		}
	}
	return 1;
}

forward OnPlayerDisconnect@lixeiro(playerid, reason);
public OnPlayerDisconnect@lixeiro(playerid, reason) {
	EquipamentoLixeiro[playerid] = 0;
	SegurandoLixo[playerid] = 0;
	if(gRoute[playerid][groutePoint]) {
		if(gRoute[playerid][groutePartner][0]) {
			Info(gRoute[playerid][groutePartner][0]-1, "Seu motorista de rota foi desconectado.");
			SegurandoLixo[gRoute[playerid][groutePartner][0]-1] = 0;
		} if(gRoute[playerid][groutePartner][1]) {
			Info(gRoute[playerid][groutePartner][1]-1, "Seu motorista de rota foi desconectado.");
			SegurandoLixo[gRoute[playerid][groutePartner][1]-1] = 0;
		}
		gRoute[playerid][grouteRoute] = 0;
		gRoute[playerid][groutePartner][0] = 0;
		gRoute[playerid][groutePartner][1] = 0;
		gRoute[playerid][grouteInvite][0] = 0;
		gRoute[playerid][grouteInvite][1] = 0;
		gRoute[playerid][grouteVehicle] = 0;
		gRoute[playerid][groutePoint] = 0;
	}
	for(new i = 0, p = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pBus] != BUSID_GARBAGE) continue;
		for(new j = 0; j < 2; j++) {
			if(gRoute[i][grouteInvite][j] == playerid+1) {
				gRoute[i][grouteInvite][j] = 0;
				Info(i, "Um dos catadores que você convidou foi desconectado.");
				p = 1;
				break;
			} else if(gRoute[i][groutePartner][j] == playerid+1) {
				gRoute[i][groutePartner][j] = 0;
				Info(i, "Um dos catadores da sua rota foi desconectado, leve o caminhão de volta na estação.");
				p = 1;
				break;
			}
		}
		if(p) break;
	}
	return 1;
}

forward PrensarLixo();
public PrensarLixo() {
	for(new i = 0; i < 4; i++) {
		if(LixosPrensados[i]) {
			DestroyDynamicObject(LixosPrensados[i]);
			LixosPrensados[i] = 0;
		}
	}
	return 1;
}

forward SubirPrensa();
public SubirPrensa() {
	MoveDynamicObject(PrensadorLixeiro[0], 41.402507, -1185.573364, 8.239198, 0.4, 0.000000, 270.000000, 0.000000);
	MoveDynamicObject(PrensadorLixeiro[1], 42.028778, -1185.628295, 8.484233, 0.2228354, 95.800109, 0.000000, 180.000000);
	MoveDynamicObject(PrensadorLixeiro[2], 40.488750, -1185.628295, 8.484233, 0.2228354, 95.800109, 0.000000, 180.000000);
	PlaySoundAround(1135, 41.402507, -1185.573364, 6.849194);
	return 1;
}