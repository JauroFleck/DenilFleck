#define ORGID_SASD			0

#define MAX_ORGS			10
#define MAX_ORG_MEMBERS		20

enum ORG_INFO {
	oSQL,
	oName[40],
	oOwner,
	oPost[MAX_ORG_MEMBERS]
};

enum MEMBER_INFO {
	mSQL,
	mName[25],
	mPSQL,
	mInvite,
	mPromote
};

new oInfo[MAX_ORGS][ORG_INFO];

new mInfo[MAX_ORGS][MAX_ORG_MEMBERS][MEMBER_INFO];

CMD:orgs(playerid) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new str[700];
	for(new i = 0; i < MAX_ORGS; i++) {
		if(oInfo[i][oSQL]) { format(str, 700, "%s\n[%02i] %s - Dono: %s", str, i, oInfo[i][oName], (oInfo[i][oOwner] ? (GetpNickBySQL(oInfo[i][oOwner])) : ("N/A") )); }
	}
	if(isnull(str)) return Info(playerid, "Não existem organizações criadas.");
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "{FFFFFF}Organizações", str, "Fechar", "");
	return 1;
}

CMD:criarorg(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	Dialog_Show(playerid, "OrgCreate", DIALOG_STYLE_INPUT, "Criar Org", "Insira abaixo o nome da organização que deseja criar.", "Criar", "Cancelar");
	return 1;
}

CMD:setlider(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new oid, id;
	if(sscanf(params, "ii", oid, id)) return AdvertCMD(playerid, "/SetLider [ID da Org] [ID do player]");
	if(oid < 0 || oid >= MAX_ORGS) return Advert(playerid, "Organização inválida.");
	if(!oInfo[oid][oSQL]) return Advert(playerid, "Organização inexistente.");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "Você colocou %s como dono da organização ID %02i.", pName(id), oid);
	Info(playerid, str);
	format(str, 144, "O %s colocou você como dono da organização ID %02i.", Staff(playerid), oid);
	Info(id, str);
	if(oInfo[oid][oOwner]) {
		new pid = GetPlayerIDBySQL(oInfo[oid][oOwner]);
		if(pid == -1) {
			mysql_format(conn, str, 144, "UPDATE playerinfo SET org = -1 WHERE sqlid = %i", oInfo[oid][oOwner]);
			mysql_query(conn, str, false);
		} else {
			pInfo[pid][pOrg] = -1;
			Info(pid, "Você foi retirado da liderança da sua organização.");
		}
	}
	oInfo[oid][oOwner] = pInfo[id][pSQL];
	pInfo[id][pOrg] = oid;
	mysql_format(conn, str, 144, "UPDATE orginfo SET owner = %i WHERE sqlid = %i", pInfo[id][pSQL], oInfo[oid][oSQL]);
	mysql_query(conn, str, false);
	return 1;
}

CMD:orginfo(playerid) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	new str[500];
	for(new j = 0; j < MAX_ORG_MEMBERS; j++) {
		if(!oInfo[pInfo[playerid][pOrg]][oPost][j]) continue;
		format(str, 500, "%s%s - %s\n", str, mInfo[pInfo[playerid][pOrg]][j][mName], (mInfo[pInfo[playerid][pOrg]][j][mPSQL] ? (GetpNickBySQL(mInfo[pInfo[playerid][pOrg]][j][mPSQL])) : ("N/A") ));
	}
	format(str, 500, "\tLíder: %s\n\n%s", GetpNickBySQL(oInfo[pInfo[playerid][pOrg]][oOwner]), str);
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, oInfo[pInfo[playerid][pOrg]][oName], str, "Fechar", "");
	return 1;
}

