#define TANK_CAPACITY		500000
#define POSTO_CAPACITY		250000
#define CARGA_CAPACITY		40000
#define TAXA_REFINARIA		135

#define MAX_FICHAS			5

enum FICHAS_INFO {
	fSQL,
	fDestino[40],
	fValor,
	fCarga,
	fID // 0 = sala do chefe; MAX_PLAYERS+1 = secretaria; 
};

enum FICHA_PARAMS {
	fpDestino[40],
	fpValor,
	fpCarga,
	fpID
};

new PortaoRefinaria;
new TankQt[4];
new Engate[6];
new TVerifyEngate[6];
new TAttCarga[6];
new QtAttCarga[6];
new TaxaRefinaria = TAXA_REFINARIA;
new fInfo[MAX_FICHAS][FICHAS_INFO];
new ParametrosCFR[MAX_PLAYERS][FICHA_PARAMS];
new CanoEngate[2];

CMD:engatar(playerid, params[]) {
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-639.9603,35.4306)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-662.9603,35.4306)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-685.9603,35.4306)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-708.9603,35.4306)) { pPanel = 4; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 666.3453,-581.1970,16.3359)) { pPanel = 5; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 1352.3315,476.2255,20.1862)) { pPanel = 6; }
	else return Advert(playerid, "Você deve estar próximo ao cano que engata na carga.");
	if(Engate[pPanel-1]) return Advert(playerid, "Essa carga já está engatada. Se quiser desengatar, use "AMARELO"/Desengatar"BRANCO".");
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/Engatar [IDV da carga]");
	if(GetVehicleModel(vid) != 584) return Advert(playerid, "Você deve engatar uma carga que suporte o armazenamento de gasolina.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Esse veículo não está registrado no banco de dados.");
	new Float:A;
	GetVehicleZAngle(vid, A);
	if(pPanel <= 4) {
		if(A > 100 || A < 80) return Advert(playerid, "Essa carga não está devidamente posicionada.");
	} // else if(ppanel == 5, 6..) verificar angulos
	if(pPanel == 1) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-639.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 2) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-662.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 3) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-685.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 4) { if(!IsVehicleInRangeOfPoint(vid, 3.0, -983.9913,-708.9285,33.1292)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 5) { if(!IsVehicleInRangeOfPoint(vid, 3.0, 665.4332,-579.4955,17.5289)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	else if(pPanel == 6) { if(!IsVehicleInRangeOfPoint(vid, 3.0, 1350.7700,476.1723,21.3702)) return Advert(playerid, "Essa carga não está devidamente posicionada."); }
	Engate[pPanel-1] = vid;
	Act(playerid, "engata o cano do tanque na carga de gasolina.");
	TVerifyEngate[pPanel-1] = SetTimerEx("VerifyEngate", 1000, true, "ii", vid, pPanel);
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	PlaySoundAround(1135, P[0], P[1], P[2]);
	if(pPanel == 5) {
		CanoEngate[0] = CreateObject(3675, 666.3681, -580.0705, 10.0000, 180.0, 0.0, 0.0);
	}
	if(pPanel == 6) {
		CanoEngate[1] = CreateObject(3675, 1350.8192, 476.0763, 13.8302, 180.0, 0.0, 0.0);
	}
	return 1;
}

CMD:desengatar(playerid) {
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-639.9603,35.4306)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-662.9603,35.4306)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-685.9603,35.4306)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -986.0909,-708.9603,35.4306)) { pPanel = 4; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 666.3453,-581.1970,16.3359)) { pPanel = 5; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 1352.3315,476.2255,20.1862)) { pPanel = 6; }
	else return Advert(playerid, "Você deve estar próximo ao engatador da refinaria.");
	if(!Engate[pPanel-1]) return Advert(playerid, "Essa carga não está engatada. Se quiser engatar, use "AMARELO"/Engatar"BRANCO".");
	Engate[pPanel-1] = 0;
	Act(playerid, "desengata o cano do tanque na carga de gasolina.");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	PlaySoundAround(1135, P[0], P[1], P[2]);
	if(pPanel >= 5 || pPanel <= 6) {
		DestroyObject(CanoEngate[pPanel-5]);
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
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 670.3523,-581.8588,16.3359)) { pPanel = 5; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 1354.9487,479.3580,20.2109)) { pPanel = 6; }
	else return Advert(playerid, "Você deve estar próximo a um painel da refinaria.");
	new str[350];
	if(pPanel <= 4) {
		format(str, 350, "\tSTATUS TANQUE:\n\nQTD LT: %iL\nCAP LT: %iL\n\n\tSTATUS CARGA:\n\n", TankQt[pPanel-1], TANK_CAPACITY);
	} else if(pPanel == 5) {
		for(new i = 0; i < MAX_PRODUTOS; i++) {
			if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
			if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
				format(str, 350, "\tSTATUS TANQUE:\n\nQTD LT: %iL\nCAP LT: %iL\n\n\tSTATUS CARGA:\n\n", prInfo[BUSID_PGDM][i][prQuant], POSTO_CAPACITY);
				break;
			}
		}
	} else if(pPanel == 6) {
		for(new i = 0; i < MAX_PRODUTOS; i++) {
			if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
			if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
				format(str, 350, "\tSTATUS TANQUE:\n\nQTD LT: %iL\nCAP LT: %iL\n\n\tSTATUS CARGA:\n\n", prInfo[BUSID_PGMG][i][prQuant], POSTO_CAPACITY);
				break;
			}
		}
	}
	if(!Engate[pPanel-1]) {
		format(str, 350, "%s"VERMELHO"Carga não engatada.", str);
		Dialog_Show(playerid, "Painel", DIALOG_STYLE_MSGBOX, "PAINEL", str, "Fechar", "");
	} else {
		format(str, 350, "%sQTD LT: %iL\nCAP LT:%iL", str, vInfo[Engate[pPanel-1]][vCargaGas], CARGA_CAPACITY);
		Dialog_Show(playerid, "Painel", DIALOG_STYLE_MSGBOX, "PAINEL", str, "Configurar", "Fechar");
	}
	return 1;
}

