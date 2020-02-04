#define BUSINESS_NONE		0
#define BUSINESS_BUS		1
#define BUSINESS_GAS		2
#define BUSINESS_REF		3
#define BUSINESS_BANK		4
#define BUSINESS_AUTO		5
#define BUSINESS_CONC		6
#define BUSINESS_TRANSP		7
#define BUSINESS_IMOB		8
#define BUSINESS_GARBAGE	9

#define BUSID_BUSBB			0
#define BUSID_PGMG			1
#define BUSID_PGDM			2
#define BUSID_REF			3
#define BUSID_BANKPC		4
#define BUSID_AUTO			5
#define BUSID_CONC			6
#define BUSID_TRANSP		7
#define BUSID_IMOB			8
#define BUSID_PGFC			9
#define BUSID_GARBAGE		10

enum CARGOS_INFO {
	cSQL,
	cName[30],
	cEmp[24],
	cSal,
	cHire,
	cPay,
	cMon
};

enum PRODUTOS_INFO {
	prSQL,
	prName[25],
	Float:prPrice,
	prQuant,
	prModel
};

enum ENTRADAS_INFO {
	eSQL,
	Float:eP[4],
	Float:sP[4],
	sInt
};

enum GE_INFO {
	geID,
	PlayerText:geTDID
};

enum TDMP_INFO { tdmpValue[24] };

new cInfo[MAX_BUSINESS][MAX_CARGOS][CARGOS_INFO];
new prInfo[MAX_BUSINESS][MAX_PRODUTOS][PRODUTOS_INFO];
new eInfo[MAX_BUSINESS][MAX_ENTRADAS][ENTRADAS_INFO];
new TDMParams[MAX_PLAYERS][70][TDMP_INFO];
new GerenciandoEmpresa[MAX_PLAYERS][GE_INFO];

CMD:servico(playerid) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] == BUSINESS_BANK) {
		if(pInfo[playerid][pDuty]) {
			pInfo[playerid][pDuty] = 0;
			pInfo[playerid][pUSECMD_anim] = 0;
		} else {
			if(!IsPlayerInRangeOfPoint(playerid, 3.0, 2305.9309,-2.4660,26.7422)) return Advert(playerid, "Você deve estar na mesa de gerenciamento de contas bancárias.");
			if(pInfo[playerid][pAnim] != ANIM_SIT3) return Advert(playerid, "Use "AMARELO"/Sentar 4"BRANCO" para entrar em serviço.");
			Info(playerid, "Você entrou em serviço. Para se levantar use "AMARELO"/Servico"BRANCO" e "AMARELO"/Clear"BRANCO".");
			pInfo[playerid][pDuty] = 1;
			pInfo[playerid][pUSECMD_anim] = 1;
		}
	}
	return 1;
}

CMD:gerenciarempresa(playerid, params[]) {
	if(pInfo[playerid][pTDSelect]) {
		if(GerenciandoEmpresa[playerid][geID]) {
			Info(playerid, "Clique em "AMARELO"salvar"BRANCO" ou "VERMELHO"cancelar"BRANCO" para sair do gerenciamento.");
		} else {
			Advert(playerid, "Comando indisponível para você nesse momento. Saia da seleção.");
		}
		return 1;
	}
	new i, k, j;
	for(; i < MAX_BUSINESS; i++) {
		if(!bInfo[i][bSQL]) continue;
		else if(strcmp(bInfo[i][bOwner], pNick(playerid), false)) continue;
		else if(!k) { k = i+1; }
		else break;
	}
	if(i == MAX_BUSINESS && !k) return Advert(playerid, "Apenas donos de empresas podem fazer isso.");
	k--;
	if(sscanf(params, "i", j)) {
		if(i == MAX_BUSINESS) { // Dono de apenas uma empresa de ID = k.
			BusinessManager(playerid, k);
		} else {				// Dono de duas ou + empresas de ID = k e ID = i.
			Advert(playerid, "Como você é dono de mais que uma empresa, use "AMARELO"/GerenciarEmpresa [ID da empresa]"BRANCO".");
		}
	} else {
		if(j < 0 || j >= MAX_BUSINESS) return Advert(playerid, "Empresa inválida. Use "AMARELO"/Empresas"BRANCO".");
		else if(!bInfo[j][bSQL]) return Advert(playerid, "Empresa inexistente. Use "AMARELO"/Empresas"BRANCO".");
		else if(strcmp(bInfo[j][bOwner], pNick(playerid), false)) return Advert(playerid, "Apenas o dono da empresa pode fazer isso.");
		else { BusinessManager(playerid, j); }
	}
	return 1;
}

