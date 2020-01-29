#define MAX_TELEPORTES		15

enum TELEPORTES_INFO {
	Float:tpP[4],
	tpInt,
	tpVW,
	tpName[30]
};

new AvailablevStaff[] = { 475,474,479,480,489,507,527,529,534,554,579 };

new BlockSV;
new Teleporte[MAX_TELEPORTES][TELEPORTES_INFO];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// COMANDOS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
				break;
			}
		}
	}
	return 1;
}

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

// Plantonista +

CMD:ajudar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Plantonista) return 1;
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

CMD:mp(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	new id, msg[125], str[144];
	if(sscanf(params, "is[124]", id, msg)) return AdvertCMD(playerid, "/MP [ID] [Mensagem]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(playerid == id) return Advert(playerid, "Não seja tão solitário a ponto de enviar mensagem privada para si próprio :(");
	format(str, 144, "[MP de %03i]"BRANCO" %s", playerid, msg);
	SendClientMessage(id, RoxoClaro, str);
	format(str, 144, "[ENVIADA]"BRANCO" %s", msg);
	SendClientMessage(playerid, RoxoClaro, str);
	return 1;
}

// Ajudante +

CMD:ir(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	new id, Float:Front, Float:Upper, Float:Side;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Ir [ID] [Distância a frente] [Distância acima] [Distância ao lado]");
	sscanf(params, "ifff", id, Front, Upper, Side);
	if(!IsPlayerConnected(id)) return Advert(playerid, "Usuário offline.");
	if(pInfo[playerid][pAdmin] == Ajudante) {
		if(pInfo[playerid][pAtd] != id+1) return Advert(playerid, "Você só pode ir aos players que você estiver ajudando.");
		if(GetPlayerScore(pInfo[playerid][pAtd]-1) > 5) return Advert(playerid, "Você só poder ir aos player com nível menor que 6.");
	}
	if(pInfo[playerid][pSpec]) return Advert(playerid, "Você deve usar "AMARELO"/SpecOFF"BRANCO" antes.");
	if(pInfo[id][pLogged] != 1) return Advert(playerid, "Usuário na tela de login/registro.");
	new str[144];
	if(pInfo[id][pAdmin] >= Senior && pInfo[playerid][pAdmin] < Senior) {
		format(str, 144, "Foi enviada uma solicitação para ir até o %s.", Staff(id));
		Info(playerid, str);
		format(str, 144, "O %s está querendo ir até você. Use "AMARELO"/Puxar %i"BRANCO" para trazê-lo.", Staff(playerid), playerid);
		Info(id, str);
		return 1;
	} else if(IsPlayerInAnyVehicle(id)) {
		new vid = GetPlayerVehicleID(id);
		format(str, 144, "%i", vid);
		cmd_irv(playerid, str);
	} else {
		new Float:P[4];
		GetPlayerPos(playerid, pInfo[playerid][pVoltar][0], pInfo[playerid][pVoltar][1], pInfo[playerid][pVoltar][2]);
		pInfo[playerid][pVoltarInt] = GetPlayerInterior(playerid);
		pInfo[playerid][pVoltarVW] = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(id, P[0], P[1], P[2]);
		GetPlayerFacingAngle(id, P[3]);
		GetXYInFrontOfPlayer(id, Front, P[0], P[1]);
		P[2] += Upper;
		GetXYInFrontOfXY(P[0], P[1], Side, (P[3]-90), P[0], P[1]);
		new vw = GetPlayerVirtualWorld(id), interiorid = GetPlayerInterior(id);
		SetPlayerInterior(playerid, interiorid);
		SetPlayerVirtualWorld(playerid, vw);
		Streamer_UpdateEx(playerid, P[0], P[1], P[2], -1, -1, -1, 1500);
	}
	format(str, 144, "O %s foi até você.", Staff(playerid));
	Info(id, str);
	format(str, 144, "Você foi até o player %s (%i).", pName(id), id);
	Info(playerid, str);
	return 1;
}

CMD:voltar(playerid) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	if(pInfo[playerid][pVoltar][0] == 0.0 && pInfo[playerid][pVoltar][1] == 0.0 && pInfo[playerid][pVoltar][2] == 0.0) return Advert(playerid, "Para voltar, antes você deve "AMARELO"/Ir"BRANCO".");
	SetPlayerInterior(playerid, pInfo[playerid][pVoltarInt]);
	SetPlayerVirtualWorld(playerid, pInfo[playerid][pVoltarVW]);
	Streamer_UpdateEx(playerid, pInfo[playerid][pVoltar][0], pInfo[playerid][pVoltar][1], pInfo[playerid][pVoltar][2], -1, -1, -1, 1500);
	Info(playerid, "Você voltou à sua posição original.");
	pInfo[playerid][pVoltar][0] = 0.0;
	pInfo[playerid][pVoltar][1] = 0.0;
	pInfo[playerid][pVoltar][2] = 0.0;
	return 1;
}

CMD:vstaff(playerid) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
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

CMD:r(playerid) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Você deve estar dentro do veículo para repará-lo.");
	new vid, Float:A;
	vid = GetPlayerVehicleID(playerid);
	GetVehicleZAngle(vid, A);
	RepairVehicle(vid);
	SetVehicleZAngle(vid, A);
	return 1;
}

