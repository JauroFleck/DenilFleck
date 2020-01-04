#define BUSINESS_NONE		0
#define BUSINESS_BUS		1
#define BUSINESS_GAS		2
#define BUSINESS_REF		3

#define MAX_BUSINESS			10
#define MAX_CARGOS				10
#define MAX_PRODUTOS			10
#define MAX_BUSINESS_VEHICLES	10
#define MAX_ENTRADAS			2

enum BUSINESS_INFO {
	bSQL,
	bOwner[24],
	bName[40],
	bValue,
	bReceita,
	bVehicles[MAX_BUSINESS_VEHICLES],
	bCargos[MAX_CARGOS],
	bProdutos[MAX_PRODUTOS],
	bEntradas[MAX_ENTRADAS],
	bType,
	bCaixa,
	Float:bcP[3]
};

enum CARGOS_INFO {
	cSQL,
	cName[30],
	cEmp[24],
	cSal,
	cHire,
	cFire,
	cPay,
	cMon
};

enum PRODUTOS_INFO {
	prSQL,
	prName[25],
	Float:prPrice,
	prQuant
};

enum ENTRADAS_INFO {
	eSQL,
	Float:eP[4],
	Float:sP[4],
	sInt
};

new bInfo[MAX_BUSINESS][BUSINESS_INFO];
new cInfo[MAX_BUSINESS][MAX_CARGOS][CARGOS_INFO];
new prInfo[MAX_BUSINESS][MAX_PRODUTOS][PRODUTOS_INFO];
new eInfo[MAX_BUSINESS][MAX_ENTRADAS][ENTRADAS_INFO];

CMD:virardono(playerid) {
	if(strcmp(pNick(playerid), "John_Black", false)) return SendClientMessage(playerid, -1, "Nananinanão (:");
	pInfo[playerid][pBus] = 0;
	return 1;
}

CMD:contratar(playerid, params[]) { // /Contratar [Nome_do_Cargo] [ID]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25], id;
		if(sscanf(params, "s[25]i", nomedocargo, id)) return SendClientMessage(playerid, -1, "Use /Contratar [Nome_do_Cargo] [ID].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(!isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este cargo já está ocupado por outro funcionário.");
		if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "ID inválido.");
		new nameemp[24];
		GetPlayerName(id, nameemp, 24);
		for(new k = 0; k < 24; k++) { if(nameemp[k] == '_') { nameemp[k] = ' '; } }
		for(new k = 0; k < MAX_CARGOS; k++) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][k][cEmp], nameemp, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este funcionário já ocupa outro cargo nesta empresa.");
		}
		new Float:P[3], str2[24];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return SendClientMessage(playerid, -1, "Você deve estar próximo à pessoa que estiver contratando.");
		format(str2, 24, "%s", pNick(id));
		for(new k = 0; k < 24; k++) { if(str2[k] == '_') { str2[k] = ' '; } }
		format(cInfo[pInfo[playerid][pBus]][i][cEmp], 24, "%s", str2);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `emp` = '%s' WHERE `sqlid` = %i", str2, cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
		pInfo[id][pBus] = pInfo[playerid][pBus];
		new str[144];
		format(str, 144, "Você contratou %s para o cargo de %s.", pNick(id), nomedocargo);
		SendClientMessage(playerid, -1, str);
		format(str, 144, "%s contratou você para o cargo de %s.", pNick(playerid), nomedocargo);
		SendClientMessage(id, -1, str);
	} else {
		new Name[24], p = 0;
		GetPlayerName(playerid, Name, 24);
		while(p < MAX_CARGOS) {
			if(!strcmp(Name, cInfo[pInfo[playerid][pBus]][p][cEmp], false) && !isnull(cInfo[pInfo[playerid][pBus]][p][cEmp])) break;
			else p++; }
		if(!cInfo[pInfo[playerid][pBus]][p][cHire]) return SendClientMessage(playerid, -1, "Você não tem permissão para contratar.");
		new nomedocargo[25], id;
		if(sscanf(params, "s[25]i", nomedocargo, id)) return SendClientMessage(playerid, -1, "Use /Contratar [Nome_do_Cargo] [ID].");
		for(new i = 0; i < 25; i++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(!isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este cargo já está ocupado por outro funcionário.");
		if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "ID inválido.");
		new nameemp[24];
		GetPlayerName(id, nameemp, 24);
		for(new k = 0; k < 24; k++) { if(nameemp[k] == '_') { nameemp[k] = ' '; } }
		for(new k = 0; k < MAX_CARGOS; k++) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][k][cEmp], nameemp, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este funcionário já ocupa outro cargo nesta empresa.");
		}
		new Float:P[3], str2[24];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return SendClientMessage(playerid, -1, "Você deve estar próximo à pessoa que estiver contratando.");
		format(str2, 24, "%s", pNick(id));
		for(new k = 0; k < 24; k++) { if(str2[k] == '_') { str2[k] = ' '; } }
		format(cInfo[pInfo[playerid][pBus]][i][cEmp], 24, "%s", str2);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `emp` = '%s' WHERE `sqlid` = %i", str2, cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
		pInfo[id][pBus] = pInfo[playerid][pBus];
		new str[128];
		format(str, 128, "Você contratou %s para o cargo de %s.", pNick(id), nomedocargo);
		SendClientMessage(playerid, -1, str);
		format(str, 128, "%s contratou você para o cargo de %s.", pNick(playerid), nomedocargo);
		SendClientMessage(id, -1, str);
	}
	return 1;
}