CMD:cargosorg(playerid) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	if(oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) return Advert(playerid, "Comando exclusivo para o líder da organização.");
	new str[500], l = 0;
	for(new j = 0; j < MAX_ORG_MEMBERS; j++) {
		if(!oInfo[pInfo[playerid][pOrg]][oPost][j]) continue;
		format(str, 500, "%s%s\n", str, mInfo[pInfo[playerid][pOrg]][j][mName], GetpNickBySQL(mInfo[pInfo[playerid][pOrg]][j][mPSQL]));
		l++;
	}
	if(l < MAX_ORG_MEMBERS) {
		format(str, 500, "%s+ Criar cargo", str);
	}
	Dialog_Show(playerid, "CargosOrg", DIALOG_STYLE_LIST, "Cargos", str, "Selecionar", "Cancelar");
	return 1;
}

CMD:recrutar(playerid, params[]) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	new i = 0;
	for(; i < MAX_ORG_MEMBERS; i++) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL] == pInfo[playerid][pSQL]) break;
	}
	if(i == MAX_ORG_MEMBERS && oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) return Advert(playerid, "Um erro inesperado aconteceu. Favor notifique a administração dessa mensagem. [COD 020]");
	if(oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mInvite]) return Advert(playerid, "Você não tem permissão para isso.");
	}
	new cargo[25], id;
	if(sscanf(params, "s[24]u", cargo, id)) return AdvertCMD(playerid, "/Recrutar [Nome_do_cargo] [ID/Nickname]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Usuário offline.");
	if(id == playerid) return Advert(playerid, "ID inválido");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(id, 3.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo a quem deseja recrutar.");
	if(pInfo[id][pOrg] != -1) return Advert(playerid, "Você não pode recrutar alguém que já participa de uma organização.");
	new j = 0;
	for(; j < MAX_ORG_MEMBERS; j++) {
		if(!mInfo[pInfo[playerid][pOrg]][j][mSQL]) continue;
		if(!strcmp(mInfo[pInfo[playerid][pOrg]][j][mName], cargo, true)) {
			if(!mInfo[pInfo[playerid][pOrg]][j][mPSQL]) break;
		}
	}
	if(j == MAX_ORG_MEMBERS) return Advert(playerid, "Esse cargo é inexistente ou já está ocupado por alguém.");
	new str[150];
	format(str, 150, "Você foi convidado por %s para participar da organização %s.", pName(playerid), oInfo[pInfo[playerid][pOrg]][oName]);
	Dialog_Show(id, "OrgRecruit", DIALOG_STYLE_MSGBOX, "Convite", str, "Aceitar", "Recusar");
	pInfo[id][pDialogParam][0] = funcidx("dialog_OrgRecruit");
	pInfo[id][pDialogParam][1] = j;
	pInfo[id][pDialogParam][2] = playerid;
	return 1;
}

CMD:revogar(playerid, params[]) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	new i = 0;
	for(; i < MAX_ORG_MEMBERS; i++) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL] == pInfo[playerid][pSQL]) break;
	}
	if(i == MAX_ORG_MEMBERS && oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) return Advert(playerid, "Um erro inesperado aconteceu. Favor notifique a administração dessa mensagem. [COD 020]");
	if(oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mInvite]) return Advert(playerid, "Você não tem permissão para isso.");
	}
	new name[25];
	if(sscanf(params, "s[24]", name)) return AdvertCMD(playerid, "/Revogar [Nome_Sobrenome]");
	new sql = GetSQLBypNick(name);
	if(!sql) return Advert(playerid, "Usuário inválido.");
	new j = 0;
	for(; j < MAX_ORG_MEMBERS; j++) {
		if(!mInfo[pInfo[playerid][pOrg]][j][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][j][mPSQL] == sql) break;
	}
	if(j == MAX_ORG_MEMBERS) return Advert(playerid, "Esse player não participa da sua organização.");
	mInfo[pInfo[playerid][pOrg]][j][mPSQL] = 0;
	new str[150];
	mysql_format(conn, str, 150, "UPDATE playerinfo SET org = -1 WHERE sqlid = %i", sql);
	mysql_query(conn, str, false);
	mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = 0 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][j][mSQL]);
	mysql_query(conn, str, false);
	new id = GetPlayerIDBySQL(sql);
	if(id != -1) {
		format(str, 144, "Você foi expulso da sua organização pelo membro %s.", pName(playerid));
		Info(id, str);
		pInfo[id][pOrg] = -1;
	}
	format(str, 144, "Você expulsou o membro %s da sua organização.", name);
	Info(playerid, str);
	return 1;
}

