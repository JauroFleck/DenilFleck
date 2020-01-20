#define LOCK_RANGE			(20.0)

#define CLOC_EDOBB			-1
#define CLOC_AUTO			-2

enum VEHICLE_INFO {
	vSQL,
	vOwner[24],
	vModel,
	vColors[2],
	Float:vSpawn[4],
	vChave,
	vLock,
	vGas,
	vCargaGas
};

new vInfo[MAX_VEHICLES][VEHICLE_INFO];		// Lida apenas com veículos dentro do banco de dados.
new vinteriorid[MAX_VEHICLES];				// Importante pois lida com veículos fora do banco de dados.
new vModels[212][] =
	{"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perennial", "Sentinel", "Dumper", "Fire Truck", "Trashmaster", "Stretch", "Manana", 
	"Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", 
	"Mr. Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", 
	"Trailer 1", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squalo", 
	"Seasparrow", "Pizzaboy", "Tram", "Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", 
	"Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", 
	"Quadbike", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", 
	"Baggage", "Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring Racer", "Sandking", 
	"Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer 3", "Hotring Racer 2", "Bloodring Banger", 
	"Rancher Lure", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", 
	"Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Towtruck", "Fortune", "Cadrona", "FBI Truck", 
	"Willard", "Forklift", "Tractor", "Combine Harvester", "Feltzer", "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent", 
	"Bullet", "Clover", "Sadler", "Fire Truck Ladder", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility Van", 
	"Nevada", "Yosemite", "Windsor", "Monster 2", "Monster 3", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", 
	"Tahoma", "Savanna", "Bandito", "Freight Train Flatbed", "Streak Train Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", 
	"AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug", "Trailer (Tanker Commando)", "Emperor", "Wayfarer", "Euros", "Hotdog", 
	"Club", "Box Freight", "Trailer 3", "Andromada", "Dodo", "RC Cam", "Launch", "Police LS", "Police SF", "Police LV", "Police Ranger", 
	"Picador", "S.W.A.T.", "Alpha", "Phoenix", "Glendale Damaged", "Sadler Damaged", "Baggage Trailer (covered)", 
	"Baggage Trailer (Uncovered)", "Trailer (Stairs)", "Boxville Mission", "Farm Trailer", "Street Clean Trailer"};
new vSeats[212] =
	{  4, 2, 2, 2, 4, 4, 1, 2, 2, 4, 2, 2, 2, 4, 2, 2, 4, 2, 4, 2, 4, 4, 2, 2, 2, 1, 4, 4, 4, 2,
	1, 7, 1, 2, 2, 0, 2, 7, 4, 2, 4, 1, 2, 2, 2, 4, 1, 2, 1, 0, 0, 2, 1, 1, 1, 2, 2, 2, 4,
	4, 2, 2, 2, 2, 1, 1, 4, 4, 2, 2, 4, 2, 1, 1, 2, 2, 1, 2, 2, 4, 2, 1, 4, 3, 1, 1, 1, 4, 2,
	2, 4, 2, 4, 1, 2, 2, 2, 4, 4, 2, 2, 1, 2, 2, 2, 2, 2, 4, 2, 1, 1, 2, 1, 1, 2, 2, 4, 2, 2,
	1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 4, 1, 1, 1, 2, 2, 2, 2, 7, 7, 1, 4, 2, 2, 2, 2, 2, 4, 4,
	2, 2, 4, 4, 2, 1, 2, 2, 2, 2, 2, 2, 4, 4, 2, 2, 1, 2, 4, 4, 1, 0, 0, 1, 1, 2, 1, 2, 2, 1, 2,
	4, 4, 2, 4, 1, 0, 4, 2, 2, 2, 2, 0, 0, 7, 2, 2, 1, 4, 4, 4, 2, 2, 2, 2, 2, 4, 2, 0, 0, 0,
	4, 0, 0};
new vGasCap[212];
new vGasGas[212];
new vMotor[MAX_VEHICLES];
new PlayerText3D:IDV[MAX_PLAYERS][MAX_VEHICLES];
new bIDV[MAX_PLAYERS];
new TVelocimetro[MAX_PLAYERS];
new TGasolimetro[MAX_VEHICLES];