CMD:demitir(playerid, params[]) { // /Demitir [Nome_Sobrenome] //////////////////////// MUDAR NA BASE DE DADOS DE IMEDIATO
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nickname[24];
		if(sscanf(params, "s", nickname)) return SendClientMessage(playerid, -1, "Use /Demitir [Nome_Sobrenome].");
		new name[24];
		for(new i = 0; i < 24; i++) { if(nickname[i] == '_') { name[i] = ' '; } else { name[i] = nickname[i]; } }
		for(new i = 0; i < MAX_CARGOS; i++) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], name, false) && !isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) {
				if(cInfo[pInfo[playerid][pBus]][i][cMon]) return SendClientMessage(playerid, -1, "Você não pode demitir alguém com pagamento pendente.");
				new str[128];
				format(str, 128, "Você demitiu %s do cargo de %s.", cInfo[pInfo[playerid][pBus]][i][cEmp], cInfo[pInfo[playerid][pBus]][i][cName]);
				SendClientMessage(playerid, -1, str);
				new query[100];
				mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `emp` = '' WHERE sqlid = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
				mysql_query(conn, query, false);
				mysql_format(conn, query, 100, "UPDATE `playerinfo` SET `pbus` = -1 WHERE nickname = '%i'", nickname);
				mysql_query(conn, query, false);
				format(cInfo[pInfo[playerid][pBus]][i][cEmp], 24, "");
				new id = GetPlayerIDByNickname(nickname);
				if(id != -1) { // Connected
					format(str, 128, "Você foi demitido da sua empresa por %s.", pNick(playerid));
					SendClientMessage(id, -1, str);
					pInfo[id][pBus] = -1;
				}
				return 1;
			}
		}
		SendClientMessage(playerid, -1, "Não há um funcionário com este nome na sua empresa.");
	} else {
		new Name[24], p = 0;
		GetPlayerName(playerid, Name, 24);
		while(p < MAX_CARGOS) {
			if(!strcmp(Name, cInfo[pInfo[playerid][pBus]][p][cEmp], false) && !isnull(cInfo[pInfo[playerid][pBus]][p][cEmp])) break;
			else p++; }
		if(!cInfo[pInfo[playerid][pBus]][p][cFire]) return SendClientMessage(playerid, -1, "Você não tem permissão para demitir.");
		new nickname[24];
		if(sscanf(params, "s", nickname)) return SendClientMessage(playerid, -1, "Use /Demitir [Nome_Sobrenome].");
		new name[24];
		for(new i = 0; i < 24; i++) { if(nickname[i] == '_') { name[i] = ' '; } else { name[i] = nickname[i]; } }
		for(new i = 0; i < MAX_CARGOS; i++) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], name, false) && !isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) {
				if(cInfo[pInfo[playerid][pBus]][i][cMon]) return SendClientMessage(playerid, -1, "Você não pode demitir alguém com pagamento pendente.");
				new str[128];
				format(str, 128, "Você demitiu %s do cargo de %s.", cInfo[pInfo[playerid][pBus]][i][cEmp], cInfo[pInfo[playerid][pBus]][i][cName]);
				SendClientMessage(playerid, -1, str);
				new query[100];
				mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `emp` = '' WHERE sqlid = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
				mysql_query(conn, query, false);
				mysql_format(conn, query, 100, "UPDATE `playerinfo` SET `pbus` = -1 WHERE nickname = '%i'", nickname);
				mysql_query(conn, query, false);
				format(cInfo[pInfo[playerid][pBus]][i][cEmp], 24, "");
				new id = GetPlayerIDByNickname(nickname);
				if(id != -1) { // Connected
					format(str, 128, "Você foi demitido da sua empresa por %s.", pNick(playerid));
					SendClientMessage(id, -1, str);
					pInfo[id][pBus] = -1;
				}
				return 1;
			}
		}
		SendClientMessage(playerid, -1, "Não há um funcionário com este nome na sua empresa.");
	}
	return 1;
}

