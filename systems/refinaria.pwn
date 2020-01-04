#define TANK_CAPACITY		500000
#define CARGA_CAPACITY		40000
#define TAXA_REFINARIA		135

new PortaoRefinaria;
new TankQt[4];
new Engate[4];
new TVerifyEngate[4];
new TAttCarga[4];
new QtAttCarga[4];
new TaxaRefinaria = TAXA_REFINARIA;

CMD:portao(playerid) {
	static usecmd;
	if(gettime() < usecmd) return 1;
	if(PortaoRefinaria > 0) {
		usecmd = gettime() + (MoveDynamicObject(PortaoRefinaria, -1022.0464, -589.1002, 33.7811, 2.0, 0.0000, 0.0000, -1.6200)/1000) + 1;
		PortaoRefinaria *= -1;
	} else {
		PortaoRefinaria *= -1;
		usecmd = gettime() + (MoveDynamicObject(PortaoRefinaria, -1033.3864, -588.7602, 33.7811, 2.0, 0.0000, 0.0000, -3.0400)/1000) + 1;
	}
	return 1;
}

CMD:engatar(playerid, params[]) {
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-639.9603,35.4306)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-662.9603,35.4306)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-685.9603,35.4306)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-708.9603,35.4306)) { pPanel = 4; }
	else return Advert(playerid, "Você deve estar próximo ao engatador da refinaria.");
	if(Engate[pPanel-1]) return Advert(playerid, "Essa carga já está engatada. Se quiser desengatar, use "AMARELO"/Desengatar"BRANCO".");
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/Engatar [IDV da carga]");
	if(GetVehicleModel(vid) != 584) return Advert(playerid, "Você deve engatar uma carga que suporte o armazenamento de gasolina.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Esse veículo não está registrado no banco de dados.");
	new Float:A;
	GetVehicleZAngle(vid, A);
	if(A > 100 || A < 80) return Advert(playerid, "Essa carga não está devidamente posicionada.");
	if(pPanel == 1) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-639.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 2) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-662.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 3) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-685.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 4) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-708.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	Engate[pPanel-1] = vid;
	Act(playerid, "engata o cano do tanque na carga de gasolina.");
	TVerifyEngate[pPanel-1] = SetTimerEx("VerifyEngate", 1000, true, "ii", vid, pPanel);
	//PlayerPlaySound
	return 1;
}

CMD:desengatar(playerid) {
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-639.9603,35.4306)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-662.9603,35.4306)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-685.9603,35.4306)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-708.9603,35.4306)) { pPanel = 4; }
	else return Advert(playerid, "Você deve estar próximo ao engatador da refinaria.");
	if(!Engate[pPanel-1]) return Advert(playerid, "Essa carga não está engatada. Se quiser engatar, use "AMARELO"/Engatar"BRANCO".");
	Engate[pPanel-1] = 0;
	Act(playerid, "desengata o cano do tanque na carga de gasolina.");
	//PlayerPlaySound
	return 1;
}

forward VerifyEngate(vehicleid, panelid);
public VerifyEngate(vehicleid, panelid) {
	if(!IsValidVehicle(vehicleid)) {
		KillTimer(TVerifyEngate[panelid-1]);
		TVerifyEngate[panelid-1] = 0;
		return 1;
	}
	new Float:A;
	GetVehicleZAngle(vehicleid, A);
	if(A > 100.0 || A < 80.0)  { Engate[panelid-1] = 0; }
	else if(panelid == 1) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-639.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 2) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-662.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 3) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-685.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 4) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-708.9285,33.1292)) { Engate[panelid-1] = 0; } }
	if(!Engate[panelid-1]) {
		KillTimer(TVerifyEngate[panelid-1]);
		TVerifyEngate[panelid-1] = 0;
	}
	return 1;
}

CMD:subir(playerid) {
	new i = 0, Float:P[4];
	for(; i < MAX_VEHICLES; i++) {
		if(GetVehicleModel(i) != 584) continue;
		GetVehiclePos(i, P[0], P[1], P[2]);
		GetVehicleZAngle(i, P[3]);
		GetXYInFrontOfXY(P[0], P[1], 2.0, (P[3]-49.2876), P[0], P[1]);
		P[2] -= 1.1509;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, P[0], P[1], P[2])) { break; }
	}
	if(i == MAX_VEHICLES) return Advert(playerid, "Você deve estar próximo à escada de uma carga.");
	GetVehiclePos(i, P[0], P[1], P[2]);
	P[2] += 1.7;
	GetVehicleZAngle(i, P[3]);
	GetXYInFrontOfXY(P[0], P[1], 1.0, (P[3]-49.2876), P[0], P[1]);
	SetPlayerPos(playerid, P[0], P[1], P[2]);
	return 1;
}