CMD:criarveiculo(playerid, params[]) {
	if(strcmp(pNick(playerid), "John_Black", false)) return SendClientMessage(playerid, -1, "Nananinanão (:");
	new vid;
	if(sscanf(params, "i", vid)) return SendClientMessage(playerid, -1, "/criarveiculo [vid]");
	else {
		if(vid < 400 || vid > 611) return SendClientMessage(playerid, -1, "399 < vid < 612");
		new Float: P[4];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		GetPlayerFacingAngle(playerid, P[3]);
		new v = CreateVehicle(vid, P[0], P[1], P[2], P[3], 1, 1, 0);
		PutPlayerInVehicle(playerid, v, 0);
		format(vInfo[v][vOwner], 24, "John_Black");
		vInfo[v][vModel] = vid;
		vInfo[v][vColors][0] = 1;
		vInfo[v][vColors][1] = 1;
		vInfo[v][vSpawn][0] = P[0];
		vInfo[v][vSpawn][1] = P[1];
		vInfo[v][vSpawn][2] = P[2];
		vInfo[v][vSpawn][3] = P[3];
		vInfo[v][vChave] = pInfo[playerid][pSQL];

		new query[300];
		mysql_format(conn, query, 300, "INSERT INTO `vehicleinfo` (`owner`, `model`, `color1`, `color2`, `sX`, `sY`, `sZ`, `sA`, `chave`) VALUES ('%s', %i, 1, 1, %f, %f, %f, %f, %i)", "John_Black", vid, P[0], P[1], P[2], P[3], pInfo[playerid][pSQL]);
		new Cache:result = mysql_query(conn, query);
		vInfo[v][vSQL] = cache_insert_id();
		cache_delete(result);

		new str[128];
		format(str, 128, "Veículo criado. Modelo: %i | ID: %i", vid, v);
		SendClientMessage(playerid, -1, str);
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			cmd_idv(i);
			cmd_idv(i);
		}
	}
	return 1;
}

CMD:deletarveiculo(playerid) {
	if(strcmp(pNick(playerid), "John_Black", false)) return SendClientMessage(playerid, -1, "Nananinanão (:");
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, -1, "Você deve estar dentro de um veículo para fazer isso.");
	new v = GetPlayerVehicleID(playerid);
	if(!vInfo[v][vSQL]) return SendClientMessage(playerid, -1, "Veículo ordinário. Use /DV.");
	else {
		format(vInfo[v][vOwner], 24, "");
		vInfo[v][vModel] = 0;
		vInfo[v][vColors][0] = 0;
		vInfo[v][vColors][1] = 0;
		vInfo[v][vSpawn][0] = 0.0;
		vInfo[v][vSpawn][1] = 0.0;
		vInfo[v][vSpawn][2] = 0.0;
		vInfo[v][vSpawn][3] = 0.0;
		vInfo[v][vChave] = 0;

		new query[100];
		mysql_format(conn, query, 100, "DELETE FROM `vehicleinfo` WHERE `sqlid` = %i", vInfo[v][vSQL]);
		mysql_query(conn, query, false);
		vInfo[v][vSQL] = 0;

		DestroyVehicle(v);
		SendClientMessage(playerid, -1, "Veículo deletado.");
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			cmd_idv(i);
			cmd_idv(i);
		}
	}
	return 1;
}

CMD:motor(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	if(gettime() < pInfo[playerid][pUSECMD_motor]) return 1;
	new vid = GetPlayerVehicleID(playerid);
	if(vInfo[vid][vSQL] || vid == vStaff[playerid][vsID]) {
		if(vInfo[vid][vChave] == pInfo[playerid][pSQL]) {
			pInfo[playerid][pUSECMD_motor] = gettime()+2;
			if(vMotor[vid]) {
				vMotor[vid] = 0;
				Act(playerid, "gira a ignição no sentido anti-horário.");
				KillTimer(TGasolimetro[vid]);
				TGasolimetro[vid] = 0;
			} else {
				vMotor[vid] = 1;
				Act(playerid, "gira a ignição no sentido horário.");
				TGasolimetro[vid] = SetTimerEx("Gasolimetro", vGasGas[GetVehicleModel(vid)-400]*60000, true, "i", vid);
			}
			SetTimerEx("Motor", 1000, false, "ii", vid, vMotor[vid]);
		} else if(vid == vStaff[playerid][vsID]) {
			pInfo[playerid][pUSECMD_motor] = gettime()+2;
			if(vMotor[vid]) {
				vMotor[vid] = 0;
				Act(playerid, "gira a ignição no sentido anti-horário.");
			} else {
				vMotor[vid] = 1;
				Act(playerid, "gira a ignição no sentido horário.");
			}
			SetTimerEx("Motor", 1000, false, "ii", vid, vMotor[vid]);
		} else {
			Advert(playerid, "Você não possui a chave desse veículo.");
		}
	} else {
		Advert(playerid, "Informe à administração sobre essa mensagem. [COD 004]");
	}
	return 1;
}

