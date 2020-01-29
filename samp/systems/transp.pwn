new PortaoTranspBB;

#define MAX_BOXES					17

#define BOXCONTENT_NONE				0
#define BOXCONTENT_CLOTHES			1
#define BOXCONTENT_FOOD				2
#define BOXCONTENT_DRINK			3

// WSP = Well Stacked Pizza | BUN = Padaria | KIR = King Ring | SPR = Sprunk | CAF = Café | CLO = Roupas

#define BOXDEST_NONE				0
#define BOXDEST_WSPBB				1
#define BOXDEST_WSPPC				2
#define BOXDEST_BUNMG				3
#define BOXDEST_KIRFC				4
#define BOXDEST_CAFFC				5
#define BOXDEST_SPRBB				6
#define BOXDEST_SPRMG				7
#define BOXDEST_BARDM				8
#define BOXDEST_BARFC				9
#define BOXDEST_CLODM				10
#define MAX_BOXDEST					10

new Float:BoxDest[MAX_BOXDEST][3] = {
	{203.5554,-182.7780,1.5781},
	{2323.6753,76.3521,26.4952},
	{1297.1293,353.3232,19.5547},
	{-146.6921,1237.0197,19.8992},
	{-190.7947,1218.7018,19.7422},
	{161.4998,-169.8608,1.5847},
	{1317.6255,345.3727,19.5547},
	{681.5496,-444.8724,16.3359},
	{-168.2877,1032.5535,19.7344},
	{658.9263,-634.6282,16.3359}
};

new Float:BoxCoord[MAX_BOXES][3] = {
	{258.343505, 20.071756, 2.007702},
	{264.715789, 21.645021, 3.647702},
	{259.311401, 20.225637, 2.007702},
	{260.345336, 20.411556, 2.007702},
	{265.650787, 21.813251, 3.647702},
	{266.457885, 21.958461, 3.647702},
	{267.274932, 22.105442, 3.647702},
	{268.229766, 22.277214, 3.647702},
	{268.229766, 22.277214, 1.987703},
	{267.363769, 22.121379, 1.987703},
	{266.517181, 21.969087, 1.987703},
	{265.651092, 21.813247, 1.987703},
	{264.725708, 21.646793, 1.987703},
	{262.459564, 30.627412, 1.927703},
	{263.444061, 30.804489, 1.927703},
	{263.444061, 30.804489, 2.997702},
	{262.518768, 30.638027, 2.997702}
};

enum BOX_INFO {
	boxID,
	Text3D:boxLabel,
	boxSlotid,
	boxPlayerid,
	boxVehicleid,
	boxContent,
	boxDestiny,
	boxValue
};

new BoxInfo[MAX_BOXES][BOX_INFO];

CMD:pegarcaixa(playerid, params[]) {
	if(pInfo[playerid][pBus] != BUSID_TRANSP) return Advert(playerid, "Apenas funcionários da transportadora podem fazer isso.");
	new i;
	if(sscanf(params, "i", i)) return AdvertCMD(playerid, "/PegarCaixa [Número da Caixa]");
	if(i < 0 || i >= MAX_BOXES) return Advert(playerid, "Caixa inexistente.");
	for(new k = 0; k < MAX_BOXES; k++) {
		if(BoxInfo[k][boxPlayerid] == playerid) return Advert(playerid, "Você só pode carregar uma caixa de cada vez.");
	}
	if(BoxInfo[i][boxSlotid] == -1) return Advert(playerid, "Não é possível pegar essa caixa.");
	if(IsPlayerInRangeOfPoint(playerid, 2.0, BoxCoord[BoxInfo[i][boxSlotid]][0], BoxCoord[BoxInfo[i][boxSlotid]][1], BoxCoord[BoxInfo[i][boxSlotid]][2])) {
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		SetPlayerAttachedObject(playerid, 0, 1271, 6, 0.1, 0.31, -0.28, 250.0, 0.0, 80.0);
		DestroyDynamicObject(BoxInfo[i][boxID]);
		DestroyDynamic3DTextLabel(BoxInfo[i][boxLabel]);
		BoxInfo[i][boxID] = 0;
		BoxInfo[i][boxPlayerid] = playerid;
		BoxInfo[i][boxSlotid] = -1;
		Act(playerid, "pega uma caixa e a carrega em seus braços.");
	} else {
		Advert(playerid, "Você deve estar próximo à caixa para pegá-la.");
	}
	return 1;
}

