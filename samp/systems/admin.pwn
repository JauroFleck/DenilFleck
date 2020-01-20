new BlockSV;
new BlockR;

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// COMANDOS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:staff(playerid) {
	new str[500];
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(pInfo[i][pAdmin] > Plantonista) { format(str, 500, "%s\t[%02i] %s\n", str, i, Staff(i)); }
	}
	if(isnull(str)) return Advert(playerid, "Não há membros da staff disponíveis no momento.");
	else {
		format(str, 500, BRANCO"\t\tMembros da Staff disponíveis no momento:\n\n%s", str);
	}
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "STAFF", str, "Fechar", "");
	return 1;
}

CMD:vstaff(playerid) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	if(!vStaff[playerid][vsID]) {
		new Float:P[4];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		GetPlayerFacingAngle(playerid, P[3]);
		vStaff[playerid][vsModel] = 400;
		vStaff[playerid][vsID] = CreateVehicle(400, P[0], P[1], P[2], P[3], 0, 0, 0);
		Info(playerid, "Você não tinha vStaff definido. Foi criado um nas condições padrões.");
		PutPlayerInVehicle(playerid, vStaff[playerid][vsID], 0);
	} else {
		Dialog_Show(playerid, "DialogvStaff", DIALOG_STYLE_LIST, "Veículo Staff", "Puxar\nIr até\nModelo\nCor 1\nCor 2\nRespawnar\nDefinir Spawn\nDestruir", "Escolher", "Cancelar");
		return 1;
	}
	return 1;
}

CMD:palomino(playerid) {
	SetPlayerPos(playerid, 2223.8, -30.1, 26.0);
	return 1;
}

CMD:r(playerid) {
	if(!BlockR) {
		if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Você deve estar dentro do veículo para repará-lo.");
		new vid, Float:A;
		vid = GetPlayerVehicleID(playerid);
		GetVehicleZAngle(vid, A);
		RepairVehicle(vid);
		SetVehicleZAngle(vid, A);
	} else {
		Advert(playerid, "Comando /R bloqueado.");
	}
	return 1;
}

CMD:blockr(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	if(BlockR) {
		BlockR = 0;
		Info(playerid, "Comando /R desbloqueado.");
	} else {
		BlockR = 1;
		Info(playerid, "Comando /R bloqueado.");
	}
	return 1;
}

CMD:blocksv(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	if(BlockSV) {
		BlockSV = 0;
		Info(playerid, "Comando /SV desbloqueado.");
	} else {
		BlockSV = 1;
		Info(playerid, "Comando /SV bloqueado.");
	}
	return 1;
}

CMD:skin(playerid, params[]) {
	new skinid;
	if(sscanf(params, "i", skinid)) return SendClientMessage(playerid, -1, "Use /Skin [ID].");
	if(skinid < 0 || skinid > 311) return SendClientMessage(playerid, -1, "-1 > SKIN > 312");
	SetPlayerSkin(playerid, skinid);
	return 1;
}

CMD:ir(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	new id, Float:Front, Float:Upper, Float:Side;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Ir [ID] [Distância a frente] [Distância acima] [Distância ao lado]");
	sscanf(params, "ifff", id, Front, Upper, Side);
	if(!IsPlayerConnected(id)) return Advert(playerid, "Usuário offline.");
	if(pInfo[id][pLogged] != 1) return Advert(playerid, "Usuário na tela de login/registro.");
	new Float:P[4];
	GetPlayerPos(id, P[0], P[1], P[2]);
	GetPlayerFacingAngle(id, P[3]);
	GetXYInFrontOfPlayer(id, Front, P[0], P[1]);
	P[2] += Upper;
	GetXYInFrontOfXY(P[0], P[1], Side, (P[3]-90), P[0], P[1]);	new vw = GetPlayerVirtualWorld(id), interiorid = GetPlayerInterior(id);
	SetPlayerInterior(playerid, interiorid);
	SetPlayerVirtualWorld(playerid, vw);
	Streamer_UpdateEx(playerid, P[0], P[1], P[2], vw, interiorid, -1, 1500);
	return 1;
}