CMD:trancar(playerid, params[]) {
	new vid;
	if(sscanf(params, "i", vid)) AdvertCMD(playerid, "/Trancar [IDV]");
	if(!vInfo[vid][vSQL]) Advert(playerid, "ID de veículo inválido.");
	if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você não tem chave desse veículo. Use "AMARELO"/Chaves"BRANCO".");
	new Float:P[3];
	GetVehiclePos(vid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, LOCK_RANGE, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo ao veículo que deseja trancar.");
	if(vInfo[vid][vLock]) return Advert(playerid, "Esse veículo já está trancado.");
	vInfo[vid][vLock] = 1;
	new a, b, c, d, e, f;
	GetVehicleParamsEx(vid, a, b, c, d, d, e, f);
	SetVehicleParamsEx(vid, a, b, c, 1, d, e, f);
	Act(playerid, "trancou seu veículo.");
	return 1;
}

CMD:destrancar(playerid, params[]) {
	new vid;
	if(sscanf(params, "i", vid)) AdvertCMD(playerid, "/Destrancar [IDV]");
	if(!vInfo[vid][vSQL]) Advert(playerid, "ID de veículo inválido.");
	if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você não tem chave desse veículo. Use "AMARELO"/Chaves"BRANCO".");
	new Float:P[3];
	GetVehiclePos(vid, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, LOCK_RANGE, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo ao veículo que deseja destrancar.");
	if(!vInfo[vid][vLock]) return Advert(playerid, "Esse veículo já está destrancado.");
	vInfo[vid][vLock] = 0;
	new a, b, c, d, e, f;
	GetVehicleParamsEx(vid, a, b, c, d, d, e, f);
	SetVehicleParamsEx(vid, a, b, c, 0, d, e, f);
	Act(playerid, "destrancou seu veículo.");
	return 1;
}

CMD:luzes(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return 1;
	new vid = GetPlayerVehicleID(playerid);
	new a, b, c, d, e, f, g;
	GetVehicleParamsEx(vid, a, b, c, d, e, f, g);
	b = (!b) ? (1) : (0);
	SetVehicleParamsEx(vid, a, b, c, d, e, f, g);
	return 1;
}

CMD:idv(playerid) {
	if(!bIDV[playerid]) {
		new str[10];
		for(new i = 0; i < MAX_VEHICLES; i++) {
			if(!vInfo[i][vSQL]) continue;
			format(str, 10, "IDV %i", i);
			IDV[playerid][i] = CreatePlayer3DTextLabel(playerid, str, -1, 0.0, 0.0, 0.25, 20.0, INVALID_PLAYER_ID, i, 1);
		}
		bIDV[playerid] = 1;
	} else {
		for(new i = 0; i < MAX_VEHICLES; i++) {
			DeletePlayer3DTextLabel(playerid, IDV[playerid][i]);
		}
		bIDV[playerid] = 0;
	}
	return 1;
}

CMD:chaves(playerid) {
	new str[300] = "";
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(!vInfo[i][vSQL]) continue;
		if(vInfo[i][vChave] == pInfo[playerid][pSQL]) {
			format(str, 300, "%s\n\t• IDV %i", str, i);
		}
	}
	if(isnull(str)) return Advert(playerid, "Você não carrega nenhuma chave consigo.");
	format(str, 300, BRANCO"Chaves:\n%s", str);
	Dialog_Show(playerid, "DialogNone", DIALOG_STYLE_MSGBOX, BRANCO"CHAVES", str, "Fechar", "");
	return 1;
}

CMD:gascap(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	if(!IsPlayerInAnyVehicle(playerid)) return Advert(playerid, "Você deve estar dentro do veículo que deseja definir a capacidade de gasolina.");
	new gascap;
	if(sscanf(params, "i", gascap)) return AdvertCMD(playerid, "/GasCap [Capacidade em Litros de Gasolina]");
	new vmodel = GetVehicleModel(GetPlayerVehicleID(playerid));
	new str[144];
	format(str, 144, "Capacidade de gasolina do veículo '%s' definido para "AMARELO"%iL"BRANCO".", vModels[vmodel-400], gascap);
	Info(playerid, str);
	new query[150], Cache:result, rows;
	mysql_format(conn, query, 150, "SELECT `gascap`, `model` FROM `vehicledata` WHERE `model` = %i", vmodel);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	cache_delete(result);
	if(!rows) {
		mysql_format(conn, query, 150, "INSERT INTO `vehicledata` (`gascap`, `model`) VALUES (%i, %i)", gascap, vmodel);
		mysql_query(conn, query, false);
	} else {
		mysql_format(conn, query, 150, "UPDATE `vehicledata` SET `gascap` = %i WHERE `model` = %i", gascap, vmodel);
		mysql_query(conn, query, false);
	}
	vGasCap[vmodel-400] = gascap;
	return 1;
}

CMD:gasgas(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	if(!IsPlayerInAnyVehicle(playerid)) return Advert(playerid, "Você deve estar dentro do veículo que deseja definir a capacidade de gasolina.");
	new gasgas;
	if(sscanf(params, "i", gasgas)) return AdvertCMD(playerid, "/GasGas [Tempo em minutos para gastar 1L de gasolina]");
	new vmodel = GetVehicleModel(GetPlayerVehicleID(playerid));
	new str[144];
	format(str, 144, "Gasto de gasolina do veículo '%s' definido para "AMARELO"%imin/L"BRANCO".", vModels[vmodel-400], gasgas);
	Info(playerid, str);
	new query[150], Cache:result, rows;
	mysql_format(conn, query, 150, "SELECT `gasgas`, `model` FROM `vehicledata` WHERE `model` = %i", vmodel);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	cache_delete(result);
	if(!rows) {
		mysql_format(conn, query, 150, "INSERT INTO `vehicledata` (`gasgas`, `model`) VALUES (%i, %i)", gasgas, vmodel);
		mysql_query(conn, query, false);
	} else {
		mysql_format(conn, query, 150, "UPDATE `vehicledata` SET `gasgas` = %i WHERE `model` = %i", gasgas, vmodel);
		mysql_query(conn, query, false);
	}
	vGasGas[vmodel-400] = gasgas;
	return 1;
}

CMD:setgas(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Administrador) return 1;
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você precisa conduzir o veículo que deseja setar a gasolina.");
	new gas;
	if(sscanf(params, "i", gas)) return AdvertCMD(playerid, "/SetGas [Quantidade de Gasolina em Litros]");
	new vid = GetPlayerVehicleID(playerid);
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Esse veículo não está registrado no banco de dados.");
	vInfo[vid][vGas] = gas;
	new str[144];
	format(str, 144, "Você setou a gasolina desse veículo para %i litros.", gas);
	Info(playerid, str);
	return 1;
}

