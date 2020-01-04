#define MAX_ROUTE_STOPS		18
#define MAX_ROUTES 			3

new Float:BusStops[MAX_ROUTE_STOPS][3] = {
	{229.3421,-167.5962,1.5318}, // BB-1
	{236.3075,-144.2081,1.5273}, // BB-2
	{1368.7019,210.2991,19.3372}, // MG-1
	{1363.6969,220.0606,19.3382}, // MG-2
	{1241.0079,350.9773,19.3389}, // MG-3
	{1256.5846,335.8900,19.3386}, // MG-4
	{1452.1853,404.5543,19.8221}, // MG-5
	{1460.1039,410.8640,19.8090}, // MG-6
	{2347.3579,251.2665,26.2684}, // PC-1
	{2341.1650,251.0762,26.2717}, // PC-2
	{2254.6021,44.9678,26.2656}, // PC-3
	{2248.4568,38.5703,26.2646}, // PC-4
	{2368.2861,95.3318,26.3991}, // PC-5
	{2370.1980,88.3404,26.3141}, // PC-6
	{685.5387,-509.6796,16.1192}, // DM-1
	{678.1996,-510.2077,16.1217}, // DM-2
	{828.0535,-546.2267,16.1191}, // DM-3
	{834.6010,-547.8644,16.1206} // DM-4
};

enum ROUTE_INFO {
	brNum,
	brVal
};

new brCP[MAX_BUSINESS][MAX_ROUTES][MAX_ROUTE_STOPS];
new BusRoute[MAX_BUSINESS][MAX_ROUTES][ROUTE_INFO];
new curPoint[MAX_BUSINESS];
new PlayerRoutePoint[MAX_PLAYERS][MAX_ROUTES];
new CriandoRota[MAX_PLAYERS];

CMD:iniciarrota(playerid, params[]) { // Definir quais cargos s�o permitidos a utilizar este comando.
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Voc� � desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return Advert(playerid, "Sua empresa n�o tem permiss�o para uso desse comando.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Voc� deve estar conduzindo um dos �nibus da empresa.");
	for(new i = 0; i < MAX_ROUTES; i++) {
		if(PlayerRoutePoint[playerid][i]) return Advert(playerid, "Voc� j� iniciou a rota. Cancele ou finalize ela. /CancelarRota | /FinalizarRota.");
	}
	new r;
	if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/IniciarRota [1-3]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/IniciarRota [1-3]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return Advert(playerid, "Essa rota n�o foi definida ainda.");
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][i]) continue;
		new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
		if(IsPlayerInVehicle(playerid, vid)) {
			if(!IsVehicleInRangeOfPoint(vid, 15.0, 364.3608, -90.8682, 1.3130)) return SendClientMessage(playerid, -1, "Voc� deve estar na Esta��o de �nibus de Blueberry.");
			SendClientMessage(playerid, -1, "Rota iniciada. Siga os checkpoints marcados no mapa e pare nos pontos de �nibus para os passageiros subirem e descerem.");
			PlayerRoutePoint[playerid][r-1] = 1;
			pInfo[playerid][pCP] = CP_BUS_ROUTE;
			SetPlayerCheckpoint(playerid, BusStops[brCP[pInfo[playerid][pBus]][r-1][PlayerRoutePoint[playerid][r-1]-1]][0], BusStops[brCP[pInfo[playerid][pBus]][r-1][PlayerRoutePoint[playerid][r-1]-1]][1], BusStops[brCP[pInfo[playerid][pBus]][r-1][PlayerRoutePoint[playerid][r-1]-1]][2], 3.0);
			return 1;
		}
	}
	SendClientMessage(playerid, -1, "Voc� deve estar conduzindo um dos �nibus da empresa.");
	return 1;
}

