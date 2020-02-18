#define MAX_HOUSES				100
#define HOUSE_TYPES				7

#define CITY_NONE						0
#define CITY_BLUEBERRY					1
#define CITY_PALOMINOCREEK				2
#define CITY_MONTGOMERY					3
#define CITY_DILLIMORE					4
#define CITY_LOSSANTOS					5

enum HOUSE_INFO {
	hSQL,
	Float:hP[4],
	hInterior,
	hOwner[24],
	hLock,
	hPickup,
	Text3D:hLabel,
	hPrice,
	hCity,
	hNeighbourhood[30],
	hNumber[15]
};

enum HOUSE_DATA {
	hdInt,
	Float:hdP[4]
};

new hData[HOUSE_TYPES][HOUSE_DATA];
new hInfo[MAX_HOUSES][HOUSE_INFO];

CMD:irc(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	new id;
	if(sscanf(params, "i", id)) return AdvertCMD(playerid, "/IrC [ID da casa]");
	if(id < 0 || id >= MAX_HOUSES) return AdvertCMD(playerid, "/IrC [0 - 99]");
	if(!hInfo[id][hSQL]) return Advert(playerid, "Casa inexistente.");
	Streamer_UpdateEx(playerid, hInfo[id][hP][0], hInfo[id][hP][1], hInfo[id][hP][2], -1, -1, -1, 1500);
	new str[144];
	format(str, 144, "Você foi para a casa [ID%03i/SQL%03i].", id, hInfo[id][hSQL]);
	Info(playerid, str);
	return 1;
}

CMD:cid(playerid) {
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
	DestroyDynamic3DTextLabel(hInfo[id][hLabel]);
	hInfo[id][hPickup] = 0;
	hInfo[id][hPrice] = 0;
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
	hInfo[i][hLabel] = CreateDynamic3DTextLabel("", Azulado, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2], 4.5);
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

CMD:cpreco(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new price;
	if(sscanf(params, "i", price)) return AdvertCMD(playerid, "/cPreco [Preço]");
	new i = 0;
	for(; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			hInfo[i][hPrice] = price;
			new str[144], query[150];
			mysql_format(conn, query, 150, "UPDATE houseinfo SET price = %i WHERE sqlid = %i", price, hInfo[i][hSQL]);
			mysql_query(conn, query, false);
			format(str, 144, "Preço da casa [ID%03i/SQL%03i] definido para "VERDEMONEY"$%i"BRANCO".", i, hInfo[i][hSQL], price);
			Success(playerid, str);
			return 1;
		}
	}
	if(i == MAX_HOUSES) return Advert(playerid, "Você deve estar na entrada de fora de uma casa.");
	return 1;
}

CMD:ccity(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new city;
	if(sscanf(params, "i", city)) return AdvertCMD(playerid, "/cCity [1 - BB | 2 - PC | 3 - MG | 4 - DM]");
	if(city < 1 || city > 4) return AdvertCMD(playerid, "/cCity [1 - BB | 2 - PC | 3 - MG | 4 - DM]");
	new i = 0;
	for(; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			hInfo[i][hCity] = city;
			new str[144], query[150];
			mysql_format(conn, query, 150, "UPDATE houseinfo SET cidade = %i WHERE sqlid = %i", city, hInfo[i][hSQL]);
			mysql_query(conn, query, false);
			format(str, 144, "Cidade da casa [ID%03i/SQL%03i] definida como "AMARELO"%s"BRANCO".", i, hInfo[i][hSQL], GetCityName(city));
			Success(playerid, str);
			return 1;
		}
	}
	if(i == MAX_HOUSES) return Advert(playerid, "Você deve estar na entrada de fora de uma casa.");
	return 1;
}

CMD:cnumber(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new number[15];
	if(sscanf(params, "s[15]", number)) return AdvertCMD(playerid, "/cNumber [Numeração da casa]");
	new i = 0;
	for(; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			format(hInfo[i][hNumber], 15, "%s", number);
			UpdateDynamic3DTextLabelText(hInfo[i][hLabel], Azulado, number);
			new str[144], query[150];
			mysql_format(conn, query, 150, "UPDATE houseinfo SET number = '%s' WHERE sqlid = %i", number, hInfo[i][hSQL]);
			mysql_query(conn, query, false);
			format(str, 144, "Número da casa [ID%03i/SQL%03i] definido como "AMARELO"%s"BRANCO".", i, hInfo[i][hSQL], number);
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
			if(!strcmp(pName(playerid), hInfo[i][hOwner], true) && !isnull(hInfo[i][hOwner])) {
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
			if(!strcmp(pName(playerid), hInfo[i][hOwner], true) && !isnull(hInfo[i][hOwner])) {
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

CMD:sethouse(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new idc, id;
	if(sscanf(params, "ii", idc, id)) return AdvertCMD(playerid, "/SetHouse [IDC] [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(idc < 0 || idc >= MAX_HOUSES) return Advert(playerid, "Casa inválida.");
	if(!hInfo[idc][hSQL])  return Advert(playerid, "Casa inexistente.");
	new str[150];
	format(hInfo[idc][hOwner], 24, "%s", pNick(id));
	mysql_format(conn, str, 150, "UPDATE houseinfo SET owner = '%s' WHERE sqlid = %i", pNick(id), hInfo[idc][hSQL]);
	mysql_query(conn, str, false);
	format(str, 144, "O %s setou uma casa para você.", Staff(playerid));
	Info(id, str);
	format(str, 144, "Você setou a casa de ID %03i para o player %s.", idc, pName(id));
	Info(playerid, str);
	return 1;
}

forward OnGameModeInit@casa();
public OnGameModeInit@casa() {
	new Cache:result, rows, str[30], x;
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
		if(!strcmp(str, "NULL", false)) { str[0] = EOS; }
		format(hInfo[i][hOwner], 24, "%s", str);
		if(!strcmp(str, "NULL", false)) { str[0] = EOS; }
		cache_get_value_name(i, "bairro", str);
		if(!strcmp(str, "NULL", false)) { str[0] = EOS; }
		format(hInfo[i][hNeighbourhood], 30, "%s", str);
		cache_get_value_name(i, "number", str);
		format(hInfo[i][hNumber], 15, "%s", str);
		cache_get_value_name_float(i, "X", hInfo[i][hP][0]);
		cache_get_value_name_float(i, "Y", hInfo[i][hP][1]);
		cache_get_value_name_float(i, "Z", hInfo[i][hP][2]);
		cache_get_value_name_float(i, "A", hInfo[i][hP][3]);
		cache_get_value_name_int(i, "cidade", hInfo[i][hCity]);
		cache_get_value_name_int(i, "i", hInfo[i][hInterior]);
		cache_get_value_name_int(i, "lock", hInfo[i][hLock]);
		cache_get_value_name_int(i, "price", hInfo[i][hPrice]);
		hInfo[i][hPickup] = CreateDynamicPickup(1273, 1, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2]);
		hInfo[i][hLabel] = CreateDynamic3DTextLabel(hInfo[i][hNumber], Azulado, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2], 4.5);
	}
	cache_delete(result);
	return 1;
}

stock GetCityName(city) {
	new str[15];
	if(city == CITY_BLUEBERRY) format(str, 10, "Blueberry");
	else if(city == CITY_PALOMINOCREEK) format(str, 15, "Palomino Creek");
	else if(city == CITY_MONTGOMERY) format(str, 11, "Montgomery");
	else if(city == CITY_DILLIMORE) format(str, 10, "Dillimore");
	else if(city == CITY_LOSSANTOS) format(str, 11, "Los Santos");
	return str;
}