CMD:contratar(playerid, params[]) { // /Contratar [Nome_do_Cargo] [ID]
	new busid = -1;
	if(IsPlayerInRangeOfPoint(playerid, 5.0, 310.0332,-60.3852,1.6241)) { busid = BUSID_BUSBB; }
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, -35.9441,-57.4258,1023.5469)) { busid = BUSID_PGMG; }
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 527.0273,197.9422,1049.9844)) { busid = BUSID_REF; }
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 2306.9746,-7.8869,26.7422)) { busid = BUSID_BANKPC; }
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 360.8137,197.5316,1084.1685)) { busid = BUSID_AUTO; }
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, -1941.2062,260.6828,1196.4410)) { busid = BUSID_CONC; }
	else if(busid == -1) return Advert(playerid, "Há lugares específicos para contratação.");
	new perm = 0;
	if(!strcmp(bInfo[busid][bOwner], pNick(playerid), false)) {
		perm = 1;
	} else {
		new Name[24], p = 0;
		GetPlayerName(playerid, Name, 24);
		UnderlineToSpace(Name);
		for(; p < MAX_CARGOS; p++) {
			if(!cInfo[busid][p][cSQL]) continue;
			else if(strcmp(Name, cInfo[busid][p][cEmp], false)) continue;
			else break;
		}
		if(!cInfo[busid][p][cHire]) return Advert(playerid, "Você não tem permissão para contratar.");
		else { perm = 1; }
	} if(perm) {
		new nomedocargo[25], id;
		if(sscanf(params, "s[25]i", nomedocargo, id)) return AdvertCMD(playerid, "/Contratar [Nome_do_Cargo] [ID]");
		UnderlineToSpace(nomedocargo);
		new i = 0;
		for(; i < MAX_CARGOS; i++) {
			if(!cInfo[busid][i][cSQL]) continue;
			else if(strcmp(cInfo[busid][i][cName], nomedocargo, true)) continue;
			else break;
		}
		if(i == MAX_CARGOS) return Advert(playerid, "Não existe um cargo com este nome.");
		if(!isnull(cInfo[busid][i][cEmp])) return Advert(playerid, "Este cargo já está ocupado por outro funcionário.");
		if(!IsPlayerConnected(id)) return SendClientMessage(playerid, -1, "ID inválido.");
		new Float:P[3];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo à pessoa que estiver contratando.");
		if(pInfo[id][pBus] != -1) return Advert(playerid, "Você não pode contratar alguém que não seja desempregado.");
		format(cInfo[busid][i][cEmp], 24, "%s", pName(id));
		new query[120];
		mysql_format(conn, query, 120, "UPDATE `cargoinfo` SET `emp` = '%s' WHERE `sqlid` = %i", pName(id), cInfo[busid][i][cSQL]);
		mysql_query(conn, query, false);
		pInfo[id][pBus] = busid;
		new str[200];
		format(str, 144, "oferece um papel e uma caneta preta para %s a fim de assinar o contrato de trabalho.", pName(id));
		Act(playerid, str);
		format(str, 200, BRANCO"Assine abaixo para ser empregado na empresa "AMARELO"%s"BRANCO" com o cargo de %s.", bInfo[busid][bName], nomedocargo);
		Dialog_Show(id, "DialogContratar", DIALOG_STYLE_MSGBOX, BRANCO"CONTRATO", str, "Assinar", "Recusar");
		pInfo[id][pDialogParam][0] = funcidx("dialog_DialogContratar");
		pInfo[id][pDialogParam][1] = busid;
		pInfo[id][pDialogParam][2] = i;
	}
	return 1;
}

