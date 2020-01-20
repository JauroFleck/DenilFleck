// Número da conta bancária = sqlid + 50.000

enum CCB_INFO {
	ccbID,
	ccbName[40]
};

enum ACB_INFO {
	acbID,
	acbIDt,
	acbPass[20],
	acbOwner[40],
	acbSaldo,
	acbSaldot
};

new ParametrosCCB[MAX_PLAYERS][CCB_INFO];
new ParametroACB[MAX_PLAYERS][ACB_INFO];

CMD:criarcontabancaria(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(bInfo[pInfo[playerid][pBus]][bType] != BUSINESS_BANK) return Advert(playerid, "Sua empresa não tem permissão para uso desse comando.");
	if(!pInfo[playerid][pDuty]) return Advert(playerid, "Para usar esse comando, antes você deve estar em "AMARELO"/Servico"BRANCO".");
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/CriarContaBancaria [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	new Float:P[3];
	GetPlayerPos(id, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 3.5, P[0], P[1], P[2]) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(id)) return Advert(playerid, "A pessoa para quem vai criar conta deve estar próximo a você.");
	Dialog_Show(playerid, "CBAccount", DIALOG_STYLE_INPUT, "Criar conta bancária", "Insira abaixo em nome de quem ou do que está criando essa conta bancária.", "Criar", "Cancelar");
	Act(playerid, "retira um novo documento de dentro de uma pasta na gaveta de sua mesa.");
	ParametrosCCB[playerid][ccbID] = id+1;
	return 1;
}

CMD:atm(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 0.8, 2309.9099, -16.6940, 26.7496) || IsPlayerInRangeOfPoint(playerid, 0.8, 2308.3982, -16.6940, 26.7496)) {
		Dialog_Show(playerid, "ATMNR", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o número da conta bancária", "Prosseguir", "Cancelar");
		Act(playerid, "aperta alguns botões da ATM.");
	} else {
		Advert(playerid, "Você deve estar próximo a uma ATM.");
	}
	return 1;
}

CMD:mostrarcomprovante(playerid, params[]) {
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/MostrarComprovante [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(id == playerid) return Advert(playerid, "Para ver seu comprovante use "AMARELO"/VerComprovante"BRANCO".");
	if(!pInfo[playerid][pComprovante]) return Advert(playerid, "Você não possui comprovante algum consigo.");
	new query[100], Cache:result, rows;
	mysql_format(conn, query, 100, "SELECT * FROM transferencias WHERE sqlid = %i", pInfo[playerid][pComprovante]);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	if(!rows) {
		Advert(playerid, "Esse comprovante foi expirado.");
	} else {
		new str[300], sender, receiver, amount, momento[25];
		cache_get_value_name_int(0, "sender", sender);
		cache_get_value_name_int(0, "receiver", receiver);
		cache_get_value_name_int(0, "amount", amount);
		cache_get_value_name(0, "time", momento);
		format(str, 300, BRANCO"- Montante de envio: "VERDEMONEY"$%i"BRANCO".\n- Conta que enviou: %i.\n- Conta que recebeu: %i.\n- Momento do envio: %s", amount, sender, receiver, momento);
		Dialog_Show(id, "Dialog_None", DIALOG_STYLE_MSGBOX, "Comprovante", str, "Devolver", "");
	}
	cache_delete(result);
	return 1;
}

CMD:vercomprovante(playerid) {
	if(!pInfo[playerid][pComprovante]) return Advert(playerid, "Você não possui comprovante algum consigo.");
	new query[100], Cache:result, rows;
	mysql_format(conn, query, 100, "SELECT * FROM transferencias WHERE sqlid = %i", pInfo[playerid][pComprovante]);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	if(!rows) {
		Advert(playerid, "Esse comprovante foi expirado.");
	} else {
		new str[300], sender, receiver, amount, momento[25];
		cache_get_value_name_int(0, "sender", sender);
		cache_get_value_name_int(0, "receiver", receiver);
		cache_get_value_name_int(0, "amount", amount);
		cache_get_value_name(0, "time", momento);
		format(str, 300, BRANCO"- Montante de envio: "VERDEMONEY"$%i"BRANCO".\n- Conta que enviou: %i.\n- Conta que recebeu: %i.\n- Momento do envio: %s", amount, sender, receiver, momento);
		Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "Comprovante", str, "Devolver", "");
	}
	cache_delete(result);
	return 1;
}

