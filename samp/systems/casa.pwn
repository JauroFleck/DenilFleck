#define MAX_HOUSES				100
#define HOUSE_TYPES				6

enum HOUSE_INFO {
	hSQL,
	Float:hP[4],
	hInterior,
	hOwner[24],
	hLock,
	hPickup,
	hPreco
};

enum HOUSE_DATA {
	hdInt,
	Float:hdP[4]
};

new hData[HOUSE_TYPES][HOUSE_DATA];
new hInfo[MAX_HOUSES][HOUSE_INFO];

CMD:ircasa(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/IrCasa [ID da casa]");
	if(id < 0 || id >= MAX_HOUSES) return AdvertCMD(playerid, "/IrCasa [0 - 99]");
	if(!hInfo[id][hSQL]) return Advert(playerid, "Casa inexistente.");
	Streamer_UpdateEx(playerid, hInfo[id][hP][0], hInfo[id][hP][1], hInfo[id][hP][2], -1, -1, -1, 1500);
	new str[144];
	format(str, 144, "Você foi para a casa [ID%03i/SQL%03i].", id, hInfo[id][hSQL]);
	Info(playerid, str);
	return 1;
}

CMD:casaid(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			new str[144];
			format(str, 144, "Casa ID: %03i | SQL: %03i.", i, hInfo[i][hSQL]);
			Info(playerid, str);
			return 1;
		}
	}
	return 1;
}

CMD:excluircasa(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/ExcluirCasa [ID da casa]");
	if(id < 0 || id > MAX_HOUSES) return Advert(playerid, "ID inválido de casa.");
	if(!hInfo[id][hSQL]) return Advert(playerid, "Casa inexistente.");
	for(new i = 0; i < MAX_PLAYERS; i ++) {
		if(!IsPlayerConnected(i)) continue;
		if(GetPlayerVirtualWorld(i) == id+MAX_BUSINESS) return Advert(playerid, "Não excluirás uma casa com alguém dentro.");
	}
	new query[150], str[144];
	mysql_format(conn, query, 150, "DELETE FROM houseinfo WHERE sqlid = %i", hInfo[id][hSQL]);
	mysql_query(conn, query, false);
	hInfo[id][hP][0] = 0.0;
	hInfo[id][hP][1] = 0.0;
	hInfo[id][hP][2] = 0.0;
	hInfo[id][hP][3] = 0.0;
	hInfo[id][hInterior] = 0;
	hInfo[id][hLock] = 0;
	format(hInfo[id][hOwner], 24, "");
	DestroyDynamicPickup(hInfo[id][hPickup]);
	hInfo[id][hPickup] = 0;
	hInfo[id][hPreco] = 0;
	format(str, 144, "Casa [ID%03i/SQL%03i] excluída com sucesso.", id, hInfo[id][hSQL]);
	hInfo[id][hSQL] = 0;
	Info(playerid, str);
	return 1;
}

CMD:criarcasa(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new i = 0;
	for(; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) break;
	}
	if(i == MAX_HOUSES) return Advert(playerid, "Máximo de casas criadas já foi atingido.");
	GetPlayerPos(playerid, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2]);
	GetPlayerFacingAngle(playerid, hInfo[i][hP][3]);
	new str[144], query[150], Cache:result;
	mysql_format(conn, query, 150,"INSERT INTO houseinfo (X, Y, Z, A) VALUES (%f, %f, %f, %f)", hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2], hInfo[i][hP][3]);
	result = mysql_query(conn, query, true);
	hInfo[i][hSQL] = cache_insert_id();
	cache_delete(result);
	hInfo[i][hPickup] = CreateDynamicPickup(1273, 1, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2]);
	format(str, 144, "Casa ID [%03i] SQL [%03i] criada com sucesso. Use "AMARELO"/cInterior"BRANCO" para configurá-la.", i, hInfo[i][hSQL]);
	Success(playerid, str);
	return 1;
}