CMD:painel(playerid) {
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-630.8459,44.8990)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-653.8459,44.8990)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-676.8459,44.8990)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-699.8459,44.8990)) { pPanel = 4; }
	else return Advert(playerid, "Você deve estar próximo a um painel da refinaria.");
	new str[350];
	format(str, 350, "\tSTATUS TANQUE:\n\nQTD LT: %iL\nCAP LT: %iL\n\n\tSTATUS CARGA:\n\n", TankQt[pPanel-1], TANK_CAPACITY);
	if(!Engate[pPanel-1]) {
		format(str, 350, "%s"VERMELHO"Carga não engatada.", str);
		Dialog_Show(playerid, "Painel", DIALOG_STYLE_MSGBOX, "PAINEL", str, "", "Fechar");
	} else {
		format(str, 350, "%sQTD LT: %iL\nCAP LT:%iL", str, vInfo[Engate[pPanel-1]][vCargaGas], CARGA_CAPACITY);
		Dialog_Show(playerid, "Painel", DIALOG_STYLE_MSGBOX, "PAINEL", str, "Configurar", "Fechar");
	}
	return 1;
}

CMD:encherrapido(playerid) {
	if(TaxaRefinaria == 400) {
		TaxaRefinaria = TAXA_REFINARIA;
		Info(playerid, "Lento.");
	} else {
		TaxaRefinaria = 400;
		Info(playerid, "Rápido.");
	}
	return 1;
}

Dialog:Painel(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_REF) return Advert(playerid, "É necessário um cartão de identificação da refinaria para manipular o painel.");
	new str[350];
	format(str, 350, "Coloque abaixo a quantidade de gasolina que deseja retirar ou colocar dentro da carga.\nNote que para definir se vai encher ou esvaziar deve-se clicar no botão correto.");
	Dialog_Show(playerid, "ConfigPainel", DIALOG_STYLE_INPUT, "CONFIGURAR", str, "Encher", "Esvaziar");
	return 1;
}

Dialog:ConfigPainel(playerid, response, listitem, inputtext[]) {
	new qt = strval(inputtext);
	if(qt < 1) return Advert(playerid, "Configuração cancelada.");
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-630.8459,44.8990)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-653.8459,44.8990)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-676.8459,44.8990)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-699.8459,44.8990)) { pPanel = 4; }
	if(!pPanel) return Advert(playerid, "Você deve estar próximo ao painel que deseja configurar.");
	if(!Engate[pPanel-1]) return Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "A carga não está mais engatada. (( Painel ))");
	if(response) {
		if(vInfo[Engate[pPanel-1]][vCargaGas] + qt > CARGA_CAPACITY) return Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Quantia além da capacidade da carga. (( Painel ))");
		if(qt > TankQt[pPanel-1]) return Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Baixo nível de combustível no tanque. (( Painel ))");
		TAttCarga[pPanel-1] = SetTimerEx("AttCarga", 1000, true, "ii", pPanel-1);
		QtAttCarga[pPanel-1] = qt;
		Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Enchendo carga. (( Painel ))");
	} else {
		if(vInfo[Engate[pPanel-1]][vCargaGas] < qt) return Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Baixo nível de combustível na carga. (( Painel ))");
		if(qt + TankQt[pPanel-1] > TANK_CAPACITY) return Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Quantia além da capacidade do tanque. (( Painel ))");
		TAttCarga[pPanel-1] = SetTimerEx("AttCarga", 1000, true, "ii", pPanel-1);
		QtAttCarga[pPanel-1] = -qt;
		Amb(-981.2379, (-630.8459 - (pPanel-1)*23.0), 44.8990, "Esvaziando carga. (( Painel ))");
	}
	return 1;
}

forward AttCarga(panelid);
public AttCarga(panelid) {
	if(!Engate[panelid]) {
		Amb(-981.2379, (-630.8459 - (panelid)*23.0), 44.8990, "A carga não está mais engatada. (( Painel ))");
		QtAttCarga[panelid] = 0;
		KillTimer(TAttCarga[panelid]);
		TAttCarga[panelid] = 0;
		return 1;
	}
	if(QtAttCarga[panelid] > 0) {
		if(QtAttCarga[panelid] <= TaxaRefinaria) {
			vInfo[Engate[panelid]][vCargaGas] += QtAttCarga[panelid];
			TankQt[panelid] -= QtAttCarga[panelid];
			QtAttCarga[panelid] = 0;
			KillTimer(TAttCarga[panelid]);
			TAttCarga[panelid] = 0;
			Amb(-981.2379, (-630.8459 - (panelid)*23.0), 44.8990, "Enchimento da carga completo. (( Painel ))");
			return 1;
		}
		QtAttCarga[panelid] -= TaxaRefinaria;
		vInfo[Engate[panelid]][vCargaGas] += TaxaRefinaria;
		TankQt[panelid] -= TaxaRefinaria;
	} else if(QtAttCarga[panelid] < 0) {
		QtAttCarga[panelid] *= -1;
		if(QtAttCarga[panelid] <= TaxaRefinaria) {
			vInfo[Engate[panelid]][vCargaGas] -= QtAttCarga[panelid];
			TankQt[panelid] += QtAttCarga[panelid];
			QtAttCarga[panelid] = 0;
			KillTimer(TAttCarga[panelid]);
			TAttCarga[panelid] = 0;
			Amb(-981.2379, (-630.8459 - (panelid)*23.0), 44.8990, "Esvaziamento da carga completo. (( Painel ))");
			return 1;
		}
		QtAttCarga[panelid] -= TaxaRefinaria;
		vInfo[Engate[panelid]][vCargaGas] -= TaxaRefinaria;
		TankQt[panelid] += TaxaRefinaria;
		QtAttCarga[panelid] *= -1;
	}
	return 1;
}