CMD:soltarcaixa(playerid) {
	new i = 0, p = 0;
	for(; i < MAX_BOXES; i++) {
		if(BoxInfo[i][boxPlayerid] == playerid) break;
	}
	if(i == MAX_BOXES) return Advert(playerid, "Você não está carregando nenhuma caixa.");
	for(new j = 0; j < MAX_BOXES; j++) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, BoxCoord[j][0], BoxCoord[j][1], BoxCoord[j][2])) continue;
		else {
			p = 0;
			for(new k = 0; k < MAX_BOXES; k++) {
				if(BoxInfo[k][boxSlotid] == j) { p = 1; }
			}
			if(p) continue;
			else {
				new str[3];
				format(str, 3, "%02i", i);
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
				RemovePlayerAttachedObject(playerid, 0);
				BoxInfo[i][boxSlotid] = j;
				BoxInfo[i][boxPlayerid] = -1;
				BoxInfo[i][boxID] = CreateDynamicObject(1271, BoxCoord[j][0], BoxCoord[j][1], BoxCoord[j][2], 0.000000, 0.000000, 10.200001, -1, -1, -1, 300.00, 300.00);
				BoxInfo[i][boxLabel] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, BoxCoord[j][0], BoxCoord[j][1], BoxCoord[j][2], 3.0);
				return 1;
			}
		}
	}
	Advert(playerid, "Você não pode soltar a caixa em qualquer lugar, apenas nas prateleiras da transportadora.");
	return 1;
}

CMD:et(playerid, params[]) return cmd_etiqueta(playerid, params);

CMD:etiqueta(playerid, params[]) {
	new i;
	if(sscanf(params, "i", i)) return AdvertCMD(playerid, "/Et"BRANCO"iqueta"AMARELO" [Número da Caixa]");
	if(i < 0 || i >= MAX_BOXES) return Advert(playerid, "Caixa inexistente.");
	if(BoxInfo[i][boxSlotid] == -1 && BoxInfo[i][boxPlayerid] != playerid) return Advert(playerid, "Não é possível ler essa caixa.");
	new leitura = 0, emmaos = 0;
	if(BoxInfo[i][boxPlayerid] == playerid) { leitura = 1; emmaos = 1; }
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, BoxCoord[BoxInfo[i][boxSlotid]][0], BoxCoord[BoxInfo[i][boxSlotid]][1], BoxCoord[BoxInfo[i][boxSlotid]][2])) { leitura = 1; }
	if(!leitura) return Advert(playerid, "Você deve estar próximo à caixa ou segurando-a para ler sua etiqueta.");
	new str[150];
	format(str, 150, BRANCO"Conteúdo: ");
	if(BoxInfo[i][boxContent] == BOXCONTENT_FOOD) { format(str, 150, "%sComida.\n", str);
	} else if(BoxInfo[i][boxContent] == BOXCONTENT_DRINK) { format(str, 150, "%sBebida.\n", str);
	} else if(BoxInfo[i][boxContent] == BOXCONTENT_CLOTHES) { format(str, 150, "%sRoupas.\n", str);
	} else return Advert(playerid, "Um erro inesperado aconteceu. Informe à administração sobre essa mensagem. [COD 018]");
	format(str, 150, "%sDestino: %s.", str, GetBoxDestinyName(BoxInfo[i][boxDestiny]));
	if(!emmaos) {
		Dialog_Show(playerid, "Etiqueta", DIALOG_STYLE_MSGBOX, "Etiqueta", str, "Pegar", "Fechar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_Etiqueta");
		pInfo[playerid][pDialogParam][1] = i;
	} else {
		Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "Etiqueta", str, "Fechar", "");
	}
	return 1;
}