CMD:demitir(playerid, params[]) { // /Demitir [Nome_Sobrenome]
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	new perm = 0;
	if(!strcmp(bInfo[pInfo[playerid][pBus]][bOwner], pNick(playerid), false)) {
		perm = 1;	
	} else {
		new Name[24], p = 0;
		GetPlayerName(playerid, Name, 24);
		UnderlineToSpace(Name);
		for(; p < MAX_CARGOS; p++) {
			if(!cInfo[pInfo[playerid][pBus]][p][cSQL]) continue;
			else if(strcmp(Name, cInfo[pInfo[playerid][pBus]][p][cEmp], false)) continue;
			else break;
		}
		if(!cInfo[pInfo[playerid][pBus]][p][cHire]) return Advert(playerid, "Você não tem permissão para demitir.");
		else { perm = 1; }
	}
	if(perm) {
		new nickname[24];
		if(sscanf(params, "s[24]", nickname)) return SendClientMessage(playerid, -1, "Use /Demitir [Nome_Sobrenome].");
		new name[24];
		for(new i = 0; i < 24; i++) { if(nickname[i] == '_') { name[i] = ' '; } else { name[i] = nickname[i]; } }
		for(new i = 0; i < MAX_CARGOS; i++) {
			if(!cInfo[pInfo[playerid][pBus]][i][cSQL]) continue;
			if(!strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], name, false)) {
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
		Advert(playerid, "Não há um funcionário com este nome na sua empresa.");
	}
	return 1;
}

CMD:precoproduto(playerid, params[]) { // /PrecoProduto [Nome_do_Produto] [Novo preço]
	for(new b = 0; b < MAX_BUSINESS; b++) {
		if(!bInfo[b][bSQL]) continue;
		if(strcmp(bInfo[b][bOwner], pNick(playerid), false)) continue;
		new produto[25], Float:preco;
		if(sscanf(params, "s[25]f", produto, preco)) return SendClientMessage(playerid, -1, "Use /PrecoProduto [Nome_do_Produto] [Novo preço].");
		for(new i = 0; i < 25; i++) { if(produto[i] == '_') { produto[i] = ' '; } }
		new i = 0;
		while(i < MAX_PRODUTOS) {
			if(!strcmp(prInfo[b][i][prName], produto, true) && !isnull(prInfo[b][i][prName])) break;
			else i++;
		}
		if(i == MAX_PRODUTOS) return SendClientMessage(playerid, -1, "Não existe um produto com este nome.");
		if(preco <= 0.0) return SendClientMessage(playerid, -1, "Preço inválido.");
		prInfo[b][i][prPrice] = preco;
		new str[128];
		format(str, 128, "Você estabeleceu o preço do produto %s para $%.2f.", prInfo[b][i][prName], preco);
		SendClientMessage(playerid, -1, str);
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `produtoinfo` SET `price` = %.2f WHERE `sqlid` = %i", preco, prInfo[b][i][prSQL]);
		mysql_query(conn, query, false);
	}
	return 1;
}