forward OnPlayerConnect@refinaria(playerid);
public OnPlayerConnect@refinaria(playerid) {
	RemoveBuildingForPlayer(playerid, 3682, -1029.3438, -702.8125, 54.8516, 0.25);
	RemoveBuildingForPlayer(playerid, 17339, -1041.6641, -728.3359, 44.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 17340, -1072.8281, -620.6328, 40.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 17341, -1083.4766, -687.9453, 31.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 17342, -1107.0703, -620.8906, 40.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 17343, -1055.5313, -617.6094, 82.6094, 0.25);
	RemoveBuildingForPlayer(playerid, 17344, -1056.0469, -632.4141, 82.7891, 0.25);
	RemoveBuildingForPlayer(playerid, 17345, -1026.7500, -705.1719, 82.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 17346, -1014.3594, -703.8828, 83.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 17347, -1055.1094, -603.5703, 61.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 17348, -1004.2969, -704.1484, 63.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1124.1797, -682.5625, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1124.1797, -706.7500, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1124.1797, -658.3750, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1124.1797, -634.1953, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1114.4531, -595.7969, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 17013, -1107.0703, -620.8906, 40.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1107.3906, -595.8281, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1101.1250, -595.8594, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 17014, -1041.6641, -728.3359, 44.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 17024, -1026.7500, -705.1719, 82.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, -1029.3438, -702.8125, 54.8516, 0.25);
	RemoveBuildingForPlayer(playerid, 17001, -1083.4766, -687.9453, 31.0234, 0.25);
	RemoveBuildingForPlayer(playerid, 17454, -1089.9297, -684.7891, 44.0859, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1037.4219, -694.1016, 36.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1030.3594, -694.1406, 36.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1024.0938, -694.1719, 36.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -999.7813, -682.5625, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -999.7813, -706.7500, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 17022, -1004.2969, -704.1484, 63.5000, 0.25);
	RemoveBuildingForPlayer(playerid, 17023, -1014.3594, -703.8828, 83.2109, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, -1020.1094, -702.4375, 57.3359, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -973.7031, -706.7500, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -973.7031, -682.5625, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3637, -992.2891, -711.9766, 38.9922, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -999.7813, -658.3750, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -973.7031, -658.3750, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 17017, -1056.0469, -632.4141, 82.7891, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -973.7031, -634.1953, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -999.7813, -634.1953, 38.9531, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1043.6406, -632.3281, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 17021, -1072.8281, -620.6328, 40.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1043.6406, -626.0625, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1065.9375, -595.8594, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1079.2656, -595.7969, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1072.2031, -595.8281, 36.2578, 0.25);
	RemoveBuildingForPlayer(playerid, 17015, -1055.1094, -603.5703, 61.8203, 0.25);
	RemoveBuildingForPlayer(playerid, 17016, -1055.5313, -617.6094, 82.6094, 0.25);
	RemoveBuildingForPlayer(playerid, 3643, -1043.6406, -619.0000, 36.2578, 0.25);
	return 1;
}

forward OnGameModeExit@refinaria();
public OnGameModeExit@refinaria() {
	new query[150], str[15];
	for(new i = 0; i < 4; i++) {
		format(str, 15, "Petróleo %i", i+1);
		mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE name = '%s'", TankQt[i], str);
		mysql_query(conn, query, false);
	}
	return 1;
}

forward OnGameModeInit@refinaria();
public OnGameModeInit@refinaria() {
	new query[150], str[15], Cache:result;
	for(new i = 0; i < 4; i++) {
		format(str, 15, "Petróleo %i", i+1);
		mysql_format(conn, query, 150, "SELECT `quant` FROM `produtoinfo` WHERE `name` = '%s'", str);
		result = mysql_query(conn, query);
		cache_get_value_name_int(0, "quant", TankQt[i]);
		cache_delete(result);
	}
	return 1;
}
// Salvar e carregar TankQt em OnGameModeInit/Exit