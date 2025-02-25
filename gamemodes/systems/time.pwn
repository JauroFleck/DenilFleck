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

	// new randomhud = random(5);
	// SpaceToUnderline(HUDMsg[randomhud]);
	// TextEncoding(HUDMsg[randomhud]);
	// TextDrawSetString(TDBarra[3], HUDMsg[randomhud]);
	SetWorldTime(sTime[sHora]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		SetPlayerTime(i, sTime[sHora], sTime[sMin]);
		if(pInfo[i][pLogged] != 1) continue;
		if(pInfo[i][ptPrisao] > 0) {
			pInfo[i][ptPrisao]--;
			if(!pInfo[i][ptPrisao]) {
				SetPlayerInterior(i, 0);
				SetPlayerVirtualWorld(i, 0);
				Streamer_UpdateEx(i, 627.0251,-571.7915,17.9145, -1, -1, -1, 1500);
				SetPlayerFacingAngle(i, 270.0);
				Info(i, "Voc� cumpriu seu tempo de pris�o.");
			}
		}
		static quarterxp[MAX_PLAYERS];
		quarterxp[i]++;
		if(quarterxp[i] == 3) {
			pInfo[i][pXP]++;

			// if(pInfo[i][pHUD]) {
			// 	new str[20], Float:prop = floatdiv(pInfo[i][pXP], GetXPNextLevel(pInfo[i][pLevel]));
			// 	PlayerTextDrawTextSize(i, TDXPBox[i], 550.5+prop*49.5, 0.0);
			// 	PlayerTextDrawHide(i, TDXPBox[i]);
			// 	PlayerTextDrawShow(i, TDXPBox[i]);
			// 	format(str, 20, "%i_/_%i", pInfo[i][pXP], GetXPNextLevel(pInfo[i][pLevel]));
			// 	PlayerTextDrawSetString(i, TDXPNumber[i], str);
			// 	format(str, 5, "%i%%", floatround(prop*100));
			// 	PlayerTextDrawSetString(i, TDXPPercent[i], str);
			// }

			quarterxp[i] = 0;
		}
		if(pInfo[i][pXP] >= GetXPNextLevel(pInfo[i][pLevel])) {
			pInfo[i][pXP] -= GetXPNextLevel(pInfo[i][pLevel]);
			pInfo[i][pLevel]++;
			SetPlayerScore(i, pInfo[i][pLevel]);
			GameTextForPlayer(i, "~b~Level UP", 1000, 1);

			new str[5];
			format(str, 5, "%i", pInfo[i][pLevel]);
			// PlayerTextDrawSetString(i, TDScore[i], str);
		}
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
	else if(n == 3) { str = "ter�a-feira"; }
	else if(n == 4) { str = "quarta-feira"; }
	else if(n == 5) { str = "quinta-feira"; }
	else if(n == 6) { str = "sexta-feira"; }
	else if(n == 7) { str = "s�bado"; }
	return str;
}