// Fiscalizador +

CMD:congelar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Congelar [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "Você congelou o player %s.", pName(id));
	Info(playerid, str);
	format(str, 144, "Você foi congelado pelo %s.", Staff(playerid));
	Advert(id, str);
	TogglePlayerControllable(id, false);
	return 1;
}

CMD:descongelar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Descongelar [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "Você descongelou o player %s.", pName(id));
	Info(playerid, str);
	format(str, 144, "Você foi descongelado pelo %s.", Staff(playerid));
	Advert(id, str);
	TogglePlayerControllable(id, true);
	return 1;
}

CMD:specoff(playerid) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	if(!pInfo[playerid][pSpec]) return Advert(playerid, "Você não está espiando ninguém.");
	TogglePlayerSpectating(playerid, false);
	return 1;
}

CMD:spec(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	if(pInfo[playerid][pSpec]) return Advert(playerid, "Antes você deve usar "AMARELO"/SpecOFF"BRANCO".");
	new id, vid;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Spec [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(pInfo[id][pLogged] != 1) return Advert(playerid, "Usuário na tela de registro/login.");
	if(pInfo[id][pAdmin] >= Senior) return Advert(playerid, "Você não pode espiar Sênior nem Fundador.");
	if(playerid == id) return Advert(playerid, "Para né fofa.");
	if(pInfo[id][pSpec]) return Advert(playerid, "Você não pode espiar alguém que está espiando outra pessoa.");
	vid = GetPlayerVehicleID(id);
	GetPlayerPos(playerid, pInfo[playerid][pVoltar][0], pInfo[playerid][pVoltar][1], pInfo[playerid][pVoltar][2]);
	pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
	pInfo[playerid][pVoltarInt] = GetPlayerInterior(playerid);
	pInfo[playerid][pVoltarVW] = GetPlayerVirtualWorld(playerid);
	SetPlayerInterior(playerid, GetPlayerInterior(id));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(id));
	TogglePlayerSpectating(playerid, true);
	pInfo[playerid][pSpec] = id+1;
	new str[144];
	format(str, 144, "Você agora está espiando o player %s.", pName(id));
	Info(playerid, str);
	Info(playerid, "Para interromper o spec, use "AMARELO"/SpecOFF"BRANCO".");
	if(vid) { PlayerSpectateVehicle(playerid, vid); } else { PlayerSpectatePlayer(playerid, id); }
	return 1;
}

CMD:kick(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Ajudante) return 1;
	if(pInfo[playerid][pAdmin] == Ajudante) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][pAdmin] > Ajudante) return Advert(playerid, "Você não tem permissão para usar esse comando se tiver um fiscalizador+ online.");
		}
	}
	new id, t, str[144];
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Kick [ID] [Tempo (opcional)]");
	sscanf(params, "ii", id, t);
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(pInfo[id][pAdmin] == Senior || pInfo[id][pAdmin] == Fundador) {
		Advert(playerid, "Tá maluco?");
		format(str, 144, "O %s tentou te expulsar.", Staff(playerid));
		Alert(id, str);
	} else if(t < 0) { Advert(playerid, "Tempo de expulsão mínimo: 0 min.");
	} else if(t > 1440) { Advert(playerid, "Tempo de expulsão máximo: 1440 min (24h).");
	} else {
		format(str, 144, "Insira abaixo o motivo para expulsar o player %s por %i minutos.", pNick(id), t);
		Dialog_Show(playerid, "Expulsar", DIALOG_STYLE_INPUT, "Motivo", str, "Expulsar", "Cancelar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_Expulsar");
		pInfo[playerid][pDialogParam][1] = id;
		pInfo[playerid][pDialogParam][2] = t;
	}
	return 1;
}