CMD:promover(playerid, params[]) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	new i = 0;
	for(; i < MAX_ORG_MEMBERS; i++) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL] == pInfo[playerid][pSQL]) break;
	}
	if(i == MAX_ORG_MEMBERS && oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) return Advert(playerid, "Um erro inesperado aconteceu. Favor notifique a administração dessa mensagem. [COD 020]");
	if(oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mPromote]) return Advert(playerid, "Você não tem permissão para isso.");
	}
	new name[25], post[25];
	if(sscanf(params, "s[24]s[24]", name, post)) return AdvertCMD(playerid, "/Promover [Nome_Sobrenome] [Nome_do_cargo]");
	new sql = GetSQLBypNick(name);
	if(!sql) return Advert(playerid, "Usuário inválido.");
	new j = 0;
	for(; j < MAX_ORG_MEMBERS; j++) {
		if(!mInfo[pInfo[playerid][pOrg]][j][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][j][mPSQL] == sql) break;
	}
	if(j == MAX_ORG_MEMBERS) return Advert(playerid, "Esse player não participa da sua organização.");
	new k = 0;
	for(; k < MAX_ORG_MEMBERS; k++) {
		if(!mInfo[pInfo[playerid][pOrg]][k][mSQL]) continue;
		if(!strcmp(mInfo[pInfo[playerid][pOrg]][k][mName], post, true)) {
			if(!mInfo[pInfo[playerid][pOrg]][k][mPSQL]) break;
		}
	}
	if(k == MAX_ORG_MEMBERS) return Advert(playerid, "Não há vagas desse cargo disponíveis.");
	mInfo[pInfo[playerid][pOrg]][j][mPSQL] = 0;
	mInfo[pInfo[playerid][pOrg]][k][mPSQL] = sql;
	new str[150];
	mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = 0 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][j][mSQL]);
	mysql_query(conn, str, false);
	mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = %i WHERE sqlid = %i", sql, mInfo[pInfo[playerid][pOrg]][k][mSQL]);
	mysql_query(conn, str, false);
	new id = GetPlayerIDBySQL(sql);
	if(id != -1) {
		format(str, 144, "Você foi promovido na sua organização para %s pelo membro %s.", post, pName(playerid));
		Info(id, str);
	}
	format(str, 144, "Você promoveu o membro %s da sua organização para %s.", name, post);
	Info(playerid, str);
	return 1;
}

CMD:rebaixar(playerid, params[]) {
	if(pInfo[playerid][pOrg] == -1) return Advert(playerid, "Você não participa de nenhuma organização.");
	new i = 0;
	for(; i < MAX_ORG_MEMBERS; i++) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL] == pInfo[playerid][pSQL]) break;
	}
	if(i == MAX_ORG_MEMBERS && oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) return Advert(playerid, "Um erro inesperado aconteceu. Favor notifique a administração dessa mensagem. [COD 020]");
	if(oInfo[pInfo[playerid][pOrg]][oOwner] != pInfo[playerid][pSQL]) {
		if(!mInfo[pInfo[playerid][pOrg]][i][mPromote]) return Advert(playerid, "Você não tem permissão para isso.");
	}
	new name[25], post[25];
	if(sscanf(params, "s[24]s[24]", name, post)) return AdvertCMD(playerid, "/Rebaixar [Nome_Sobrenome] [Nome_do_cargo]");
	new sql = GetSQLBypNick(name);
	if(!sql) return Advert(playerid, "Usuário inválido.");
	new j = 0;
	for(; j < MAX_ORG_MEMBERS; j++) {
		if(!mInfo[pInfo[playerid][pOrg]][j][mSQL]) continue;
		if(mInfo[pInfo[playerid][pOrg]][j][mPSQL] == sql) break;
	}
	if(j == MAX_ORG_MEMBERS) return Advert(playerid, "Esse player não participa da sua organização.");
	new k = 0;
	for(; k < MAX_ORG_MEMBERS; k++) {
		if(!mInfo[pInfo[playerid][pOrg]][k][mSQL]) continue;
		if(!strcmp(mInfo[pInfo[playerid][pOrg]][k][mName], post, true)) {
			if(!mInfo[pInfo[playerid][pOrg]][k][mPSQL]) break;
		}
	}
	if(k == MAX_ORG_MEMBERS) return Advert(playerid, "Não há vagas desse cargo disponíveis.");
	mInfo[pInfo[playerid][pOrg]][j][mPSQL] = 0;
	mInfo[pInfo[playerid][pOrg]][k][mPSQL] = sql;
	new str[150];
	mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = 0 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][j][mSQL]);
	mysql_query(conn, str, false);
	mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = %i WHERE sqlid = %i", sql, mInfo[pInfo[playerid][pOrg]][k][mSQL]);
	mysql_query(conn, str, false);
	new id = GetPlayerIDBySQL(sql);
	if(id != -1) {
		format(str, 144, "Você foi rebaixado na sua organização para %s pelo membro %s.", post, pName(playerid));
		Info(id, str);
	}
	format(str, 144, "Você rebaixou o membro %s da sua organização para %s.", name, post);
	Info(playerid, str);
	return 1;
}