CMD:finalizarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Voc� � desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return SendClientMessage(playerid, -1, "Sua empresa n�o tem permiss�o para uso desse comando.");
	new r;
	while(r < MAX_ROUTES) {
		if(PlayerRoutePoint[playerid][r]) break;
		r++;
	}
	if(r == MAX_ROUTES) return Advert(playerid, "Voc� n�o iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
	if(PlayerRoutePoint[playerid][r] < BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Voc� ainda n�o passou por todos os pontos obrigat�rios da rota.");
	new j = 0;
	while(j < MAX_BUSINESS_VEHICLES) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
		if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
		else j++;
	}
	if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Voc� deve estar conduzindo um �nibus da empresa.");
	new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
	if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Voc� deve estar no estacionamento deste �nibus.");
	new name[24];
	GetPlayerName(playerid, name, 24);
	for(new i = 0; i < 24; i ++) { if(name[i] == '_') { name[i] = ' '; } }
	new i;
	while(i < MAX_CARGOS) {
		if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], name, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) break;
		else i++;
	}
	if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Um erro imposs�vel aconteceu. [COD 002]");
	cInfo[pInfo[playerid][pBus]][i][cMon] += BusRoute[pInfo[playerid][pBus]][r][brVal];

	new query[150];
	mysql_format(conn, query, 150, "UPDATE `cargoinfo` SET `mon` = %i WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cMon], cInfo[pInfo[playerid][pBus]][i][cSQL]);
	mysql_query(conn, query, false);

	new str[144];
	PlayerRoutePoint[playerid][r] = 0;
	SendClientMessage(playerid, -1, "Rota finalizada com sucesso.");
	format(str, 144, "Foram adicionados $%i ao pagamento do seu sal�rio, totalizando atualmente $%i.", BusRoute[pInfo[playerid][pBus]][r][brVal], cInfo[pInfo[playerid][pBus]][i][cMon]);
	SendClientMessage(playerid, -1, str);
	return 1;
}

CMD:cancelarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Voc� � desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return SendClientMessage(playerid, -1, "Sua empresa n�o tem permiss�o para uso desse comando.");
	new r;
	while(r < MAX_ROUTES) {
		if(PlayerRoutePoint[playerid][r]) break;
		r++;
	}
	if(r == MAX_ROUTES) return Advert(playerid, "Voc� n�o iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
	if(PlayerRoutePoint[playerid][r] == BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Voc� j� passou por todos os pontos obrigat�rios da rota. Use "AMARELO"/FinalizarRota"BRANCO".");
	new j = 0;
	while(j < MAX_BUSINESS_VEHICLES) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
		if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
		else j++;
	}
	if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Voc� deve estar conduzindo um �nibus da empresa.");
	new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
	if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Voc� deve estar no estacionamento deste �nibus.");
	SendClientMessage(playerid, -1, "Rota cancelada.");
	pInfo[playerid][pCP] = 0;
	DisablePlayerCheckpoint(playerid);
	PlayerRoutePoint[playerid][r] = 0;
	return 1;
}

CMD:criarrota(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Voc� � desempregado.");
	if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new n, r;
	if(sscanf(params, "ii", r, n)) return AdvertCMD(playerid, "/CriarRota [N�mero da Rota] [N�mero de Paradas]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/CriarRota [1-3] [N�mero de Paradas]");
	if(BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "Esta rota j� existe. Use /ExcluirRota antes de criar outra.");
	if(n < 4 || n > MAX_ROUTE_STOPS) return AdvertCMD(playerid, "/CriarRota [1-3] [4-18]");
	curPoint[pInfo[playerid][pBus]] = 0;
	BusRoute[pInfo[playerid][pBus]][r-1][brNum] = n;
	CriandoRota[playerid] = r-1;
	Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, "1� Ponto", "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Prosseguir", "Cancelar");
	return 1;
}