CMD:carregar(playerid, params[]) {
	if(pInfo[playerid][pBus] != BUSID_TRANSP) return Advert(playerid, "Apenas funcionários da transportadora podem fazer isso.");
	new i = 0;
	for(; i < MAX_BOXES; i++) {
		if(BoxInfo[i][boxPlayerid] == playerid) break;
	}
	if(i == MAX_BOXES) return Advert(playerid, "Você não está carregando nenhuma caixa.");
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/Carregar [IDV]");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inválido.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	new j = 0;
	for(; j < MAX_BUSINESS_VEHICLES; j++) {
		if(bInfo[BUSID_TRANSP][bVehicles][j] == vInfo[vid][vSQL]) break;
	}
	if(j == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Você só pode carregar em veículos da empresa.");
	new Float:P[6], Float:D, modelid = GetVehicleModel(vid);
	GetVehicleBootDistance(modelid, D);
	if(!D) return Advert(playerid, "Veículo sem portamalas. :P");
	GetVehiclePos(vid, P[0], P[1], P[2]);
	GetVehicleZAngle(vid, P[3]);
	GetXYInFrontOfXY(P[0], P[1], D, (P[3]+180.0), P[4], P[5]);
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, P[4], P[5], P[2])) return Advert(playerid, "Você deve estar próximo ao portamalas do veículo.");
	if(!vInfo[vid][vBoot]) return Advert(playerid, "O portamalas do veículo deve estar aberto.");
	new k = 0, n = GetVehicleBootSlots(modelid);
	for(; k < n; k++) {
		if(!vInfo[vid][vBootSlot][k]) break;
	}
	if(k == n) return Advert(playerid, "Todos os slots do portamalas desse veículo estão ocupados.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	RemovePlayerAttachedObject(playerid, 0);
	BoxInfo[i][boxPlayerid] = -1;
	BoxInfo[i][boxVehicleid] = vid;
	Act(playerid, "carrega uma caixa no veículo.");
	vInfo[vid][vBootSlot][k] = i+1;
	//AttachObjectToVehicle(objectid, vehicleid, Float:OffsetX, Float:OffsetY, Float:OffsetZ, Float:RotX, Float:RotY, Float:RotZ);
	return 1;
}

CMD:cargas(playerid, params[]) {
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/Cargas [IDV]");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inválido.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	new j = 0;
	for(; j < MAX_BUSINESS_VEHICLES; j++) {
		if(bInfo[BUSID_TRANSP][bVehicles][j] == vInfo[vid][vSQL]) break;
	}
	if(j == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não suporta caixas.");
	new Float:P[6], Float:D, modelid = GetVehicleModel(vid);
	GetVehicleBootDistance(modelid, D);
	if(!D) return Advert(playerid, "Veículo sem portamalas. :P");
	GetVehiclePos(vid, P[0], P[1], P[2]);
	GetVehicleZAngle(vid, P[3]);
	GetXYInFrontOfXY(P[0], P[1], D, (P[3]+180.0), P[4], P[5]);
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, P[4], P[5], P[2])) return Advert(playerid, "Você deve estar próximo ao portamalas do veículo.");
	if(!vInfo[vid][vBoot]) return Advert(playerid, "O portamalas do veículo deve estar aberto.");
	new k = 0, n = GetVehicleBootSlots(modelid), str[400];
	for(; k < n; k++) {
		if(vInfo[vid][vBootSlot][k]) {
			format(str, 400, "%sCaixa %02i - Destino: %s.\n", str, vInfo[vid][vBootSlot][k]-1, GetBoxDestinyName(BoxInfo[vInfo[vid][vBootSlot][k]-1][boxDestiny]));
		}
	}
	if(isnull(str)) return Advert(playerid, "Portamalas vazio.");
	new str2[12];
	format(str2, 12, "Cargas %03i", vid);
	Dialog_Show(playerid, "BoxLoading", DIALOG_STYLE_LIST, str2, str, "Descarregar", "Cancelar");
	pInfo[playerid][pDialogParam][0] = funcidx("dialog_BoxLoading");
	pInfo[playerid][pDialogParam][1] = vid;
	pInfo[playerid][pDialogParam][2] = vInfo[vid][vSQL];
	return 1;
}