CMD:estacionar(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar o veículo para estacioná-lo.");
	new vid = GetPlayerVehicleID(playerid);
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
	if(strcmp(vInfo[vid][vOwner], pNick(playerid), false)) return Advert(playerid, "Apenas o dono do veículo pode fazer isso.");
	GetVehiclePos(vid, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2]);
	GetVehicleZAngle(vid, vInfo[vid][vSpawn][3]);
	Success(playerid, "Veículo estacionado.");
	new query[150];
	mysql_format(conn, query, 150, "UPDATE `vehicleinfo` SET `sX` = %f, `sY` = %f, `sZ` = %f, `sA` = %f WHERE `sqlid` = %i", vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2], vInfo[vid][vSpawn][3], vInfo[vid][vSQL]);
	mysql_query(conn, query, false);
	return 1;
}

stock GetVehicleIDBySQL(sqlid) {
	new i;
	for(; i < MAX_VEHICLES; i++) {
		if(!GetVehicleModel(i)) continue;
		if(vInfo[i][vSQL] == sqlid) return i;
	}
	if(i == MAX_VEHICLES) return 0;
	return 0;
}

stock SetVehicleInterior(vehicleid, interiorid) {
	if(!GetVehicleModel(vehicleid)) return 0;
	vinteriorid[vehicleid] = interiorid;
	return LinkVehicleToInterior(vehicleid, interiorid);
}