CMD:cinterior(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new interior;
	if(sscanf(params, "i", interior)) return AdvertCMD(playerid, "/cInterior [Interior ID]");
	if(interior < 1 || interior > HOUSE_TYPES) return AdvertCMD(playerid, "/cInterior [1-7]");
	new i = 0;
	for(; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			for(new j = 0; j < MAX_PLAYERS; j++) {
				if(!IsPlayerConnected(j)) continue;
				if(GetPlayerVirtualWorld(j) == MAX_BUSINESS+i) return Advert(playerid, "Não configurarás uma casa com alguém dentro.");
			}
			hInfo[i][hInterior] = interior;
			new str[144], query[150];
			mysql_format(conn, query, 150, "UPDATE houseinfo SET i = %i WHERE sqlid = %i", interior, hInfo[i][hSQL]);
			mysql_query(conn, query, false);
			format(str, 144, "Interior da casa [ID%03i/SQL%03i] definido como "AMARELO"%i"BRANCO".", i, hInfo[i][hSQL], interior);
			Success(playerid, str);
			return 1;
		}
	}
	if(i == MAX_HOUSES) return Advert(playerid, "Você deve estar na entrada de fora de uma casa.");
	return 1;
}

CMD:trancarcasa(playerid) {
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			if(!strcmp(pNick(playerid), hInfo[i][hOwner], true) && !isnull(hInfo[i][hOwner])) {
				if(!hInfo[i][hLock]) {
					hInfo[i][hLock] = 1;
					Act(playerid, "tranca a porta da casa.");
				} else {
					Advert(playerid, "A sua casa já está trancada.");
				}
			} else {
				Advert(playerid, "Você não tem a chave dessa casa.");
			}
			return 1;
		}
	}
	return 1;
}

CMD:destrancarcasa(playerid) {
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			if(!strcmp(pNick(playerid), hInfo[i][hOwner], true) && !isnull(hInfo[i][hOwner])) {
				if(hInfo[i][hLock]) {
					hInfo[i][hLock] = 0;
					Act(playerid, "destranca a porta da casa.");
				} else {
					Advert(playerid, "A sua casa já está destrancada.");
				}
			} else {
				Advert(playerid, "Você não tem a chave dessa casa.");
			}
			return 1;
		}
	}
	return 1;
}

forward OnGameModeInit@casa();
public OnGameModeInit@casa() {
	new Cache:result, rows, str[24], x;
	result = mysql_query(conn, "SELECT * FROM housedata", true);
	cache_get_row_count(rows);
	for(new i = 0; i < rows; i++) {
		cache_get_value_index_int(i, 0, x);
		cache_get_value_name_float(i, "X", hData[x][hdP][0]);
		cache_get_value_name_float(i, "Y", hData[x][hdP][1]);
		cache_get_value_name_float(i, "Z", hData[x][hdP][2]);
		cache_get_value_name_float(i, "A", hData[x][hdP][3]);
		cache_get_value_name_int(i, "interior", hData[x][hdInt]);
	}
	cache_delete(result);
	result = mysql_query(conn, "SELECT * FROM houseinfo", true);
	cache_get_row_count(rows);
	for(new i = 0; i < rows; i++) {
		cache_get_value_index_int(i, 0, hInfo[i][hSQL]);
		cache_get_value_name(i, "owner", str);
		format(hInfo[i][hOwner], 24, "%s", str);
		cache_get_value_name_float(i, "X", hInfo[i][hP][0]);
		cache_get_value_name_float(i, "Y", hInfo[i][hP][1]);
		cache_get_value_name_float(i, "Z", hInfo[i][hP][2]);
		cache_get_value_name_float(i, "A", hInfo[i][hP][3]);
		cache_get_value_name_int(i, "i", hInfo[i][hInterior]);
		cache_get_value_name_int(i, "lock", hInfo[i][hLock]);
		cache_get_value_name_int(i, "price", hInfo[i][hPreco]);
		hInfo[i][hPickup] = CreateDynamicPickup(1273, 1, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2]);
	}
	cache_delete(result);
	return 1;
}