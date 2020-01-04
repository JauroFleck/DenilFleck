///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///																																	///
///												MUDE MAX_BOMBAS AO ATUALIZAR														///
///																																	///
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define MAX_BOMBAS		8
new Float:BombasGasMG[MAX_BOMBAS][3] =
	{
		{1385.4600,459.0000,20.7},
		{1383.7800,459.7400,20.7},
		{1381.0200,460.9400,20.7},
		{1379.3400,461.7100,20.7},
		{1378.6400,460.3200,20.7},
		{1380.3200,459.5500,20.7},
		{1383.0800,458.3500,20.7},
		{1384.7600,457.6100,20.7}
	};
new BombaLiberadaMG[MAX_BOMBAS];
new sbBombaMG[MAX_PLAYERS];
new TVerifySBombMG[MAX_PLAYERS];
/*new Float:BombasGasDM[MAX_BOMBAS][3] =
	{
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0},
		{0.0,0.0,0.0}
	};
*/

CMD:liberarbomba(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_GAS) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	new vw = GetPlayerVirtualWorld(playerid); // O VIRTUAL WORLD SERÁ IGUAL AO ID DA EMPRESA (CONSIDERANDO QUE A EMPRESA TEM UM INTERIOR)
	if(vw == pInfo[playerid][pBus] && GetPlayerInterior(playerid)) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, bInfo[vw][bcP][0], bInfo[vw][bcP][1], bInfo[vw][bcP][2])) {
			new bomb, litters;
			if(sscanf(params, "ii", bomb, litters)) return AdvertCMD(playerid, "/LiberarBomba [Número da Bomba] [Quantidade de Litros]");
			if(bomb < 1 || bomb > 8) return AdvertCMD(playerid, "Número de bomba combustível inválido. [1-8]");
			new i = 0;
			while(i < MAX_PRODUTOS) {
				if(!prInfo[vw][i][prSQL]) continue;
				if(!strcmp(prInfo[vw][i][prName], "Gasolina", true)) break;
				i++;
			}
			if(i == MAX_PRODUTOS) return Advert(playerid, "Notifique a administração sobre esse erro. [COD 005]");
			Act(playerid, "bate em algumas teclas do caixa.");
			if(litters > prInfo[vw][i][prQuant]) {
				Amb(bInfo[vw][bcP][0], bInfo[vw][bcP][1], bInfo[vw][bcP][2], "Gasolina insuficiente. (( Caixa ))");
				return 1;
			}
			new money = GetPlayerMoney(playerid), Float:price = (prInfo[vw][i][prPrice]*litters);
			if(money < floatround(price)) {
				Amb(bInfo[vw][bcP][0], bInfo[vw][bcP][1], bInfo[vw][bcP][2], "Dinheiro insuficiente. (( Caixa ))");
				return 1;
			}
			new str[144];
			BombaLiberadaMG[bomb-1] += litters;
			format(str, 144, "Bomba %i: %i litros liberados. (( Caixa ))", bomb, BombaLiberadaMG[bomb-1]);
			Amb(bInfo[vw][bcP][0], bInfo[vw][bcP][1], bInfo[vw][bcP][2], str);
			GivePlayerMoney(playerid, -floatround(price));
		} else { Advert(playerid, "Você deve estar perto do caixa da sua empresa."); }
	} else { // PARA O CASO DE EMPRESAS CUJO CAIXA NÃO FICA EM UM INTERIOR (e.g. Posto de Dillimore)
		Advert(playerid, "Bug? [COD 006]");
	}
	return 1;
}