CMD:valorrota(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Voc� � desempregado.");
	if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new value, r;
	if(sscanf(params, "ii", r, value)) return AdvertCMD(playerid, "/ValorRota [N�mero da Rota] [Valor]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/ValorRota [1-3] [Valor]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "Essa rota n�o est� criada. Para cri�-la, use /CriarRota [N�mero da Rota] [N�mero de Paradas].");
	if(value < 1) return SendClientMessage(playerid, -1, "Valor inv�lido.");
	new str[144];
	format(str, 144, "Valor da rota atribu�do para $%i.", value);
	SendClientMessage(playerid, -1, str);
	BusRoute[pInfo[playerid][pBus]][r-1][brVal] = value;

	new query[150];
	mysql_format(conn, query, 150, "UPDATE `busrouteinfo` SET `routevalue` = %i WHERE `sqlbus` = %i AND `numroute` = %i", value, bInfo[pInfo[playerid][pBus]][bSQL], r-1);
	mysql_query(conn, query, false);
	return 1;
}

Dialog:RouteCreation(playerid, response, listitem, inputtext[]) {
	if(!response) {
		for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
			brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][i] = -1;
		}
		BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] = 0;
		SendClientMessage(playerid, -1, "Sele��o de pontos zerada e cancelada.");
		CriandoRota[playerid] = 0;
	} else {
		for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
			if(brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][i] == listitem) {
				for(new j = 0; j < MAX_ROUTE_STOPS; j++) {
					brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][j] = -1;
				}
				BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] = 0;
				SendClientMessage(playerid, -1, "Voc� n�o pode repetir o mesmo ponto em uma mesma rota.");
				SendClientMessage(playerid, -1, "Sele��o de pontos zerada e cancelada.");
				CriandoRota[playerid] = 0;
				return 1;
			}
		}
		brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][curPoint[pInfo[playerid][pBus]]] = listitem;
		curPoint[pInfo[playerid][pBus]]++;
		if(curPoint[pInfo[playerid][pBus]] == BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] - 1) {
			Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, "�ltimo Ponto", "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Finalizar", "Cancelar");
		} else if(curPoint[pInfo[playerid][pBus]] == BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]) {
			curPoint[pInfo[playerid][pBus]] = 0;
			new str[144];
			format(str, 144, "Todos os %i pontos da rota foram definidos com sucesso.", BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]);
			SendClientMessage(playerid, -1, str);

			new query[500];
			format(query, 500, "INSERT INTO `busrouteinfo` (`numstops`, `numroute`, `sqlbus`, `routevalue`, ");
			for(new i = 0; i < BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]-1; i++) {
				format(query, 500, "%s`stop%i`, ", query, i);
			}
			format(query, 500, "%s`stop%i`) VALUES (%i, %i, %i, %i, ", query, BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]-1, BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum], CriandoRota[playerid], bInfo[pInfo[playerid][pBus]][bSQL], 0);
			for(new i = 0; i < BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]-1; i++) {
				format(query, 500, "%s%i, ", query, brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][i]);
			}
			format(query, 500, "%s%i)", query, brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]-1]);
			mysql_query(conn, query, false);
			CriandoRota[playerid] = 0;
		} else {
			new str[15];
			format(str, 15, "%i� Ponto", curPoint[pInfo[playerid][pBus]]+1);
			Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, str, "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Prosseguir", "Cancelar");
		}
	}
	return 1;
}

CMD:excluirrota(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Voc� � desempregado.");
	if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new r;
	if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/ExcluirRota [N�mero da Rota]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/ExcluirRota [1-3]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "N�o h� rota para excluir. Para criar uma, use /CriarRota [N�mero de Paradas].");
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(PlayerRoutePoint[i][r-1]) return Advert(playerid, "Voc� n�o pode excluir uma rota enquanto houver um funcion�rio executando ela.");
	}
	for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
		brCP[pInfo[playerid][pBus]][r-1][i] = -1;
	}
	BusRoute[pInfo[playerid][pBus]][r-1][brNum] = 0;
	BusRoute[pInfo[playerid][pBus]][r-1][brVal] = 0;
	SendClientMessage(playerid, -1, "Rota exclu�da com sucesso.");

	new query[150];
	mysql_format(conn, query, 150, "DELETE FROM `busrouteinfo` WHERE `sqlbus` = %i AND `numroute` = %i", bInfo[pInfo[playerid][pBus]][bSQL], r-1);
	mysql_query(conn, query, false);

	return 1;
}

forward OnPlayerConnect@bus(playerid);
public OnPlayerConnect@bus(playerid) {
	RemoveBuildingForPlayer(playerid, 14604, 1492.9766, 1303.8516, 1093.2656, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1498.1406, 1305.1328, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1499.6484, 1305.1328, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1501.0781, 1305.1328, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1489.7656, 1306.0234, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1489.0078, 1306.2188, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 2173, 1489.4688, 1306.2578, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 2190, 1489.8984, 1306.4141, 1093.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1498.1406, 1305.7813, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1498.1406, 1306.4141, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1499.6484, 1305.7813, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1499.6484, 1306.4141, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1501.0781, 1305.7813, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1501.0781, 1306.4141, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1491.1719, 1307.8906, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 2190, 1491.5000, 1308.3047, 1093.0781, 0.25);
	RemoveBuildingForPlayer(playerid, 2173, 1491.5625, 1308.5313, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1491.2266, 1309.1328, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 2201, 1493.0078, 1309.6406, 1093.9453, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1498.1406, 1307.0156, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1498.1406, 1307.6719, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1499.6484, 1307.0156, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1499.6484, 1307.6719, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1501.0781, 1307.0156, 1092.2813, 0.25);
	RemoveBuildingForPlayer(playerid, 1721, 1501.0781, 1307.6719, 1092.2813, 0.25);
	return 1;
}

