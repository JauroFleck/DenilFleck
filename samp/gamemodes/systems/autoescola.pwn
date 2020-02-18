enum AVAUTO_INFO {
	aaAO,
	aaAR,
	aaCP,
	aaVE
};

new AvAuto[MAX_BUSINESS_VEHICLES][AVAUTO_INFO];

new Float:CPAVAUTO[15][3] = {
	{650.3480,-487.8753,15.8167},
	{716.5928,-489.5588,15.8171},
	{718.2355,-595.1509,15.8171},
	{695.8887,-597.6196,15.8172},
	{678.7901,-656.0158,15.8173},
	{555.4431,-628.3126,26.3481},
	{407.7326,-612.2418,33.4774},
	{251.5605,-1016.0300,56.1953},
	{380.9700,-1148.4392,77.7085},
	{682.7929,-972.9283,51.6238},
	{604.6039,-702.6564,10.5745},
	{684.0857,-687.9335,15.8170},
	{683.6342,-544.1593,15.8154},
	{683.8315,-499.3346,15.8196},
	{643.7288,-499.5864,15.9658}
};

CMD:chaveauto(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/ChaveAuto [IDV]");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
	new i = 0;
	for(; i < MAX_BUSINESS_VEHICLES; i++) {
		if(bInfo[BUSID_AUTO][bVehicles][i] == vInfo[vid][vSQL]) { break; }
	}
	if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence à autoescola.");
	new str[144];
	if(vInfo[vid][vChave] == pInfo[playerid][pSQL]) {
		format(str, 144, "A chave do veículo de IDV %03i foi entregue de volta à autoescola.", vid);
		Info(playerid, str);
		vInfo[vid][vChave] = CLOC_AUTO;
	} else if(vInfo[vid][vChave] != CLOC_AUTO) {
		format(str, 144, "A chave do veículo de IDV %03i está nas mãos de alguém no momento, portanto indisponível.", vid);
		Info(playerid, str);
	} else {
		format(str, 144, "Você pegou a chave de IDV %03i. Faça a avaliação e não se esqueça de usar /ChaveAuto novamente.", vid);
		Info(playerid, str);
		vInfo[vid][vChave] = pInfo[playerid][pSQL];
	}
	return 1;
}

CMD:avaliar(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1 && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_AUTO && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Avaliar [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new vid = GetPlayerVehicleID(playerid);
	if(!vid) return Advert(playerid, "Você precisa estar no veículo da autoescola.");
	new seatid = GetPlayerVehicleSeat(playerid);
	if(seatid != 1) return Advert(playerid, "Você deve estar no assento ao lado do motorista.");
	if(GetPlayerVehicleID(id) != vid || GetPlayerVehicleSeat(id)) return Advert(playerid, "Quem fará o teste deve estar como motorista do veículo.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Você só pode fazer o teste de autoescola nos veículos da autoescola.");
	new i = 0;
	for(; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!bInfo[BUSID_AUTO][bVehicles][i]) continue;
		if(vInfo[vid][vSQL] == bInfo[BUSID_AUTO][bVehicles][i]) break;
	}
	if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Você só pode fazer o teste de autoescola nos veículos da autoescola.");
	for(new j = 0; j < MAX_BUSINESS_VEHICLES; j++) {
		if(!AvAuto[j][aaCP]) continue;
		else if(AvAuto[j][aaAR] == playerid) return Advert(playerid, "Você já iniciou uma avaliação. Finalize-a antes de iniciar outra.");
	}
	if(pInfo[id][pHab]) return Advert(playerid, "Esse indivíduo já possui habilitação.");
	AvAuto[i][aaAO] = id;
	AvAuto[i][aaAR] = playerid;
	AvAuto[i][aaCP] = 1;
	AvAuto[i][aaVE] = vid;
	pInfo[id][pCP] = CP_AVAUTO;
	SetPlayerCheckpoint(id, CPAVAUTO[0][0], CPAVAUTO[0][1], CPAVAUTO[0][2], 4.0);
	new str[144];
	format(str, 144, "Seu instrutor, %s, iniciou sua avaliação.", pName(playerid));
	Info(id, str);
	Info(playerid, "A avaliação foi iniciada. Preste atenção em cada movimento do seu motorista.");
	return 1;
}

CMD:cancelaravaliacao(playerid) {
	if(pInfo[playerid][pBus] == -1 && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Você é desempregado.");
	if(bInfo[BUSID_AUTO][bType] != BUSINESS_AUTO && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!AvAuto[i][aaCP]) continue;
		else if(AvAuto[i][aaAR] == playerid) {
			Info(playerid, "A avaliação foi cancelada.");
			Info(playerid, "Leve o veículo de volta para a autoescola.");
			if(IsPlayerConnected(AvAuto[i][aaAO])) {
				Info(AvAuto[i][aaAO], "Seu instrutor cancelou a avaliação. É de total direito seu solicitar um reembolso.");
				DisablePlayerCheckpoint(AvAuto[i][aaAO]);
				pInfo[AvAuto[i][aaAO]][pCP] = 0;
			}
			ResetAvAuto(i);
			return 1;
		}
	}
	Advert(playerid, "Você não iniciou avaliação alguma para poder cancelar.");
	return 1;
}