Dialog:ATMNR(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new accountid = strval(inputtext);
	if(accountid < 50001) return Advert(playerid, "Número de conta inválido.");
	if(accountid > 60000) return Advert(playerid, "Informe a administração sobre essa mensagem de erro. [COD 008]");
	new query[150], Cache:result, rows;
	mysql_format(conn, query, 150, "SELECT pass, saldo, owner FROM contasbanco WHERE sqlid = %i", accountid - 50000);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	if(!rows) {
		Advert(playerid, "Número de conta bancária inválido.");
	} else {
		new str[144];
		format(str, 144, "Insira a senha da conta bancária (%i) abaixo.", accountid);
		Dialog_Show(playerid, "ATMPass", DIALOG_STYLE_PASSWORD, "ATM", str, "Prosseguir", "Cancelar");
		ParametroACB[playerid][acbID] = accountid;
		cache_get_value_name(0, "pass", str);
		format(ParametroACB[playerid][acbPass], 20, "%s", str);
		cache_get_value_name_int(0, "saldo", ParametroACB[playerid][acbSaldo]);
		cache_get_value_name(0, "owner", str);
		format(ParametroACB[playerid][acbOwner], 40, "%s", str);
	}
	cache_delete(result);
	return 1;
}

Dialog:ATMPass(playerid, response, listitem, inputtext[]) {
	if(!response) {
		ClearParametersACB(playerid);
		return 1;
	} else if(!strlen(inputtext) || strlen(inputtext) > 19) {
		ClearParametersACB(playerid);
		Advert(playerid, "Senha inválida.");
		return 1;
	} else if(strcmp(inputtext, ParametroACB[playerid][acbPass], false)) {
		ClearParametersACB(playerid);
		Advert(playerid, "Senha inválida.");
	} else {
		SendClientMessage(playerid, Verde, "[ATM]"BRANCO" Logado com sucesso.");
		Dialog_Show(playerid, "ATMMenu", DIALOG_STYLE_LIST, "ATM", "Visualizar saldo\nRealizar saque\nRealizar depósito\nTransferência entre contas", "Selecionar", "Cancelar");
	}
	return 1;
}