CMD:adicionarveiculo(playerid, params[]) { // /AdicionarVeiculo [Empresa ID]
	if(pInfo[playerid][pAdmin] < Senior) return SendClientMessage(playerid, -1, "Nananinanão (:");
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
	if(pInfo[playerid][pAdmin] < Senior) return SendClientMessage(playerid, -1, "Nananinanão (:");
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
	for(new b = 0; b < MAX_BUSINESS; b++) {
		if(!bInfo[b][bSQL]) continue;
		if(strcmp(bInfo[b][bOwner], pNick(playerid), false)) continue;
		new nomedocargo[25];
		if(sscanf(params, "s[25]", nomedocargo)) return SendClientMessage(playerid, -1, "Use /PagarSalario [Nome_do_Cargo].");
		for(new i = 0; i < 25; i ++) { if(nomedocargo[i] == '_') { nomedocargo[i] = ' '; } }
		new i = 0;
		while(i < MAX_CARGOS) {
			if(!strcmp(cInfo[b][i][cName], nomedocargo, true) && !isnull(cInfo[b][i][cName])) break;
			else i++;
		}
		if(i == MAX_CARGOS) return SendClientMessage(playerid, -1, "Não existe um cargo com este nome.");
		if(isnull(cInfo[b][i][cEmp])) return SendClientMessage(playerid, -1, "Este cargo está desocupado.");

		new nickname[24];
		format(nickname, 24, "%s", cInfo[b][i][cEmp]);
		for(new j = 0; j < 24; j ++) { if(nickname[j] == ' ') { nickname[j] = '_'; } }
		new id = GetPlayerIDByNickname(nickname);
		if(id == -1) return SendClientMessage(playerid, -1, "O funcionário que ocupa este cargo está desconectado.");
		new Float:P[3];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		if(!IsPlayerInRangeOfPoint(id, 5.0, P[0], P[1], P[2])) return SendClientMessage(playerid, -1, "Você deve estar próximo à pessoa que estiver pagando.");
		if(cInfo[b][i][cMon] < 1) return SendClientMessage(playerid, -1, "Este funcionário não tem nada a receber.");
		if(bInfo[b][bReceita] < cInfo[b][i][cMon]) {
			new str[128];
			format(str, 128, "Os fundos da empresa ($%i) não são suficientes para pagar o salário deste funcionário ($%i)", bInfo[b][bReceita], cInfo[b][i][cMon]);
			SendClientMessage(playerid, -1, str);
			return 1;
		}
		new str[128];
		format(str, 128, "O funcionário %s de cargo %s foi pago em $%i pelos seus serviços.", cInfo[b][i][cEmp], cInfo[b][i][cName], cInfo[b][i][cMon]);
		SendClientMessage(playerid, -1, str);
		format(str, 128, "Você foi pago por %s na quantia de $%i pelos serviços prestados.", pNick(playerid), cInfo[b][i][cMon]);
		SendClientMessage(id, -1, str);
		GivePlayerMoney(id, cInfo[b][i][cMon]);
		bInfo[b][bReceita] -= cInfo[b][i][cMon];
		cInfo[b][i][cMon] = 0;
		new query[100];
		mysql_format(conn, query, 100, "UPDATE `businessinfo` SET `receita` = %i WHERE `sqlid` = %i", bInfo[b][bReceita], bInfo[b][bSQL]);
		mysql_query(conn, query, false);
		mysql_format(conn, query, 100, "UPDATE `cargoinfo` SET `mon` = 0 WHERE `sqlid` = %i", cInfo[b][i][cSQL]);
		mysql_query(conn, query, false);
	}
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	new Name[24], p = 0;
	GetPlayerName(playerid, Name, 24);
	for(new j = 0; j < 24; j ++) { if(Name[j] == '_') { Name[j] = ' '; } }
	while(p < MAX_CARGOS) {
		if(!strcmp(Name, cInfo[pInfo[playerid][pBus]][p][cEmp], false) && !isnull(cInfo[pInfo[playerid][pBus]][p][cEmp])) break;
		else p++;
	}
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
	return 1;
}

CMD:empresas(playerid) {
	new str[600];
	for(new i = 0; i < MAX_BUSINESS; i++) {
		if(bInfo[i][bSQL]) { format(str, 600, "%s\n[%02i] %s - Dono: %s", str, i, bInfo[i][bName], bInfo[i][bOwner]); }
	}
	if(isnull(str)) return Info(playerid, "Não existem empresas criadas.");
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "{FFFFFF}Empresas", str, "Fechar", "");
	return 1;
}

CMD:setprof(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id, bid;
	if(sscanf(params, "ii", id, bid)) return AdvertCMD(playerid, "/SetProf [ID do player] [ID da empresa]");
	if(bid < 0 || bid >= MAX_BUSINESS) return Advert(playerid, "Empresa inválida.");
	if(!bInfo[bid][bSQL]) return Advert(playerid, "Empresa inexistente.");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "Você colocou %s como funcionário da empresa ID %02i.", pName(id), bid);
	Info(playerid, str);
	format(str, 144, "O %s colocou você como funcionário da empresa ID %02i.", Staff(playerid), bid);
	Info(id, str);
	pInfo[id][pBus] = bid;
	return 1;
}

CMD:setdono(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new bid, id;
	if(sscanf(params, "ii", bid, id)) return AdvertCMD(playerid, "/SetDono [ID da empresa] [ID do player]");
	if(bid < 0 || bid >= MAX_BUSINESS) return Advert(playerid, "Empresa inválida.");
	if(!bInfo[bid][bSQL]) return Advert(playerid, "Empresa inexistente.");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new str[144];
	format(str, 144, "Você colocou %s como dono da empresa ID %02i.", pName(id), bid);
	Info(playerid, str);
	format(str, 144, "O %s colocou você como dono da empresa ID %02i.", Staff(playerid), bid);
	Info(id, str);
	format(bInfo[bid][bOwner], 24, "%s", pNick(id));
	mysql_format(conn, str, 144, "UPDATE businessinfo SET owner = '%s' WHERE sqlid = %i", pNick(id), bInfo[bid][bSQL]);
	mysql_query(conn, str, false);
	return 1;
}