CMD:verficha(playerid, params[]) {
	new file;
	if(sscanf(params, "i", file)) return AdvertCMD(playerid, "/VerFicha [Número da Ficha]");
	if(file < 1 || file > MAX_FICHAS) return AdvertCMD(playerid, "/VerFicha [1-5]");
	if(fInfo[file-1][fID] != playerid+1) return Advert(playerid, "Você não possui essa ficha.");
	new str1[20], str2[200];
	format(str1, 20, AMARELO"Ficha %02i", file);
	format(str2, 200, BRANCO"Destino: %s\nValor: "VERDEMONEY"$%i"BRANCO"\nCarga: %iL", fInfo[file-1][fDestino], fInfo[file-1][fValor], fInfo[file-1][fCarga]);
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, str1, str2, "Fechar", "");
	Act(playerid, "retira uma ficha de dentro do bolso.");
	return 1;
}

CMD:entregarficha(playerid, params[]) {
	new file, id;
	if(sscanf(params, "ii", file, id)) return AdvertCMD(playerid, "/EntregarFicha [Número da ficha] [ID]");
	if(file < 1 || file > MAX_FICHAS) return AdvertCMD(playerid, "/EntregarFicha [1-5] [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(fInfo[file-1][fID] != playerid+1) return Advert(playerid, "Você não tem essa ficha consigo.");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(id, 2.5, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo a quem deseja entregar a ficha.");
	fInfo[file-1][fID] = id+1;
	new str[144];
	format(str, 144, "entrega uma ficha de numeração \"%02i\" para %s.", file, pName(id));
	Act(playerid, str);
	format(str, 144, "Para ver os dados da sua ficha, use "AMARELO"/VerFicha %i"BRANCO".", file);
	Info(id, str);
	return 1;
}