Dialog:OrgCreate(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new i = 0;
	for(; i < MAX_ORGS; i++) {
		if(!oInfo[i][oSQL]) break;
	}
	if(i == MAX_ORGS) return Advert(playerid, "O máximo de organizações já foi atingido.");
	if(isnull(inputtext)) return Advert(playerid, "Nome de organização inválido.");
	if(strlen(inputtext) > 40) return Advert(playerid, "Nome muito longo para organização - Máximo de 40 caracteres.");
	format(oInfo[i][oName], 40, "%s", inputtext);
	new query[150], str[40], Cache:result;
	mysql_escape_string(inputtext, str);
	mysql_format(conn, query, 150, "INSERT INTO orginfo (name) VALUES ('%s')", str);
	result = mysql_query(conn, query, true);
	oInfo[i][oSQL] = cache_insert_id();
	cache_delete(result);
	format(query, 144, "Organização %s criada com sucesso.", inputtext);
	Success(playerid, query);
	return 1;
}

Dialog:OrgRecruit(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_OrgRecruit")) return ResetDialogParams(playerid);
	new j = pInfo[playerid][pDialogParam][1], id = pInfo[playerid][pDialogParam][2];
	if(!response) {
		Advert(playerid, "Você recusou o convite.");
		Advert(id, "Seu convite foi recusado.");
	} else if(mInfo[pInfo[id][pOrg]][j][mPSQL]) {
		Advert(playerid, "Não foi possível aceitar o convite. Tente novamente.");
		Advert(id, "Esse cargo foi ocupado por outro membro. Tente novamente.");
	} else {
		pInfo[playerid][pOrg] = pInfo[id][pOrg];
		mInfo[pInfo[playerid][pOrg]][j][mPSQL] = pInfo[playerid][pSQL];
		new str[150];
		mysql_format(conn, str, 150, "UPDATE playerinfo SET org = %i WHERE sqlid = %i", pInfo[playerid][pOrg], pInfo[playerid][pSQL]);
		mysql_query(conn, str, false);
		mysql_format(conn, str, 150, "UPDATE memberinfo SET psql = %i WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][j][mPSQL], mInfo[pInfo[playerid][pOrg]][j][mSQL]);
		mysql_query(conn, str, false);
	}
	return ResetDialogParams(playerid);
}

Dialog:CargosOrg(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new li[MAX_ORG_MEMBERS], l = 0;
	for(new j = 0; j < MAX_ORG_MEMBERS; j++) {
		if(!oInfo[pInfo[playerid][pOrg]][oPost][j]) continue;
		li[l] = j;
		l++;
	}
	if(listitem == l) {
		Dialog_Show(playerid, "CCargoOrg", DIALOG_STYLE_INPUT, "Criar cargo", "Insira abaixo o nome do cargo que deseja criar.", "Criar", "Voltar");
	} else {
		new str[150];
		format(str, 150, "Membro: %s\nPermissão para recrutar/revogar: %s\nPermissão para promover/rebaixar: %s\nExcluir cargo",
			(mInfo[pInfo[playerid][pOrg]][li[listitem]][mPSQL] ? (GetpNickBySQL(mInfo[pInfo[playerid][pOrg]][li[listitem]][mPSQL])) : ("N/A")),
			(mInfo[pInfo[playerid][pOrg]][li[listitem]][mInvite] ? ("Sim") : ("Não")),
			(mInfo[pInfo[playerid][pOrg]][li[listitem]][mPromote] ? ("Sim") : ("Não")));
		Dialog_Show(playerid, "ECargoOrg", DIALOG_STYLE_LIST, "Editar cargo", str, "Selecionar", "Voltar");
		pInfo[playerid][pDialogParam][0] = funcidx("dialog_ECargoOrg");
		pInfo[playerid][pDialogParam][1] = li[listitem];
	}
	return 1;
}

Dialog:ECargoOrg(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_ECargoOrg")) return ResetDialogParams(playerid);
	new i = pInfo[playerid][pDialogParam][1];
	if(!response) {
		cmd_cargosorg(playerid);
	} else if(listitem == 0) {
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL]) {
			new str[144];
			format(str, 144, "Para retirá-lo da sua organização, use "AMARELO"/Revogar %s"BRANCO".", GetpNickBySQL(mInfo[pInfo[playerid][pOrg]][i][mPSQL]));
			Info(playerid, str);
		} else {
			Info(playerid, "Não há membro recrutado nesse cargo. Para recrutar alguém, use "AMARELO"/Recrutar [ID]"BRANCO".");
		}
	} else if(listitem == 1) {
		if(mInfo[pInfo[playerid][pOrg]][i][mInvite]) {
			mInfo[pInfo[playerid][pOrg]][i][mInvite] = 0;
			new query[150];
			mysql_format(conn, query, 150, "UPDATE memberinfo SET invite = 0 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][i][mSQL]);
			mysql_query(conn, query, false);
			format(query, 144, "Permissão para recrutar/revogar do cargo %s removida.", mInfo[pInfo[playerid][pOrg]][i][mName]);
			Success(playerid, query);
		} else {
			mInfo[pInfo[playerid][pOrg]][i][mInvite] = 1;
			new query[150];
			mysql_format(conn, query, 150, "UPDATE memberinfo SET invite = 1 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][i][mSQL]);
			mysql_query(conn, query, false);
			format(query, 144, "Permissão para recrutar/revogar do cargo %s adicionada.", mInfo[pInfo[playerid][pOrg]][i][mName]);
			Success(playerid, query);
		}
	} else if(listitem == 2) {
		if(mInfo[pInfo[playerid][pOrg]][i][mPromote]) {
			mInfo[pInfo[playerid][pOrg]][i][mPromote] = 0;
			new query[150];
			mysql_format(conn, query, 150, "UPDATE memberinfo SET promote = 0 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][i][mSQL]);
			mysql_query(conn, query, false);
			format(query, 144, "Permissão para promover/rebaixar do cargo %s removida.", mInfo[pInfo[playerid][pOrg]][i][mName]);
			Success(playerid, query);
		} else {
			mInfo[pInfo[playerid][pOrg]][i][mPromote] = 1;
			new query[150];
			mysql_format(conn, query, 150, "UPDATE memberinfo SET promote = 1 WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][i][mSQL]);
			mysql_query(conn, query, false);
			format(query, 144, "Permissão para promover/rebaixar do cargo %s adicionada.", mInfo[pInfo[playerid][pOrg]][i][mName]);
			Success(playerid, query);
		}
	} else if(listitem == 3) {
		if(mInfo[pInfo[playerid][pOrg]][i][mPSQL]) {
			Advert(playerid, "Você não pode excluir um cargo que esteja preenchido por um membro.");
		} else {
			new query[150];
			mysql_format(conn, query, 150, "DELETE FROM memberinfo WHERE sqlid = %i", mInfo[pInfo[playerid][pOrg]][i][mSQL]);
			mysql_query(conn, query, false);
			format(query, 144, "Cargo %s excluído com sucesso.", mInfo[pInfo[playerid][pOrg]][i][mName]);
			Success(playerid, query);
			mInfo[pInfo[playerid][pOrg]][i][mSQL] = 0;
			mInfo[pInfo[playerid][pOrg]][i][mPSQL] = 0;
			mInfo[pInfo[playerid][pOrg]][i][mName][0] = EOS;
			mInfo[pInfo[playerid][pOrg]][i][mInvite] = 0;
			mInfo[pInfo[playerid][pOrg]][i][mPromote] = 0;
			oInfo[pInfo[playerid][pOrg]][oPost][i] = 0;
		}
	}
	return ResetDialogParams(playerid);
}

Dialog:CCargoOrg(playerid, response, listitem, inputtext[]) {
	if(!response) {
		cmd_cargosorg(playerid);
	} else if(isnull(inputtext)) {
		Advert(playerid, "Nome inválido para cargo.");
	} else if(strlen(inputtext) > 24) {
		Advert(playerid, "Nome muito longo (máx 24 caracteres).");
	} else {
		new i = 0;
		for(; i < MAX_ORG_MEMBERS; i++) {
			if(!oInfo[pInfo[playerid][pOrg]][oPost][i]) break;
		}
		new str[150], Cache:result;
		format(mInfo[pInfo[playerid][pOrg]][i][mName], 25, "%s", inputtext);
		format(str, 144, "Novo cargo criado: %s", inputtext);
		Success(playerid, str);
		mysql_format(conn, str, 150, "INSERT INTO memberinfo (name) VALUES ('%s')", inputtext);
		result = mysql_query(conn, str, true);
		mInfo[pInfo[playerid][pOrg]][i][mSQL] = cache_insert_id();
		cache_delete(result);
		oInfo[pInfo[playerid][pOrg]][oPost][i] = mInfo[pInfo[playerid][pOrg]][i][mSQL];
		mysql_format(conn, str, 150, "UPDATE orginfo SET member%i = %i", i, mInfo[pInfo[playerid][pOrg]][i][mSQL]);
		mysql_query(conn, str, false);
	}
	return 1;
}

forward OnGameModeInit@org();
public OnGameModeInit@org() {
	mysql_tquery(conn, "SELECT * FROM `orginfo`", "LoadOrgData");
	mysql_tquery(conn, "SELECT * FROM `memberinfo`", "LoadMemberData");
	return 1;
}

forward LoadOrgData();
public LoadOrgData() {
	new row, str[40];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {
		cache_get_value_index_int(i, 0, oInfo[i][oSQL]);
		cache_get_value_name_int(i, "owner", oInfo[i][oOwner]);
		cache_get_value_name(i, "name", str);
		format(oInfo[i][oName], 40, "%s", str);

		for(new j = 0; j < MAX_ORG_MEMBERS; j++) {
			format(str, 10, "member%i", j);
			cache_get_value_name_int(i, str, oInfo[i][oPost][j]);
		}

	}
	return 1;
}

forward LoadMemberData();
public LoadMemberData() {
	new row, str[25];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {

		new y = 0, x = 0;

		cache_get_value_index_int(i, 0, x);

		for(new j = 0; j < MAX_ORGS; j++) {
			if(!oInfo[j][oSQL]) continue;
			for(new k = 0; k < MAX_ORG_MEMBERS; k++) {
				if(oInfo[j][oPost][k] == x) {
					mInfo[j][k][mSQL] = x;
					cache_get_value_name(i, "name", str);
					if(strcmp(str, "NULL", false)) { format(mInfo[j][k][mName], 24, "%s", str); }
					cache_get_value_name_int(i, "psql", mInfo[j][k][mPSQL]);
					cache_get_value_name_int(i, "invite", mInfo[j][k][mInvite]);
					cache_get_value_name_int(i, "promote", mInfo[j][k][mPromote]);
					y = 1;
					break;
				}
			}
			if(y) { break; }
		}
	}
	return 1;
}