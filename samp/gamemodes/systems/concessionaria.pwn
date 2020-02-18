#define MAX_CONC_VMODELS			10
#define POSSIBLE_VEHICLES			58

new PossibleVehicles[2][POSSIBLE_VEHICLES] = {
	{
		400,401,404,405,419,421,422,426,436,439,445,458,466,467,474,475,478,479,480,489,491,492,496,507,516,517,518,526,527,
		529,533,534,536,540,543,545,546,547,550,551,554,555,558,559,560,561,562,566,567,575,576,579,580,585,587,589,600,602
	}, {
		26290,13000,7990,26000,14270,17000,7000,24330,10230,19000,18500,14350,7300,7450,7600,13700,5650,3900,55450,24270,10570,12920,15000,17990,14900,9990,11700,9000,6500,
		11000,26400,24000,16000,17900,4550,32990,11200,9900,16550,23400,13000,24000,42600,36850,65500,26700,48270,12500,10900,27850,7400,30950,58500,8950,37250,30950,7750,65450
	}
};
new GaragemConc;

CMD:venderveiculo(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_CONC) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, -1938.9280,262.4574,1190.8627)) return Advert(playerid, "Você só pode fazer isso a partir da concessionária.");
	new id, vid;
	if(sscanf(params, "ii", id, vid)) return AdvertCMD(playerid, "/VenderVeiculo [ID] [IDV]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(!IsPlayerInRangeOfPoint(id, 5.0, -1938.9280,262.4574,1190.8627)) return Advert(playerid, "A pessoa para quem for vender o veículo deve estar próxima a você.");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inválido.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você deve estar com a chave do veículo.");
	new i = 0;
	for(; i < MAX_BUSINESS_VEHICLES; i++) {
		if(bInfo[BUSID_CONC][bVehicles][i] == vInfo[vid][vSQL]) break;
	}
	if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence à concessionária portanto não pode ser vendido dessa forma.");
	new j = 0;
	for(; j < MAX_PRODUTOS; j++) {
		if(prInfo[BUSID_CONC][j][prModel] == vInfo[vid][vModel]) break;
	}
	if(j == MAX_PRODUTOS) return Advert(playerid, "Um erro inesperado aconteceu. Informe à administração sobre essa mensagem. [COD 014]");
	if(GetPlayerMoney(id) < prInfo[BUSID_CONC][j][prPrice]) return Advert(playerid, "Seu cliente não tem dinheiro suficiente para a compra.");
	new str[144];
	format(str, 144, "%s está te oferecendo vender o veículo %s por "VERDEMONEY"$%.0f"BRANCO".\nDeseja aceitar?", pName(playerid), vModels[GetVehicleModel(vid)-400], prInfo[BUSID_CONC][j][prPrice]);
	Dialog_Show(id, "ComprarVeiculo", DIALOG_STYLE_MSGBOX, "Comprar Veículo", str, "Comprar", "Negar");
	pInfo[id][pDialogParam][0] = funcidx("dialog_ComprarVeiculo");
	pInfo[id][pDialogParam][1] = vid;
	pInfo[id][pDialogParam][2] = playerid;
	format(str, 144, "oferece um contrato de compra para %s, junto com uma caneta preta.", pName(id));
	Act(playerid, str);
	return 1;
}

CMD:tabelaconc(playerid) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_CONC) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, -1938.9280,262.4574,1190.8627)) return Advert(playerid, "Você só pode fazer isso na mesa de negociação.");
	new str[400];
	format(str, 400, "Modelo\tQuantia\t"VERDEMONEY"Preço\n");
	for(new i = 0; i < MAX_CONC_VMODELS; i++) {
		if(prInfo[BUSID_CONC][i][prModel]) {
			format(str, 400, "%s%s\t%i\t"VERDEMONEY"$%.0f\n", str, vModels[prInfo[BUSID_CONC][i][prModel]-400], prInfo[BUSID_CONC][i][prQuant], prInfo[BUSID_CONC][i][prPrice]);
		} else {
			format(str, 400, "%s-\t-\t-\n", str);
		}
	}
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_LIST, "Tabela", str, "Fechar", "");
	return 1;
}

