enum TIME_INFO {
	sAno,
	sMes,
	sDia,
	sHora,
	sMin,
	sSem,
	sCli
};

new sTime[TIME_INFO];

forward OnGameModeInit@time();
public OnGameModeInit@time() {
	new Cache:result;
	result = mysql_query(conn, "SELECT * FROM servertime");
	cache_get_value_name_int(0, "ano", sTime[sAno]);
	cache_get_value_name_int(0, "mes", sTime[sMes]);
	cache_get_value_name_int(0, "dia", sTime[sDia]);
	cache_get_value_name_int(0, "hora", sTime[sHora]);
	cache_get_value_name_int(0, "min", sTime[sMin]);
	cache_get_value_name_int(0, "sem", sTime[sSem]);
	cache_delete(result);
	SetTimer("ServerTime", 15000, true);
	return 1;
}

forward OnGameModeExit@time();
public OnGameModeExit@time() {
	new query[200];
	mysql_format(conn, query, 200, "UPDATE servertime SET ano = %i, mes = %i, dia = %i, hora = %i, min = %i, sem = %i", sTime[sAno], sTime[sMes], sTime[sDia], sTime[sHora], sTime[sMin], sTime[sSem]);
	mysql_query(conn, query, false);
	return 1;
}

forward ServerTime();
public ServerTime() {

	sTime[sMin]++;
	if(sTime[sMin] == 60) {
		sTime[sMin] = 0;
		sTime[sHora]++;
		if(sTime[sHora] == 24) {
			sTime[sHora] = 0;
			sTime[sDia]++;
			sTime[sSem]++;
			if(sTime[sSem] == 8) { sTime[sSem] = 1; }
			if(sTime[sDia] > 28) {
				if(sTime[sMes] == 2) {
					sTime[sMes]++;
					sTime[sDia] = 1;
				} else if(sTime[sDia] == 31) {
					if(sTime[sMes] == 4 || sTime[sMes] == 6 || sTime[sMes] == 9 || sTime[sMes] == 11) {
						sTime[sMes]++;
						sTime[sDia] = 1;
					}
				} else if(sTime[sDia] == 32) {
					if(sTime[sMes] == 1 || sTime[sMes] == 3 || sTime[sMes] == 5 || sTime[sMes] == 7 || sTime[sMes] == 8 || sTime[sMes] == 10 || sTime[sMes] == 12) {
						sTime[sMes]++;
						sTime[sDia] = 1;
						if(sTime[sMes] == 13) {
							sTime[sMes] = 1;
							sTime[sAno]++;
						}
					}
				}
			}
		}
	}

	SetWorldTime(sTime[sHora]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		SetPlayerTime(i, sTime[sHora], sTime[sMin]);
	}
	return 1;
}

CMD:hora(playerid) {
	new str[144];
	format(str, 144, "%02i:%02i %i/%i/%i - %s", sTime[sHora], sTime[sMin], sTime[sDia], sTime[sMes], sTime[sAno], SemanaIntToStr(sTime[sSem]));
	SendClientMessage(playerid, -1, str);
	return 1;
}

stock SemanaIntToStr(n) {
	new str[20];
	if(n == 1) { str = "domingo"; }
	else if(n == 2) { str = "segunda-feira"; }
	else if(n == 3) { str = "terça-feira"; }
	else if(n == 4) { str = "quarta-feira"; }
	else if(n == 5) { str = "quinta-feira"; }
	else if(n == 6) { str = "sexta-feira"; }
	else if(n == 7) { str = "sábado"; }
	return str;
}