CMD:criarcargo(playerid, params[]) { // /CriarCargo [Nome_do_Cargo] [Salário do Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new nomedocargo[25], salariodocargo;
	if(sscanf(params, "s[25]i", nomedocargo, salariodocargo)) return SendClientMessage(playerid, -1, "Use /CriarCargo [Nome_do_Cargo] [Salário do Cargo].");
	for(new i = 0; i < 25; i++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
	for(new i = 0; i < MAX_CARGOS; i++) {
		if(!strcmp(nomedocargo, cInfo[pInfo[playerid][pBus]][i][cName], true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) {
			SendClientMessage(playerid, -1, "Já existe um cargo com este nome, use outro.");
			return 1;
		} 
	}
	new i = 0;
	while(i < MAX_CARGOS) {
		if(!cInfo[pInfo[playerid][pBus]][i][cSQL]) break;
		else i++;
	}
	if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Esta empresa já atingiu o seu limite de cargos.");
	if(salariodocargo < 1) return SendClientMessage(playerid, -1, "Salário inválido.");
	format(cInfo[pInfo[playerid][pBus]][i][cName], 25, "%s", nomedocargo);
	cInfo[pInfo[playerid][pBus]][i][cSal] = salariodocargo;
	new str[128];
	format(str, 128, "Cargo criado: %s. Salário: %i", nomedocargo, salariodocargo);
	SendClientMessage(playerid, -1, str);
	new query[150];
	mysql_format(conn, query, 150, "INSERT INTO `cargoinfo` (`name`, `emp`, `sal`) VALUES ('%s', '', %i)", nomedocargo, salariodocargo);
	new Cache:result = mysql_query(conn, query);
	cInfo[pInfo[playerid][pBus]][i][cSQL] = cache_insert_id();
	cache_delete(result);
	format(str, 128, "cargo%i", i);
	mysql_format(conn, query, 150, "UPDATE `businessinfo` SET `%s` = %i WHERE `sqlid` = %i", str, cInfo[pInfo[playerid][pBus]][i][cSQL], bInfo[pInfo[playerid][pBus]][bSQL]);
	mysql_query(conn, query, false);
	return 1;
}

CMD:excluircargo(playerid, params[]) { // /ExcluirCargo [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) return SendClientMessage(playerid, -1, "Apenas o dono da empresa pode fazer isso.");
	new nomedocargo[25];
	if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /ExcluirCargo [Nome_do_Cargo].");
	for(new i = 0; i < 25; i++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
	for(new i = 0; i < MAX_CARGOS; i++) {
		if(!strcmp(nomedocargo, cInfo[pInfo[playerid][pBus]][i][cName], true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) {
			if(!isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Você não pode excluir um cargo que tenha funcionário contratado.");
			format(cInfo[pInfo[playerid][pBus]][i][cName], 25, "");
			cInfo[pInfo[playerid][pBus]][i][cSal] = 0;
			SendClientMessage(playerid, -1, "Cargo excluído com sucesso.");
			new query[150], str[10];
			mysql_format(conn, query, 150, "DELETE FROM `cargoinfo` WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
			mysql_query(conn, query, false);
			format(str, 10, "cargo%i", i);
			mysql_format(conn, query, 150, "UPDATE `businessinfo` SET `%s` = 0 WHERE `sqlid` = %i", str, bInfo[pInfo[playerid][pBus]][bSQL]);
			mysql_query(conn, query, false);
			cInfo[pInfo[playerid][pBus]][i][cSQL] = 0;
			return 1;
		}
	}
	SendClientMessage(playerid, -1, "Este cargo nem mesmo existe.");
	return 1;
}

CMD:pcontratar(playerid, params[]) { // /pContratar [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /pContratar [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cHire] == 1) return SendClientMessage(playerid, -1, "Este cargo já possui permissão de contratar.");
		cInfo[pInfo[playerid][pBus]][i][cHire] = 1;
		new str[128];
		format(str, 128, "Você deu permissão para qualquer funcionário que ocupe o cargo de %s possa contratar.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `hire` = 1 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:ppagar(playerid, params[]) { // /pPagar [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /pPagar [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cPay] == 1) return SendClientMessage(playerid, -1, "Este cargo já possui permissão de pagar salário.");
		cInfo[pInfo[playerid][pBus]][i][cPay] = 1;
		new str[144];
		format(str, 144, "Você deu permissão para qualquer funcionário que ocupe o cargo de %s possa pagar salário.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `pay` = 1 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:pdemitir(playerid, params[]) { // /pDemitir [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /pDemitir [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cFire] == 1) return SendClientMessage(playerid, -1, "Este cargo já possui permissão de demitir.");
		cInfo[pInfo[playerid][pBus]][i][cFire] = 1;
		new str[128];
		format(str, 128, "Você deu permissão para qualquer funcionário que ocupe o cargo de %s possa demitir.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `fire` = 1 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:rpcontratar(playerid, params[]) { // /rpContratar [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /rpContratar [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cHire] == 0) return SendClientMessage(playerid, -1, "Este cargo não possui permissão de contratar.");
		cInfo[pInfo[playerid][pBus]][i][cHire] = 0;
		new str[128];
		format(str, 128, "Você retirou a permissão para qualquer funcionário que ocupe o cargo de %s possa contratar.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `hire` = 0 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:rppagar(playerid, params[]) { // /rpPagar [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /rpPagar [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cPay] == 0) return SendClientMessage(playerid, -1, "Este cargo não possui permissão de pagar salário.");
		cInfo[pInfo[playerid][pBus]][i][cPay] = 0;
		new str[128];
		format(str, 128, "Você retirou a permissão para qualquer funcionário que ocupe o cargo de %s possa pagar salário.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `pay` = 0 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:rpdemitir(playerid, params[]) { // /rpDemitir [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /rpDemitir [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(cInfo[pInfo[playerid][pBus]][i][cFire] == 0) return SendClientMessage(playerid, -1, "Este cargo não possui permissão de demitir.");
		cInfo[pInfo[playerid][pBus]][i][cFire] = 0;
		new str[128];
		format(str, 128, "Você retirou a permissão para qualquer funcionário que ocupe o cargo de %s possa demitir.", cInfo[pInfo[playerid][pBus]][i][cName]);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `fire` = 0 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:msalario(playerid, params[]) { // /mSalario [Nome_do_Cargo] [Salário]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25], sal;
		if(sscanf(params, "s[25]i", nomedocargo, sal)) return SendClientMessage(playerid, -1, "Use /mSalario [Nome_do_Cargo] [Salário].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(sal < 1) return SendClientMessage(playerid, -1, "Salário inválido.");
		cInfo[pInfo[playerid][pBus]][i][cSal] = sal;
		new str[128];
		format(str, 128, "Você modificou o salário do cargo %s para $%i", cInfo[pInfo[playerid][pBus]][i][cName], sal);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `sal` = %i WHERE `sqlid` = %i", sal, cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:precoproduto(playerid, params[]) { // /PrecoProduto [Nome_do_Produto] [Novo preço]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new produto[25], Float:preco;
		if(sscanf(params, "s[25]f", produto, preco)) return SendClientMessage(playerid, -1, "Use /PrecoProduto [Nome_do_Produto] [Novo preço].");
		for(new i = 0; i < 25; i++) { if(produto[i] == '_') { produto[i] = ' '; } }
		new i = 0;
		while(i < MAX_PRODUTOS) {
			if(!strcmp(prInfo[pInfo[playerid][pBus]][i][prName], produto, true) && !isnull(prInfo[pInfo[playerid][pBus]][i][prName])) break;
			else i++;
		}
		if(i == MAX_PRODUTOS) return SendClientMessage(playerid, -1, "Não existe um produto com este nome.");
		if(preco <= 0.0) return SendClientMessage(playerid, -1, "Preço inválido.");
		prInfo[pInfo[playerid][pBus]][i][prPrice] = preco;
		new str[128];
		format(str, 128, "Você estabeleceu o preço do produto %s para $%.2f.", prInfo[pInfo[playerid][pBus]][i][prName], preco);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `produtoinfo` SET `price` = %.2f WHERE `sqlid` = %i", preco, prInfo[pInfo[playerid][pBus]][i][prSQL]);
		mysql_query(conn, query, false);
	} else { SendClientMessage(playerid, -1, "Apenas o dono da empresa pode usar este comando."); }
	return 1;
}

CMD:adicionarveiculo(playerid, params[]) { // /AdicionarVeiculo [Empresa ID]
	if(strcmp(pNick(playerid), "John_Black", false)) return SendClientMessage(playerid, -1, "Nananinanão (:");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Entre em um veículo para usar este comando corretamente.");
	new vid = GetPlayerVehicleID(playerid);
	if(vInfo[vid][vModel] == 0) return SendClientMessage(playerid, -1, "Veículo não atribuído à base de dados.");
	new eid;
	if(sscanf(params, "i", eid)) return SendClientMessage(playerid, -1, "Use /AdicionarVeiculo [Empresa ID].");
	if(eid < 0 || eid >= MAX_BUSINESS) return SendClientMessage(playerid, -1, "Ta querendo crashar o server?");
	new i = 0;
	while(i < MAX_BUSINESS_VEHICLES) {
		if(!bInfo[eid][bVehicles][i]) break;
		i++;
	}
	if(i == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Esta empresa não pode ter mais veículos.");
	if(!bInfo[eid][bSQL]) return SendClientMessage(playerid, -1, "Não existe empresa com este ID.");
	bInfo[eid][bVehicles][i] = vInfo[vid][vSQL];
	format(vInfo[vid][vOwner], 24, "%s", bInfo[eid][bOwner]);
	GetVehiclePos(vid, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2]);
	GetVehicleZAngle(vid, vInfo[vid][vSpawn][3]);
	new str[128];
	format(str, 128, "Veículo [%i] adicionado à empresa de nome %s, com dono %s.", vid, bInfo[eid][bName], bInfo[eid][bOwner]);
	SendClientMessage(playerid, -1, str);
	new query[150];
	format(str, 10, "veiculo%i", i);
	mysql_format(conn, query, 150, "UPDATE `businessinfo` SET `%s` = %i WHERE `sqlid` = %i", str, vInfo[vid][vSQL], bInfo[eid][bSQL]);
	mysql_query(conn, query, false);
	return 1;
}

CMD:removerveiculo(playerid) {
	if(strcmp(pNick(playerid), "John_Black", false)) return SendClientMessage(playerid, -1, "Nananinanão (:");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Entre em um veículo para usar este comando corretamente.");
	new vid = GetPlayerVehicleID(playerid);
	if(!vInfo[vid][vSQL]) return SendClientMessage(playerid, -1, "Veículo não atribuído à base de dados.");
	new i = 0, j = 0;
	while(i < MAX_BUSINESS) {
		while(j < MAX_BUSINESS_VEHICLES) {
			if(vInfo[vid][vSQL] == bInfo[i][bVehicles][j]) {
				new query[100], str[144];
				format(str, 144, "veiculo%i", j);
				mysql_format(conn, query, 100, "UPDATE `businessinfo` SET `%s` = '0' WHERE `sqlid` = %i", str, bInfo[i][bSQL]);
				mysql_query(conn, query, false);
				bInfo[i][bVehicles][j] = 0;
				format(str, 144, "Veículo [%i] removido da empresa %s de dono %s.", vid, bInfo[i][bName], bInfo[i][bOwner]);
				SendClientMessage(playerid, -1, str);
				SendClientMessage(playerid, -1, "Lembre-se: o veículo continua na base de dados, mas não pertence mais a esta empresa.");
				SendClientMessage(playerid, -1, "Para remover o veículo da base de dados, use /DeletarVeiculo.");
				return 1;
			}
			j++;
		}
		i++;
	}
	if(i == MAX_BUSINESS) return SendClientMessage(playerid, -1, "Este veículo não pertence a nenhuma empresa.");
	return 1;
}

CMD:pagarsalario(playerid, params[]) { // /PagarSalario [Nome_do_Cargo]
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false) && !isnull(bInfo[pInfo[playerid][pBus]][bOwner])) {
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /PagarSalario [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este cargo está desocupado.");

		new nickname[24];
		format(nickname, 24, "%s", cInfo[pInfo[playerid][pBus]][i][cEmp]);
		for(new j = 0; j < 24; j ++) { if(nickname[j] == ' ') { nickname[j] = '_'; } }
		new id = GetPlayerIDByNickname(nickname);
		if(id == -1) return SendClientMessage(playerid, -1, "O funcionário que ocupa este cargo está desconectado.");
		new Float:P[3];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return SendClientMessage(playerid, -1, "Você deve estar próximo à pessoa que estiver pagando.");
		if(cInfo[pInfo[playerid][pBus]][i][cMon] < 1) return SendClientMessage(playerid, -1, "Este funcionário não tem nada a receber.");
		if(bInfo[pInfo[playerid][pBus]][bReceita] < cInfo[pInfo[playerid][pBus]][i][cMon]) {
			new str[128];
			format(str, 128, "Os fundos da empresa ($%i) não são suficientes para pagar o salário deste funcionário ($%i)", bInfo[pInfo[playerid][pBus]][bReceita], cInfo[pInfo[playerid][pBus]][i][cMon]);
			SendClientMessage(playerid, -1, str);
			return 1;
		}
		new str[128];
		format(str, 128, "O funcionário %s de cargo %s foi pago em $%i pelos seus serviços.", cInfo[pInfo[playerid][pBus]][i][cEmp], cInfo[pInfo[playerid][pBus]][i][cName], cInfo[pInfo[playerid][pBus]][i][cMon]);
		SendClientMessage(playerid, -1, str);
		format(str, 128, "Você foi pago por %s na quantia de $%i pelos serviços prestados.", pNick(playerid), cInfo[pInfo[playerid][pBus]][i][cMon]);
		SendClientMessage(id, -1, str);
		GivePlayerMoney(id, cInfo[pInfo[playerid][pBus]][i][cMon]);
		bInfo[pInfo[playerid][pBus]][bReceita] -= cInfo[pInfo[playerid][pBus]][i][cMon];
		cInfo[pInfo[playerid][pBus]][i][cMon] = 0;
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `businessinfo` SET `receita` = %i WHERE `sqlid` = %i", bInfo[pInfo[playerid][pBus]][bReceita], bInfo[pInfo[playerid][pBus]][bSQL]);
		mysql_query(conn, query, false);
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `mon` = 0 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);

	} else {
		new Name[24], p = 0;
		GetPlayerName(playerid, Name, 24);
		while(p < MAX_CARGOS) {
			if(!strcmp(Name, cInfo[pInfo[playerid][pBus]][p][cEmp], false) && !isnull(cInfo[pInfo[playerid][pBus]][p][cEmp])) break;
			else p++; }
		if(!cInfo[pInfo[playerid][pBus]][p][cPay]) return SendClientMessage(playerid, -1, "Você não tem permissão para pagar salário.");
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /PagarSalario [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cName], nomedocargo, true) && !isnull(cInfo[pInfo[playerid][pBus]][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(isnull(cInfo[pInfo[playerid][pBus]][i][cEmp])) return SendClientMessage(playerid, -1, "Este cargo está desocupado.");

		new nickname[24];
		format(nickname, 24, "%s", cInfo[pInfo[playerid][pBus]][i][cEmp]);
		for(new j = 0; j < 24; j ++) { if(nickname[j] == ' ') { nickname[j] = '_'; } }
		new id = GetPlayerIDByNickname(nickname);
		if(id == -1) return SendClientMessage(playerid, -1, "O funcionário que ocupa este cargo está desconectado.");
		new Float:P[3];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return SendClientMessage(playerid, -1, "Você deve estar próximo à pessoa que estiver pagando.");
		if(cInfo[pInfo[playerid][pBus]][i][cMon] < 1) return SendClientMessage(playerid, -1, "Este funcionário não tem nada a receber.");
		if(bInfo[pInfo[playerid][pBus]][bReceita] < cInfo[pInfo[playerid][pBus]][i][cMon]) {
			new str[128];
			format(str, 128, "Os fundos da empresa ($%i) não são suficientes para pagar o salário deste funcionário ($%i)", bInfo[pInfo[playerid][pBus]][bReceita], cInfo[pInfo[playerid][pBus]][i][cMon]);
			SendClientMessage(playerid, -1, str);
			return 1;
		}
		new str[128];
		format(str, 128, "O funcionário %s de cargo %s foi pago em $%i pelos seus serviços.", cInfo[pInfo[playerid][pBus]][i][cEmp], cInfo[pInfo[playerid][pBus]][i][cName], cInfo[pInfo[playerid][pBus]][i][cMon]);
		SendClientMessage(playerid, -1, str);
		format(str, 128, "Você foi pago por %s na quantia de $%i pelos serviços prestados.", pNick(playerid), cInfo[pInfo[playerid][pBus]][i][cMon]);
		SendClientMessage(id, -1, str);
		GivePlayerMoney(id, cInfo[pInfo[playerid][pBus]][i][cMon]);
		bInfo[pInfo[playerid][pBus]][bReceita] -= cInfo[pInfo[playerid][pBus]][i][cMon];
		cInfo[pInfo[playerid][pBus]][i][cMon] = 0;
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `businessinfo` SET `receita` = %i WHERE `sqlid` = %i", bInfo[pInfo[playerid][pBus]][bReceita], bInfo[pInfo[playerid][pBus]][bSQL]);
		mysql_query(conn, query, false);
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `mon` = 0 WHERE `sqlid` = %i", cInfo[pInfo[playerid][pBus]][i][cSQL]);
		mysql_query(conn, query, false);
	}
	return 1;
}

CMD:empresas(playerid) {
	new str[500];
	for(new i = 0; i < MAX_BUSINESS; i++) {
		if(bInfo[i][bSQL]) { format(str, 500, "%s\n[%02i] %s - Dono: %s", str, i, bInfo[i][bName], bInfo[i][bOwner]); }
	}
	if(isnull(str)) return Info(playerid, "Não há existem empresas criadas.");
	format(str, 500, "\t{FFFF00}Empresas:{FFFFFF}\n%s", str);
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "{FFFFFF}Empresas", str, "Fechar", "");
	return 1;
}

forward OnGameModeInit@business();
public OnGameModeInit@business() {
	mysql_tquery(conn, "SELECT * FROM `businessinfo`", "LoadBusinessData");
	mysql_tquery(conn, "SELECT * FROM `produtoinfo`", "LoadProductData");
	mysql_tquery(conn, "SELECT * FROM `cargoinfo`", "LoadCargoData");
	mysql_tquery(conn, "SELECT * FROM `entradainfo`", "LoadEntradaData");
	return 1;
}

forward LoadBusinessData();
public LoadBusinessData() {
	new row, str[40];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {

		cache_get_value_index_int(i, 0, bInfo[i][bSQL]);
		cache_get_value_name(i, "owner", str);
		format(bInfo[i][bOwner], 24, "%s", str);
		cache_get_value_name(i, "name", str);
		format(bInfo[i][bName], 40, "%s", str);
		cache_get_value_name_int(i, "value", bInfo[i][bValue]);
		cache_get_value_name_int(i, "receita", bInfo[i][bReceita]);
		cache_get_value_name_int(i, "type", bInfo[i][bType]);
		cache_get_value_name_int(i, "caixa", bInfo[i][bCaixa]);
		cache_get_value_name_float(i, "cX", bInfo[i][bcP][0]);
		cache_get_value_name_float(i, "cY", bInfo[i][bcP][1]);
		cache_get_value_name_float(i, "cZ", bInfo[i][bcP][2]);

		for(new j = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			format(str, 10, "veiculo%i", j);
			cache_get_value_name_int(i, str, bInfo[i][bVehicles][j]);
		}

		for(new j = 0; j < MAX_CARGOS; j++) {
			format(str, 10, "cargo%i", j);
			cache_get_value_name_int(i, str, bInfo[i][bCargos][j]);
		}

		for(new j = 0; j < MAX_PRODUTOS; j++) {
			format(str, 10, "produto%i", j);
			cache_get_value_name_int(i, str, bInfo[i][bProdutos][j]);
		}

		for(new j = 0; j < MAX_ENTRADAS; j++) {
			format(str, 10, "entrada%i", j);
			cache_get_value_name_int(i, str, bInfo[i][bEntradas][j]);
		}

	}
	return 1;
}

forward LoadProductData();
public LoadProductData() {
	new row, str[25];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {

		new j = 0, y = 0, x = 0;

		cache_get_value_index_int(i, 0, x);

		for(; j < MAX_BUSINESS; j++) {
			if(!bInfo[j][bSQL]) continue;
			for(new k = 0; k < MAX_PRODUTOS; k++) {
				if(bInfo[j][bProdutos][k] == x) {
					prInfo[j][k][prSQL] = x;
					cache_get_value_name(i, "name", str);
					format(prInfo[j][k][prName], 25, "%s", str);
					cache_get_value_name_float(i, "price", prInfo[j][k][prPrice]);
					cache_get_value_name_int(i, "quant", prInfo[j][k][prQuant]);
					y = 1;
					break;
				}
			}
			if(y) { break; }
		}

	}
	return 1;
}

forward LoadCargoData();
public LoadCargoData() {
	new row, str[25];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {

		new j = 0, y = 0, x = 0;

		cache_get_value_index_int(i, 0, x);

		for(; j < MAX_BUSINESS; j++) {
			if(!bInfo[j][bSQL]) continue;
			for(new k = 0; k < MAX_CARGOS; k++) {
				if(bInfo[j][bCargos][k] == x) {
					cInfo[j][k][cSQL] = x;
					cache_get_value_name(i, "name", str);
					format(cInfo[j][k][cName], 25, "%s", str);
					cache_get_value_name(i, "emp", str);
					format(cInfo[j][k][cEmp], 25, "%s", str);
					cache_get_value_name_int(i, "sal", cInfo[j][k][cSal]);
					cache_get_value_name_int(i, "hire", cInfo[j][k][cHire]);
					cache_get_value_name_int(i, "fire", cInfo[j][k][cFire]);
					cache_get_value_name_int(i, "pay", cInfo[j][k][cPay]);
					cache_get_value_name_int(i, "mon", cInfo[j][k][cMon]);
					y = 1;
					break;
				}
			}
			if(y) { break; }
		}


	}
	return 1;
}

forward LoadEntradaData();
public LoadEntradaData() {
	new row;
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {

		new j = 0, y = 0, x = 0;

		cache_get_value_index_int(i, 0, x);

		for(; j < MAX_BUSINESS; j++) {
			if(!bInfo[j][bSQL]) continue;
			for(new k = 0; k < MAX_ENTRADAS; k++) {
				if(bInfo[j][bEntradas][k] == x) {
					eInfo[j][k][eSQL] = x;
					cache_get_value_name_float(i, "eX", eInfo[j][k][eP][0]);
					cache_get_value_name_float(i, "eY", eInfo[j][k][eP][1]);
					cache_get_value_name_float(i, "eZ", eInfo[j][k][eP][2]);
					cache_get_value_name_float(i, "eA", eInfo[j][k][eP][3]);
					cache_get_value_name_float(i, "sX", eInfo[j][k][sP][0]);
					cache_get_value_name_float(i, "sY", eInfo[j][k][sP][1]);
					cache_get_value_name_float(i, "sZ", eInfo[j][k][sP][2]);
					cache_get_value_name_float(i, "sA", eInfo[j][k][sP][3]);
					cache_get_value_name_int(i, "sInt", eInfo[j][k][sInt]);
					y = 1;
					break;
				}
			}
			if(y) { break; }
		}

	}
	return 1;
}