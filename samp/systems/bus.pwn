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

enum PROUTE_INFO {
	proutePoint,
	prouteVehicle
	//proutePartner
};

new PortaoBusBB;
new brCP[MAX_BUSINESS][MAX_ROUTES][MAX_ROUTE_STOPS];
new BusRoute[MAX_BUSINESS][MAX_ROUTES][ROUTE_INFO];
new curPoint[MAX_BUSINESS];
new pRoute[MAX_PLAYERS][MAX_ROUTES][PROUTE_INFO];
new CriandoRota[MAX_PLAYERS];

CMD:iniciarrota(playerid, params[]) { // Definir quais cargos são permitidos a utilizar este comando.
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um dos ônibus da empresa.");
	for(new i = 0; i < MAX_ROUTES; i++) {
		if(pRoute[playerid][i][proutePoint]) return Advert(playerid, "Você já iniciou a rota. Cancele ou finalize ela. /CancelarRota | /FinalizarRota.");
	}
	new r;
	if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/IniciarRota [1-3]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/IniciarRota [1-3]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return Advert(playerid, "Essa rota não foi definida ainda.");
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][i]) continue;
		new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
		if(IsPlayerInVehicle(playerid, vid)) {
			if(!IsVehicleInRangeOfPoint(vid, 15.0, 321.1762,-24.1846,1.5781)) return SendClientMessage(playerid, -1, "Você deve estar na Estação de Ônibus de Blueberry.");
			Success(playerid, "Rota iniciada. Siga os checkpoints marcados no mapa e pare nos pontos de ônibus para os passageiros subirem e descerem.");
			pRoute[playerid][r-1][proutePoint] = 1;
			//pRoute[playerid][r-1][proutePartner] = id;
			pRoute[playerid][r-1][prouteVehicle] = vid;
			pInfo[playerid][pCP] = CP_BUS_ROUTE;
			SetPlayerCheckpoint(playerid, BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][0], BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][1], BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][2], 3.0);
			return 1;
		}
	}
	Advert(playerid, "Você deve estar conduzindo um dos ônibus da empresa.");
	return 1;
}

CMD:finalizarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return SendClientMessage(playerid, -1, "Sua empresa não tem permissão para uso desse comando.");
	new r;
	for(; r < MAX_ROUTES; r++) {
		if(pRoute[playerid][r][proutePoint]) break;
	}
	if(r == MAX_ROUTES) return Advert(playerid, "Você não iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
	if(pRoute[playerid][r][proutePoint] < BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Você ainda não passou por todos os pontos obrigatórios da rota.");
	new j = 0;
	for(; j < MAX_BUSINESS_VEHICLES; j++) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
		if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
	}
	if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Você deve estar conduzindo um ônibus da empresa.");
	new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
	if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Você deve estar no estacionamento deste ônibus.");

	GivePlayerMoney(playerid, BusRoute[pInfo[playerid][pBus]][r][brVal]*BusRoute[pInfo[playerid][pBus]][r][brNum]);
	//GivePlayerMoney(pRoute[playerid][r][proutePartner]-1, floatround(0.8*BusRoute[pInfo[playerid][pBus]][r][brVal]));

	new str[144];
	Success(playerid, "Rota finalizada com sucesso.");
	//Success(pRoute[playerid][r][proutePartner]-1, "Rota finalizada com sucesso.");
	format(str, 144, "Você foi pago em $%i pela rota.", BusRoute[pInfo[playerid][pBus]][r][brVal]*BusRoute[pInfo[playerid][pBus]][r][brNum]);
	Success(playerid, str);
	//format(str, 144, "Você foi pago em $%i pela rota.", floatround(0.8*BusRoute[pInfo[playerid][pBus]][r][brVal]));
	//Success(pRoute[playerid][r][proutePartner]-1, str);
	pRoute[playerid][r][proutePoint] = 0;
	//pRoute[playerid][r][proutePartner] = 0;
	pRoute[playerid][r][prouteVehicle] = 0;
	bInfo[BUSID_BUSBB][bReceita] += ((16-BusRoute[pInfo[playerid][pBus]][r][brVal])*BusRoute[pInfo[playerid][pBus]][r][brNum]);
	return 1;
}