CMD:setreceita(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new bid, mon;
	if(sscanf(params, "ii", bid, mon)) return AdvertCMD(playerid, "/SetReceita [ID da empresa] [Receita]");
	if(bid < 0 || bid >= MAX_BUSINESS) return Advert(playerid, "Empresa inválida.");
	if(!bInfo[bid][bSQL]) return Advert(playerid, "Empresa inexistente.");
	if(mon < 0) return Advert(playerid, "Valor inválido.");
	new str[144];
	format(str, 144, "Você setou a receita da empresa ID %02i para $%i.", bid, mon);
	Info(playerid, str);
	bInfo[bid][bReceita] = mon;
	mysql_format(conn, str, 144, "UPDATE businessinfo SET receita = %i WHERE sqlid = %i", mon, bInfo[bid][bSQL]);
	mysql_query(conn, str, false);
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
					cache_get_value_name_int(i, "model", prInfo[j][k][prModel]);
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

		new y = 0, x = 0;

		cache_get_value_index_int(i, 0, x);
		printf("Cargo SQL %03i detectado. Row: %02i", x, i);

		for(new j = 0; j < MAX_BUSINESS; j++) {
			if(!bInfo[j][bSQL]) {
				printf("Pulando empresa %02i", j);
				continue;
			}
			for(new k = 0; k < MAX_CARGOS; k++) {
				if(bInfo[j][bCargos][k] == x) {
					printf("Atribuindo cargo SQL %03i a empresa ID %02i [SLOT %02i]", x, j, k);
					cInfo[j][k][cSQL] = x;
					cache_get_value_name(i, "name", str);
					if(strcmp(str, "NULL", true)) { format(cInfo[j][k][cName], 25, "%s", str); }
					cache_get_value_name(i, "emp", str);
					if(strcmp(str, "NULL", true)) { format(cInfo[j][k][cEmp], 25, "%s", str); }
					cache_get_value_name_int(i, "sal", cInfo[j][k][cSal]);
					cache_get_value_name_int(i, "hire", cInfo[j][k][cHire]);
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
					CreateDynamicPickup(1318, 1, eInfo[j][k][eP][0], eInfo[j][k][eP][1], eInfo[j][k][eP][2]);
					y = 1;
					break;
				}
			}
			if(y) { break; }
		}

	}
	return 1;
}

forward OnPlayerClickTextDraw@bus(playerid, Text:clickedid);
public OnPlayerClickTextDraw@bus(playerid, Text:clickedid) {
	if(clickedid == TDManager[28]) { // Salvar
		new query[200];
		BusinessManager(playerid, -1);
		for(new i = 0; i < 10; i++) {
			if(!strcmp(TDMParams[playerid][(i*7) + 0][tdmpValue], "Criar Cargo", false)) {
				if(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]) {
					mysql_format(conn, query, 200, "DELETE FROM cargoinfo WHERE sqlid = %i", cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]);
					mysql_query(conn, query, false);
					mysql_format(conn, query, 200, "UPDATE businessinfo SET `cargo%i` = 0 WHERE sqlid = %i", i, bInfo[GerenciandoEmpresa[playerid][geID]-1][bSQL]);
					mysql_query(conn, query, false);
					format(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName], 20, "");
					format(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cEmp], 20, "");
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL] = 0;
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSal] = 0;
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cHire] = 0;
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cPay] = 0;
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cMon] = 0;
				}
			} else {
				format(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName], 20, "%s", TDMParams[playerid][(i*7) + 0][tdmpValue]);
				if(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]) {
					TextDecoding(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName]);
					mysql_format(conn, query, 200, "UPDATE cargoinfo SET name = '%s' WHERE sqlid = %i", cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName], cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]);
					mysql_query(conn, query, false);
				} else {
					new Cache:result;
					TextDecoding(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName]);
					mysql_format(conn, query, 200, "INSERT INTO cargoinfo (name) VALUES ('%s')", cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName]);
					result = mysql_query(conn, query, true);
					cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL] = cache_insert_id();
					cache_delete(result);
				}
				mysql_format(conn, query, 200, "UPDATE businessinfo SET `cargo%i` = %i WHERE sqlid = %i", i, cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL], bInfo[GerenciandoEmpresa[playerid][geID]-1][bSQL]);
				mysql_query(conn, query, false);
			} if(!strlen(TDMParams[playerid][(i*7) + 2][tdmpValue])) {
				cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSal] = 0;
			} else {
				cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSal] = strval(TDMParams[playerid][(i*7) + 2][tdmpValue][1]);
				mysql_format(conn, query, 200, "UPDATE cargoinfo SET sal = %i WHERE sqlid = %i", cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSal], cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]);
				mysql_query(conn, query, false);
			}
		}
	} else if(clickedid == TDManager[27]) { // Cancelar
		BusinessManager(playerid, -1);
		Info(playerid, "Gerenciamento de empresa cancelado.");
	}
	return 1;
}