CMD:pegarficha(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_REF) return Advert(playerid, "Você não tem permissão para isso.");
	new file;
	if(sscanf(params, "i", file)) return AdvertCMD(playerid, "/PegarFicha [Número da ficha]");
	if(file < 1 || file > MAX_FICHAS) return AdvertCMD(playerid, "/PegarFicha [1-5]");
	if(!fInfo[file-1][fSQL]) return Advert(playerid, "Ficha inexistente.");
	if(fInfo[file-1][fID] == playerid+1) return Advert(playerid, "Essa ficha já está com você.");
	else if(fInfo[file-1][fID] == 0) { // Sala do chefe
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 514.5214,199.8806,1049.9844)) return Advert(playerid, "Essa ficha se encontra na sala do chefe.");
		new str[144];
		fInfo[file-1][fID] = playerid+1;
		format(str, 144, "pega uma ficha com numeração "BRANCO"\"%02i\""CINZAAZULADO" de dentro da pasta.", file);
		Act(playerid, str);
		return 1;
	} else if(fInfo[file-1][fID] == MAX_PLAYERS+1) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 530.7697,208.9076,1049.9844)) return Advert(playerid, "Essa ficha se encontra na secretaria.");
		new str[144];
		fInfo[file-1][fID] = playerid+1;
		format(str, 144, "pega uma ficha com numeração "BRANCO"\"%02i\""CINZAAZULADO" de dentro da pasta.", file);
		Act(playerid, str);
	} else { Advert(playerid, "Essa ficha está com outra pessoa no momento."); }
	return 1;
}

CMD:guardarficha(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_REF) return Advert(playerid, "Você não tem permissão para isso.");
	new file;
	if(sscanf(params, "i", file)) return AdvertCMD(playerid, "/GuardarFicha [Número da ficha]");
	if(file < 1 || file > MAX_FICHAS) return AdvertCMD(playerid, "/GuardarFicha [1-5]");
	if(!fInfo[file-1][fSQL]) return Advert(playerid, "Ficha inexistente.");
	if(fInfo[file-1][fID] != playerid+1) return Advert(playerid, "Essa ficha não está com você.");
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 514.5214,199.8806,1049.9844)) { // Sala do chefe
		new str[144];
		fInfo[file-1][fID] = 0;
		format(str, 144, "guarda uma ficha de numeração "BRANCO"\"%02i\""CINZAAZULADO" dentro da pasta.", file);
		Act(playerid, str);
		return 1;
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 530.7697,208.9076,1049.9844)) {
		new str[144];
		fInfo[file-1][fID] = MAX_PLAYERS+1;
		format(str, 144, "guarda uma ficha de numeração "BRANCO"\"%02i\""CINZAAZULADO" dentro da pasta.", file);
		Act(playerid, str);
	} else { Advert(playerid, "Você deve estar na secretaria ou na sala do chefe para guardar a ficha em uma pasta."); }
	return 1;
}

CMD:fichasrefinaria(playerid) { // Apenas o dono da refinaria pode criar para evitar conflito mysql de duas pessoas criarem ao mesmo tempo
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_REF) return Advert(playerid, "Sua empresa não tem acesso a esse comando.");
	if(IsPlayerInRangeOfPoint(playerid, 2.5, 514.5214,199.8806,1049.9844)) { // Sala do chefe refinaria
		new str[300];
		for(new i = 0; i < MAX_FICHAS; i++) {
			if(!fInfo[i][fSQL]) { format(str, 300, "%s+ Criar ficha %02i\n", str, i+1); }
			else if(!fInfo[i][fID]) { format(str, 300, "%sVer ficha %02i\n", str, i+1); }
			else { format(str, 300, "%sFicha %02i ausente\n", str, i+1); }
		}
		Dialog_Show(playerid, "FichasRef", DIALOG_STYLE_LIST, "FICHAS", str, "Selecionar", "Cancelar");
		Act(playerid, "pega uma pasta de cima da mesa com várias fichas dentro.");
	} else if (IsPlayerInRangeOfPoint(playerid, 2.5, 530.7697,208.9076,1049.9844)) { // Secretaria refinaria
		new str[300];
		for(new i = 0; i < MAX_FICHAS; i++) {
			if(fInfo[i][fID] == MAX_PLAYERS+1) { format(str, 300, "%sVer ficha %02i\n", str, i+1); }
			else { format(str, 300, "%sFicha %02i ausente\n", str, i+1); }
		}
		Dialog_Show(playerid, "FichasRefSec", DIALOG_STYLE_LIST, "FICHAS", str, "Selecionar", "Cancelar");
		Act(playerid, "pega uma pasta de dentro da gaveta com várias fichas dentro.");
	} else { Advert(playerid, "Você deve estar na sala do chefe ou na secretaria, onde se têm as fichas."); }
	return 1;
}