Dialog:BoxLoading(playerid, response, listitem, inputtext[]) {
	if(response && pInfo[playerid][pDialogParam][0] == funcidx("dialog_BoxLoading")) {
		new vid = pInfo[playerid][pDialogParam][1];
		if(IsValidVehicle(vid)) {
			new sql = pInfo[playerid][pDialogParam][2];
			if(vInfo[vid][vSQL] == sql) {
				new k = 0, n = GetVehicleBootSlots(GetVehicleModel(vid)), li = 0;
				for(; k < n; k++) {
					if(vInfo[vid][vBootSlot][k]) {
						if(listitem == li) {
							SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
							SetPlayerAttachedObject(playerid, 0, 1271, 6, 0.1, 0.31, -0.28, 250.0, 0.0, 80.0);
							BoxInfo[vInfo[vid][vBootSlot][k]-1][boxPlayerid] = playerid;
							BoxInfo[vInfo[vid][vBootSlot][k]-1][boxVehicleid] = -1;
							vInfo[vid][vBootSlot][k] = 0;
							Act(playerid, "descarrega uma caixa do veículo.");
							break;
						} else { li++; }
					}
				}
			}
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:Etiqueta(playerid, response, listitem, inputtext[]) {
	if(response && pInfo[playerid][pDialogParam][0] == funcidx("dialog_Etiqueta")) {
		if(pInfo[playerid][pBus] != BUSID_TRANSP) return Advert(playerid, "Apenas funcionários da transportadora podem fazer isso.");
		new i = 0, cid = pInfo[playerid][pDialogParam][1];
		for(; i < MAX_BOXES; i++) {
			if(i == cid) continue;
			if(BoxInfo[i][boxPlayerid] == playerid) break;
		}
		if(i < MAX_BOXES) { Advert(playerid, "Você só pode carregar uma caixa de cada vez.");
		} else {
			if(BoxInfo[cid][boxSlotid] == -1) { Advert(playerid, "Alguém já pegou essa caixa.");
			} else {
				SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
				SetPlayerAttachedObject(playerid, 0, 1271, 6, 0.1, 0.31, -0.28, 250.0, 0.0, 80.0);
				DestroyDynamicObject(BoxInfo[cid][boxID]);
				DestroyDynamic3DTextLabel(BoxInfo[cid][boxLabel]);
				BoxInfo[cid][boxID] = 0;
				BoxInfo[cid][boxPlayerid] = playerid;
				BoxInfo[cid][boxSlotid] = -1;
				Act(playerid, "pega uma caixa e a carrega em seus braços.");
			}
		}
	}
	return ResetDialogParams(playerid);
}

CMD:entregarcaixa(playerid) {
	new i = 0;
	for(; i < MAX_BOXES; i++) {
		if(BoxInfo[i][boxPlayerid] == playerid) break;
	}
	if(i == MAX_BOXES) return Advert(playerid, "Você não está carregando nenhuma caixa.");
	for(new j = 0; j < MAX_BOXDEST; j++) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, BoxDest[j][0], BoxDest[j][1], BoxDest[j][2])) continue;
		else {
			if(BoxInfo[i][boxDestiny] != j+1) return Advert(playerid, "O destino dessa caixa não é este.");
			SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
			RemovePlayerAttachedObject(playerid, 0);
			BoxInfo[i][boxPlayerid] = -1;
			Act(playerid, "entrega uma caixa para o estabelecimento.");
			new value;
			if(j == 0) { value = 18+random(10);
			} else if(j == 1) { value = 80+random(20);
			} else if(j == 2) { value = 45+random(15);
			} else if(j == 3) { value = 55+random(20);
			} else if(j == 4) { value = 55+random(20);
			} else if(j == 5) { value = 18+random(10);
			} else if(j == 6) { value = 45+random(15);
			} else if(j == 7) { value = 40+random(12);
			} else if(j == 8) { value = 55+random(15);
			} else if(j == 9) { value = 40+random(12); }
			GivePlayerMoney(playerid, value);
			new str[8];
			format(str, 8, "~g~+%i", value);
			GameTextForPlayer(playerid, str, 1000, 1);
			bInfo[BUSID_TRANSP][bReceita] += (value/5);
			// Criar caixa compensatória
			new k = 0, s = 0;
			for(; k < MAX_BOXES; k++) {
				s = BoxSlotID(k);
				if(s == MAX_BOXES) break;
			}
			if(k == MAX_BOXES) return Advert(playerid, "Um erro inesperado aconteceu. Informe à administração sobre essa mensagem. [COD 018]");
			BoxInfo[i][boxSlotid] = k;
			BoxInfo[i][boxVehicleid] = -1;
			format(str, 3, "%02i", i);
			BoxInfo[i][boxID] = CreateDynamicObject(1271, BoxCoord[k][0], BoxCoord[k][1], BoxCoord[k][2], 0.000000, 0.000000, 10.200001, -1, -1, -1, 300.00, 300.00);
			BoxInfo[i][boxLabel] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, BoxCoord[k][0], BoxCoord[k][1], BoxCoord[k][2], 3.0);
			BoxInfo[i][boxContent] = random(3)+1;
			if(BoxInfo[i][boxContent] == BOXCONTENT_FOOD) {
				BoxInfo[i][boxDestiny] = random(5)+1;
			} else if(BoxInfo[i][boxContent] == BOXCONTENT_DRINK) {
				BoxInfo[i][boxDestiny] = random(4)+6;
			} else if(BoxInfo[i][boxContent] == BOXCONTENT_CLOTHES) {
				BoxInfo[i][boxDestiny] = random(1)+10;
			}
			return 1;
		}
	}
	Advert(playerid, "Você não está em um lugar onde se entregam caixas.");
	return 1;
}