stock GetVehicleInterior(vehicleid) {
	if(!GetVehicleModel(vehicleid)) return 0;
	return vinteriorid[vehicleid];
}

public OnVehicleSpawn(vehicleid) {
	if(vInfo[vehicleid][vSQL]) {
		SetVehiclePos(vehicleid, vInfo[vehicleid][vSpawn][0], vInfo[vehicleid][vSpawn][1], vInfo[vehicleid][vSpawn][2]);
		SetVehicleZAngle(vehicleid, vInfo[vehicleid][vSpawn][3]);
	}
	return 1;
}

forward Motor(vid, eng);
public Motor(vid, eng) {
	if(eng) {
		if(vInfo[vid][vSQL]) {
			if(!vInfo[vid][vGas]) {
				new Float:P[3];
				GetVehiclePos(vid, P[0], P[1], P[2]);
				Amb(P[0], P[1], P[2], "Falha do motor ao ser ligado.");
				return 1;
			}
		}
	}
	vMotor[vid] = eng;
	new a, b, c, d, e, f;
	GetVehicleParamsEx(vid, a, a, b, c, d, e, f);
	SetVehicleParamsEx(vid, eng, a, b, c, d, e, f);
	return 1;
}

forward LoadVehicleData();
public LoadVehicleData() {
	new row, v, owner[24];
	cache_get_row_count(row);
	for(new i = 0; i < row; i++) {
		new m, Float:P[4], c1, c2, k; // Necessário devido à variável v.
		cache_get_value_name_int(i, "model", m);
		cache_get_value_name_float(i, "sX", P[0]);
		cache_get_value_name_float(i, "sY", P[1]);
		cache_get_value_name_float(i, "sZ", P[2]);
		cache_get_value_name_float(i, "sA", P[3]);
		cache_get_value_name_int(i, "color1", c1);
		cache_get_value_name_int(i, "color2", c2);
		cache_get_value_name_int(i, "chave", k);
		cache_get_value_name(i, "owner", owner);
		v = CreateVehicle(m, P[0], P[1], P[2], P[3], c1, c2, 0);
		vInfo[v][vModel] = m;
		vInfo[v][vSpawn][0] = P[0];
		vInfo[v][vSpawn][1] = P[1];
		vInfo[v][vSpawn][2] = P[2];
		vInfo[v][vSpawn][3] = P[3];
		vInfo[v][vColors][0] = c1;
		vInfo[v][vColors][1] = c2;
		vInfo[v][vChave] = k;
		format(vInfo[v][vOwner], 24, "%s", owner);
		cache_get_value_index_int(i, 0, vInfo[v][vSQL]);
		cache_get_value_name_int(i, "gas", vInfo[v][vGas]);
		SetVehicleParamsEx(v, 0, 0, 0, 1, 0, 0, 0);
		vInfo[v][vLock] = 1;
	}
	return 1;
}

forward LoadVehicleParams();
public LoadVehicleParams() {
	new rows, m;
	cache_get_row_count(rows);
	for(new i = 0; i < rows; i++) {
		cache_get_value_name_int(i, "model", m);
		m -= 400;
		cache_get_value_name_int(i, "gascap", vGasCap[m]);
		cache_get_value_name_int(i, "gasgas", vGasGas[m]);
	}
	return 1;
}

forward OnGameModeInit@vehicle();
public OnGameModeInit@vehicle() {
	print("LOADING DATA FROM... vehicleinfo");
	mysql_tquery(conn, "SELECT * FROM `vehicleinfo`", "LoadVehicleData");
	print("CONCLUDED!");
	print("LOADING DATA FROM... vehicledata");
	mysql_tquery(conn, "SELECT * FROM `vehicledata`", "LoadVehicleParams");
	print("CONCLUDED!");
	return 1;
}

forward OnGameModeExit@vehicle();
public OnGameModeExit@vehicle() {
	new query[120];
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(!vInfo[i][vSQL]) continue;
		mysql_format(conn, query, 120, "UPDATE vehicleinfo SET `gas` = %i, `chave` = %i WHERE sqlid = %i", vInfo[i][vGas], vInfo[i][vChave], vInfo[i][vSQL]);
		mysql_query(conn, query, false);
	}
	return 1;
}