CMD:puxar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	new id, Float:Front, Float:Upper, Float:Side;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Puxar [ID] [Distância a frente] [Distância acima] [Distância ao lado]");
	sscanf(params, "ifff", id, Front, Upper, Side);
	if(!IsPlayerConnected(id)) return Advert(playerid, "Usuário offline.");
	if(pInfo[id][pLogged] != 1) return Advert(playerid, "Usuário na tela de login/registro.");
	if(pInfo[id][pAdmin] >= Senior) return Advert(playerid, "Não se pode puxar Sênior nem Fundador.");
	new Float:P[4];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[3]);
	GetXYInFrontOfPlayer(playerid, Front, P[0], P[1]);
	P[2] += Upper;
	GetXYInFrontOfXY(P[0], P[1], Side, (P[3]-90), P[0], P[1]);
	SetPlayerInterior(id, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(id, GetPlayerVirtualWorld(playerid));
	new vw = GetPlayerVirtualWorld(playerid), interiorid = GetPlayerInterior(playerid);
	SetPlayerInterior(id, interiorid);
	SetPlayerVirtualWorld(id, vw);
	Streamer_UpdateEx(id, P[0], P[1], P[2], vw, interiorid, -1, 1500);
	return 1;
}

CMD:irv(playerid, params[]) {
	new vid;
	if(sscanf(params, "i", vid)) return SendClientMessage(playerid, -1, "Use /IrV [IDV].");
	if(!GetVehicleModel(vid)) return SendClientMessage(playerid, -1, "Veículo inexistente.");
	PutPlayerInVehicle(playerid, vid, 0);
	return 1;
}

CMD:vida(playerid) {
	SetPlayerHealth(playerid, 100.0);
	return 1;
}

CMD:closeserver(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return SendClientMessage(playerid, -1, "Nananinanão (:");
	SendClientMessageToAll(-1, "O Programador John Black fechou o Servidor.");
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		KickPlayer(i);
	}
	SendRconCommand("exit");
	return 1;
}

CMD:sdinheiro(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id, mon;
	if(sscanf(params, "ii", id, mon)) return AdvertCMD(playerid, "/sDinheiro [ID] [Dinheiro]");
	ResetPlayerMoney(id);
	GivePlayerMoney(id, mon);
	new str[144];
	format(str, 144, "Você setou $%i para o player %s.", mon, pName(id));
	Info(playerid, str);
	format(str, 144, "O staff %s setou $%i para você.", pName(playerid), mon);
	Success(id, str);
	return 1;
}

CMD:sv(playerid, params[]) {
	if(!BlockSV) {
		new Float:vel;
		if(sscanf(params, "f", vel)) return AdvertCMD(playerid, "/SV [Velocidade]");
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um veículo.");
		if(vel > 5000) { Success(playerid, "LANÇASTE"); Info(playerid, "sqn"); return 1; }
		new vid = GetPlayerVehicleID(playerid);
		new Float:A, Float:V[2];
		GetVehicleZAngle(vid, A);
		vel /= 162.7;
		V[0] = vel*floatsin(-A, degrees);
		V[1] = vel*floatcos(-A, degrees);
		SetVehicleVelocity(vid, V[0], V[1], 0.0);
	} else {
		Advert(playerid, "Cabeça de pica.");
	}
	return 1;
}

CMD:jump(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um veículo.");
	new vid = GetPlayerVehicleID(playerid);
	new Float:V[3];
	GetVehicleVelocity(vid, V[0], V[1], V[2]);
	V[2] += 0.2;
	SetVehicleVelocity(vid, V[0], V[1], V[2]);
	return 1;
}

CMD:ajudar(playerid, params[]) {
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Ajudar [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	new i = 0;
	for(; i < MAX_ATENDIMENTOS; i++) {
		if(SolAtd[i] == id+1) break;
	}
	if(i == MAX_ATENDIMENTOS) return Advert(playerid, "Este player não solicitou atendimento ou já está sendo/foi atendido.");
	SolAtd[i] = 0;
	pInfo[playerid][pAtd] = id+1;
	new str[144];
	format(str, 144, "O %s atendeu sua solicitação. Para conversar com ele use o sinal ponto (.) antes da mensagem. Exemplo:", Staff(playerid));
	Success(id, str);
	SendClientMessage(id, AzulPiscina, ".Oi adm, como eu pego profissão?");
	Info(id, "Quando satisfeito, use "AMARELO"/FinalizarAtendimento"BRANCO".");
	format(str, 144, "Você atendeu a solicitação de ajuda do player %s [%i].", pNick(id), id);
	Info(playerid, str);
	return 1;
}

CMD:setsen(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fundador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/SetSen [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] >= Senior) return Advert(playerid, "Este player já tem cargo sênior ou maior.");
	pInfo[id][pAdmin] = Senior;
	new str[144];
	format(str, 144, "Você promoveu %s para Sênior.", pNick(id));
	Info(playerid, str);
	Success(id, "Você foi promovido a Sênior.");
	return 1;
}