CMD:cancelarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return SendClientMessage(playerid, -1, "Sua empresa não tem permissão para uso desse comando.");
	new r;
	for(; r < MAX_ROUTES; r++) {
		if(pRoute[playerid][r][proutePoint]) break;
	}
	if(r == MAX_ROUTES) return Advert(playerid, "Você não iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
	if(pRoute[playerid][r][proutePoint] == BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Você já passou por todos os pontos obrigatórios da rota. Use "AMARELO"/FinalizarRota"BRANCO".");
	new j = 0;
	for(; j < MAX_BUSINESS_VEHICLES; j++) {
		if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
		if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
	}
	if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Você deve estar conduzindo um ônibus da empresa.");
	new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
	if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Você deve estar no estacionamento deste ônibus.");
	Info(playerid, "Rota cancelada.");
	pInfo[playerid][pCP] = 0;
	DisablePlayerCheckpoint(playerid);
	pRoute[playerid][r][proutePoint] = 0;
	return 1;
}

CMD:criarrota(playerid, params[]) {
	if(strcmp(bInfo[BUSID_BUSBB][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new n, r;
	if(sscanf(params, "ii", r, n)) return AdvertCMD(playerid, "/CriarRota [Número da Rota] [Número de Paradas]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/CriarRota [1-3] [Número de Paradas]");
	if(BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "Esta rota já existe. Use /ExcluirRota antes de criar outra.");
	if(n < 4 || n > MAX_ROUTE_STOPS) return AdvertCMD(playerid, "/CriarRota [1-3] [4-18]");
	curPoint[pInfo[playerid][pBus]] = 0;
	BusRoute[pInfo[playerid][pBus]][r-1][brNum] = n;
	CriandoRota[playerid] = r-1;
	Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, "1° Ponto", "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Prosseguir", "Cancelar");
	return 1;
}

CMD:valorrota(playerid, params[]) {
	if(strcmp(bInfo[BUSID_BUSBB][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new value, r;
	if(sscanf(params, "ii", r, value)) return AdvertCMD(playerid, "/ValorRota [Número da Rota] [Valor por ponto]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/ValorRota [1-3] [Valor por ponto]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "Essa rota não está criada. Para criá-la, use /CriarRota [Número da Rota] [Número de Paradas].");
	if(value < 1 || value > 16) return SendClientMessage(playerid, -1, "Valor inválido (1-16).");
	new str[144];
	format(str, 144, "Valor da rota atribuído para $%i por ponto (total: $%i)", value, value*BusRoute[pInfo[playerid][pBus]][r-1][brNum]);
	Info(playerid, str);
	BusRoute[pInfo[playerid][pBus]][r-1][brVal] = BusRoute[pInfo[playerid][pBus]][r-1][brNum]*value;

	new query[150];
	mysql_format(conn, query, 150, "UPDATE `busrouteinfo` SET `routevalue` = %i WHERE `sqlbus` = %i AND `numroute` = %i", value*BusRoute[pInfo[playerid][pBus]][r-1][brNum], bInfo[pInfo[playerid][pBus]][bSQL], r-1);
	mysql_query(conn, query, false);
	return 1;
}

CMD:excluirrota(playerid, params[]) {
	if(strcmp(bInfo[BUSID_BUSBB][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new r;
	if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/ExcluirRota [Número da Rota]");
	if(r < 1 || r > 3) return AdvertCMD(playerid, "/ExcluirRota [1-3]");
	if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return SendClientMessage(playerid, -1, "Não há rota para excluir. Para criar uma, use /CriarRota [Número de Paradas].");
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pRoute[i][r-1][proutePoint]) return Advert(playerid, "Você não pode excluir uma rota enquanto houver um funcionário executando ela.");
	}
	for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
		brCP[pInfo[playerid][pBus]][r-1][i] = -1;
	}
	BusRoute[pInfo[playerid][pBus]][r-1][brNum] = 0;
	BusRoute[pInfo[playerid][pBus]][r-1][brVal] = 0;
	Success(playerid, "Rota excluída com sucesso.");

	new query[150];
	mysql_format(conn, query, 150, "DELETE FROM `busrouteinfo` WHERE `sqlbus` = %i AND `numroute` = %i", bInfo[pInfo[playerid][pBus]][bSQL], r-1);
	mysql_query(conn, query, false);

	return 1;
}

/*	Cobrador
	CMD:cobrarticket(playerid, params[]) {
		if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
		if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
		new id;
		if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/CobrarTicket [ID]");
		if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
		for(new j = 0; j < MAX_ROUTES; j++) {
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(pRoute[i][j][proutePartner] == playerid+1) {
					if(GetPlayerVehicleID(id) != pRoute[i][j][prouteVehicle]) return Advert(playerid, "A pessoa a ser cobrada deve entrar no ônibus primeiro.");
					new k = 0;
					for(; k < MAX_PRODUTOS; k++) {
						if(!strcmp(prInfo[pInfo[playerid][pBus]][k][prName], "Ticket", true) && !isnull(prInfo[pInfo[playerid][pBus]][k][prName])) break;
					}
					new str[144];
					format(str, 144, "O cobrador %s está exigindo "VERDEMONEY"$%.2f"BRANCO" pelo preço do ticket.", pName(playerid), prInfo[pInfo[playerid][pBus]][k][prPrice]);
					Info(id, str);
					format(str, 144, "Use "AMARELO"/Pagar %i %i"BRANCO" para pagar.", playerid, floatround(prInfo[pInfo[playerid][pBus]][k][prPrice]));
					Info(id, str);
					format(str, 144, "cobra o preço do ticket de passagem para %s.", pName(id));
					Act(playerid, str);
					return 1;
				}
			}
		}
		Advert(playerid, "Você não faz parte de nenhuma rota.");
		return 1;
	}

	CMD:expulsar(playerid, params[]) {
		if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
		if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
		new id;
		if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Expulsar [ID]");
		if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
		for(new j = 0; j < MAX_ROUTES; j++) {
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(pRoute[i][j][proutePartner] == playerid+1) {
					if(GetPlayerVehicleID(i) != pRoute[i][j][prouteVehicle]) return Advert(playerid, "Você só consegue expulsar alguém do ônibus com ajuda do motorista.");
					if(GetPlayerVehicleID(id) != pRoute[i][j][prouteVehicle]) return Advert(playerid, "A pessoa a ser cobrada deve estar dentro do ônibus.");
					if(id == i) return Advert(playerid, "Você não pode expulsar o motorista.");
					new str[144];
					RemovePlayerFromVehicle(id);
					format(str, 144, "com ajuda do motorista expulsou %s do ônibus.", pName(id));
					Act(playerid, str);
					return 1;
				}
			}
		}
		Advert(playerid, "Você não faz parte de nenhuma rota.");
		return 1;
	}

	CMD:depositarcaixa(playerid, params[]) {
		if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
		if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BUS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
		new mon;
		if(sscanf(params, "i", mon)) return AdvertCMD(playerid, "/DepositarCaixa [Quantia]");
		if(mon > GetPlayerMoney(playerid)) return Advert(playerid, "Não é possível depositar algo além do que se tem em mãos.");
		if(mon < 1) return Advert(playerid, "Quantia inválida.");
		GivePlayerMoney(playerid, -mon);
		bInfo[pInfo[playerid][pBus]][bCaixa] += mon;
		new str[144];
		format(str, 144, "depositou "VERDEMONEY"$%i"CINZAAZULADO" no caixa.", mon);
		Act(playerid, str);
		format(str, 20, "~r~-$%i", mon);
		GameTextForPlayer(playerid, str, 1000, 1);
		return 1;
	}
*/

Dialog:RouteCreation(playerid, response, listitem, inputtext[]) {
	if(!response) {
		for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
			brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][i] = -1;
		}
		BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] = 0;
		Info(playerid, "Seleção de pontos zerada e cancelada.");
		CriandoRota[playerid] = 0;
	} else {
		for(new i = 0; i < MAX_ROUTE_STOPS; i++) {
			if(brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][i] == listitem) {
				for(new j = 0; j < MAX_ROUTE_STOPS; j++) {
					brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][j] = -1;
				}
				BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] = 0;
				Info(playerid, "Você não pode repetir o mesmo ponto em uma mesma rota.");
				Info(playerid, "Seleção de pontos zerada e cancelada.");
				CriandoRota[playerid] = 0;
				return 1;
			}
		}
		brCP[pInfo[playerid][pBus]][CriandoRota[playerid]][curPoint[pInfo[playerid][pBus]]] = listitem;
		curPoint[pInfo[playerid][pBus]]++;
		if(curPoint[pInfo[playerid][pBus]] == BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum] - 1) {
			Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, "Último Ponto", "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Finalizar", "Cancelar");
		} else if(curPoint[pInfo[playerid][pBus]] == BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]) {
			curPoint[pInfo[playerid][pBus]] = 0;
			new str[144];
			format(str, 144, "Todos os %i pontos da rota foram definidos com sucesso.", BusRoute[pInfo[playerid][pBus]][CriandoRota[playerid]][brNum]);
			Success(playerid, str);

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
			format(str, 15, "%i° Ponto", curPoint[pInfo[playerid][pBus]]+1);
			Dialog_Show(playerid, RouteCreation, DIALOG_STYLE_LIST, str, "BB-1\nBB-2\nMG-1\nMG-2\nMG-3\nMG-4\nMG-5\nMG-6\nPC-1\nPC-2\nPC-3\nPC-4\nPC-5\nPC-6\nDM-1\nDM-2\nDM-3\nDM-4", "Prosseguir", "Cancelar");
		}
	}
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

	RemoveBuildingForPlayer(playerid, 13063, 321.8516, -34.5234, 4.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1294, 329.7813, -64.8047, 5.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1468, 307.8984, -59.1484, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1468, 307.8984, -53.8281, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1468, 307.8984, -48.5000, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1468, 307.8984, -43.1797, 3.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 308.7891, -54.6875, 1.0625, 0.25);
	RemoveBuildingForPlayer(playerid, 1684, 317.6953, -42.2344, 2.0156, 0.25);
	RemoveBuildingForPlayer(playerid, 13436, 252.3281, -28.8906, 9.1094, 0.25);
	RemoveBuildingForPlayer(playerid, 705, 294.4453, -0.8516, 1.3438, 0.25);
	RemoveBuildingForPlayer(playerid, 13061, 321.8516, -34.5234, 4.8984, 0.25);
	return 1;
}