forward OnPlayerDisconnect@bus(playerid);
public OnPlayerDisconnect@bus(playerid) {
	for(new r = 0; r < MAX_ROUTES; r++) {
		if(PlayerRoutePoint[playerid][r]) {
			if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {	
				for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
					new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
					if(IsPlayerInVehicle(playerid, vid)) {
						SetVehicleToRespawn(vid);
					}
				}
				PlayerRoutePoint[playerid][r] = 0;
			}
			return 1;
		}
	}
	CriandoRota[playerid] = 0;
	return 1;
}

forward OnPlayerEnterCheckpoint@bus(playerid);
public OnPlayerEnterCheckpoint@bus(playerid) {
	if(pInfo[playerid][pCP] == CP_BUS_ROUTE) {
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!bInfo[pInfo[playerid][pBus]][bVehicles][i]) continue;
			new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
			new r;
			while(r < MAX_ROUTES) {
				if(PlayerRoutePoint[playerid][r]) break;
				r++;
			}
			if(r == MAX_ROUTES) return Advert(playerid, "Advirta a administra��o deste bug - [COD 003]");
			if(IsPlayerInVehicle(playerid, vid)) {
				if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "Voc� deve estar conduzindo um dos �nibus da empresa.");
				DisablePlayerCheckpoint(playerid);
				PlayerRoutePoint[playerid][r]++;
				if(PlayerRoutePoint[playerid][r] == BusRoute[pInfo[playerid][pBus]][r][brNum]+1) {
					SendClientMessage(playerid, -1, "Voc� passou por todos os pontos. Agora volte para a esta��o entregar o �nibus e /FinalizarRota.");
					SetPlayerCheckpoint(playerid, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2], 3.0);
				} else if(PlayerRoutePoint[playerid][r] == BusRoute[pInfo[playerid][pBus]][r][brNum]+2) {
					SendClientMessage(playerid, -1, "Use /FinalizarRota.");
					pInfo[playerid][pCP] = 0;
				} else {
					SetPlayerCheckpoint(playerid, BusStops[brCP[pInfo[playerid][pBus]][r][PlayerRoutePoint[playerid][r]-1]][0], BusStops[brCP[pInfo[playerid][pBus]][r][PlayerRoutePoint[playerid][r]-1]][1], BusStops[brCP[pInfo[playerid][pBus]][r][PlayerRoutePoint[playerid][r]-1]][2], 3.0);
				}
				return 1;
			}
		}
		SendClientMessage(playerid, -1, "Voc� deve estar conduzindo um dos �nibus da empresa.");
		return 1;
	}
	return 1;
}

forward OnGameModeInit@bus();
public OnGameModeInit@bus() {
	for(new j = 0; j < MAX_BUSINESS; j++) {
		for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
			for(new k = 0; k < MAX_ROUTES; k++) {
				brCP[j][k][i] = -1;
			}
		}
	}

	mysql_tquery(conn, "SELECT * FROM `busrouteinfo`", "LoadBusRouteInfo");

	return 1;
}

forward LoadBusRouteInfo();
public LoadBusRouteInfo() {
	new row, x, y, str[10];
	cache_get_row_count(row);

	for(new i = 0; i < row; i++) {
		cache_get_value_name_int(i, "sqlbus", x);

		new k = 0;
		for(; k < MAX_BUSINESS; k++) {
			if(bInfo[k][bSQL] == x) break;
		}

		cache_get_value_name_int(i, "numroute", y);
		cache_get_value_name_int(i, "routevalue", BusRoute[k][y][brVal]);
		cache_get_value_name_int(i, "numstops", BusRoute[k][y][brNum]);
		for(new j = 0; j < BusRoute[k][y][brNum]; j++) {
			format(str, 10, "stop%i", j);
			cache_get_value_name_int(i, str, brCP[k][y][j]);
		}
	}
	return 1;
}