CMD:setadm(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/SetAdm [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] == Administrador) return Advert(playerid, "Este player já tem cargo administrador.");
	pInfo[id][pAdmin] = Administrador;
	new str[144];
	format(str, 144, "Você promoveu %s para administrador.", pNick(id));
	Info(playerid, str);
	Success(id, "Você foi promovido a administrador.");
	return 1;
}

CMD:setfis(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/SetFis [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] == Fiscalizador) return Advert(playerid, "Este player já tem cargo fiscalizador.");
	pInfo[id][pAdmin] = Fiscalizador;
	new str[144];
	format(str, 144, "Você promoveu %s para fiscalizador.", pNick(id));
	Info(playerid, str);
	Success(id, "Você foi promovido a fiscalizador.");
	return 1;
}

CMD:setaju(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/SetAju [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] == Ajudante) return Advert(playerid, "Este player já tem cargo ajudante.");
	pInfo[id][pAdmin] = Ajudante;
	new str[144];
	format(str, 144, "Você promoveu %s para ajudante.", pNick(id));
	Info(playerid, str);
	Success(id, "Você foi promovido a ajudante.");
	return 1;
}

CMD:setpla(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/SetPlant [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] == Plantonista) return Advert(playerid, "Este player já tem cargo plantonista.");
	pInfo[id][pAdmin] = Plantonista;
	new str[144];
	format(str, 144, "Você promoveu %s para plantonista.", pNick(id));
	Info(playerid, str);
	Success(id, "Você foi promovido a plantonista.");
	return 1;
}

CMD:unsetstaff(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/UnsetStaff [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	if(pInfo[id][pAdmin] == Player) return Advert(playerid, "Este player já não possui cargo na staff.");
	pInfo[id][pAdmin] = Player;
	new str[144];
	format(str, 144, "Você removeu o cargo de %s.", pNick(id));
	Info(playerid, str);
	Success(id, "Seu cargo da staff foi removido.");
	return 1;
}

CMD:finalizaratendimento(playerid) {
	new str[144];
	if(pInfo[playerid][pAtd]) {
		format(str, 144, "O %s finalizou o atendimento.", Staff(playerid));
		Info(pInfo[playerid][pAtd]-1, str);
		Info(playerid, "Você finalizou o atendimento.");
		pInfo[playerid][pAtd] = 0;
	} else {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			if(pInfo[i][pAtd] == playerid+1) {
				format(str, 144, "O %s finalizou o atendimento.", Staff(playerid));
				Info(i, str);
				Info(playerid, "Você finalizou o atendimento.");
				pInfo[i][pAtd] = 0;
				return 0;
			}
		}
	}
	return 1;
}

CMD:jetpack(playerid) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) {
		Info(playerid, "Jetpack removido.");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	} else {
		Info(playerid, "Jetpack adicionado.");
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
	}
	return 1;
}