forward OnGameModeInit@transp();
public OnGameModeInit@transp() {
	new str[3];
	for(new i = 0; i < MAX_BOXES; i++) {
		BoxInfo[i][boxID] = CreateDynamicObject(1271, BoxCoord[i][0], BoxCoord[i][1], BoxCoord[i][2], 0.000000, 0.000000, 10.200001, -1, -1, -1, 300.00, 300.00);
		format(str, 3, "%02i", i);
		BoxInfo[i][boxLabel] = CreateDynamic3DTextLabel(str, 0xFFFFFFFF, BoxCoord[i][0], BoxCoord[i][1], BoxCoord[i][2], 3.0);
		BoxInfo[i][boxSlotid] = i;
		BoxInfo[i][boxPlayerid] = -1;
		BoxInfo[i][boxVehicleid] = -1;
		BoxInfo[i][boxContent] = random(3)+1;
		if(BoxInfo[i][boxContent] == BOXCONTENT_FOOD) {
			BoxInfo[i][boxDestiny] = random(5)+1;
		} else if(BoxInfo[i][boxContent] == BOXCONTENT_DRINK) {
			BoxInfo[i][boxDestiny] = random(4)+6;
		} else if(BoxInfo[i][boxContent] == BOXCONTENT_CLOTHES) {
			BoxInfo[i][boxDestiny] = random(1)+10;
		}
	}
	for(new i = 0; i < MAX_BOXDEST; i++) {
		CreateDynamicObject(19198, BoxDest[i][0], BoxDest[i][1], BoxDest[i][2], 0.0, 0.0, 0.0);
	}
	return 1;
}

forward OnPlayerConnect@transp(playerid);
public OnPlayerConnect@transp(playerid) {
	RemoveBuildingForPlayer(playerid, 13059, 266.359, 20.132, 5.484, 0.250);
	RemoveBuildingForPlayer(playerid, 13062, 266.359, 20.132, 5.484, 0.250);
	RemoveBuildingForPlayer(playerid, 1440, 255.272, 22.773, 1.898, 0.250);
	RemoveBuildingForPlayer(playerid, 1684, 276.843, -2.429, 2.882, 0.250);
	RemoveBuildingForPlayer(playerid, 1440, 243.953, 24.617, 2.015, 0.250);
	RemoveBuildingForPlayer(playerid, 3287, 259.835, -4.031, 6.109, 0.250);
	RemoveBuildingForPlayer(playerid, 3296, 259.835, -4.031, 6.109, 0.250);
	return 1;
}

stock BoxSlotID(slotid) {
	new i = 0;
	for(; i < MAX_BOXES; i++) {
		if(BoxInfo[i][boxSlotid] == slotid) break;
	}
	return i;
}

stock GetBoxDestinyName(destinyid) {
	new str[37];
	if(destinyid == 1) format(str, 32, "Well Stacked Pizza de Blueberry");
	else if(destinyid == 2) format(str, 37, "Well Stacked Pizza de Palomino Creek");
	else if(destinyid == 3) format(str, 23, "Padaria de Montgomery");
	else if(destinyid == 4) format(str, 26, "King Ring de Fort Carson");
	else if(destinyid == 5) format(str, 21, "Café de Fort Carson");
	else if(destinyid == 6) format(str, 21, "Sprunk de Blueberry");
	else if(destinyid == 7) format(str, 22, "Sprunk de Montgomery");
	else if(destinyid == 8) format(str, 18, "Bar de Dillimore");
	else if(destinyid == 9) format(str, 20, "Bar de Fort Carson");
	else if(destinyid == 10) format(str, 29, "Loja de roupas de Dillimore");
	return str;
}