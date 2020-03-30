#define MAX_POSTOS			2

new BombaLiberada[16];
new sbBomba[MAX_PLAYERS];
new TVerifySBomb[MAX_PLAYERS];

new PostosID[MAX_POSTOS] =  {
	BUSID_PGMG,
	BUSID_PGDM
};

new Float:BombasGas[MAX_POSTOS][8][3] = {
	{
		{1385.4600,459.0000,20.7},
		{1383.7800,459.7400,20.7},
		{1381.0200,460.9400,20.7},
		{1379.3400,461.7100,20.7},
		{1378.6400,460.3200,20.7},
		{1380.3200,459.5500,20.7},
		{1383.0800,458.3500,20.7},
		{1384.7600,457.6100,20.7}
	}, {
		{656.4305,-571.1978,16.5015},
		{656.4312,-569.6002,16.5015},
		{654.8958,-569.5781,16.5015},
		{654.8962,-571.2374,16.5015},
		{656.4323,-560.5354,16.5015},
		{656.4310,-558.9411,16.5015},
		{654.8954,-558.9395,16.5015},
		{654.8932,-560.6038,16.5015}
	}
};

CMD:liberarbomba(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_GAS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	new vw = GetPlayerVirtualWorld(playerid), j = 0;
	for(; j < MAX_POSTOS; j++) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, bInfo[PostosID[j]][bcP][0], bInfo[PostosID[j]][bcP][1], bInfo[PostosID[j]][bcP][2])) {
			if(vw == PostosID[j] && PostosID[j] != BUSID_PGDM) { break;
			} else if(PostosID[j] == BUSID_PGDM) { break; }
		}
	}
	if(pInfo[playerid][pBus] != PostosID[j]) return Advert(playerid, "Você não trabalha para esse posto de gasolina.");
	if(j < MAX_POSTOS) {
		new bomb, litters;
		if(sscanf(params, "ii", bomb, litters)) return AdvertCMD(playerid, "/LiberarBomba [Número da Bomba] [Quantidade de Litros]");
		if(bomb < 1 || bomb > 8) return AdvertCMD(playerid, "Número de bomba combustível inválido. [1-8]");
		new i = 0;
		for(; i < MAX_PRODUTOS; i++) {
			if(!prInfo[PostosID[j]][i][prSQL]) continue;
			if(!strcmp(prInfo[PostosID[j]][i][prName], "Gasolina", false)) break;
		}
		if(i == MAX_PRODUTOS) return Advert(playerid, "Notifique a administração sobre esse erro. [COD 005]");
		Act(playerid, "bate em algumas teclas do caixa.");
		if(litters > prInfo[PostosID[j]][i][prQuant]) {
			Amb(bInfo[PostosID[j]][bcP][0], bInfo[PostosID[j]][bcP][1], bInfo[PostosID[j]][bcP][2], "Gasolina insuficiente. (( Caixa ))");
			return 1;
		}
		new money = GetPlayerMoney(playerid), Float:price = (prInfo[PostosID[j]][i][prPrice]*litters);
		if(money < floatround(price)) {
			Amb(bInfo[PostosID[j]][bcP][0], bInfo[PostosID[j]][bcP][1], bInfo[PostosID[j]][bcP][2], "Dinheiro insuficiente. (( Caixa ))");
			return 1;
		}
		new str[144], n = (j*8 + bomb - 1);
		BombaLiberada[n] += litters;
		format(str, 144, "Bomba %i: %i litros liberados. (( Caixa ))", bomb, BombaLiberada[n]);
		Amb(bInfo[PostosID[j]][bcP][0], bInfo[PostosID[j]][bcP][1], bInfo[PostosID[j]][bcP][2], str);
		GivePlayerMoney(playerid, -floatround(price));
	}
	return 1;
}

CMD:bomba(playerid, params[]) {
	new bomb;
	if(sscanf(params, "i", bomb)) return AdvertCMD(playerid, "/Bomba [Número da bomba combustível]");
	if(bomb < 1 || bomb > 8) return Advert(playerid, "Número de bomba combustível inválido. [1-8]");
	for(new j = 0; j < MAX_POSTOS; j++) {
		if(IsPlayerInRangeOfPoint(playerid, 1.0, BombasGas[j][bomb-1][0], BombasGas[j][bomb-1][1], BombasGas[j][bomb-1][2])) {
			if(!BombaLiberada[(bomb-1) + (j*8)]) return Advert(playerid, "O bico dessa bomba combustível está preso.");
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(!IsPlayerConnected(i)) continue;
				if(sbBomba[i] == (bomb + j*8)) return Advert(playerid, "O bico dessa bomba já está em mãos de outra pessoa.");
			}
			sbBomba[playerid] = (bomb + j*8);
			new str[144];
			format(str, 144, "sacou o bico da bomba combustível número %i.", bomb);
			Act(playerid, str);
			TVerifySBomb[playerid] = SetTimerEx("VerifySBomb", 500, true, "i", playerid);
			return 1;
		} else {
			Advert(playerid, "Você deve estar próximo à bomba combustível que deseja sacar o bico.");
		}
	}
	return 1;
}