forward OnPlayerClickPlayerTextDraw@bus(playerid, PlayerText:playertextid);
public OnPlayerClickPlayerTextDraw@bus(playerid, PlayerText:playertextid) {
	if(!GerenciandoEmpresa[playerid][geID]) return 1;
	GerenciandoEmpresa[playerid][geTDID] = playertextid;
	for(new j = 0; j < 10; j++) {
		if(playertextid == PTDManager[playerid][(j*7) + 0]) { 								// 	- Cargo
			if(!strlen(TDMParams[playerid][(j*7) + 0][tdmpValue])) return 1;
			if(!strcmp(TDMParams[playerid][(j*7) + 0][tdmpValue], "Criar Cargo", false)) {  // > Criar Cargo
				Dialog_Show(playerid, "DialogCCargo", DIALOG_STYLE_INPUT, "Criar Cargo", "Insira abaixo o nome do cargo que deseja criar.", "Criar", "Cancelar");
			} else {																		// > Cargo existente
				Dialog_Show(playerid, "DialogECargo", DIALOG_STYLE_MSGBOX, "Excluir Cargo", "Deseja excluir esse cargo?", "Sim", "Não");
			}
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 1]) { 						//	- Funcionário
			if(!strlen(TDMParams[playerid][(j*7) + 1][tdmpValue])) return 1;
			Dialog_Show(playerid, "DialogDemitir", DIALOG_STYLE_MSGBOX, "Demitir Funcionário", "Deseja demitir esse funcionário?", "Sim", "Não");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 2]) { 						//	- Salário
			if(!strlen(TDMParams[playerid][(j*7) + 2][tdmpValue])) return 1;
			Dialog_Show(playerid, "DialogMSalario", DIALOG_STYLE_INPUT, "Mudar Salário", "Insira abaixo o salário desse cargo.", "Definir", "Cancelar");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 3]) { 						//	- Permissão 1
			if(!strlen(TDMParams[playerid][(j*7) + 3][tdmpValue])) return 1;
			Dialog_Show(playerid, "DialogPerm1", DIALOG_STYLE_LIST, "Permissão 1", "Em desenvolvimento", "Permitir", "Cancelar");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 4]) { 						//	- Permissão 2
			if(!strlen(TDMParams[playerid][(j*7) + 4][tdmpValue])) return 1;
			Dialog_Show(playerid, "DialogPerm2", DIALOG_STYLE_LIST, "Permissão 2", "Em desenvolvimento", "Permitir", "Cancelar");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 5]) { 						//	- Permissão 3
			if(!strlen(TDMParams[playerid][(j*7) + 5][tdmpValue])) return 1;
			Dialog_Show(playerid, "DialogPerm3", DIALOG_STYLE_LIST, "Permissão 3", "Em desenvolvimento", "Permitir", "Cancelar");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		} else if(playertextid == PTDManager[playerid][(j*7) + 6]) { 						//	- Ficha Pessoal
			if(!strlen(TDMParams[playerid][(j*7) + 6][tdmpValue])) return 1;
			new str[200];
			format(str, 200, "Total a receber: "VERDEMONEY"$%i"BRANCO".\nConta bancária, documentos etc", cInfo[GerenciandoEmpresa[playerid][geID]-1][j][cMon]);
			Dialog_Show(playerid, "DialogFPessoal", DIALOG_STYLE_MSGBOX, "Ficha Pessoal", str, "Fechar", "");
			pInfo[playerid][pTDSelect] = 0;
			CancelSelectTextDraw(playerid);
			break;
		}
	}
	return 1;
}