CMD:finalizaravaliacao(playerid) {
	if(pInfo[playerid][pBus] == -1 && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_AUTO && pInfo[playerid][pAdmin] < Ajudante) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!AvAuto[i][aaCP]) continue;
		else if(AvAuto[i][aaAR] == playerid) {
			if(AvAuto[i][aaCP] != 16) return Advert(playerid, "O avaliado ainda não terminou a fase de rotas. E não esqueça de avaliar a baliza.");
			new str[144];
			format(str, 144, "Conforme a avaliação que você prestou para %s, ele deve ser aprovado ou reprovado?", pName(AvAuto[i][aaAO]));
			Dialog_Show(playerid, "FinalizarAvaliacao", DIALOG_STYLE_MSGBOX, "Finalizar Avaliação", str, "Aprovar", "Reprovar");
			return 1;
		}
	}
	Advert(playerid, "Você não iniciou avaliação alguma para poder finalizar.");
	return 1;
}

Dialog:FinalizarAvaliacao(playerid, response, listitem, inputtext[]) {
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!AvAuto[i][aaCP]) continue;
		else if(AvAuto[i][aaAR] == playerid) {
			if(response) {
				new str[144];
				Info(playerid, "Você aprovou o avaliado.");
				format(str, 144, "entrega uma carta de habilitação para %s.", pName(AvAuto[i][aaAO]));
				Act(playerid, str);
				pInfo[AvAuto[i][aaAO]][pHab] = 1;
			} else {
				Info(playerid, "Você reprovou o avaliado. Notifique-o sobre isso.");
				pInfo[AvAuto[i][aaAO]][pHab] = 0;
			}
			ResetAvAuto(i);
			return 1;
		}
	}
	Advert(playerid, "Um erro inesperado aconteceu.");
	return 1;
}

forward OnPlayerDisconnect@autoescola(playerid);
public OnPlayerDisconnect@autoescola(playerid) {
	for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
		if(!AvAuto[i][aaCP]) continue;
		else if(AvAuto[i][aaAO] == playerid) {
			if(IsPlayerConnected(AvAuto[i][aaAR])) {
				Info(AvAuto[i][aaAR], "O player que estava sendo avaliado foi desconectado do servidor. Por favor retorne à autoescola.");
				vInfo[AvAuto[i][aaVE]][vChave] = pInfo[AvAuto[i][aaAR]][pSQL];
			} else {
				SetVehicleToRespawn(AvAuto[i][aaVE]);
				vInfo[AvAuto[i][aaVE]][vChave] = CLOC_AUTO;
			}
			return ResetAvAuto(i);
		} else if(AvAuto[i][aaAR] == playerid) {
			if(IsPlayerConnected(AvAuto[i][aaAO])) {
				Info(AvAuto[i][aaAO], "O player que estava te avaliando foi desconectado do servidor.");
				DisablePlayerCheckpoint(AvAuto[i][aaAO]);
				pInfo[AvAuto[i][aaAO]][pCP] = 0;
			}
			SetVehicleToRespawn(AvAuto[i][aaVE]);
			vInfo[AvAuto[i][aaVE]][vChave] = CLOC_AUTO;
			return ResetAvAuto(i);
		}
	}
	return 1;
}

forward OnPlayerEnterCheckpoint@auto(playerid);
public OnPlayerEnterCheckpoint@auto(playerid) {
	if(pInfo[playerid][pCP] == CP_AVAUTO) {
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!AvAuto[i][aaCP]) continue;
			else if(AvAuto[i][aaAO] == playerid) {
				DisablePlayerCheckpoint(playerid);
				if(AvAuto[i][aaCP] >= 15) {
					pInfo[playerid][pCP] = 0;
					Info(playerid, "Foi encerrada a fase de rota da avaliação. Prepare-se para as próximas orientações do instrutor.");
					Info(AvAuto[i][aaAR], "Foi encerrada a fase de rota da avaliação, agora oriente sobre a avaliação da baliza.");
					AvAuto[i][aaCP] = 16;
					return 1;
				}
				SetPlayerCheckpoint(playerid, CPAVAUTO[AvAuto[i][aaCP]][0], CPAVAUTO[AvAuto[i][aaCP]][1], CPAVAUTO[AvAuto[i][aaCP]][2], 4.0);
				AvAuto[i][aaCP]++;
				break;
			}
		}
	}
	return 1;
}

forward OnPlayerConnect@autoescola(playerid);
public OnPlayerConnect@autoescola(playerid) {
	RemoveBuildingForPlayer(playerid, 1503, 638.8359, -517.4766, 15.5469, 0.25);
	RemoveBuildingForPlayer(playerid, 1440, 642.7188, -511.0547, 15.8203, 0.25);
	return 1;
}

stock ResetAvAuto(id) {
	AvAuto[id][aaAO] = 0;
	AvAuto[id][aaAR] = 0;
	AvAuto[id][aaCP] = 0;
	AvAuto[id][aaVE] = 0;
	return 1;
}