CMD:bomba(playerid, params[]) {
	new bomb;
	if(sscanf(params, "i", bomb)) return AdvertCMD(playerid, "/Bomba [Número da bomba combustível]");
	if(bomb < 1 || bomb > 8) return Advert(playerid, "Número de bomba combustível inválido. [1-8]");
	if(IsPlayerInRangeOfPoint(playerid, 1.0, BombasGasMG[bomb-1][0], BombasGasMG[bomb-1][1], BombasGasMG[bomb-1][2])) {
		if(!BombaLiberadaMG[bomb-1]) return Advert(playerid, "O bico dessa bomba combustível está preso.");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			if(sbBombaMG[i] == bomb) return Advert(playerid, "O bico dessa bomba já está em mãos de outra pessoa.");
		}
		sbBombaMG[playerid] = bomb;
		new str[144];
		format(str, 144, "sacou o bico da bomba combustível número %i.", bomb);
		Act(playerid, str);
		TVerifySBombMG[playerid] = SetTimerEx("VerifySBombMG", 500, true, "i", playerid);
		return 1;
	// else if(IsPlayerInRangeOfPoint(playerid, 1.0, BombaGasDM[bomb-1][0], BombaGasDM[bomb-1][1], BombaGasDM[bomb-1][2])) { ...
	} else {
		Advert(playerid, "Você deve estar próximo à bomba combustível que deseja sacar o bico.");
	}
	return 1;
}

CMD:abastecer(playerid, params[]) {
	if(!sbBombaMG[playerid]) return Advert(playerid, "Você deve estar segurando o bico da bomba combustível.");
	new vid, litters;
	if(sscanf(params, "ii", vid, litters)) return AdvertCMD(playerid, "/Abastecer [IDV] [Litros de gasolina]");
	new model = GetVehicleModel(vid);
	if(!model) return Advert(playerid, "IDV inválido.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "IDV inválido.");
	if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você precisa ter a chave do veículo em mãos para abrir o tanque de gasolina.");
	if(litters > BombaLiberadaMG[sbBombaMG[playerid]-1]) return Advert(playerid, "Esta bomba tem liberada uma quantia menor de gasolina.");
	if(litters > vGasCap[model-400]-vInfo[vid][vGas]) return Advert(playerid, "Você não pode abastecer uma quantia maior que seu veículo suporta.");
	new Float:P[3];
	GetVehiclePos(vid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo ao veículo que pretende abastecer.");
	KillTimer(TVerifySBombMG[playerid]);
	TVerifySBombMG[playerid] = 0;
	TogglePlayerControllable(playerid, 0);
	SetTimerEx("Abastecer", litters*2250, false, "iii", playerid, vid, litters);
	Act(playerid, "abre o tanque de gasolina do seu veículo e começa a abastecê-lo.");
	return 1;
}

forward Abastecer(playerid, vehicleid, litters);
public Abastecer(playerid, vehicleid, litters) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(!GetVehicleModel(vehicleid)) return 1;
	if(!vInfo[vehicleid][vSQL]) return 1;
	BombaLiberadaMG[sbBombaMG[playerid]-1] -= litters;
	sbBombaMG[playerid] = 0;
	vInfo[vehicleid][vGas] += litters;
	TogglePlayerControllable(playerid, 1);
	Info(playerid, "Tanque abastecido.");
	Act(playerid, "fecha o tanque e gasolina e guarda o bico da bomba combustível.");
	return 1;
}

forward OnGameModeInit@posto();
public OnGameModeInit@posto() {
	new str[10];
	for(new i = 0; i < MAX_BOMBAS; i++) {
		format(str, 10, "Bomba %i", i+1);
		CreateDynamic3DTextLabel(str, -1, BombasGasMG[i][0], BombasGasMG[i][1], BombasGasMG[i][2], 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1);
	}
	return 1;
}

forward VerifySBombMG(playerid);
public VerifySBombMG(playerid) {
	if(!IsPlayerConnected(playerid)) {
		sbBombaMG[playerid] = 0;
		KillTimer(TVerifySBombMG[playerid]);
		TVerifySBombMG[playerid] = 0;
	} else if(!IsPlayerInRangeOfPoint(playerid, 3.5, BombasGasMG[sbBombaMG[playerid]-1][0], BombasGasMG[sbBombaMG[playerid]-1][1], BombasGasMG[sbBombaMG[playerid]-1][2]) || GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) {
		Advert(playerid, "Você se distanciou da bomba combustível e largou o bico.");
		sbBombaMG[playerid] = 0;
		KillTimer(TVerifySBombMG[playerid]);
		TVerifySBombMG[playerid] = 0;
		return 1;
	}
	return 1;
}