forward OnPlayerDisconnect@bus(playerid);
public OnPlayerDisconnect@bus(playerid) {
	for(new r = 0; r < MAX_ROUTES; r++) {
		if(pRoute[playerid][r][proutePoint]) {
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(!IsPlayerConnected(i)) continue;
				if(GetPlayerVehicleID(i) == pRoute[playerid][r][prouteVehicle]) {
					Info(i, "O motorista da rota foi desconectado. Espero um momento até ele reconectar ou façam um RP alternativo.");
					//if(i != pRoute[playerid][r][proutePartner]-1) {
					Info(i, "Foi devolvido também o valor do ticket de passagem para você.");
					new k = 0, str[20];
					for(; k < MAX_PRODUTOS; k++) {
						if(!strcmp(prInfo[pInfo[playerid][pBus]][k][prName], "Ticket", true) && !isnull(prInfo[pInfo[playerid][pBus]][k][prName])) break;
					}
					GivePlayerMoney(i, floatround(prInfo[pInfo[playerid][pBus]][k][prPrice]));
					format(str, 20, "~g~+$%i", floatround(prInfo[pInfo[playerid][pBus]][k][prPrice]));
					GameTextForPlayer(i, str, 1000, 1);
					//}
				}
			}
			/*if(IsPlayerConnected(pRoute[playerid][r][proutePartner]-1)) {
				new Float:P[3];
				GetVehiclePos(pRoute[playerid][r][prouteVehicle], P[0], P[1], P[2]);
				Info(pRoute[playerid][r][proutePartner]-1, "Se você tiver carteira de motorista, é aconselhável que leve o ônibus de volta para a estação cancelar a rota.");
				vInfo[pRoute[playerid][r][prouteVehicle]][vChave] = pInfo[pRoute[playerid][r][proutePartner]-1][pSQL];
				Amb(P[0], P[1], P[2], "Foi entregue a chave do ônibus para o cobrador da rota.");
				pRoute[pRoute[playerid][r][proutePartner]-1][r][proutePoint] = pRoute[playerid][r][proutePoint];
				pRoute[pRoute[playerid][r][proutePartner]-1][r][proutePartner] = 0;
				pRoute[pRoute[playerid][r][proutePartner]-1][r][prouteVehicle] = pRoute[playerid][r][prouteVehicle];
				pRoute[playerid][r][proutePoint] = 0;
				pRoute[playerid][r][proutePartner] = 0;
				pRoute[playerid][r][prouteVehicle] = 0;
			} else {*/
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(!IsPlayerConnected(i)) continue;
				if(GetPlayerVehicleID(i) == pRoute[playerid][r][prouteVehicle]) {
					Info(i, "Como o cobrador da rota não tem disponibilidade para conduzir um ônibus, o veículo foi enviado para o respawn.");
				}
			}
			SetVehicleToRespawn(pRoute[playerid][r][prouteVehicle]);
			pRoute[playerid][r][proutePoint] = 0;
			pRoute[playerid][r][prouteVehicle] = 0;
			//pRoute[playerid][r][proutePartner] = 0;
			//}
			break;
		}
		/*for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pRoute[i][r][proutePartner] == playerid+1) {
				Info(i, "O cobrador da rota foi desconectado. Volte para a estação de ônibus cancelar a rota.");
				pRoute[i][r][proutePartner] = 0;
				break;
			}
		}*/
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
			for(; r < MAX_ROUTES; r++) {
				if(pRoute[playerid][r][proutePoint]) break;
			}
			if(r == MAX_ROUTES) return Advert(playerid, "Advirta a administração dessa mensagem - [COD 003]");
			if(IsPlayerInVehicle(playerid, vid)) {
				//if(!pRoute[playerid][r][proutePartner]) return Advert(playerid, "Você deve voltar para a estação cancelar a rota pois está sem cobrador.");
				if(!IsPlayerInVehicle(playerid, pRoute[playerid][r][prouteVehicle])) return Advert(playerid, "Você deve estar no ônibus em que iniciou a rota.");
				//if(!IsPlayerInVehicle(pRoute[playerid][r][proutePartner]-1, pRoute[playerid][r][prouteVehicle])) return Advert(playerid, "O cobrador deve estar contigo para continuar a rota.");
				if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid, -1, "Você deve estar conduzindo um dos ônibus da empresa.");
				DisablePlayerCheckpoint(playerid);
				pRoute[playerid][r][proutePoint]++;
				if(pRoute[playerid][r][proutePoint] == BusRoute[pInfo[playerid][pBus]][r][brNum]+1) {
					SendClientMessage(playerid, -1, "Você passou por todos os pontos. Agora volte para a estação entregar o ônibus e /FinalizarRota.");
					SetPlayerCheckpoint(playerid, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2], 3.0);
				} else if(pRoute[playerid][r][proutePoint] == BusRoute[pInfo[playerid][pBus]][r][brNum]+2) {
					SendClientMessage(playerid, -1, "Use /FinalizarRota.");
					pInfo[playerid][pCP] = 0;
				} else {
					SetPlayerCheckpoint(playerid, BusStops[brCP[pInfo[playerid][pBus]][r][pRoute[playerid][r][proutePoint]-1]][0], BusStops[brCP[pInfo[playerid][pBus]][r][pRoute[playerid][r][proutePoint]-1]][1], BusStops[brCP[pInfo[playerid][pBus]][r][pRoute[playerid][r][proutePoint]-1]][2], 3.0);
				}
				return 1;
			}
		}
		SendClientMessage(playerid, -1, "Você deve estar conduzindo um dos ônibus da empresa.");
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