CMD:ban(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new id, str[144];
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Ban [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(pInfo[id][pAdmin] == Senior || pInfo[id][pAdmin] == Fundador) {
		Advert(playerid, "Tá maluco?");
		format(str, 144, "O %s tentou te banir.", Staff(playerid));
		Alert(id, str);
	} else {
		format(str, 144, "Insira abaixo o motivo para banir o player %s.", pNick(id));
		Dialog_Show(playerid, "Banir", DIALOG_STYLE_INPUT, "Motivo", str, "Banir", "Cancelar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_Expulsar");
		pInfo[playerid][pDialogParam][1] = id;
		pInfo[playerid][pDialogParam][2] = -1;
	}
	return 1;
}

CMD:desban(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new str[150], nick[24], Cache:result, r, t, x;
	if(sscanf(params, "s[24]", nick)) return AdvertCMD(playerid, "/Desban [Nickname]");
	mysql_format(conn, str, 150, "SELECT * FROM kickbans WHERE name = '%s'", nick);
	result = mysql_query(conn, str, true);
	cache_get_row_count(r);
	for(new i = 0; i < r; i++) {
		cache_get_value_name_int(i, "time", t);
		if(t == -1) {
			cache_get_value_name_int(i, "exec", x);
			cache_delete(result);
			mysql_format(conn, str, 150, "UPDATE kickbans SET `time` = -2 WHERE `exec` = %i AND `name` = '%s'", x, nick);
			mysql_query(conn, str, false);
			format(str, 144, "Você desbaniu o player %s.", nick);
			Info(playerid, str);
			return 1;
		}
	}
	cache_delete(result);
	Advert(playerid, "Esse player não está banido do servidor.");
	return 1;
}

CMD:deskick(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new str[150], nick[24], Cache:result, r, t, x, time = gettime();
	if(sscanf(params, "s[24]", nick)) return AdvertCMD(playerid, "/Deskick [Nickname]");
	mysql_format(conn, str, 150, "SELECT * FROM kickbans WHERE name = '%s'", nick);
	result = mysql_query(conn, str, true);
	cache_get_row_count(r);
	for(new i = 0; i < r; i++) {
		cache_get_value_name_int(i, "time", t);
		if(t > time) {
			cache_get_value_name_int(i, "exec", x);
			cache_delete(result);
			mysql_format(conn, str, 150, "UPDATE kickbans SET `time` = %i WHERE `exec` = %i AND `name` = '%s'", x, x, nick);
			mysql_query(conn, str, false);
			format(str, 144, "Você deskickou o player %s.", nick);
			Info(playerid, str);
			return 1;
		}
	}
	cache_delete(result);
	Advert(playerid, "Esse player não está kickado do servidor.");
	return 1;
}

CMD:puxar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new id, Float:Front, Float:Upper, Float:Side;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Puxar [ID] [Distância a frente] [Distância acima] [Distância ao lado]");
	sscanf(params, "ifff", id, Front, Upper, Side);
	if(!IsPlayerConnected(id)) return Advert(playerid, "Usuário offline.");
	if(pInfo[id][pLogged] != 1) return Advert(playerid, "Usuário na tela de login/registro.");
	if(pInfo[id][pAdmin] >= Senior && pInfo[playerid][pAdmin] < Senior) return Advert(playerid, "Não se pode puxar Sênior nem Fundador.");
	new vid = GetPlayerVehicleID(playerid), str[144];
	if(IsValidVehicle(vid)) {
		new model = GetVehicleModel(vid), i;
		for(; i < vSeats[model-400]; i++) {
			if(GetPlayerIDVehicleSeat(vid, i) == -1) break;
		}
		SetPlayerInterior(id, GetVehicleInterior(vid));
		SetPlayerVirtualWorld(id, GetVehicleVirtualWorld(vid));
		if(i == vSeats[model-400]) {
			new Float:P[3];
			GetVehiclePos(vid, P[0], P[1], P[2]);
			Streamer_UpdateEx(id, P[0], P[1], P[2], -1, -1, -1, 1500);
			Advert(id, "O veículo estava cheio e você foi teleportado para cima do veículo.");
		} else { PutPlayerInVehicle(id, vid, i); }
	} else {
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
	}
	format(str, 144, "O %s puxou você.", Staff(playerid));
	Info(id, str);
	format(str, 144, "Você puxou o player %s (%i).", pName(id), id);
	Info(playerid, str);
	return 1;
}