Dialog:DialogContratar(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_DialogContratar")) {
		Advert(playerid, "Informe essa mensagem de erro para a administração. [COD 010]");
	} else if(!response) {
		Act(playerid, "recusa a assinar, devolvendo o contrato e a caneta de volta.");
	} else {
		Act(playerid, "assina o contrato de trabalho e devolve a caneta de volta.");
		pInfo[playerid][pBus] = pInfo[playerid][pDialogParam][1];
		format(cInfo[pInfo[playerid][pBus]][pInfo[playerid][pDialogParam][2]][cEmp], 24, "%s", pName(playerid));
	}
	ResetDialogParams(playerid);
	return 1;
}

Dialog:DialogFPessoal(playerid, response, listitem, inputtext[]) {
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogPerm1(playerid, response, listitem, inputtext[]) {
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogPerm2(playerid, response, listitem, inputtext[]) {
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogPerm3(playerid, response, listitem, inputtext[]) {
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogMSalario(playerid, response, listitem, inputtext[]) {
	if(response) {
		new value = strval(inputtext);
		if(value < 1 || value > 100000) {
			Advert(playerid, "Valor de salário inválido.");
		} else {
			for(new j = 0; j < 10; j++) {
				if(GerenciandoEmpresa[playerid][geTDID] == PTDManager[playerid][(7*j) + 2]) {
					format(TDMParams[playerid][(7*j) + 2][tdmpValue], 20, "$%i", value);
					TextEncoding(TDMParams[playerid][(7*j) + 2][tdmpValue]);
					PlayerTextDrawSetString(playerid, PTDManager[playerid][(7*j) + 2], TDMParams[playerid][(7*j) + 2][tdmpValue]);
					break;
				}
			}
		}
	}
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogCCargo(playerid, response, listitem, inputtext[]) {
	if(response) {
		if(strlen(inputtext) < 1 || strlen(inputtext) > 19) {
			Advert(playerid, "Nome para cargo inválido.");
		} else {
			new i = 0;
			for(; i < MAX_CARGOS; i++) {
				if(!cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cSQL]) continue;
				if(strcmp(cInfo[GerenciandoEmpresa[playerid][geID]-1][i][cName], inputtext, true)) continue;
				else break;
			}
			if(i < MAX_CARGOS) {
				Advert(playerid, "Já existe um cargo com esse nome.");
			} else {
				for(new j = 0; j < 10; j++) {
					if(GerenciandoEmpresa[playerid][geTDID] == PTDManager[playerid][(7*j) + 0]) {
						format(TDMParams[playerid][(7*j) + 0][tdmpValue], 20, "%s", inputtext);
						format(TDMParams[playerid][(7*j) + 2][tdmpValue], 10, "$0");
						TextEncoding(TDMParams[playerid][(7*j) + 0][tdmpValue]);
						TextEncoding(TDMParams[playerid][(7*j) + 2][tdmpValue]);
						PlayerTextDrawSetString(playerid, PTDManager[playerid][(7*j) + 0], TDMParams[playerid][(7*j) + 0][tdmpValue]);
						PlayerTextDrawSetString(playerid, PTDManager[playerid][(7*j) + 2], TDMParams[playerid][(7*j) + 2][tdmpValue]);
						break;
					}
				}
			}
		}
	}
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogECargo(playerid, response, listitem, inputtext[]) {
	if(response) {
		for(new j = 0; j < 10; j++) {
			if(GerenciandoEmpresa[playerid][geTDID] == PTDManager[playerid][(7*j) + 0]) {
				if(strlen(TDMParams[playerid][(7*j) + 1][tdmpValue])) {
					Advert(playerid, "Você não pode excluir um cargo que esteja sendo ocupado por um funcionário.");
				} else {
					format(TDMParams[playerid][(7*j) + 0][tdmpValue], 20, "Criar Cargo");
					format(TDMParams[playerid][(7*j) + 2][tdmpValue], 2, "");
					PlayerTextDrawSetString(playerid, PTDManager[playerid][(7*j) + 0], TDMParams[playerid][(7*j) + 0][tdmpValue]);
					PlayerTextDrawSetString(playerid, PTDManager[playerid][(7*j) + 2], TDMParams[playerid][(7*j) + 2][tdmpValue]);
				}
				break;
			}
		}
	}
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

Dialog:DialogDemitir(playerid, response, listitem, inputtext[]) {
	if(response) {
		Advert(playerid, "Você não pode demitir alguém por meio dessa interface. Use "AMARELO"/Demitir"BRANCO".");
	}
	SelectTextDraw(playerid, AmareloPalido);
	pInfo[playerid][pTDSelect] = 1;
	return 1;
}

stock BusinessManager(playerid, businessid) {
	if(businessid == -1) {
		for(new i = 0; i < 70; i++) {
			PlayerTextDrawHide(playerid, PTDManager[playerid][i]);
		}
		for(new i = 0; i < sizeof(TDManager); i++) {
			TextDrawHideForPlayer(playerid, TDManager[i]);
		}
		pInfo[playerid][pTDSelect] = 0;
		CancelSelectTextDraw(playerid);
		return 1;
	}
	LimparChat(playerid);
	pInfo[playerid][pTDSelect] = 1;
	SelectTextDraw(playerid, AmareloPalido);
	GerenciandoEmpresa[playerid][geID] = businessid+1;
	for(new i = 0; i < sizeof(TDManager); i++) { TextDrawShowForPlayer(playerid, TDManager[i]); } // Estrutura
	for(new i = 0; i < 7; i++) { // Coluna
		for(new j = 0; j < 10; j++) { // Linha
			if(i == 0) { // Cargo
				if(!cInfo[businessid][j][cSQL]) {
					format(TDMParams[playerid][(j*7) + 0][tdmpValue], 24, "Criar Cargo");
				} else {
					format(TDMParams[playerid][(j*7) + 0][tdmpValue], 24, "%s", cInfo[businessid][j][cName]);
					TextEncoding(TDMParams[playerid][(j*7) + 0][tdmpValue]);
				}
			} else if(i == 1) { // Funcionário
				if(!cInfo[businessid][j][cSQL]) {
					format(TDMParams[playerid][(j*7) + 1][tdmpValue], 24, "");
				} else {
					format(TDMParams[playerid][(j*7) + 1][tdmpValue], 24, "%s", cInfo[businessid][j][cEmp]);
					TextEncoding(TDMParams[playerid][(j*7) + 1][tdmpValue]);
				}
			} else if(i == 2) { // Salário
				if(!cInfo[businessid][j][cSQL]) {
					format(TDMParams[playerid][(j*7) + 2][tdmpValue], 24, "");
				} else {
					format(TDMParams[playerid][(j*7) + 2][tdmpValue], 24, "$%i", cInfo[businessid][j][cSal]);
				}
			} else if(i == 3) { // Permissão 1
				format(TDMParams[playerid][(j*7) + 3][tdmpValue], 24, "Desenvolvendo");
			} else if(i == 4) { // Permissão 2
				format(TDMParams[playerid][(j*7) + 4][tdmpValue], 24, "Desenvolvendo");
			} else if(i == 5) { // Permissão 3
				format(TDMParams[playerid][(j*7) + 5][tdmpValue], 24, "Desenvolvendo");
			} else if(i == 6) { // Ficha Pessoal
				if(isnull(cInfo[businessid][j][cEmp])) {
					format(TDMParams[playerid][(j*7) + 6][tdmpValue][0], 24, "");
				} else {
					format(TDMParams[playerid][(j*7) + 6][tdmpValue][0], 24, "Ficha Pessoal");
				}
			}
		}
	}
	for(new i = 0; i < 70; i++) {
		PlayerTextDrawSetString(playerid, PTDManager[playerid][i], TDMParams[playerid][i][tdmpValue]);
		PlayerTextDrawShow(playerid, PTDManager[playerid][i]);
	}
	return 1;
}