Dialog:FichasRefSec(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Act(playerid, "coloca a pasta na gaveta de volta.");
		return 1;
	}
	for(new i = 0; i < MAX_FICHAS; i++) {
		if(listitem == i) {
			if(fInfo[i][fID] == MAX_PLAYERS+1) { // Ver ficha
				new str1[20], str2[200];
				format(str1, 20, AMARELO"Ficha %02i", i+1);
				format(str2, 200, BRANCO"Destino: %s\nValor: "VERDEMONEY"$%i"BRANCO"\nCarga: %iL", fInfo[i][fDestino], fInfo[i][fValor], fInfo[i][fCarga]);
				Dialog_Show(playerid, "VerFichaRef", DIALOG_STYLE_MSGBOX, str1, str2, "Fechar", "Voltar");
				Act(playerid, "pega uma das fichas preenchidas de dentro da pasta.");
			} else { Act(playerid, "coloca a pasta de volta na gaveta."); }
			break;
		}
	}
	return 1;
}

Dialog:FichasRef(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Act(playerid, "coloca a pasta na mesa de volta.");
		return 1;
	}
	for(new i = 0; i < MAX_FICHAS; i++) {
		if(listitem == i) {
			if(!fInfo[i][fSQL]) { // Criar ficha
				if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) {
					Advert(playerid, "Apenas o chefe da refinaria pode fazer isso.");
					Act(playerid, "coloca a pasta na mesa de volta.");
				} else {
					Dialog_Show(playerid, "FichaDestino", DIALOG_STYLE_INPUT, "Criar Ficha", "Informe abaixo o destino da carga de gasolina.", "Prosseguir", "Voltar");
					ParametrosCFR[playerid][fpID] = i+1;
					Act(playerid, "pega uma ficha em branco de dentro da pasta.");
				}
			} else if(!fInfo[i][fID]) { // Ver ficha
				new str1[20], str2[200];
				format(str1, 20, AMARELO"Ficha %02i", i+1);
				format(str2, 200, BRANCO"Destino: %s\nValor: "VERDEMONEY"$%i"BRANCO"\nCarga: %iL", fInfo[i][fDestino], fInfo[i][fValor], fInfo[i][fCarga]);
				Dialog_Show(playerid, "VerFichaRef", DIALOG_STYLE_MSGBOX, str1, str2, "Fechar", "Voltar");
				Act(playerid, "pega uma das fichas preenchidas de dentro da pasta.");
			} else { Act(playerid, "coloca a pasta de volta na mesa."); }
			break;
		}
	}
	return 1;
}