forward OnPlayerKeyStateChange@vehicle(playerid, newkeys, oldkeys);
public OnPlayerKeyStateChange@vehicle(playerid, newkeys, oldkeys) {
	if(newkeys & KEY_LOOK_BEHIND) {
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
			cmd_motor(playerid);
		}
	}
	if((newkeys & KEY_FIRE) && !(oldkeys & KEY_FIRE)) {
		if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER) {
			cmd_luzes(playerid);
		}
	}
	return 1;
}

forward OnPlayerStateChange@vehicle(playerid, newstate, oldstate);
public OnPlayerStateChange@vehicle(playerid, newstate, oldstate) {
	if(newstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < sizeof(TDGas); i++) {
			TextDrawShowForPlayer(playerid, TDGas[i]);
		}
		new str[30], vid = GetPlayerVehicleID(playerid), Float:V[4];
		format(str, 30, "%iL/%iL", vInfo[vid][vGas], vGasCap[GetVehicleModel(vid)-400]);
		PlayerTextDrawSetString(playerid, TDGasolina[playerid], str);
		PlayerTextDrawShow(playerid, TDGasolina[playerid]);
		GetVehicleVelocity(vid, V[0], V[1], V[2]);
		V[3] = floatsqroot(floatpower(V[0], 2) + floatpower(V[1], 2) + floatpower(V[2], 2));
		V[3] *= 162.7;
		format(str, 30, "%fKm/h", V[3]);
		PlayerTextDrawSetString(playerid, TDVelocidade[playerid], str);
		PlayerTextDrawShow(playerid, TDVelocidade[playerid]);
		TVelocimetro[playerid] = SetTimerEx("Velocimetro", 250, true, "i", playerid);
	} else if(oldstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < sizeof(TDGas); i++) {
			TextDrawHideForPlayer(playerid, TDGas[i]);
		}
		PlayerTextDrawHide(playerid, TDGasolina[playerid]);
		PlayerTextDrawHide(playerid, TDVelocidade[playerid]);
	}
	return 1;
}

stock GetModelIDFromModelName(const name[]) {
	if(isnull(name)) return 0;
	for(new i = 0; i < 212; i++) {
		if(!strcmp(vModels[i], name, true)) return (i+400);
	}
	return 0;
}

stock GetPlayerIDVehicleSeat(vehicleid, seatid) {
	if(!GetVehicleModel(vehicleid)) return -1;
	new id;
	while(id < MAX_PLAYERS) {
		if(IsPlayerConnected(id)) {
			if(IsPlayerInVehicle(id, vehicleid)) {
				if(GetPlayerVehicleSeat(id) == seatid) return id;
			}
		}
		id++;
	}
	return -1;
}

forward Velocimetro(playerid);
public Velocimetro(playerid) {
	new vid = GetPlayerVehicleID(playerid);
	if(!vid) { KillTimer(TVelocimetro[playerid]); TVelocimetro[playerid] = 0; }
	new Float:V[4], str[30];
	GetVehicleVelocity(vid, V[0], V[1], V[2]);
	V[3] = floatsqroot(floatpower(V[0], 2) + floatpower(V[1], 2) + floatpower(V[2], 2));
	V[3] *= 162.7;
	format(str, 30, "%.0fKm/h", V[3]);
	PlayerTextDrawSetString(playerid, TDVelocidade[playerid], str);
	return 1;
}

forward Gasolimetro(vehicleid);
public Gasolimetro(vehicleid) {
	new vid;
	vInfo[vehicleid][vGas]--;
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(GetPlayerState(i) != PLAYER_STATE_DRIVER) continue;
		vid = GetPlayerVehicleID(i);
		if(vid == vehicleid) {
			new str[30];
			format(str, 30, "%iL/%iL", vInfo[vehicleid][vGas], vGasCap[GetVehicleModel(vid)-400]);
			PlayerTextDrawSetString(i, TDGasolina[i], str);
			break;
		}
	}
	if(!vInfo[vehicleid][vGas]) {
		KillTimer(TGasolimetro[vehicleid]);
		TGasolimetro[vehicleid] = 0;
		Motor(vid, 0);
	}
	return 1;
}