CMD:guardarveiculo(playerid) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_CONC) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, 797.4374,-617.7095,16.2241)) return Advert(playerid, "Você só pode fazer isso na garagem principal da concessionária.");
	new v = GetPlayerVehicleID(playerid);
	if(!v) return Advert(playerid, "Você deve estar dentro de um veículo da sua concessionária.");
	if(!vInfo[v][vSQL]) return Advert(playerid, "Veículo não atribuído à base de dados.");
	new i = 0;
	for(; i < MAX_BUSINESS_VEHICLES; i++) {
		if(bInfo[BUSID_CONC][bVehicles][i] == vInfo[v][vSQL]) break;
	}
	if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Você deve estar dentro de um veículo da sua concessionária.");
	new str[144];
	format(str, 144, "Você guardou o veículo de modelo %s na garagem.", vModels[vInfo[v][vModel]-400]);
	Info(playerid, str);
	format(vInfo[v][vOwner], 24, "");
	vInfo[v][vModel] = 0;
	vInfo[v][vColors][0] = 0;
	vInfo[v][vColors][1] = 0;
	vInfo[v][vSpawn][0] = 0.0;
	vInfo[v][vSpawn][1] = 0.0;
	vInfo[v][vSpawn][2] = 0.0;
	vInfo[v][vSpawn][3] = 0.0;
	vInfo[v][vChave] = 0;
	bInfo[BUSID_CONC][bVehicles][i] = 0;
	mysql_format(conn, str, 100, "UPDATE `businessinfo` SET `veiculo%i` = 0 WHERE `sqlid` = %i", i, bInfo[BUSID_CONC][bSQL]);
	mysql_query(conn, str, false);
	mysql_format(conn, str, 100, "DELETE FROM `vehicleinfo` WHERE `sqlid` = %i", vInfo[v][vSQL]);
	mysql_query(conn, str, false);
	vInfo[v][vSQL] = 0;
	DestroyVehicle(v);
	for(new j = 0; j < MAX_PLAYERS; j++) {
		if(!IsPlayerConnected(j)) continue;
		cmd_idv(j);
		cmd_idv(j);
	}
	return 1;
}

CMD:pegarveiculo(playerid) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_CONC) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, 797.4374,-617.7095,16.2241)) return Advert(playerid, "Você só pode fazer isso na garagem principal da concessionária.");
	new str[400];
	for(new i = 0; i < MAX_CONC_VMODELS; i++) {
		if(prInfo[BUSID_CONC][i][prModel]) {
			format(str, 400, "%s%s\t\t%i\n", str, vModels[prInfo[BUSID_CONC][i][prModel]-400], prInfo[BUSID_CONC][i][prQuant]);
		} else {
			format(str, 400, "%s-\t\t-\n", str);
		}
	}
	Dialog_Show(playerid, "CatchVehicle", DIALOG_STYLE_LIST, "Receber Veículo", str, "Solicitar", "Cancelar");
	return 1;
}