Dialog:FichaDestino(playerid, response, listitem, inputtext[]) {
	if(!response) {
		new str[300];
		for(new i = 0; i < MAX_FICHAS; i++) {
			if(!fInfo[i][fSQL]) { format(str, 300, "%s+ Criar ficha %02i\n", str, i+1); }
			else { format(str, 300, "%sVer ficha %02i\n", str, i+1); }
		}
		Dialog_Show(playerid, "FichasRef", DIALOG_STYLE_LIST, "FICHAS", str, "Selecionar", "Cancelar");
		ParametrosCFR[playerid][fpID] = 0;
		Act(playerid, "guarda a ficha de volta na pasta");
	} else {
		if(!strlen(inputtext) || strlen(inputtext) > 39) {
			Dialog_Show(playerid, "FichaDestino", DIALOG_STYLE_INPUT, "Criar Ficha", "Informe abaixo o destino da carga de gasolina.", "Prosseguir", "Voltar");
			Advert(playerid, "Nome de destino inválido.");
			return 1;
		}
		new str[144];
		format(ParametrosCFR[playerid][fpDestino], 40, "%s", inputtext);
		format(str, 144, "Destino definido: '"AMARELO"%s"BRANCO"'.", inputtext);
		Info(playerid, str);
		Dialog_Show(playerid, "FichaCarga", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo quantos litros de gasolina a carga deverá transportar.", "Prosseguir", "Voltar");
	}
	return 1;
}

Dialog:FichaCarga(playerid, response, listitem, inputtext[]) {
	if(!response) {
			format(ParametrosCFR[playerid][fpDestino], 40, "");
			Dialog_Show(playerid, "FichaDestino", DIALOG_STYLE_INPUT, "Criar Ficha", "Informe abaixo o destino da carga de gasolina.", "Prosseguir", "Voltar");
	} else {
		new carga = strval(inputtext);
		if(carga < 1 || carga > CARGA_CAPACITY) {
			Dialog_Show(playerid, "FichaCarga", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo quantos litros de gasolina a carga deverá transportar.", "Prosseguir", "Voltar");
			Advert(playerid, "Quantia inválida.");
			new str[144];
			format(str, 144, "Lembre-se que a capacidade máxima da carga é de %i litros.", CARGA_CAPACITY);
			Info(playerid, str);
			return 1;
		}
		new str[144];
		ParametrosCFR[playerid][fpCarga] = carga;
		format(str, 144, "Carga definida: "AMARELO"%iL"BRANCO".", carga);
		Info(playerid, str);
		Dialog_Show(playerid, "FichaValor", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo o valor que o motorista irá receber por transportar essa carga.", "Finalizar", "Voltar");
	}
	return 1;
}

Dialog:FichaValor(playerid, response, listitem, inputtext[]) {
	if(!response) {
			ParametrosCFR[playerid][fpCarga] = 0;
			Dialog_Show(playerid, "FichaCarga", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo quantos litros de gasolina a carga deverá transportar.", "Prosseguir", "Voltar");
	} else {
		new valor = strval(inputtext);
		if(valor < 1) {
			Dialog_Show(playerid, "FichaValor", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo o valor que o motorista irá receber por transportar essa carga.", "Finalizar", "Voltar");
			Advert(playerid, "Valor inválido.");
			return 1;
		}
		new str[200];
		ParametrosCFR[playerid][fpValor] = valor;
		format(str, 144, "Valor definido: "VERDEMONEY"$%i"VERDEMONEY".", valor);
		Info(playerid, str);
		format(str, 200, BRANCO"Destino: %s\nValor: "VERDEMONEY"$%i"BRANCO"\nCarga: %iL\n\nVocê confirma a criação dessa ficha?", ParametrosCFR[playerid][fpDestino], ParametrosCFR[playerid][fpValor], ParametrosCFR[playerid][fpCarga]);
		Dialog_Show(playerid, "FichaConfirmar", DIALOG_STYLE_MSGBOX, "Criar Ficha", str, "Criar", "Voltar");
	}
	return 1;
}

Dialog:FichaConfirmar(playerid, response, listitem, inputtext[]) {
	if(!response) {
		ParametrosCFR[playerid][fpValor] = 0;
		Dialog_Show(playerid, "FichaValor", DIALOG_STYLE_INPUT, "Criar Ficha", "Insira abaixo o valor que o motorista irá receber por transportar essa carga.", "Finalizar", "Voltar");
	} else {
		new query[200], Cache:result;
		mysql_format(conn, query, 200, "INSERT INTO fichasinfo (destiny, value, carga) VALUES ('%s', %i, %i)", ParametrosCFR[playerid][fpDestino], ParametrosCFR[playerid][fpValor], ParametrosCFR[playerid][fpCarga]);
		result = mysql_query(conn, query, true);
		fInfo[ParametrosCFR[playerid][fpID]-1][fSQL] = cache_insert_id();
		cache_delete(result);
		format(fInfo[ParametrosCFR[playerid][fpID]-1][fDestino], 40, "%s", ParametrosCFR[playerid][fpDestino]);
		fInfo[ParametrosCFR[playerid][fpID]-1][fValor] = ParametrosCFR[playerid][fpValor];
		fInfo[ParametrosCFR[playerid][fpID]-1][fCarga] = ParametrosCFR[playerid][fpCarga];
		fInfo[ParametrosCFR[playerid][fpID]-1][fID] = 0;
		ClearParametrosCFR(playerid);
		Success(playerid, "Ficha criada com sucesso.");
		Act(playerid, "escreve algumas informações na ficha nova e assina sua rubrica na parte de baixo do documento.");
	}
	return 1;
}

Dialog:VerFichaRef(playerid, response, listitem, inputtext[]) {
	if(!response) {
		new str[300];
		for(new i = 0; i < MAX_FICHAS; i++) {
			if(!fInfo[i][fSQL]) { format(str, 300, "%s+ Criar ficha %02i\n", str, i+1); }
			else { format(str, 300, "%sVer ficha %02i\n", str, i+1); }
		}
		Dialog_Show(playerid, "FichasRef", DIALOG_STYLE_LIST, "FICHAS", str, "Selecionar", "Cancelar");
		Act(playerid, "guarda a ficha de volta na pasta.");
	}
	return 1;
}

Dialog:Painel(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_REF) return Advert(playerid, "É necessário um cartão de identificação da refinaria para manipular o painel.");
	new pPanel = 0;
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-630.8459,44.8990)) { pPanel = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-653.8459,44.8990)) { pPanel = 2; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-676.8459,44.8990)) { pPanel = 3; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-699.8459,44.8990)) { pPanel = 4; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 670.3523,-581.8588,16.3359)) { pPanel = 5; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 1354.9487,479.3580,20.2109)) { pPanel = 6; }
	else return Advert(playerid, "Você deve estar próximo a um painel da refinaria.");
	if(!Engate[pPanel-1]) return 1;
	new str[350];
	format(str, 350, "Coloque abaixo a quantidade de gasolina que deseja retirar ou colocar dentro da carga.\nNote que para definir se vai encher ou esvaziar deve-se clicar no botão correto.");
	Dialog_Show(playerid, "ConfigPainel", DIALOG_STYLE_INPUT, "CONFIGURAR", str, "Encher", "Esvaziar");
	return 1;
}