Dialog:ATMMenu(playerid, response, listitem, inputtext[]) {
	if(!response) {
		ClearParametersACB(playerid);
	} else if(listitem == 0) { // Visualizar saldo
		new str[180];
		format(str, 180, "Saldo da conta %i [%s] atualmente consta em "VERDEMONEY"$%i"BRANCO".", ParametroACB[playerid][acbID], ParametroACB[playerid][acbOwner], ParametroACB[playerid][acbSaldo]);
		Dialog_Show(playerid, "ATMSaldo", DIALOG_STYLE_MSGBOX, "ATM", str, "Fechar", "Voltar");
	} else if(listitem == 1) { // Realizar saque
		Dialog_Show(playerid, "ATMSaque", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o valor do saque que deseja realizar.", "Sacar", "Voltar");
	} else if(listitem == 2) { // Realizar depósito
		Dialog_Show(playerid, "ATMDeposito", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o valor do depósito que deseja realizar.", "Depositar", "Voltar");
	} else if(listitem == 3) { // Transferência entre contas
		Dialog_Show(playerid, "ATMTransferir", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o número da conta bancária que deseja transferir.", "Prosseguir", "Voltar");
	}
	return 1;
}

Dialog:ATMTransferir2(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Dialog_Show(playerid, "ATMTransferir", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o número da conta bancária que deseja transferir.", "Prosseguir", "Voltar");
	} else {
		new valor = strval(inputtext);
		if(valor < 1) {
			ClearParametersACB(playerid);
			Advert(playerid, "Valor inválido.");
			return 1;
		} else if(valor > ParametroACB[playerid][acbSaldo]) {
			new str[144];
			SendClientMessage(playerid, Vermelho, "[ATM]"BRANCO" Quantia maior que o saldo atual.");
			format(str, 144, "Insira abaixo a quantia que deseja transferir para a conta bancária %i.", ParametroACB[playerid][acbIDt]);
			Dialog_Show(playerid, "ATMTransferir2", DIALOG_STYLE_INPUT, "ATM", str, "Transferir", "Voltar");
			return 1;
		} else {
			new query[150], str[200], Cache:result, sqlid;
			mysql_format(conn, query, 150, "SELECT saldo FROM contasbanco WHERE sqlid = %i", ParametroACB[playerid][acbID]-50000);
			result = mysql_query(conn, query, true);
			cache_get_value_name_int(0, "saldo", ParametroACB[playerid][acbSaldo]);
			cache_delete(result);
			mysql_format(conn, query, 150, "SELECT saldo FROM contasbanco WHERE sqlid = %i", ParametroACB[playerid][acbIDt]-50000);
			result = mysql_query(conn, query, true);
			cache_get_value_name_int(0, "saldo", ParametroACB[playerid][acbSaldot]);
			cache_delete(result);
			ParametroACB[playerid][acbSaldot] += valor;
			ParametroACB[playerid][acbSaldo] -= valor;
			mysql_format(conn, query, 150, "UPDATE contasbanco SET saldo = %i WHERE sqlid = %i", ParametroACB[playerid][acbSaldo], ParametroACB[playerid][acbID]-50000);
			mysql_query(conn, query, false);
			mysql_format(conn, query, 150, "UPDATE contasbanco SET saldo = %i WHERE sqlid = %i", ParametroACB[playerid][acbSaldot], ParametroACB[playerid][acbIDt]-50000);
			mysql_query(conn, query, false);
			mysql_format(conn, query, 150, "INSERT INTO transferencias (`sender`, `receiver`, `amount`, `time`) VALUES (%i, %i, %i, '%04i-%02i-%02i %02i:%02i:00')", 
				ParametroACB[playerid][acbID], ParametroACB[playerid][acbIDt], valor, sTime[sAno], sTime[sMes], sTime[sDia], sTime[sHora], sTime[sMin]);
			result = mysql_query(conn, query, true);
			sqlid = cache_insert_id();
			cache_delete(result);
			format(str, 200, "Transferência de "VERDEMONEY"$%i"BRANCO" realizada com sucesso a para conta bancária "AMARELO"%i"BRANCO".\n\n(( Tire print [F8] para tornar isso um comprovante de pagamento ))", valor, ParametroACB[playerid][acbIDt]);
			Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "ATM", str, "Fechar", "");
			ClearParametersACB(playerid);
			Act(playerid, "retira da ATM um comprovante de pagamento.");
			Info(playerid, "Para apresentar o comprovante de pagamento para alguém, use "AMARELO"/MostrarComprovante"BRANCO".");
			pInfo[playerid][pComprovante] = sqlid;
		}
	}
	return 1;
}

Dialog:ATMTransferir(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Dialog_Show(playerid, "ATMMenu", DIALOG_STYLE_LIST, "ATM", "Visualizar saldo\nRealizar saque\nRealizar depósito\nTransferência entre contas", "Selecionar", "Cancelar");
	} else {
		new accountid = strval(inputtext);
		if(accountid < 50001) return Advert(playerid, "Número de conta inválido.");
		if(accountid > 60000) return Advert(playerid, "Informe a administração sobre essa mensagem de erro. [COD 009]");
		new query[150], Cache:result, rows;
		mysql_format(conn, query, 150, "SELECT saldo FROM contasbanco WHERE sqlid = %i", accountid - 50000);
		result = mysql_query(conn, query, true);
		cache_get_row_count(rows);
		if(!rows) {
			Advert(playerid, "Número de conta bancária inválido.");
			Dialog_Show(playerid, "ATMTransferir", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o número da conta bancária que deseja transferir.", "Prosseguir", "Voltar");
		} else {
			new str[144];
			format(str, 144, "Insira abaixo a quantia que deseja transferir para a conta bancária %i.", accountid);
			Dialog_Show(playerid, "ATMTransferir2", DIALOG_STYLE_INPUT, "ATM", str, "Transferir", "Voltar");
			ParametroACB[playerid][acbIDt] = accountid;
			cache_get_value_name_int(0, "saldo", ParametroACB[playerid][acbSaldot]);
		}
		cache_delete(result);
	}
	return 1;
}

Dialog:ATMDeposito(playerid, response, listitem, inputtext[]) {
	if(response) {
		new valor = strval(inputtext);
		if(valor < 1) {
			ClearParametersACB(playerid);
			Advert(playerid, "Valor inválido.");
			return 1;
		} else if(valor > GetPlayerMoney(playerid)) {
			SendClientMessage(playerid, Vermelho, "[ATM]"BRANCO" Quantia maior que você possui na carteira.");
			Dialog_Show(playerid, "ATMDeposito", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o valor do depósito que deseja realizar.", "Depositar", "Voltar");
			return 1;
		} else {
			GivePlayerMoney(playerid, -valor);
			ParametroACB[playerid][acbSaldo] += valor;
			new query[150], str[20];
			mysql_format(conn, query, 150, "UPDATE contasbanco SET saldo = %i WHERE sqlid = %i", ParametroACB[playerid][acbSaldo], ParametroACB[playerid][acbID]-50000);
			mysql_query(conn, query, false);
			Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "ATM", "Depósito realizado com sucesso.", "Fechar", "");
			format(str, 20, "~r~-$%i", valor);
			GameTextForPlayer(playerid, str, 1000, 1);
			ClearParametersACB(playerid);
		}
	} else {
		Dialog_Show(playerid, "ATMMenu", DIALOG_STYLE_LIST, "ATM", "Visualizar saldo\nRealizar saque\nRealizar depósito\nTransferência entre contas", "Selecionar", "Cancelar");
	}
	return 1;
}

Dialog:ATMSaque(playerid, response, listitem, inputtext[]) {
	if(response) {
		new valor = strval(inputtext);
		if(valor < 1) {
			ClearParametersACB(playerid);
			Advert(playerid, "Valor inválido.");
			return 1;
		} else if(valor > ParametroACB[playerid][acbSaldo]) {
			SendClientMessage(playerid, Vermelho, "[ATM]"BRANCO" Quantia maior que o saldo atual.");
			Dialog_Show(playerid, "ATMSaque", DIALOG_STYLE_INPUT, "ATM", "Insira abaixo o valor do saque que deseja realizar.", "Sacar", "Voltar");
			return 1;
		} else {
			GivePlayerMoney(playerid, valor);
			ParametroACB[playerid][acbSaldo] -= valor;
			new query[150], str[20];
			mysql_format(conn, query, 150, "UPDATE contasbanco SET saldo = %i WHERE sqlid = %i", ParametroACB[playerid][acbSaldo], ParametroACB[playerid][acbID]-50000);
			mysql_query(conn, query, false);
			Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "ATM", "Saque realizado com sucesso.", "Fechar", "");
			format(str, 20, "~g~+$%i", valor);
			GameTextForPlayer(playerid, str, 1000, 1);
			ClearParametersACB(playerid);
		}
	} else {
		Dialog_Show(playerid, "ATMMenu", DIALOG_STYLE_LIST, "ATM", "Visualizar saldo\nRealizar saque\nRealizar depósito\nTransferência entre contas", "Selecionar", "Cancelar");
	}
	return 1;
}

Dialog:ATMSaldo(playerid, response, listitem, inputtext[]) {
	if(response) {
		ClearParametersACB(playerid);
	} else {
		Dialog_Show(playerid, "ATMMenu", DIALOG_STYLE_LIST, "ATM", "Visualizar saldo\nRealizar saque\nRealizar depósito\nTransferência entre contas", "Selecionar", "Cancelar");
	}
	return 1;
}

Dialog:CBAccount(playerid, response, listitem, inputtext[]) {
	if(!response) return Act(playerid, "guarda o documento na pasta novamente e a coloca dentro da gaveta de sua mesa.");
	if(!strlen(inputtext) || strlen(inputtext) > 39) return Advert(playerid, "Nome inválido.");
	if(!IsPlayerConnected(ParametrosCCB[playerid][ccbID]-1)) return Advert(playerid, "O player para quem você estava criando a conta foi desconectado.");
	new str[300];
	format(str, 300, "Está sendo criada uma nova conta bancária para você, em nome de '%s'.\nDeseja continuar? Se sim, insira abaixo uma senha de acesso para essa conta bancária.", inputtext);
	Dialog_Show(ParametrosCCB[playerid][ccbID]-1, "PassCBAccount", DIALOG_STYLE_INPUT, "Criando conta bancária", str, "Definir", "Cancelar");
	format(str, 144, "escreve em itálico com sua caneta preta no documento: '%s'.", inputtext);
	Act(playerid, str);
	format(ParametrosCCB[playerid][ccbName], 40, "%s", inputtext);
	return 1;
}

Dialog:PassCBAccount(playerid, response, listitem, inputtext[]) {
	new i = 0;
	for(; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(ParametrosCCB[i][ccbID] == playerid+1) { break; }
	}
	if(i == MAX_PLAYERS) {
		Act(playerid, "se recusa a assinar o documento proposto.");
		ParametrosCCB[i][ccbID] = 0;
		Advert(playerid, "Seu gerenciador de conta bancária foi desconectado.");
		return 1;
	}
	if(!response) {
		Act(playerid, "se recusa a assinar o documento proposto.");
		ParametrosCCB[i][ccbID] = 0;
	} else {
		if(!strlen(inputtext) || strlen(inputtext) > 19) {
			Act(playerid, "se recusa a assinar o documento proposto.");
			ParametrosCCB[i][ccbID] = 0;
			Advert(playerid, "Senha inválida.");
			return 1;
		}
		new query[100], Cache:result, accountid, str[144];
		mysql_format(conn, query, 100, "INSERT INTO contasbanco (owner, pass) VALUES ('%s', '%s')", ParametrosCCB[i][ccbName], inputtext);
		result = mysql_query(conn, query, true);
		accountid = cache_insert_id();
		cache_delete(result);
		Act(playerid, "assina o documento proposto e o entrega de volta.");
		Success(playerid, "Sua conta foi criada com sucesso. As próximas informações serão EXTREMAMENTE IMPORTANTES! Não as esqueça.");
		format(str, 144, "Número da conta: "AMARELO"%i", 50000 + accountid);
		Info(playerid, str);
		format(str, 144, "Senha da conta: "AMARELO"%s", inputtext);
		Info(playerid, str);
		format(str, 144, "Dono(a) da conta: "AMARELO"%s", ParametrosCCB[i][ccbName]);
		Info(playerid, str);
	}
	return 1;
}

stock ClearParametersACB(playerid) {
	format(ParametroACB[playerid][acbPass], 20, "");
	format(ParametroACB[playerid][acbOwner], 20, "");
	ParametroACB[playerid][acbID] = 0;
	ParametroACB[playerid][acbIDt] = 0;
	ParametroACB[playerid][acbSaldo] = 0;
	ParametroACB[playerid][acbSaldot] = 0;
	return 1;
}