CMD:gerenciarveiculos(playerid) {
	if(strcmp(bInfo[BUSID_CONC][bOwner], pNick(playerid), false)) return Advert(playerid, "Apenas o dono da concessionária tem permissão para isso.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, -1941.2062,260.6828,1196.4410)) return Advert(playerid, "Você só pode fazer isso a partir da secretaria de administração.");
	new str[400];
	format(str, 400, "Modelo\tQuantia\t"VERDEMONEY"Preço\n");
	for(new i = 0; i < MAX_CONC_VMODELS; i++) {
		if(prInfo[BUSID_CONC][i][prModel]) {
			format(str, 400, "%s%s\t%i\t"VERDEMONEY"$%.0f\n", str, vModels[prInfo[BUSID_CONC][i][prModel]-400], prInfo[BUSID_CONC][i][prQuant], prInfo[BUSID_CONC][i][prPrice]);
		} else {
			format(str, 400, "%s-\t-\t-\n", str);
		}
	}
	Dialog_Show(playerid, "ManageVehicle", DIALOG_STYLE_TABLIST_HEADERS, "Gerenciamento", str, "Selecionar", "Cancelar");
	return 1;
}

CMD:importarveiculo(playerid) {
	if(strcmp(bInfo[BUSID_CONC][bOwner], pNick(playerid), false)) return Advert(playerid, "Apenas o dono da concessionária tem permissão para isso.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, -1941.2062,260.6828,1196.4410)) return Advert(playerid, "Você só pode fazer isso a partir da secretaria de administração.");
	new str[400];
	format(str, 400, "Modelo\tQuantia\t"VERDEMONEY"Preço\n");
	for(new i = 0; i < MAX_CONC_VMODELS; i++) {
		if(prInfo[BUSID_CONC][i][prModel]) {
			new j = 0;
			for(; j < POSSIBLE_VEHICLES; j++) {
				if(PossibleVehicles[0][j] == prInfo[BUSID_CONC][i][prModel]) break;
			}
			if(j == POSSIBLE_VEHICLES) return Advert(playerid, "Um erro inesperado aconteceu. Informe a administração sobre essa mensagem. [COD 012]");
			format(str, 400, "%s%s\t%i\t"VERDEMONEY"$%i\n", str, vModels[prInfo[BUSID_CONC][i][prModel]-400], prInfo[BUSID_CONC][i][prQuant], PossibleVehicles[1][j]);
		} else {
			format(str, 400, "%s-\t-\t-\n", str);
		}
	}
	Dialog_Show(playerid, "ImportVehicle", DIALOG_STYLE_TABLIST_HEADERS, "Importação", str, "Importar", "Cancelar");
	return 1;
}

CMD:definirimportados(playerid) {
	if(strcmp(bInfo[BUSID_CONC][bOwner], pNick(playerid), false)) return Advert(playerid, "Apenas o dono da concessionária tem permissão para isso.");
	if(!IsPlayerInRangeOfPoint(playerid, 2.5, -1941.2062,260.6828,1196.4410)) return Advert(playerid, "Você só pode fazer isso a partir da secretaria de administração.");
	new str[400];
	for(new i = 0; i < MAX_CONC_VMODELS; i++) {
		if(prInfo[BUSID_CONC][i][prModel]) {
			format(str, 400, "%s%s\n", str, vModels[prInfo[BUSID_CONC][i][prModel]-400]);
		} else {
			format(str, 400, "%sAdicionar modelo\n", str);
		}
	}
	Dialog_Show(playerid, "DefImport", DIALOG_STYLE_LIST, "Definir Importados", str, "Selecionar", "Cancelar");
	return 1;
}

forward OnGameModeInit@conc();
public OnGameModeInit@conc() {
	GaragemConc = CreateDynamicObject(13028, 797.58588, -614.49469, 17.26250,   0.00000, 0.00000, 90.00000); // Fechado
	return 1;
}

forward OnPlayerConnect@conc(playerid);
public OnPlayerConnect@conc(playerid) {
	RemoveBuildingForPlayer(playerid, 1438, 808.5625, -612.9531, 15.3203, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, 806.7500, -612.6016, 15.3047, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 780.0859, -594.4219, 15.8281, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, 835.8672, -601.0313, 15.3203, 0.25);
	RemoveBuildingForPlayer(playerid, 1438, 867.9453, -589.0547, 16.9219, 0.25);
	return 1;
}

Dialog:CatchVehicle(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(!prInfo[BUSID_CONC][listitem][prModel]) {
		Advert(playerid, "Item inválido.");
		cmd_pegarveiculo(playerid);
	} else if(!prInfo[BUSID_CONC][listitem][prQuant]) {
		Advert(playerid, "Seu estoque desse modelo está zerado.");
		cmd_pegarveiculo(playerid);
	} else {
		for(new i = 0; i < MAX_VEHICLES; i++) {
			if(!IsValidVehicle(i)) continue;
			if(IsVehicleInRangeOfPoint(i, 5.0, 797.4374,-617.7095,16.2241)) return Advert(playerid, "É necessário que a garagem esteja sem veículos por perto.");
		}
		new q = 0, x;
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!bInfo[BUSID_CONC][bVehicles][i]) continue;
			x = GetVehicleIDBySQL(bInfo[BUSID_CONC][bVehicles][i]);
			if(!x) continue;
			if(!vInfo[x][vSQL]) return Advert(playerid, "Um erro inesperado aconteceu. Informe a administração dessa mensagem. [COD 013]");
			else if(vInfo[x][vModel] == prInfo[BUSID_CONC][listitem][prModel]) { q++; }
		}
		if(q >= prInfo[BUSID_CONC][listitem][prQuant]) return Advert(playerid, "Você já retirou todos os seus veículos desse modelo da garagem.");
		new k = 0;
		for(; k < MAX_BUSINESS_VEHICLES; k++) {
			if(!bInfo[BUSID_CONC][bVehicles][k]) break;
		}
		if(k == MAX_BUSINESS_VEHICLES) return Advert(playerid, "O máximo de veículos que você pode tirar da garagem são 10.");
		x = CreateVehicle(prInfo[BUSID_CONC][listitem][prModel], 797.4374,-617.7095,16.2241,0.0, 1, 1, 0);
		PutPlayerInVehicle(playerid, x, 0);
		format(vInfo[x][vOwner], 24, "%s", bInfo[BUSID_CONC][bOwner]);
		vInfo[x][vModel] = prInfo[BUSID_CONC][listitem][prModel];
		vInfo[x][vColors][0] = 1;
		vInfo[x][vColors][1] = 1;
		vInfo[x][vSpawn][0] = 797.4374;
		vInfo[x][vSpawn][1] = -617.7095;
		vInfo[x][vSpawn][2] = 16.2241;
		vInfo[x][vSpawn][3] = 0.0;
		vInfo[x][vChave] = pInfo[playerid][pSQL];
		new query[300];
		mysql_format(conn, query, 300, "INSERT INTO `vehicleinfo` (`owner`, `model`, `color1`, `color2`, `sX`, `sY`, `sZ`, `sA`, `chave`) VALUES ('%s', %i, 1, 1, 797.4374,-617.7095,16.2241,0.0, %i)",
			bInfo[BUSID_CONC][bOwner], prInfo[BUSID_CONC][listitem][prModel], pInfo[playerid][pSQL]);
		new Cache:result = mysql_query(conn, query);
		vInfo[x][vSQL] = cache_insert_id();
		cache_delete(result);
		bInfo[BUSID_CONC][bVehicles][k] = vInfo[x][vSQL];
		mysql_format(conn, query, 300, "UPDATE `businessinfo` SET `veiculo%i` = %i WHERE `sqlid` = %i", k, vInfo[x][vSQL], bInfo[BUSID_CONC][bSQL]);
		mysql_query(conn, query, false);
		format(query, 144, "Você pegou o veículo de modelo %s da garagem.", vModels[prInfo[BUSID_CONC][listitem][prModel]-400]);
		Success(playerid, query);
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			cmd_idv(i);
			cmd_idv(i);
		}
	}
	return 1;
}