Dialog:ConfigPainel(playerid, response, listitem, inputtext[]) {
	new qt = strval(inputtext);
	if(qt < 1) return Advert(playerid, "Configuração cancelada.");
	new pPanel = 0, Float:P[3];
	if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-630.8459,44.8990)) { pPanel = 1; P[0] = -981.2379; P[1] = -630.8459; P[2] = 44.8990; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-653.8459,44.8990)) { pPanel = 2; P[0] = -981.2379; P[1] = -653.8459; P[2] = 44.8990; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-676.8459,44.8990)) { pPanel = 3; P[0] = -981.2379; P[1] = -676.8459; P[2] = 44.8990; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, -981.2379,-699.8459,44.8990)) { pPanel = 4; P[0] = -981.2379; P[1] = -699.8459; P[2] = 44.8990; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 670.3523,-581.8588,16.3359)) { pPanel = 5; P[0] = 670.3523; P[1] = -581.8588; P[2] = 16.3359; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.5, 1354.9487,479.3580,20.2109)) { pPanel = 6; P[0] = 1354.9487; P[1] = 479.3580; P[2] = 20.2109; }
	if(!pPanel) return Advert(playerid, "Você deve estar próximo ao painel que deseja configurar.");
	if(!Engate[pPanel-1]) return Amb(P[0], P[1], P[2], "A carga não está mais engatada. (( Painel ))");
	if(response) {
		if(vInfo[Engate[pPanel-1]][vCargaGas] + qt > CARGA_CAPACITY) return Amb(P[0], P[1], P[2], "Quantia além da capacidade da carga. (( Painel ))");
		if(pPanel <= 4) {
			if(qt > TankQt[pPanel-1]) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
		} else if(pPanel == 5) { // Posto DM
			for(new i = 0; i < MAX_PRODUTOS; i++) {
				if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
				if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
					if(qt > prInfo[BUSID_PGDM][i][prQuant]) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
					break;
				}
			}
		} else if(pPanel == 6) { // Posto MG
			for(new i = 0; i < MAX_PRODUTOS; i++) {
				if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
				if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
					if(qt > prInfo[BUSID_PGMG][i][prQuant]) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
					break;
				}
			}
		}
		TAttCarga[pPanel-1] = SetTimerEx("AttCarga", 1000, true, "ii", pPanel-1);
		QtAttCarga[pPanel-1] = qt;
		Amb(P[0], P[1], P[2], "Enchendo carga. (( Painel ))");
	} else {
		if(vInfo[Engate[pPanel-1]][vCargaGas] < qt) return Amb(P[0], P[1], P[2], "Baixo nível de combustível na carga. (( Painel ))");
		if(pPanel <= 4) {
			if(qt + TankQt[pPanel-1] > TANK_CAPACITY) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
		} else if(pPanel == 5) { // Posto DM
			for(new i = 0; i < MAX_PRODUTOS; i++) {
				if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
				if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
					if(qt + prInfo[BUSID_PGDM][i][prQuant] > POSTO_CAPACITY) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
					break;
				}
			}
		} else if(pPanel == 6) { // Posto MG
			for(new i = 0; i < MAX_PRODUTOS; i++) {
				if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
				if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
					if(qt + prInfo[BUSID_PGMG][i][prQuant] > POSTO_CAPACITY) return Amb(P[0], P[1], P[2], "Baixo nível de combustível no tanque. (( Painel ))");
					break;
				}
			}
		}
		TAttCarga[pPanel-1] = SetTimerEx("AttCarga", 1000, true, "ii", pPanel-1);
		QtAttCarga[pPanel-1] = -qt;
		Amb(P[0], P[1], P[2], "Esvaziando carga. (( Painel ))");
	}
	return 1;
}