CMD:irpos(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new Float:P[3];
	if(sscanf(params, "fff", P[0], P[1], P[2])) return AdvertCMD(playerid, "/IrPos [X] [Y] [Z]");
	new str[144];
	format(str, 144, "X: %.2f | Y: %.2f | Z: %.2f", P[0], P[1], P[2]);
	Info(playerid, str);
	SetPlayerPos(playerid, P[0], P[1], P[2]);
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////// DIALOGS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Dialog:SolicitarAtd(playerid, response, listitem, inputtext[]) {
	if(!response) { Info(playerid, "Solicitação de atendimento cancelada."); }
	else {
		new i = 0;
		for(; i < MAX_ATENDIMENTOS; i++) {
			if(!SolAtd[i]) { break; }
		}
		if(i == MAX_ATENDIMENTOS) return Advert(playerid, "No momento estamos sem vaga de atendimento. Tente novamente mais tarde."); // 
		SolAtd[i] = playerid+1;
		new str[144], x = 0;
		format(str, 144, "[AJUDA] O player %s está solicitando ajuda. Use /Ajudar %i para atendê-lo.", pNick(playerid), playerid); // 
		for(new j = 0; j < MAX_PLAYERS; j++) {
			if(!IsPlayerConnected(j)) continue;
			if(pInfo[j][pAdmin] == Ajudante || pInfo[j][pAdmin] == Fiscalizador) {
				if(pInfo[j][pAtd]) continue;
				else {
					SendClientMessage(j, Amarelo, str);
					x++;
				}
			}
		}
		if(!x) {
			for(new j = 0; j < MAX_PLAYERS; j++) {
				if(!IsPlayerConnected(j)) continue;
				if(pInfo[j][pAdmin] > Fiscalizador) {
					if(pInfo[j][pAtd]) continue;
					SendClientMessage(j, Amarelo, str);
					x++;
				}
			}
		}
		if(!x) {
			Advert(playerid, "No momento não temos nenhum membro da Staff disponível para atendê-lo.");
			SolAtd[i] = 0;
		}
		else {
			Success(playerid, "Foi enviada uma solicitação de atendimento para os membros da Staff disponíveis no momento."); // 
		}
	}
	return 1;
}

Dialog:DialogvStaff(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(listitem == 0) { 		// Puxar
		new Float:P[4], vwid, interiorid;
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		GetPlayerFacingAngle(playerid, P[3]);
		vwid = GetPlayerVirtualWorld(playerid);
		interiorid = GetPlayerInterior(playerid);
		SetVehiclePos(vStaff[playerid][vsID], P[0], P[1], P[2]);
		SetVehicleZAngle(vStaff[playerid][vsID], P[3]);
		SetVehicleVirtualWorld(vStaff[playerid][vsID], vwid);
		SetVehicleInterior(vStaff[playerid][vsID], interiorid);
		PutPlayerInVehicle(playerid, vStaff[playerid][vsID], 0);
		Success(playerid, "vStaff puxado até você.");
	} else if(listitem == 1) {	// Ir até
		SetPlayerInterior(playerid, GetVehicleInterior(vStaff[playerid][vsID]));
		SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(vStaff[playerid][vsID]));
		PutPlayerInVehicle(playerid, vStaff[playerid][vsID], 0);
		Success(playerid, "Você foi até o seu vStaff.");
	} else if(listitem == 2) {	// Modelo
		Dialog_Show(playerid, "vStaffModel", DIALOG_STYLE_INPUT, "Modelo vStaff", "Coloque abaixo o número do modelo do veículo.", "Modificar", "Voltar");
	} else if(listitem == 3) {	// Cor 1
		Dialog_Show(playerid, "vStaffColor1", DIALOG_STYLE_INPUT, "Cor 1 vStaff", "Coloque abaixo o número da cor 1 do veículo.", "Pintar", "Voltar");
	} else if(listitem == 4) {	// Cor 2
		Dialog_Show(playerid, "vStaffColor2", DIALOG_STYLE_INPUT, "Cor 2 vStaff", "Coloque abaixo o número da cor 2 do veículo.", "Pintar", "Voltar");
	} else if(listitem == 5) {	// Respawnar
		SetVehicleInterior(vStaff[playerid][vsID], vStaff[playerid][vsInterior]);
		SetVehicleVirtualWorld(vStaff[playerid][vsID], vStaff[playerid][vsVW]);
		SetVehicleToRespawn(vStaff[playerid][vsID]);
		Success(playerid, "vStaff Respawnado com sucesso.");
	} else if(listitem == 6) {	// Definir Spawn
		GetVehiclePos(vStaff[playerid][vsID], vStaff[playerid][vsSpawn][0], vStaff[playerid][vsSpawn][1], vStaff[playerid][vsSpawn][2]);
		GetVehicleZAngle(vStaff[playerid][vsID], vStaff[playerid][vsSpawn][3]);
		vStaff[playerid][vsVW] = GetVehicleVirtualWorld(vStaff[playerid][vsID]);
		vStaff[playerid][vsInterior] = GetVehicleInterior(vStaff[playerid][vsID]);
		Success(playerid, "Spawn do vStaff definido com sucesso.");
	} else if(listitem == 7) { 	// Destruir
		DestroyVehicle(vStaff[playerid][vsID]);
		vStaff[playerid][vsID] = 0;
		vStaff[playerid][vsModel] = 0;
		Success(playerid, "vStaff destruído com sucesso.");
	}
	return 1;
}