Dialog:ComprarVeiculo(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] == funcidx("dialog_ComprarVeiculo")) {
		if(!response) {
			Act(playerid, "se nega a assinar o contrato o devolve com a caneta.");
		} else {
			new vid = pInfo[playerid][pDialogParam][1], id = pInfo[playerid][pDialogParam][2];
			if(!IsPlayerConnected(id)) Advert(playerid, "O vendedor foi desconectado.");
			else if(!IsPlayerInRangeOfPoint(id, 5.0, -1938.9280,262.4574,1190.8627)) Advert(playerid, "O vendedor deve estar próximo a você.");
			else if(!IsValidVehicle(vid)) Advert(playerid, "Veículo inválido.");
			else if(!vInfo[vid][vSQL]) Advert(playerid, "Veículo não registrado na base de dados.");
			else if(vInfo[vid][vChave] != pInfo[id][pSQL]) Advert(playerid, "O vendedor deve estar com a chave do veículo em mãos.");
			else {
				new i = 0;
				for(; i < MAX_BUSINESS_VEHICLES; i++) {
					if(bInfo[BUSID_CONC][bVehicles][i] == vInfo[vid][vSQL]) break;
				}
				if(i == MAX_BUSINESS_VEHICLES) Advert(playerid, "Esse veículo já foi vendido.");
				else {
					new j = 0;
					for(; j < MAX_PRODUTOS; j++) {
						if(prInfo[BUSID_CONC][j][prModel] == vInfo[vid][vModel]) break;
					}
					if(j == MAX_PRODUTOS) Advert(playerid, "Um erro inesperado aconteceu. Informe à administração sobre essa mensagem. [COD 014]");
					else if(GetPlayerMoney(playerid) < prInfo[BUSID_CONC][j][prPrice]) Advert(playerid, "Você não tem dinheiro suficiente para a compra.");
					else {
						new query[150];
						format(query, 20, "~r~-$%.0f", prInfo[BUSID_CONC][j][prPrice]);
						GameTextForPlayer(playerid, query, 1000, 1);
						GivePlayerMoney(playerid, -floatround(prInfo[BUSID_CONC][j][prPrice]));
						format(vInfo[vid][vOwner], 24, "%s", pNick(playerid));
						bInfo[BUSID_CONC][bVehicles][i] = 0;
						prInfo[BUSID_CONC][j][prQuant]--;
						vInfo[vid][vChave] = pInfo[playerid][pSQL];
						Act(playerid, "assina o contrato de compra e recebe as chaves do veículo.");
						mysql_format(conn, query, 150, "UPDATE vehicleinfo SET owner = '%s' WHERE sqlid = %i", pNick(playerid), vInfo[vid][vSQL]);
						mysql_query(conn, query, false);
						mysql_format(conn, query, 150, "UPDATE businessinfo SET veiculo%i = 0 WHERE sqlid = %i", i, bInfo[BUSID_CONC][bSQL]);
						mysql_query(conn, query, false);
						mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_CONC][j][prQuant], prInfo[BUSID_CONC][j][prSQL]);
						mysql_query(conn, query, false);
					}
				}
			}
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:ManageVehicle(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(!prInfo[BUSID_CONC][listitem][prModel]) {
		Advert(playerid, "Item inválido.");
		cmd_gerenciarveiculos(playerid);
	} else if(!prInfo[BUSID_CONC][listitem][prQuant]) {
		Advert(playerid, "Seu estoque desse modelo está zerado.");
		cmd_gerenciarveiculos(playerid);
	} else {
		new str[200];
		format(str, 200, BRANCO"Insira abaixo o preço que deseja vender os seus veículos de modelo %s.", vModels[prInfo[BUSID_CONC][listitem][prModel]-400]);
		Dialog_Show(playerid, "PriceVehicle", DIALOG_STYLE_INPUT, "Gerenciamento", str, "Definir", "Voltar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_PriceVehicle");
		pInfo[playerid][pDialogParam][1] = listitem;
	}
	return 1;
}