forward AttCarga(panelid);
public AttCarga(panelid) {
	new Float:P[3];
	if(panelid == 0) { P[0] = -981.2379; P[1] = -630.8459; P[2] = 44.8990; }
	else if(panelid == 1) { P[0] = -981.2379; P[1] = -653.8459; P[2] = 44.8990; }
	else if(panelid == 2) { P[0] = -981.2379; P[1] = -676.8459; P[2] = 44.8990; }
	else if(panelid == 3) { P[0] = -981.2379; P[1] = -699.8459; P[2] = 44.8990; }
	else if(panelid == 4) { P[0] = 670.3523; P[1] = -581.8588; P[2] = 16.3359; }
	else if(panelid == 5) { P[0] = 1354.9487; P[1] = 479.3580; P[2] = 20.2109; }
	if(!Engate[panelid]) {
		Amb(P[0], P[1], P[2], "A carga não está mais engatada. (( Painel ))");
		QtAttCarga[panelid] = 0;
		KillTimer(TAttCarga[panelid]);
		TAttCarga[panelid] = 0;
		return 1;
	}
	if(QtAttCarga[panelid] > 0) {
		if(QtAttCarga[panelid] <= TaxaRefinaria) {
			vInfo[Engate[panelid]][vCargaGas] += QtAttCarga[panelid];
			if(panelid <= 3) {			// Refinaria
				TankQt[panelid] -= QtAttCarga[panelid];
			} else if(panelid == 4) { 	// Posto DM
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGDM][i][prQuant] -= QtAttCarga[panelid];
						break;
					}
				}
			} else if(panelid == 5) {	// Posto MG
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGMG][i][prQuant] -= QtAttCarga[panelid];
						break;
					}
				}
			}
			QtAttCarga[panelid] = 0;
			KillTimer(TAttCarga[panelid]);
			TAttCarga[panelid] = 0;
			Amb(P[0], P[1], P[2], "Enchimento da carga completo. (( Painel ))");
			return 1;
		} else {
			QtAttCarga[panelid] -= TaxaRefinaria;
			vInfo[Engate[panelid]][vCargaGas] += TaxaRefinaria;
			if(panelid <= 3) {			// Refinaria
				TankQt[panelid] -= TaxaRefinaria;
			} else if(panelid == 4) { 	// Posto DM
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGDM][i][prQuant] -= TaxaRefinaria;
						break;
					}
				}
			} else if(panelid == 5) {	// Posto MG
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGMG][i][prQuant] -= TaxaRefinaria;
						break;
					}
				}
			}
		}
	} else if(QtAttCarga[panelid] < 0) {
		QtAttCarga[panelid] *= -1;
		if(QtAttCarga[panelid] <= TaxaRefinaria) {
			vInfo[Engate[panelid]][vCargaGas] -= QtAttCarga[panelid];
			if(panelid <= 3) {			// Refinaria
				TankQt[panelid] += QtAttCarga[panelid];
			} else if(panelid == 4) { 	// Posto DM
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGDM][i][prQuant] += QtAttCarga[panelid];
						break;
					}
				}
			} else if(panelid == 5) {	// Posto MG
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGMG][i][prQuant] += QtAttCarga[panelid];
						break;
					}
				}
			}
			QtAttCarga[panelid] = 0;
			KillTimer(TAttCarga[panelid]);
			TAttCarga[panelid] = 0;
			Amb(P[0], P[1], P[2], "Esvaziamento da carga completo. (( Painel ))");
			return 1;
		} else {
			QtAttCarga[panelid] -= TaxaRefinaria;
			vInfo[Engate[panelid]][vCargaGas] -= TaxaRefinaria;
			if(panelid <= 3) {			// Refinaria
				TankQt[panelid] += TaxaRefinaria;
			} else if(panelid == 4) { 	// Posto DM
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGDM][i][prQuant] += TaxaRefinaria;
						break;
					}
				}
			} else if(panelid == 5) {	// Posto MG
				for(new i = 0; i < MAX_PRODUTOS; i++) {
					if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
					if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
						prInfo[BUSID_PGMG][i][prQuant] += TaxaRefinaria;
						break;
					}
				}
			}
		}
		QtAttCarga[panelid] *= -1;
	}
	return 1;
}

