Dialog:MenuImob(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(listitem == 0) {
		Dialog_Show(playerid, "BuyHouseCity", DIALOG_STYLE_LIST, "Localização da propriedade", "Blueberry\nPalomino Creek\nMontgomery\nDillimore\nLos Santos", "Avançar", "Cancelar");
	} else if(listitem == 1) {
		new str[144];
		format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_IMOB][bOwner]);
		Info(playerid, str);
	} else if(listitem == 2) {
		Info(playerid, "Você precisar contatar com o gerente da empresa e verificar se estamos contratando.");
	}
	return 1;
}

Dialog:BuyHouseCity(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	pInfo[playerid][pDialogParam][0] = funcidx("dialog_BuyHouseNumber");
	pInfo[playerid][pDialogParam][1] = listitem+1;
	new str[144];
	format(str, 144, BRANCO"Cidade selecionada: "AZULADOCLARO"%s"BRANCO".\nAgora me diga qual a numeração da casa.", GetCityName(listitem+1));
	Dialog_Show(playerid, "BuyHouseNumber", DIALOG_STYLE_INPUT, "Numeração", str, "Prosseguir", "Voltar");
	return 1;
}

Dialog:BuyHouseNumber(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam] != funcidx("dialog_BuyHouseNumber")) return ResetDialogParams(playerid);
	if(!response) {
		ResetDialogParams(playerid);
		Dialog_Show(playerid, "BuyHouseCity", DIALOG_STYLE_LIST, "Localização da propriedade", "Blueberry\nPalomino Creek\nMontgomery\nDillimore\nLos Santos", "Avançar", "Cancelar");
	} else {
		new cid = pInfo[playerid][pDialogParam][1];
		for(new i = 0; i < MAX_HOUSES; i++) {
			if(!hInfo[i][hSQL]) continue;
			if(hInfo[i][hCity] != cid) continue;
			if(!strcmp(hInfo[i][hNumber], inputtext, true)) {
				if(!isnull(hInfo[i][hOwner])) {
					Advert(playerid, "Essa casa não está a venda.");
				} else {
					new str[200];
					format(str, 200, "A casa de número %s da cidade de %s atualmente está custando\n\t\t"VERDEMONEY"$%i"BRANCO"\n\nDeseja comprá-la?", hInfo[i][hNumber], GetCityName(cid), hInfo[i][hPrice]);
					Dialog_Show(playerid, "BuyHouseConfirm", DIALOG_STYLE_MSGBOX, "Compra de propriedade", str, "Comprar", "Cancelar");
					pInfo[playerid][pDialogParam][0] = funcidx("dialog_BuyHouseConfirm");
					pInfo[playerid][pDialogParam][1] = i;
				}
				return 1;
			}
		}
		Advert(playerid, "Essa casa não existe.");
	}
	return 1;
}

Dialog:BuyHouseConfirm(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_BuyHouseConfirm") || !response) return ResetDialogParams(playerid);
	new cid = pInfo[playerid][pDialogParam][1];
	if(hInfo[cid][hPrice] > 0) {
		if(GetPlayerMoney(playerid) < hInfo[cid][hPrice]) {
			Advert(playerid, "Você não tem dinheiro suficiente para pagar essa casa.");
		} else {
			Success(playerid, "Casa comprada! Chaves recebidas e dinheiro retirado rsrs ;)");
			GivePlayerMoney(playerid, -hInfo[cid][hPrice]);
			format(hInfo[cid][hOwner], 24, "%s", pName(playerid));
			new query[150];
			mysql_format(conn, query, 150, "UPDATE houseinfo SET owner = '%s' WHERE sqlid = %i", pName(playerid), hInfo[cid][hSQL]);
			mysql_query(conn, query, false);
		}
	}
	return ResetDialogParams(playerid);
}