Dialog:PriceVehicle(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] == funcidx("dialog_PriceVehicle")) {
		if(!response) {
			cmd_gerenciarveiculos(playerid);
		} else {
			new Float:price = floatstr(inputtext);
			if(isnull(inputtext)) {
				Advert(playerid, "Preço inválido.");
			} else if(price < 1.0 || price > 1000000.0) {
				Advert(playerid, "Preço inválido.");
			} else {
				new i = pInfo[playerid][pDialogParam][1];
				new str[144];
				format(str, 144, "Foi definido como "VERDEMONEY"$%.0f"BRANCO" o preço do modelo %s.", price, vModels[prInfo[BUSID_CONC][i][prModel]-400]);
				Info(playerid, str);
				prInfo[BUSID_CONC][i][prPrice] = price;
				mysql_format(conn, str, 144, "UPDATE produtoinfo SET price = %.2f WHERE sqlid = %i", price, prInfo[BUSID_CONC][i][prSQL]);
				mysql_query(conn, str, false);
			}
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:ImportVehicle(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(!prInfo[BUSID_CONC][listitem][prModel]) {
		Advert(playerid, "Item inválido.");
		cmd_importarveiculo(playerid);
	} else {
		new j = 0;
		for(; j < POSSIBLE_VEHICLES; j++) {
			if(PossibleVehicles[0][j] == prInfo[BUSID_CONC][listitem][prModel]) break;
		}
		if(j == POSSIBLE_VEHICLES) return Advert(playerid, "Um erro inesperado aconteceu. Informe a administração sobre essa mensagem. [COD 012]");
		new str[200];
		format(str, 200, BRANCO"Insira abaixo a quantidade de veículos do modelo %s deseja importar.\nLembre-se de multiplicar pelo preço ("VERDEMONEY"$%i"BRANCO")", vModels[prInfo[BUSID_CONC][listitem][prModel]-400], PossibleVehicles[1][j]);
		Dialog_Show(playerid, "QuantImpVeh", DIALOG_STYLE_INPUT, "Importação", str, "Importar", "Voltar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_QuantImpVeh");
		pInfo[playerid][pDialogParam][1] = listitem;
	}
	return 1;
}

Dialog:QuantImpVeh(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] == funcidx("dialog_QuantImpVeh")) {
		if(!response) {
			cmd_importarveiculo(playerid);
		} else {
			new quant = strval(inputtext);
			if(isnull(inputtext)) {
				Advert(playerid, "Quantia inválida.");
			} else if(quant < 1 || quant > 50) {
				Advert(playerid, "Quantia inválida.");
			} else {
				new j = 0, i = pInfo[playerid][pDialogParam][1];
				for(; j < POSSIBLE_VEHICLES; j++) {
					if(PossibleVehicles[0][j] == prInfo[BUSID_CONC][i][prModel]) break;
				}
				if(j == POSSIBLE_VEHICLES) {
					Advert(playerid, "Um erro inesperado aconteceu. Informe a administração sobre essa mensagem. [COD 012]");
				} else if((quant*PossibleVehicles[1][j]) > bInfo[BUSID_CONC][bReceita]) {
					Advert(playerid, "Sua empresa não possui capital suficiente para bancar essa importação.");
				} else {
					new str[144];
					bInfo[BUSID_CONC][bReceita] -= (quant*PossibleVehicles[1][j]);
					format(str, 144, "Foram importados %i veículos de modelo %s pelo preço de "VERDEMONEY"$%i"BRANCO".", quant, vModels[prInfo[BUSID_CONC][i][prModel]-400], (quant*PossibleVehicles[1][j]));
					Info(playerid, str);
					prInfo[BUSID_CONC][i][prQuant] += quant;
					mysql_format(conn, str, 144, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_CONC][i][prQuant], prInfo[BUSID_CONC][i][prSQL]);
					mysql_query(conn, str, false);
				}
			}
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:DefImport(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(prInfo[BUSID_CONC][listitem][prModel]) {
		if(!prInfo[BUSID_CONC][listitem][prQuant]) {
			new str[150];
			format(str, 150, "Deseja remover o modelo %s das vendas?", vModels[prInfo[BUSID_CONC][listitem][prModel]-400]);
			Dialog_Show(playerid, "RemoveImport", DIALOG_STYLE_MSGBOX, "Remover Modelo", str, "Remover", "Voltar");
			pInfo[playerid][pDialogParam][0] = funcidx("dialog_RemoveImport");
			pInfo[playerid][pDialogParam][1] = listitem;
		} else {
			cmd_definirimportados(playerid);
			Info(playerid, "Esse veículo não pode ser removido pois você já o importou. Primeiro zere o estoque.");
		}
	} else {
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_AddImport");
		pInfo[playerid][pDialogParam][1] = listitem;
		Dialog_Show(playerid, "AddImport", DIALOG_STYLE_INPUT, "Adicionar Modelo", "Insira abaixo o nome do modelo do veículo que deseja adicionar para a venda.", "Adicionar", "Voltar");
	}
	return 1;
}

Dialog:AddImport(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] == funcidx("dialog_AddImport")) {
		if(!response) {
			cmd_definirimportados(playerid);
		} else {
			new i = pInfo[playerid][pDialogParam][1];
			if(!prInfo[BUSID_CONC][i][prModel]) {
				new model = GetModelIDFromModelName(inputtext);
				if(!model) { Advert(playerid, "Modelo inválido.");
				} else {
					new j = 0;
					for(; j < POSSIBLE_VEHICLES; j++) {
						if(model == PossibleVehicles[0][j]) break;
					}
					if(j == POSSIBLE_VEHICLES) {
						Advert(playerid, "Esse modelo não é permitido para vendas.");
					} else {
						new k = 0;
						for(; k < MAX_BUSINESS_VEHICLES; k++) {
							if(prInfo[BUSID_CONC][k][prModel] == model) break;
						}
						if(k == MAX_BUSINESS_VEHICLES) {
							new str[200];
							format(str, 144, "Modelo %s adicionado às vendas.", vModels[model-400]);
							Info(playerid, str);
							mysql_format(conn, str, 200, "UPDATE produtoinfo SET model = %i WHERE sqlid = %i", model, prInfo[BUSID_CONC][i][prSQL]);
							mysql_query(conn, str, false);
							prInfo[BUSID_CONC][i][prModel] = model;
						} else {
							Advert(playerid, "Esse modelo já está disponível para vendas.");
						}
					}
				}
			} else {
				Advert(playerid, "Um erro inesperado aconteceu. Informe isso para a administração. [COD 011]");
			}
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:RemoveImport(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] == funcidx("dialog_RemoveImport")) {
		if(!response) {
			cmd_definirimportados(playerid);
		} else {
			new i = pInfo[playerid][pDialogParam][1];
			if(prInfo[BUSID_CONC][i][prModel] && !prInfo[BUSID_CONC][i][prQuant]) {
				new str[200];
				format(str, 144, "Modelo %s removido das vendas.", vModels[prInfo[BUSID_CONC][i][prModel]-400]);
				Info(playerid, str);
				mysql_format(conn, str, 200, "UPDATE produtoinfo SET model = 0 WHERE sqlid = %i", prInfo[BUSID_CONC][i][prSQL]);
				mysql_query(conn, str, false);
				prInfo[BUSID_CONC][i][prModel] = 0;
			} else {
				Advert(playerid, "Um erro inesperado aconteceu. Informe isso para a administração. [COD 011]");
			}
		}
	}
	return ResetDialogParams(playerid);
}