forward VerifyEngate(vehicleid, panelid);
public VerifyEngate(vehicleid, panelid) {
	if(!IsValidVehicle(vehicleid)) {
		KillTimer(TVerifyEngate[panelid-1]);
		TVerifyEngate[panelid-1] = 0;
		if(panelid >= 5 || panelid <= 6) {
			DestroyObject(CanoEngate[panelid-5]);
		}
		return 1;
	}
	new Float:A;
	GetVehicleZAngle(vehicleid, A);
	if(panelid <= 4) { if(A > 100.0 || A < 80.0)  { Engate[panelid-1] = 0; } }
	else if(panelid == 1) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-639.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 2) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-662.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 3) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-685.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 4) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, -983.9913,-708.9285,33.1292)) { Engate[panelid-1] = 0; } }
	else if(panelid == 5) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, 664.9177,-579.4975,17.3650)) { Engate[panelid-1] = 0; } }
	else if(panelid == 6) { if(!IsVehicleInRangeOfPoint(vehicleid, 3.0, 1350.7700,476.1723,21.3702)) { Engate[panelid-1] = 0; } }
	if(!Engate[panelid-1]) {
		KillTimer(TVerifyEngate[panelid-1]);
		TVerifyEngate[panelid-1] = 0;
		if(panelid >= 5 || panelid <= 6) {
			DestroyObject(CanoEngate[panelid-5]);
		}
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
		format(str, 15, "Gasolina T%i", i+1);
		mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE name = '%s'", TankQt[i], str);
		mysql_query(conn, query, false);
	}
	for(new i = 0; i < MAX_PRODUTOS; i++) {
		if(!prInfo[BUSID_PGDM][i][prSQL]) continue;
		if(!strcmp(prInfo[BUSID_PGDM][i][prName], "Gasolina", false)) {
			mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_PGDM][i][prQuant], prInfo[BUSID_PGDM][i][prSQL]);
			mysql_query(conn, query, false);
			break;
		}
	}
	for(new i = 0; i < MAX_PRODUTOS; i++) {
		if(!prInfo[BUSID_PGMG][i][prSQL]) continue;
		if(!strcmp(prInfo[BUSID_PGMG][i][prName], "Gasolina", false)) {
			mysql_format(conn, query, 150, "UPDATE produtoinfo SET quant = %i WHERE sqlid = %i", prInfo[BUSID_PGMG][i][prQuant], prInfo[BUSID_PGMG][i][prSQL]);
			mysql_query(conn, query, false);
			break;
		}
	}
	return 1;
}

forward OnGameModeInit@refinaria();
public OnGameModeInit@refinaria() {
	new query[150], str[40], Cache:result, rows;
	for(new i = 0; i < 4; i++) {
		format(str, 15, "Gasolina T%i", i+1);
		mysql_format(conn, query, 150, "SELECT `quant` FROM `produtoinfo` WHERE `name` = '%s'", str);
		result = mysql_query(conn, query);
		cache_get_value_name_int(0, "quant", TankQt[i]);
		cache_delete(result);
	}
	mysql_format(conn, query, 150, "SELECT * FROM fichasinfo");
	result = mysql_query(conn, query);
	cache_get_row_count(rows);
	if(rows > MAX_FICHAS) return print("ERRO NO CARREGAMENTO DAS FICHAS DA REFINARIA");
	for(new i = 0; i < rows; i++) {
		 // sqlid destiny value carga
		cache_get_value_index_int(i, 0, fInfo[i][fSQL]);
		cache_get_value_name(i, "destiny", str);
		format(fInfo[i][fDestino], 40, "%s", str);
		cache_get_value_name_int(i, "value", fInfo[i][fValor]);
		cache_get_value_name_int(i, "carga", fInfo[i][fCarga]);
	}
	cache_delete(result);
	return 1;
}

stock ClearParametrosCFR(playerid) {
	format(ParametrosCFR[playerid][fpDestino], 2, "");
	ParametrosCFR[playerid][fpCarga] = 0;
	ParametrosCFR[playerid][fpValor] = 0;
	ParametrosCFR[playerid][fpID] = 0;
	return 1;
}