CMD:abastecer(playerid, params[]) {
	if(!sbBomba[playerid]) return Advert(playerid, "Você deve estar segurando o bico da bomba combustível.");
	for(new i = 0; i < MAX_POSTOS; i++) {
		new vid, litters;
		if(sscanf(params, "ii", vid, litters)) return AdvertCMD(playerid, "/Abastecer [IDV] [Litros de gasolina]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "IDV inválido.");
		new model = GetVehicleModel(vid);
		if(!vInfo[vid][vSQL]) return Advert(playerid, "IDV inválido.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você precisa ter a chave do veículo em mãos para abrir o tanque de gasolina.");
		if(litters > BombaLiberada[sbBomba[playerid]-1]) return Advert(playerid, "Esta bomba tem liberada uma quantia menor de gasolina.");
		if(litters > vGasCap[model-400]-vInfo[vid][vGas]) return Advert(playerid, "Você não pode abastecer uma quantia maior que seu veículo suporta.");
		new Float:P[3];
		GetVehiclePos(vid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(playerid, 3.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo ao veículo que pretende abastecer.");
		KillTimer(TVerifySBomb[playerid]);
		TVerifySBomb[playerid] = 0;
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("Abastecer", litters*2250, false, "iii", playerid, vid, litters);
		Act(playerid, "abre o tanque de gasolina do seu veículo e começa a abastecê-lo.");
	}
	return 1;
}

forward Abastecer(playerid, vehicleid, litters);
public Abastecer(playerid, vehicleid, litters) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(!GetVehicleModel(vehicleid)) return 1;
	if(!vInfo[vehicleid][vSQL]) return 1;
	BombaLiberada[sbBomba[playerid]-1] -= litters;
	vInfo[vehicleid][vGas] += litters;
	new i = 0, query[150];
	if(sbBomba[playerid] <= 8) {
		while(i < MAX_PRODUTOS) {
			if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
			if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) break;
			i++;
		}
		prInfo[BUSID_PGMG][i][prQuant] -= litters;
		mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_PGMG][i][prQuant], prInfo[BUSID_PGMG][i][prSQL]);
	} else if(sbBomba[playerid] <= 16) {
		while(i < MAX_PRODUTOS) {
			if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
			if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) break;
			i++;
		}
		prInfo[BUSID_PGDM][i][prQuant] -= litters;
		mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_PGDM][i][prQuant], prInfo[BUSID_PGDM][i][prSQL]);
	}
	mysql_query(conn, query, false);
	TogglePlayerControllable(playerid, 1);
	Info(playerid, "Tanque abastecido.");
	Act(playerid, "fecha o tanque e gasolina e guarda o bico da bomba combustível.");
	sbBomba[playerid] = 0;
	return 1;
}

forward OnPlayerConnect@posto(playerid);
public OnPlayerConnect@posto(playerid) {
	// Montgomery
	RemoveBuildingForPlayer(playerid, 1370, 1373.4531, 469.9688, 19.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, 1373.1719, 471.1016, 19.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1448, 1357.7188, 481.7031, 19.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 1370, 1358.4844, 483.6563, 19.6953, 0.25);
	RemoveBuildingForPlayer(playerid, 1450, 1355.8516, 483.3906, 19.7734, 0.25);
	RemoveBuildingForPlayer(playerid, 1358, 1356.3750, 485.1875, 20.3750, 0.25);
	// Dillimore
	RemoveBuildingForPlayer(playerid, 12854, 666.4922, -571.1797, 17.3125, 0.25);
	RemoveBuildingForPlayer(playerid, 1510, 664.2031, -567.6953, 16.2266, 0.25);
	RemoveBuildingForPlayer(playerid, 1512, 664.2109, -567.4141, 16.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 1514, 665.2891, -567.2813, 16.4297, 0.25);
	RemoveBuildingForPlayer(playerid, 956, 662.4297, -552.1641, 15.7109, 0.25);
	return 1;
}

forward OnGameModeInit@posto();
public OnGameModeInit@posto() {
	new str[10];
	for(new j = 0; j < MAX_POSTOS; j++) {
		for(new i = 0; i < 8; i++) {
			format(str, 10, "Bomba %i", i+1);
			CreateDynamic3DTextLabel(str, -1, BombasGas[j][i][0], BombasGas[j][i][1], BombasGas[j][i][2], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
		}
	}
	return 1;
}

forward VerifySBomb(playerid);
public VerifySBomb(playerid) {
	if(!IsPlayerConnected(playerid)) {
		sbBomba[playerid] = 0;
		KillTimer(TVerifySBomb[playerid]);
		TVerifySBomb[playerid] = 0;
	} else if(sbBomba[playerid] <= 8) {
		if(!IsPlayerInRangeOfPoint(playerid, 3.5, BombasGas[0][sbBomba[playerid]-1][0], BombasGas[0][sbBomba[playerid]-1][1], BombasGas[0][sbBomba[playerid]-1][2]) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
			Advert(playerid, "Você se distanciou da bomba combustível e largou o bico.");
			sbBomba[playerid] = 0;
			KillTimer(TVerifySBomb[playerid]);
			TVerifySBomb[playerid] = 0;
			return 1;
		}
	} else if(sbBomba[playerid] <= 16) {
		if(!IsPlayerInRangeOfPoint(playerid, 3.5, BombasGas[1][sbBomba[playerid]-9][0], BombasGas[1][sbBomba[playerid]-9][1], BombasGas[1][sbBomba[playerid]-9][2]) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
			Advert(playerid, "Você se distanciou da bomba combustível e largou o bico.");
			sbBomba[playerid] = 0;
			KillTimer(TVerifySBomb[playerid]);
			TVerifySBomb[playerid] = 0;
			return 1;
		}
	}
	return 1;
}