Dialog:vStaffColor1(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Dialog_Show(playerid, "DialogvStaff", DIALOG_STYLE_LIST, "Veículo Staff", "Puxar\nIr até\nModelo\nCor 1\nCor 2\nRespawnar\nDefinir Spawn", "Escolher", "Cancelar");
	} else {
		new cor = strval(inputtext), str[144];
		vStaff[playerid][vsColor][0] = cor;
		format(str, 144, "Cor 1 do vStaff modificada para %i.", cor);
		Info(playerid, str);
		ChangeVehicleColor(vStaff[playerid][vsID], vStaff[playerid][vsColor][0], vStaff[playerid][vsColor][1]);
	}
	return 1;
}

Dialog:vStaffColor2(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Dialog_Show(playerid, "DialogvStaff", DIALOG_STYLE_LIST, "Veículo Staff", "Puxar\nIr até\nModelo\nCor 1\nCor 2\nRespawnar\nDefinir Spawn", "Escolher", "Cancelar");
	} else {
		new cor = strval(inputtext), str[144];
		vStaff[playerid][vsColor][1] = cor;
		format(str, 144, "Cor 2 do vStaff modificada para %i.", cor);
		Info(playerid, str);
		ChangeVehicleColor(vStaff[playerid][vsID], vStaff[playerid][vsColor][0], vStaff[playerid][vsColor][1]);
	}
	return 1;
}

Dialog:vStaffModel(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Dialog_Show(playerid, "DialogvStaff", DIALOG_STYLE_LIST, "Veículo Staff", "Puxar\nIr até\nModelo\nCor 1\nCor 2\nRespawnar\nDefinir Spawn", "Escolher", "Cancelar");
	} else {
		new vmodel = GetModelIDFromModelName(inputtext);
		if(!vmodel) {
			vmodel = strval(inputtext);
			if(vmodel < 400 || vmodel > 611) return Advert(playerid, "O modelo do veículo deve ser entre 400 e 611.");
		}
		new Float:P[4], vw, intid;
		GetVehiclePos(vStaff[playerid][vsID], P[0], P[1], P[2]);
		GetVehicleZAngle(vStaff[playerid][vsID], P[3]);
		vStaff[playerid][vsModel] = GetVehicleModel(vStaff[playerid][vsID]);
		intid = GetVehicleInterior(vStaff[playerid][vsID]);
		vw = GetVehicleVirtualWorld(vStaff[playerid][vsID]);
		new x[7];
		for(new i = 0; i < 7; i++) { x[i] = -1; }
		for(new i = 0; i < 7; i++) { x[i] = GetPlayerIDVehicleSeat(vStaff[playerid][vsID], i); }
		DestroyVehicle(vStaff[playerid][vsID]);
		vStaff[playerid][vsID] = CreateVehicle(vmodel, P[0], P[1], P[2], P[3], vStaff[playerid][vsColor][0], vStaff[playerid][vsColor][1], 0);
		SetVehicleInterior(vStaff[playerid][vsID], intid);
		SetVehicleVirtualWorld(vStaff[playerid][vsID], vw);
		vStaff[playerid][vsModel] = vmodel;
		for(new i = 0; i < vSeats[vmodel-400]; i++) { if(x[i] != -1) { PutPlayerInVehicle(x[i], vStaff[playerid][vsID], i); } }
		new str[144];
		format(str, 144, "Seu vStaff foi modificado para o modelo %i com sucesso.", vmodel);
		Success(playerid, str);
		vMotor[vStaff[playerid][vsID]] = 0;
	}
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// PUBLICS /////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

forward OnPlayerText@admin(playerid, text[]);
public OnPlayerText@admin(playerid, text[]) {
	new str[144];
	if(text[0] == '.') {
		if(pInfo[playerid][pAtd]) {
			format(str, 144, "[AJD] %s: "BRANCO"%s", pNick(playerid), text[1]);
			SendClientMessage(pInfo[playerid][pAtd]-1, AzulPiscina, str);
			SendClientMessage(playerid, AzulPiscina, str);
			return 0;
		} else {
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(!IsPlayerConnected(i)) continue;
				if(pInfo[i][pAtd] == playerid+1) {
					format(str, 144, "[AJD] %s: "BRANCO"%s", pNick(playerid), text[1]);
					SendClientMessage(i, AzulPiscina, str);
					SendClientMessage(playerid, AzulPiscina, str);
					return 0;
				}
			}
		}
	} else if(text[0] == '#') {
		if(pInfo[playerid][pAdmin] >= Administrador) {
			if(strlen(text) == 1) {
				Advert(playerid, "Use "AMARELO"#Mensagem"BRANCO".");
				return 0;
			}
			format(str, 144, "[%s] %s", Staff(playerid, 1), text[1]);
			SendClientMessageToAll(Azul, str);
			return 0;
		}
	}
	return 1;
}