// Administrador +

CMD:irv(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Fiscalizador) return 1;
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/IrV [IDV]");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
	new model = GetVehicleModel(vid), i;
	for(; i < vSeats[model-400]; i++) {
		if(GetPlayerIDVehicleSeat(vid, i) == -1) break;
	}
	SetPlayerInterior(playerid, GetVehicleInterior(vid));
	SetPlayerVirtualWorld(playerid, GetVehicleVirtualWorld(vid));
	if(i == vSeats[model-400]) {
		new Float:P[3];
		GetVehiclePos(vid, P[0], P[1], P[2]);
		Streamer_UpdateEx(playerid, P[0], P[1], P[2], -1, -1, -1, 1500);
		Advert(playerid, "O veículo estava cheio e você foi teleportado para cima do veículo.");
	} else { PutPlayerInVehicle(playerid, vid, i); }
	return 1;
}

CMD:tele(playerid) {
	if(pInfo[playerid][pAdmin] == Administrador) {
		new str[450];
		for(new i = 0; i < MAX_TELEPORTES; i++) {
			if(!isnull(Teleporte[i][tpName])) {
				format(str, 450, "%s%s\n", str, Teleporte[i][tpName]);
			}
		}
		if(isnull(str)) Advert(playerid, "Não há teleportes disponíveis para uso.");
		else Dialog_Show(playerid, "TeleporteIR", DIALOG_STYLE_LIST, "TELEPORTES", str, "Ir", "Cancelar");
	} else if(pInfo[playerid][pAdmin] > Administrador) {
		Dialog_Show(playerid, "TeleporteME", DIALOG_STYLE_LIST, "MENU TELEPORTES", "Usar teleporte\nCriar teleporte\nExcluir teleporte", "Seleiconar", "Cancelar");
	}
	return 1;
}

