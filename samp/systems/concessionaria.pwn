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
						new str[200];
						format(str, 144, "Modelo %s adicionado às vendas.", vModels[model-400]);
						Info(playerid, str);
						mysql_format(conn, str, 200, "UPDATE produtoinfo SET model = %i WHERE sqlid = %i", model, prInfo[BUSID_CONC][i][prSQL]);
						mysql_query(conn, str, false);
						prInfo[BUSID_CONC][i][prModel] = model;
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