forward OnPlayerEnterVehicle@admin(playerid, vehicleid, ispassenger);
public OnPlayerEnterVehicle@admin(playerid, vehicleid, ispassenger) {
	if(!ispassenger) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			if(vehicleid == vStaff[i][vsID]) {
				if(i != playerid) {
					new Float:P[3];
					TogglePlayerControllable(playerid, 0);
					SetTimerEx("UnfreezePlayer", 1000, false, "i", playerid);
					SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerid)+1);
					GetPlayerPos(playerid, P[0], P[1], P[2]);
					SetPlayerPos(playerid, P[0], P[1], P[2]);
					Advert(playerid, "Este veículo é exclusivo para o Staff que o possui.");
				}
				break;
			}
		}
	}
	return 1;
}

forward OnPlayerDisconnect@admin(playerid);
public OnPlayerDisconnect@admin(playerid) {
	if(pInfo[playerid][pAdmin] >= Fiscalizador) {
		if(GetVehicleModel(vStaff[playerid][vsID])) {
			DestroyVehicle(vStaff[playerid][vsID]);
		}
	}
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// FORWARDS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

forward UnfreezePlayer(playerid);
public UnfreezePlayer(playerid) {
	TogglePlayerControllable(playerid, 1);
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(playerid)-1);
	return 1;
}

forward LoadvStaff(playerid);
public LoadvStaff(playerid) {
	new rows;
	cache_get_row_count(rows);
	if(rows) {
		cache_get_value_name_int(0, "model", vStaff[playerid][vsModel]);
		cache_get_value_name_int(0, "color1", vStaff[playerid][vsColor][0]);
		cache_get_value_name_int(0, "color2", vStaff[playerid][vsColor][1]);
		cache_get_value_name_float(0, "sX", vStaff[playerid][vsSpawn][0]);
		cache_get_value_name_float(0, "sY", vStaff[playerid][vsSpawn][1]);
		cache_get_value_name_float(0, "sZ", vStaff[playerid][vsSpawn][2]);
		cache_get_value_name_float(0, "sA", vStaff[playerid][vsSpawn][3]);
		cache_get_value_name_int(0, "i", vStaff[playerid][vsInterior]);
		cache_get_value_name_int(0, "vw", vStaff[playerid][vsVW]);
		if(vStaff[playerid][vsModel]) {
			vStaff[playerid][vsID] = CreateVehicle(vStaff[playerid][vsModel], vStaff[playerid][vsSpawn][0], vStaff[playerid][vsSpawn][1], vStaff[playerid][vsSpawn][2], vStaff[playerid][vsSpawn][3], vStaff[playerid][vsColor][0], vStaff[playerid][vsColor][1], 0);
			SetVehicleInterior(vStaff[playerid][vsID], vStaff[playerid][vsInterior]);
			SetVehicleVirtualWorld(vStaff[playerid][vsID], vStaff[playerid][vsVW]);
		}
	} else {
		new query[150];
		mysql_format(conn, query, 150, "INSERT INTO vstaffinfo (`psqlid`, `model`) VALUES (%i, 0)", pInfo[playerid][pSQL]);
		mysql_query(conn, query, false);
	}
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////// STOCKS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

stock Staff(playerid, i = 0) {
	new s[40];
	if(pInfo[playerid][pAdmin] == Player) { format(s, 40, "player %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Plantonista) { format(s, 40, "plantonista %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Ajudante) { format(s, 40, "ajudante %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Fiscalizador) { format(s, 40, "fiscalizador %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Administrador) { format(s, 40, "administrador %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Senior) { format(s, 40, "senior %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Fundador) { format(s, 40, "fundador %s", pNick(playerid)); }
	if(i == 1) { toupper(s[0]); }
	return s;
}