CMD:gvw(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/gVW [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O player %s está no Virtual World %i.", pName(id), GetPlayerVirtualWorld(id));
	Info(playerid, str);
	return 1;
}

CMD:ginterior(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/gInterior [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O player %s está no interior %i.", pName(id), GetPlayerInterior(id));
	Info(playerid, str);
	return 1;
}

CMD:gmoney(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/gMoney [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O player %s está com "VERDEMONEY"$%i"BRANCO" na carteira.", pName(id), GetPlayerMoney(id));
	Info(playerid, str);
	return 1;
}

CMD:gvida(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/gVida [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144], Float:health;
	GetPlayerHealth(id, health);
	format(str, 144, "O player %s está com %.0f de vida.", pName(id), health);
	Info(playerid, str);
	return 1;
}

CMD:svw(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id, vw;
	if(sscanf(params, "ii", id, vw)) return AdvertCMD(playerid, "/sVW [ID] [Virtual World]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O %s setou o Virtual World %i para você.", Staff(playerid), vw);
	Info(id, str);
	format(str, 144, "Você setou o Virtual World %i para o player %s.", vw, pName(id));
	Info(playerid, str);
	SetPlayerVirtualWorld(id, vw);
	return 1;
}

CMD:sinterior(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id, interiorid;
	if(sscanf(params, "ii", id, interiorid)) return AdvertCMD(playerid, "/sInterior [ID] [Interior]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "O %s setou o interior %i para você.", Staff(playerid), interiorid);
	Info(id, str);
	format(str, 144, "Você setou o interior %i para o player %s.", interiorid, pName(id));
	Info(playerid, str);
	SetPlayerInterior(id, interiorid);
	return 1;
}

CMD:sskin(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id, skinid;
	if(sscanf(params, "ii", id, skinid)) return AdvertCMD(playerid, "/sSkin [ID] [Skin]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(skinid < 0 || skinid > 311) return Advert(playerid, "Skin inválida.");
	new str[144];
	format(str, 144, "O %s setou a skin %i para você.", Staff(playerid), skinid);
	Info(id, str);
	format(str, 144, "Você setou a skin %i para o player %s.", skinid, pName(id));
	Info(playerid, str);
	SetPlayerSkin(id, skinid);
	pInfo[id][pSkin] = skinid;
	return 1;
}

CMD:svida(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id, Float:health;
	if(sscanf(params, "if", id, health)) return AdvertCMD(playerid, "/sVida [ID] [Vida]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(health < 0.0 || health > 100.0) return Advert(playerid, "Vida inválida. [0-100]");
	new str[144];
	format(str, 144, "O %s setou a sua vida para %.0f.", Staff(playerid), health);
	Info(id, str);
	format(str, 144, "Você setou a vida do player %s para %.0f.", pName(id), health);
	Info(playerid, str);
	SetPlayerHealth(id, health);
	return 1;
}

CMD:smoney(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id, mon;
	if(sscanf(params, "ii", id, mon)) return AdvertCMD(playerid, "/sMoney [ID] [Dinheiro]");
	ResetPlayerMoney(id);
	GivePlayerMoney(id, mon);
	new str[144];
	format(str, 144, "Você setou "VERDEMONEY"$%i"BRANCO" para o player %s.", mon, pName(id));
	Info(playerid, str);
	format(str, 144, "O %s setou "VERDEMONEY"$%i"BRANCO" para você.", Staff(playerid), mon);
	Success(id, str);
	return 1;
}

CMD:sv(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
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
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	if(!BlockSV) {
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um veículo.");
		new vid = GetPlayerVehicleID(playerid);
		new Float:V[3];
		GetVehicleVelocity(vid, V[0], V[1], V[2]);
		V[2] += 0.2;
		SetVehicleVelocity(vid, V[0], V[1], V[2]);
	} else {
		Advert(playerid, "Cabeça de pica.");
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

// Sênior +

CMD:clima(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/Clima [ID do clima]");
	if(id < 0 || id > 45) return AdvertCMD(playerid, "/Clima [0-45]");
	SetWeather(id);
	new str[144];
	format(str, 144, "Você setou o tempo para "AMARELO"%02i"BRANCO".", id);
	Info(playerid, str);
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

CMD:closeserver(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return SendClientMessage(playerid, -1, "Nananinanão (:");
	SendClientMessageToAll(-1, "O Programador John Black fechou o Servidor.");
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		KickPlayer(i);
	}
	SetTimer("CloseServer", 1000, false);
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

CMD:setplant(playerid, params[]) {
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

CMD:desempregar(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new str[144], i;
	if(sscanf(params, "i", i)) return AdvertCMD(playerid, "/Desempregar [ID]");
	if(!IsPlayerConnected(i)) return Advert(playerid, "ID inválido.");
	pInfo[i][pBus] = -1;
	format(str, 144, "Você desempregou %s.", pName(i));
	Info(playerid, str);
	format(str, 144, "Você foi desempregado pelo %s.", Staff(playerid));
	Info(i, str);
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////// DIALOGS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Dialog:Expulsar(playerid, response, listitem, inputtext[]) {
	if(!response) return ResetDialogParams(playerid);
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_Expulsar")) return ResetDialogParams(playerid);
	if(!strlen(inputtext) || strlen(inputtext) > 30) {
		Advert(playerid, "Motivo inválido.");
	} else if(pInfo[playerid][pDialogParam][2] != -1) {
		new str[250];
		format(str, 144, "Você foi expulso pelo %s por %i minuto(s). Motivo: %s.", pNick(playerid), pInfo[playerid][pDialogParam][2], inputtext);
		Advert(pInfo[playerid][pDialogParam][1], str);
		format(str, 144, "Você expulsou o player %s por %i minuto(s) pelo motivo %s.", pNick(pInfo[playerid][pDialogParam][1]), pInfo[playerid][pDialogParam][2], inputtext);
		Info(playerid, str);
		mysql_format(conn, str, 250, "INSERT INTO kickbans (`name`, `time`, `motivo`, `staff`, `exec`) VALUES ('%s', %i, '%s', '%s', %i)",
			pNick(pInfo[playerid][pDialogParam][1]), (gettime() + pInfo[playerid][pDialogParam][2]*60), inputtext, pNick(playerid), gettime());
		mysql_query(conn, str, false);
		KickPlayer(pInfo[playerid][pDialogParam][1]);
	} else {
		new str[250];
		format(str, 144, "Você foi banido pelo %s. Motivo: %s.", pNick(playerid), inputtext);
		Advert(pInfo[playerid][pDialogParam][1], str);
		format(str, 144, "Você baniu o player %s pelo motivo %s.", pNick(pInfo[playerid][pDialogParam][1]), inputtext);
		Info(playerid, str);
		mysql_format(conn, str, 250, "INSERT INTO kickbans (`name`, `time`, `motivo`, `staff`, `exec`) VALUES ('%s', -1, '%s', '%s', %i)",
			pNick(pInfo[playerid][pDialogParam][1]), inputtext, pNick(playerid), gettime());
		mysql_query(conn, str, false);
		KickPlayer(pInfo[playerid][pDialogParam][1]);
	}
	return ResetDialogParams(playerid);
}

Dialog:TeleporteME(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(listitem == 0) {
			new str[450];
			for(new i = 0; i < MAX_TELEPORTES; i++) {
				if(!isnull(Teleporte[i][tpName])) {
					format(str, 450, "%s%s\n", str, Teleporte[i][tpName]);
				}
			}
			if(isnull(str)) Advert(playerid, "Não há teleportes disponíveis para uso.");
			else Dialog_Show(playerid, "TeleporteIR", DIALOG_STYLE_LIST, "TELEPORTES", str, "Ir", "Voltar");
		} else if(listitem == 1) {
			new i = 0;
			for(; i < MAX_TELEPORTES; i++) if(isnull(Teleporte[i][tpName])) break;
			if(i == MAX_TELEPORTES) Advert(playerid, "Já foi criado o máximo de teleportes possíveis. (15)");
			else Dialog_Show(playerid, "TeleporteCR", DIALOG_STYLE_INPUT, "CRIAR TELEPORTE", "Insira abaixo o nome do teleporte que deseja criar.", "Criar", "Voltar");
		} else if(listitem == 2) {
			new str[450];
			for(new i = 0; i < MAX_TELEPORTES; i++) {
				if(!isnull(Teleporte[i][tpName])) {
					format(str, 450, "%s%s\n", str, Teleporte[i][tpName]);
				}
			}
			if(isnull(str)) Advert(playerid, "Não há teleportes criados.");
			else Dialog_Show(playerid, "TeleporteEX", DIALOG_STYLE_LIST, "EXCLUIR TELEPORTE", str, "Excluir", "Voltar");
		}
	}
	return 1;
}

Dialog:TeleporteCR(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(!strlen(inputtext) || strlen(inputtext) > 29) {
			Advert(playerid, "Nome inválido.");
			Dialog_Show(playerid, "TeleporteCR", DIALOG_STYLE_INPUT, "CRIAR TELEPORTE", "Insira abaixo o nome do teleporte que deseja criar.", "Criar", "Voltar");
		} else {
			new i = 0;
			for(; i < MAX_TELEPORTES; i++) {
				if(isnull(Teleporte[i][tpName])) continue;
				else if(!strcmp(Teleporte[i][tpName], inputtext, true)) {
					Advert(playerid, "Já existe um teleporte com esse nome.");
					Dialog_Show(playerid, "TeleporteCR", DIALOG_STYLE_INPUT, "CRIAR TELEPORTE", "Insira abaixo o nome do teleporte que deseja criar.", "Criar", "Voltar");
					break;
				}
			} if(i == MAX_TELEPORTES) {
				i = 0;
				for(; i < MAX_TELEPORTES; i++) if(isnull(Teleporte[i][tpName])) break;
				if(i == MAX_TELEPORTES) Advert(playerid, "Aconteceu um erro inesperado. Tente novamente.");
				else {
					new str[200];
					GetPlayerPos(playerid, Teleporte[i][tpP][0], Teleporte[i][tpP][1], Teleporte[i][tpP][2]);
					GetPlayerFacingAngle(playerid, Teleporte[i][tpP][3]);
					Teleporte[i][tpInt] = GetPlayerInterior(playerid);
					Teleporte[i][tpVW] = GetPlayerVirtualWorld(playerid);
					format(Teleporte[i][tpName], 30, "%s", inputtext);
					format(str, 144, "Teleporte criado com sucesso: '"AMARELOPALIDO"%s"BRANCO"'.", inputtext);
					Success(playerid, str);
					mysql_format(conn, str, 200, "INSERT INTO teleporteinfo (name, X, Y, Z, A, i, vw) VALUES ('%s', %f, %f, %f, %f, %i, %i)",
						Teleporte[i][tpName], Teleporte[i][tpP][0], Teleporte[i][tpP][1], Teleporte[i][tpP][2], Teleporte[i][tpP][3], Teleporte[i][tpInt], Teleporte[i][tpVW]);
					mysql_query(conn, str, false);
				}
			}
		}
	} else cmd_tele(playerid);
	return 1;
}

Dialog:TeleporteEX(playerid, response, listitem, inputtext[]) {
	if(response) {
		for(new i = 0; i < MAX_TELEPORTES; i++) {
			if(isnull(Teleporte[i][tpName])) continue;
			if(!strcmp(inputtext, Teleporte[i][tpName], false)) {
				new str[144];
				mysql_format(conn, str, 144, "DELETE FROM teleporteinfo WHERE name = '%s'", Teleporte[i][tpName]);
				mysql_query(conn, str, false);
				format(Teleporte[i][tpName], 2, "");
				Teleporte[i][tpP][0] = 0.0;
				Teleporte[i][tpP][1] = 0.0;
				Teleporte[i][tpP][2] = 0.0;
				Teleporte[i][tpP][3] = 0.0;
				Teleporte[i][tpInt] = 0;
				Teleporte[i][tpVW] = 0;
				format(str, 144, "Teleporte '"AMARELOPALIDO"%s"BRANCO"' excluído com sucesso.", inputtext);
				Success(playerid, str);
				return 1;
			}
		}
		Advert(playerid, "Um erro inesperado aconteceu, por favor tente novamente.");
	} else cmd_tele(playerid);
	return 1;
}

Dialog:TeleporteIR(playerid, response, listitem, inputtext[]) {
	if(response) {
		for(new i = 0; i < MAX_TELEPORTES; i++) {
			if(isnull(Teleporte[i][tpName])) continue;
			if(!strcmp(inputtext, Teleporte[i][tpName], false)) {
				new str[144];
				SetPlayerInterior(playerid, Teleporte[i][tpInt]);
				SetPlayerVirtualWorld(playerid, Teleporte[i][tpVW]);
				Streamer_UpdateEx(playerid, Teleporte[i][tpP][0], Teleporte[i][tpP][1], Teleporte[i][tpP][2], -1, -1, -1, 1500);
				SetPlayerFacingAngle(playerid, Teleporte[i][tpP][3]);
				format(str, 144, "Você utilizou o teleporte '"AMARELOPALIDO"%s"BRANCO"'.", inputtext);
				return 1;
			}
		}
		Advert(playerid, "Um erro inesperado aconteceu, por favor tente novamente.");
	} else if(pInfo[playerid][pAdmin] > Administrador) cmd_tele(playerid);
	return 1;
}

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
		if(pInfo[playerid][pAdmin] < Senior) {
			new i = 0;
			for(; i < sizeof(AvailablevStaff); i++) {
				if(vmodel == AvailablevStaff[i]) break;
			}
			if(i == sizeof(AvailablevStaff)) return Advert(playerid, "Esse modelo de veículo não é permitido para uso no vStaff.");
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

forward OnGameModeInit@admin();
public OnGameModeInit@admin() {
	new Cache:result, rows, str[30];
	result = mysql_query(conn, "SELECT * FROM teleporteinfo");
	cache_get_row_count(rows);
	if(rows > MAX_TELEPORTES) print("\nERROR\nROWS > MAX_TELEPORTES\n");
	else {
		for(new i = 0; i < rows; i++) {
			cache_get_value_name(i, "name", str);
			format(Teleporte[i][tpName], 30, "%s", str);
			cache_get_value_name_float(i, "X", Teleporte[i][tpP][0]);
			cache_get_value_name_float(i, "Y", Teleporte[i][tpP][1]);
			cache_get_value_name_float(i, "Z", Teleporte[i][tpP][2]);
			cache_get_value_name_float(i, "A", Teleporte[i][tpP][3]);
			cache_get_value_name_int(i, "i", Teleporte[i][tpInt]);
			cache_get_value_name_int(i, "vw", Teleporte[i][tpVW]);
		}
	}
	cache_delete(result);
	return 1;
}

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
			format(str, 144, "%s: %s", Staff(playerid), text[1]);
			SendClientMessageToAll(Azul, str);
			return 0;
		}
	} else if(text[0] == '@') {
		if(pInfo[playerid][pAdmin] >= Ajudante) {
			if(strlen(text) == 1) {
				Advert(playerid, "Use "AMARELO"@Mensagem"BRANCO".");
				return 0;
			}
			format(str, 144, "%s:"BRANCO" %s", pName(playerid), text[1]);
			new color = GetStaffColor(playerid);
			for(new i = 0; i < MAX_PLAYERS; i++) {
				if(pInfo[i][pAdmin] >= Ajudante) {
					SendClientMessage(i, color, str);
				}
			}
			return 0;
		}
	}
	return 1;
}

forward OnPlayerInteriorChange@admin(playerid, newinteriorid, oldinteriorid);
public OnPlayerInteriorChange@admin(playerid, newinteriorid, oldinteriorid) {
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pSpec] == playerid+1) {
			SetPlayerInterior(i, newinteriorid);
		}
	}
	return 1;
}

forward OnPlayerStateChange@admin(playerid, newstate, oldstate);
public OnPlayerStateChange@admin(playerid, newstate, oldstate) {
	if(oldstate == PLAYER_STATE_PASSENGER || oldstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][pSpec] == playerid+1) {
				PlayerSpectatePlayer(i, playerid);
			}
		}
	} else if(newstate == PLAYER_STATE_PASSENGER || newstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][pSpec] == playerid+1) {
				PlayerSpectateVehicle(i, GetPlayerVehicleID(playerid));
			}
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
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(pInfo[i][pDialogParam][0] == funcidx("dialog_Expulsar")) {
			if(pInfo[i][pDialogParam][1] == playerid) {
				ResetDialogParams(i);
				Advert(i, "O player que você ia expulsar foi desconectado.");
			}
		}
	}
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pSpec] == playerid+1) {
			pInfo[i][pSpec] = 0;
		}
	}
	return 1;
}

forward OnPlayerVirtualWorldChange@adm(playerid, newworldid, oldworldid);
public OnPlayerVirtualWorldChange@adm(playerid, newworldid, oldworldid) {
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][pSpec] == playerid+1) {
			SetPlayerVirtualWorld(i, newworldid);
		}
	}
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// FORWARDS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

forward CloseServer();
public CloseServer() {
	SendRconCommand("exit");
	return 1;
}

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

stock Staff(playerid) {
	new s[40];
	if(pInfo[playerid][pAdmin] == Player) { format(s, 40, "Player %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Plantonista) { format(s, 40, "Plantonista %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Ajudante) { format(s, 40, "Ajudante %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Fiscalizador) { format(s, 40, "Fiscalizador %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Administrador) { format(s, 40, "Administrador %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Senior) { format(s, 40, "Senior %s", pNick(playerid)); }
	else if(pInfo[playerid][pAdmin] == Fundador) { format(s, 40, "Fundador %s", pNick(playerid)); }
	return s;
}

stock GetStaffColor(playerid) {
	if(pInfo[playerid][pAdmin] == Player) return CPlayer;
	else if(pInfo[playerid][pAdmin] == Plantonista) return CPlantonista;
	else if(pInfo[playerid][pAdmin] == Ajudante) return CAjudante;
	else if(pInfo[playerid][pAdmin] == Fiscalizador) return CFiscalizador;
	else if(pInfo[playerid][pAdmin] == Administrador) return CAdministrador;
	else if(pInfo[playerid][pAdmin] == Senior) return CSenior;
	else if(pInfo[playerid][pAdmin] == Fundador) return CFundador;
	else return 0;
}