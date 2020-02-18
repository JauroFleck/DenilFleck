#define LOCK_RANGE			(20.0)

#define CLOC_EDOBB			-1
#define CLOC_AUTO			-2
#define CLOC_CONC			-3
#define CLOC_RCSD			-4
#define CLOC_REF			-5
#define CLOC_TRANSP			-6
#define CLOC_GARBAGE		-7

#define MAX_BOOT_SLOTS		10

#define GPSTYPE_NONE		0
#define GPSTYPE_TRANSP		1
#define GPSTYPE_PERSONAL	2

#define MAX_VATTACHMENTS	30

enum VATTACH_INFO {
	vaSQL,
	vaID,
	vaModel,
	Float:vaP[3],
	Float:vaR[3]
};

enum VEHICLE_INFO {
	vSQL,
	vOwner[24],
	vModel,
	vColors[2],
	Float:vSpawn[4],
	vChave,
	vLock,
	vBoot,
	vLights,
	vGas,
	vCargaGas,
	vBootSlot[MAX_BOOT_SLOTS],
	vGPS,
	vAttObj[3]
};

new vAttachments[MAX_VATTACHMENTS][VATTACH_INFO];
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
new Float:vBootDist[212];
new vMotor[MAX_VEHICLES];
new PlayerText3D:IDV[MAX_PLAYERS][MAX_VEHICLES];
new bIDV[MAX_PLAYERS];
new TVelocimetro[MAX_PLAYERS];
new TGasolimetro[MAX_VEHICLES];

CMD:gps(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você precisa estar conduzindo um veículo.");
	new vid = GetPlayerVehicleID(playerid);
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	if(vInfo[vid][vGPS] == GPSTYPE_NONE) return Advert(playerid, "Esse veículo não possui GPS.");
	if(vInfo[vid][vGPS] == GPSTYPE_TRANSP) {
		new str[] = "Transportadora de Blueberry\n\
					 Well Stacked Pizza de Blueberry\n\
					 Well Stacked Pizza de Palomino Creek\n\
					 Padaria de Montgomery\n\
					 King Ring de Fort Carson\n\
					 Café de Fort Carson\n\
					 Sprunk de Blueberry\n\
					 Sprunk de Montgomery\n\
					 Bar de Dillimore\n\
					 Bar de Fort Carson\n\
					 Loja de roupas de Dillimore\n\
					 Desligar GPS";
		Dialog_Show(playerid, "GPSTransp", DIALOG_STYLE_LIST, "GPS", str, "Ir", "Cancelar");
	}
	if(vInfo[vid][vGPS] == GPSTYPE_PERSONAL) {
		new str[] = "Imobiliária de Palomino Creek\n\
					 Banco de Palomino Creek\n\
					 Transportadora de Blueberry\n\
					 Estação de ônibus de Blueberry\n\
					 Concessionária de Dillimore\n\
					 Autoescola de Dillimore\n\
					 Refinaria de Flint County\n\
					 Desligar GPS";
		Dialog_Show(playerid, "GPSPersonal", DIALOG_STYLE_LIST, "GPS", str, "Ir", "Cancelar");
	}
	return 1;
}

CMD:criarveiculo(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new vid;
	if(sscanf(params, "i", vid)) return SendClientMessage(playerid, -1, "/criarveiculo [vid]");
	else {
		if(vid < 400 || vid > 611) return SendClientMessage(playerid, -1, "399 < vid < 612");
		new Float: P[4];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		GetPlayerFacingAngle(playerid, P[3]);
		new v = CreateVehicle(vid, P[0], P[1], P[2], P[3], 1, 1, 0);
		PutPlayerInVehicle(playerid, v, 0);
		format(vInfo[v][vOwner], 24, pNick(playerid));
		vInfo[v][vModel] = vid;
		vInfo[v][vColors][0] = 1;
		vInfo[v][vColors][1] = 1;
		vInfo[v][vSpawn][0] = P[0];
		vInfo[v][vSpawn][1] = P[1];
		vInfo[v][vSpawn][2] = P[2];
		vInfo[v][vSpawn][3] = P[3];
		vInfo[v][vChave] = pInfo[playerid][pSQL];

		new query[300];
		mysql_format(conn, query, 300, "INSERT INTO `vehicleinfo` (`owner`, `model`, `color1`, `color2`, `sX`, `sY`, `sZ`, `sA`, `chave`) VALUES ('%s', %i, 1, 1, %f, %f, %f, %f, %i)", pNick(playerid), vid, P[0], P[1], P[2], P[3], pInfo[playerid][pSQL]);
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

CMD:setveh(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new vid, id;
	if(sscanf(params, "ii", vid, id)) return AdvertCMD(playerid, "/SetVeh [IDV] [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
	for(new i = 0; i < MAX_BUSINESS; i++) {
		if(!bInfo[i][bSQL]) continue;
		for(new j = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			if(bInfo[i][bVehicles][j] == vInfo[vid][vSQL]) {
				Advert(playerid, "Esse veículo pertence a uma empresa.");
				Advert(playerid, "Para remover da empresa use /RemoverVeiculo.");
				return 1;
			}
		}
	}
	new str[150];
	format(vInfo[vid][vOwner], 24, "%s", pNick(id));
	mysql_format(conn, str, 150, "UPDATE vehicleinfo SET owner = '%s' WHERE sqlid = %i", pNick(id), vInfo[vid][vSQL]);
	mysql_query(conn, str, false);
	format(str, 144, "O %s setou o veículo de IDV %03i para você.", Staff(playerid), vid);
	Info(id, str);
	format(str, 144, "Você setou o veículo de IDV %03i para o player %s.", vid, pName(id));
	Info(playerid, str);
	format(str, 144, "Para setar a chave, use "AMARELO"/SetKey %i %i"BRANCO".", vid, id);
	Info(playerid, str);
	return 1;
}

CMD:setkey(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new vid, id;
	if(sscanf(params, "ii", vid, id)) return AdvertCMD(playerid, "/SetKey [IDV] [ID]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
	new pid = -1;
	if(vInfo[vid][vChave] > 0) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][pSQL] == vInfo[vid][vChave]) {
				pid = i;
				break;
			}
		}
	}
	new str[144];
	if(pid != -1) {
		format(str, 144, "Sua chave %03i foi retirada pelo %s.", vid, Staff(playerid));
		Info(pid, str);
		format(str, 144, "Você retirou a chave %03i do player %s para entregar ao player %s.", vid, pName(pid), pName(id));
		Info(playerid, str);
	} else {
		format(str, 144, "Você entregou a chave %03i para o player %s.", vid, pName(id));
		Info(playerid, str);
	}
	format(str, 144, "O %s entregou a chave %03i para você.", Staff(playerid), vid);
	Info(id, str);
	vInfo[vid][vChave] = pInfo[id][pSQL];
	return 1;
}

CMD:setvcolors(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new c1, c2;
	if(sscanf(params, "ii", c1, c2)) return AdvertCMD(playerid, "/SetvColors [Cor 1] [Cor 2]");
	new vid = GetPlayerVehicleID(playerid);
	if(!IsValidVehicle(vid)) return Advert(playerid, "Você precisa estar dentro de um veículo.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	vInfo[vid][vColors][0] = c1;
	vInfo[vid][vColors][1] = c2;
	ChangeVehicleColor(vid, c1, c2);
	new str[144];
	format(str, 144, "Você mudou a cor 1 desse veículo para %i e a cor 2 para %i.", c1, c2);
	Info(playerid, str);
	new query[150];
	mysql_format(conn, query, 150, "UPDATE vehicleinfo SET color1 = %i, color2 = %i WHERE sqlid = %i", c1, c2, vInfo[vid][vSQL]);
	mysql_query(conn, query, false);
	return 1;
}

CMD:setgps(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new gps;
	if(sscanf(params, "i", gps)) return AdvertCMD(playerid, "/SetGPS [GPS]");
	new vid = GetPlayerVehicleID(playerid);
	if(!IsValidVehicle(vid)) return Advert(playerid, "Você precisa estar dentro de um veículo.");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	vInfo[vid][vGPS] = gps;
	new str[144];
	format(str, 144, "Você setou o GPS do veículo %03i para %i.", vid, gps);
	Info(playerid, str);
	new query[150];
	mysql_format(conn, query, 150, "UPDATE vehicleinfo SET gps = %i WHERE sqlid = %i", gps, vInfo[vid][vSQL]);
	mysql_query(conn, query, false);
	return 1;
}

CMD:deletarveiculo(playerid) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
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
	if(!IsValidVehicle(vid)) return 1;
	new a, b, c, d, e, f, g;
	GetVehicleParamsEx(vid, a, g, b, c, d, e, f);
	if(!vInfo[vid][vSQL]) {
		if(!vInfo[vid][vLights]) { vInfo[vid][vLights] = 1; } else { vInfo[vid][vLights] = 0; }
		SetVehicleParamsEx(vid, a, vInfo[vid][vLights], b, c, d, e, f);
	} else {
		if(g == 1) { g = 0; } else { g = 1; }
		SetVehicleParamsEx(vid, a, g, b, c, d, e, f);
	}
	return 1;
}

CMD:idv(playerid) {
	if(!bIDV[playerid]) {
		new str[10];
		for(new i = 0; i < MAX_VEHICLES; i++) {
			if(!vInfo[i][vSQL]) continue;
			format(str, 10, "IDV %i", i);
			IDV[playerid][i] = CreatePlayer3DTextLabel(playerid, str, -1, 0.0, 0.0, 0.0, 20.0, INVALID_PLAYER_ID, i, 1);
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
	new str[400] = "";
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(!vInfo[i][vSQL]) continue;
		if(vInfo[i][vChave] == pInfo[playerid][pSQL]) {
			format(str, 400, "%s\n• IDV %i - %s", str, i, vModels[GetVehicleModel(i)-400]);
		}
	}
	if(isnull(str)) return Advert(playerid, "Você não carrega nenhuma chave consigo.");
	format(str, 400, BRANCO"\tChaves:\n%s", str);
	Dialog_Show(playerid, "DialogNone", DIALOG_STYLE_MSGBOX, BRANCO"CHAVES", str, "Fechar", "");
	return 1;
}

CMD:repor(playerid) {
	new vid = GetPlayerVehicleID(playerid);
	if(!IsValidVehicle(vid)) return 1;
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	new i = 0;
	for(; i < 3; i++) {
		if(!vInfo[vid][vAttObj][i]) continue;
		for(new j = 0; j < MAX_VATTACHMENTS; j++) {
			if(vAttachments[j][vaSQL] == vInfo[vid][vAttObj][i]) {
				DestroyDynamicObject(vAttachments[j][vaID]);
				vAttachments[j][vaID] = CreateDynamicObject(vAttachments[j][vaModel], 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0);
				AttachDynamicObjectToVehicle(vAttachments[j][vaID], vid, vAttachments[j][vaP][0], vAttachments[j][vaP][1], vAttachments[j][vaP][2], vAttachments[j][vaR][0], vAttachments[j][vaR][1], vAttachments[j][vaR][2]);
				break;
			}
		}
	}
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

CMD:bootd(playerid, params[]) {
	if(pInfo[playerid][pAdmin] < Senior) return 1;
	new Float:D, model;
	if(sscanf(params, "if", model, D)) return AdvertCMD(playerid, "/BootD [modelo] [Distância do portamalas]");
	new str[144];
	format(str, 144, "Distância do portamalas do modelo '%s' definido para "AMARELO"%.2f"BRANCO".", vModels[model-400], D);
	Info(playerid, str);
	new query[150], Cache:result, rows;
	mysql_format(conn, query, 150, "SELECT `model` FROM `vehicledata` WHERE `model` = %i", model);
	result = mysql_query(conn, query, true);
	cache_get_row_count(rows);
	cache_delete(result);
	if(!rows) {
		mysql_format(conn, query, 150, "INSERT INTO `vehicledata` (`bootd`, `model`) VALUES (%.2f, %i)", D, model);
		mysql_query(conn, query, false);
	} else {
		mysql_format(conn, query, 150, "UPDATE `vehicledata` SET `bootd` = %.2f WHERE `model` = %i", D, model);
		mysql_query(conn, query, false);
	}
	vBootDist[model-400] = D;
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

CMD:portamalas(playerid, params[]) {
	new vid;
	if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/Portamalas [IDV]");
	if(!vInfo[vid][vSQL]) return Advert(playerid, "ID de veículo inválido.");
	if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você não tem chave desse veículo. Use "AMARELO"/Chaves"BRANCO".");
	new Float:P[6], Float:D, modelid = GetVehicleModel(vid), str[144];
	GetVehicleBootDistance(modelid, D);
	if(!D) return Advert(playerid, "Veículo sem portamalas. :P");
	GetVehiclePos(vid, P[0], P[1], P[2]);
	GetVehicleZAngle(vid, P[3]);
	GetXYInFrontOfXY(P[0], P[1], D, (P[3]+180.0), P[4], P[5]);
	if(!IsPlayerInRangeOfPoint(playerid, 1.5, P[4], P[5], P[2])) return Advert(playerid, "Você deve estar próximo ao portamalas do veículo.");
	if(vInfo[vid][vBoot]) { vInfo[vid][vBoot] = 0; } else { vInfo[vid][vBoot] = 1; }
	new a, b, c, d, e, f;
	GetVehicleParamsEx(vid, a, b, c, d, e, f, f);
	SetVehicleParamsEx(vid, a, b, c, d, e, vInfo[vid][vBoot], f);
	if(modelid == 609 || modelid == 482) {
		SetVehicleDoorState(vid, BR_DOOR, vInfo[vid][vBoot]);
		SetVehicleDoorState(vid, BL_DOOR, vInfo[vid][vBoot]);
	}
	format(str, 144, "%s o portamalas do seu veículo.", (vInfo[vid][vBoot] ? ("abriu") : ("fechou")));
	Act(playerid, str);
	return 1;
}

CMD:veridv(playerid) {
	new Float:D, Float:d = 100.0, Float:P[6], vid;
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(!IsValidVehicle(i)) continue;
		if(!vInfo[i][vSQL]) continue;
		GetVehiclePos(i, P[3], P[4], P[5]);
		D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
		if(D > 10.0) continue;
		if(D < d) {
			d = D;
			vid = i;
		}
	}
	if(d == 100.0) {
		Advert(playerid, "Você deve estar a pelo menos 10 metros do veículo para saber seu IDV.");
	} else {
		new str[144];
		format(str, 144, "O veículo mais próximo de você tem IDV %03i e modelo %s.", vid, vModels[GetVehicleModel(vid)-400]);
		Info(playerid, str);
	}
	return 1;
}

CMD:gasolina(playerid) {
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "É necessário estar conduzindo um veículo para isso.");
	new vid = GetPlayerVehicleID(playerid);
	if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado na base de dados.");
	new str[144];
	format(str, 144, "Status do tanque de gasolina: "AMARELO"%i/%iL", vInfo[vid][vGas], vGasCap[GetVehicleModel(vid)-400]);
	Info(playerid, str);
	return 1;
}

Dialog:GPSTransp(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new Float:GPSCoord[11][3] = {
		{237.7735,30.8647,2.1306},
		{204.3268,-207.1580,1.4392},
		{2339.0771,74.2452,26.3365},
		{1305.9254,368.0321,19.4163},
		{-146.1384,1202.9658,19.5319},
		{-187.4217,1203.2543,19.5396},
		{176.0676,-148.6380,1.4299},
		{1313.6764,321.9250,19.4061},
		{681.5193,-480.1891,16.1845},
		{-185.4162,1035.2633,19.5986},
		{677.0688,-635.1308,16.1905}
	};
	if(listitem == 11) { // Desligar GPS
		if(pInfo[playerid][pCP] == CP_GPS) {
			pInfo[playerid][pCP] = CP_NONE;
			DisablePlayerCheckpoint(playerid);
			Info(playerid, "GPS desligado.");
		} else {
			Advert(playerid, "Seu GPS não está ligado.");
		}
	} else {
		pInfo[playerid][pCP] = CP_GPS;
		SetPlayerCheckpoint(playerid, GPSCoord[listitem][0], GPSCoord[listitem][1], GPSCoord[listitem][2], 2.5);
		Info(playerid, "GPS habilitado.");
	}
	return 1;
}

Dialog:GPSPersonal(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new Float:GPSCoord[7][3] = {
		{2298.7888,-41.5417,26.3386},
		{2298.8108,-14.8488,26.3359},
		{237.5936,32.6788,2.4342},
		{316.4675,-67.1039,1.4305},
		{843.8165,-571.4354,16.3908},
		{612.1050,-490.4809,16.1889},
		{-1038.8312,-582.3068,31.9389}
	};
	if(listitem == 7) { // Desligar GPS
		if(pInfo[playerid][pCP] == CP_GPS) {
			pInfo[playerid][pCP] = CP_NONE;
			DisablePlayerCheckpoint(playerid);
			Info(playerid, "GPS desligado.");
		} else {
			Advert(playerid, "Seu GPS não está ligado.");
		}
	} else {
		pInfo[playerid][pCP] = CP_GPS;
		SetPlayerCheckpoint(playerid, GPSCoord[listitem][0], GPSCoord[listitem][1], GPSCoord[listitem][2], 2.5);
		Info(playerid, "GPS habilitado.");
	}
	return 1;
}

forward OnVehicleSpawn@veh(vehicleid);
public OnVehicleSpawn@veh(vehicleid) {
	if(vInfo[vehicleid][vSQL]) {
		SetVehiclePos(vehicleid, vInfo[vehicleid][vSpawn][0], vInfo[vehicleid][vSpawn][1], vInfo[vehicleid][vSpawn][2]);
		SetVehicleZAngle(vehicleid, vInfo[vehicleid][vSpawn][3]);
		vInfo[vehicleid][vLock] = 1;
		vInfo[vehicleid][vBoot] = 0;
		vInfo[vehicleid][vLights] = 0;
		SetVehicleParamsEx(vehicleid, 0, 0, 0, 1, 0, 0, 0);
	}
	return 1;
}

forward OnVehicleDeath@veh(vehicleid, killerid);
public OnVehicleDeath@veh(vehicleid, killerid) {
	if(vInfo[vehicleid][vSQL]) {
		vInfo[vehicleid][vLock] = 1;
		vInfo[vehicleid][vBoot] = 0;
		vInfo[vehicleid][vLights] = 0;
	}
	return 1;
}

forward OnPlayerEnterCheckpoint@veh(playerid);
public OnPlayerEnterCheckpoint@veh(playerid) {
	if(pInfo[playerid][pCP] == CP_GPS) {
		DisablePlayerCheckpoint(playerid);
		pInfo[playerid][pCP] = CP_NONE;
		return 1;
	}
	return 1;
}

forward Motor(vid, eng);
public Motor(vid, eng) {
	if(eng) {
		if(vInfo[vid][vSQL]) {
			if(vInfo[vid][vGas] <= 0) {
				new Float:P[3];
				GetVehiclePos(vid, P[0], P[1], P[2]);
				Amb(P[0], P[1], P[2], "Falha do motor ao ser ligado.");
				vInfo[vid][vGas] = 0;
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
		new m, Float:P[4], c1, c2, k, gps; // Necessário devido à variável v.
		cache_get_value_name_int(i, "model", m);
		cache_get_value_name_float(i, "sX", P[0]);
		cache_get_value_name_float(i, "sY", P[1]);
		cache_get_value_name_float(i, "sZ", P[2]);
		cache_get_value_name_float(i, "sA", P[3]);
		cache_get_value_name_int(i, "color1", c1);
		cache_get_value_name_int(i, "color2", c2);
		cache_get_value_name_int(i, "chave", k);
		cache_get_value_name_int(i, "gps", gps);
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
		vInfo[v][vGPS] = gps;
		format(vInfo[v][vOwner], 24, "%s", owner);
		cache_get_value_index_int(i, 0, vInfo[v][vSQL]);
		cache_get_value_name_int(i, "gas", vInfo[v][vGas]);
		SetVehicleParamsEx(v, 0, 0, 0, 1, 0, 0, 0);
		vInfo[v][vLock] = 1;
		vInfo[v][vBoot] = 0;
		vInfo[v][vLights] = 0;
		if(m == 408) { // Trashmaster
			new j = 0;
			for(; j < MAX_VATTACHMENTS; j++) {
				if(!vAttachments[j][vaSQL]) break;
			}
			if(j == MAX_VATTACHMENTS) continue;
			vAttachments[j][vaSQL] = j+1;
			vAttachments[j][vaModel] = 3280;
			vAttachments[j][vaID] = CreateDynamicObject(3280, 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0);
			vAttachments[j][vaP][0] = -0.54;
			vAttachments[j][vaP][1] = -4.1;
			vAttachments[j][vaP][2] = -1.06;
			vAttachments[j][vaR][0] = 0.0;
			vAttachments[j][vaR][1] = 0.0;
			vAttachments[j][vaR][2] = 0.0;
			vAttachments[j+1][vaSQL] = j+2;
			vAttachments[j+1][vaModel] = 3280;
			vAttachments[j+1][vaID] = CreateDynamicObject(3280, 0.0, 0.0, -1000.0, 0.0, 0.0, 0.0);
			vAttachments[j+1][vaP][0] = 0.51;
			vAttachments[j+1][vaP][1] = -4.1;
			vAttachments[j+1][vaP][2] = -1.06;
			vAttachments[j+1][vaR][0] = 0.0;
			vAttachments[j+1][vaR][1] = 0.0;
			vAttachments[j+1][vaR][2] = 0.0;
			AttachDynamicObjectToVehicle(vAttachments[j][vaID], v, vAttachments[j][vaP][0], vAttachments[j][vaP][1], vAttachments[j][vaP][2], vAttachments[j][vaR][0], vAttachments[j][vaR][1], vAttachments[j][vaR][2]);
			AttachDynamicObjectToVehicle(vAttachments[j+1][vaID], v, vAttachments[j+1][vaP][0], vAttachments[j+1][vaP][1], vAttachments[j+1][vaP][2], vAttachments[j+1][vaR][0], vAttachments[j+1][vaR][1], vAttachments[j+1][vaR][2]);
			vInfo[v][vAttObj][0] = j+1;
			vInfo[v][vAttObj][1] = j+2;
		}
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
		cache_get_value_name_float(i, "bootd", vBootDist[m]);
	}
	return 1;
}

forward OnGameModeInit@vehicle();
public OnGameModeInit@vehicle() {
	mysql_tquery(conn, "SELECT * FROM `vehicleinfo`", "LoadVehicleData");
	mysql_tquery(conn, "SELECT * FROM `vehicledata`", "LoadVehicleParams");
	return 1;
}

forward OnGameModeExit@vehicle();
public OnGameModeExit@vehicle() {
	new query[120];
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(vInfo[i][vSQL] <= 0) continue;
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
		new a, b, c, d, e, f, g, v = GetPlayerVehicleID(playerid);
		GetVehicleParamsEx(v, a, b, c, d, e, f, g);
		SetVehicleParamsEx(v, a, b, c, d, e, f, g);
		for(new i = 0; i < sizeof(TDGas); i++) {
			TextDrawShowForPlayer(playerid, TDGas[i]);
		}
		new str[30], vid = GetPlayerVehicleID(playerid), Float:V[4];
		format(str, 30, "~w~%i~b~/~w~%i~y~L", vInfo[vid][vGas], vGasCap[GetVehicleModel(vid)-400]);
		PlayerTextDrawSetString(playerid, TDGasolina[playerid], str);
		PlayerTextDrawShow(playerid, TDGasolina[playerid]);
		GetVehicleVelocity(vid, V[0], V[1], V[2]);
		V[3] = floatsqroot(floatpower(V[0], 2) + floatpower(V[1], 2) + floatpower(V[2], 2));
		V[3] *= 162.7;
		format(str, 30, "~w~%.0f~y~Km/h", V[3]);
		PlayerTextDrawSetString(playerid, TDVelocidade[playerid], str);
		PlayerTextDrawShow(playerid, TDVelocidade[playerid]);
		TVelocimetro[playerid] = SetTimerEx("Velocimetro", 250, true, "i", playerid);
	} else if(oldstate == PLAYER_STATE_DRIVER) {
		for(new i = 0; i < sizeof(TDGas); i++) {
			TextDrawHideForPlayer(playerid, TDGas[i]);
		}
		PlayerTextDrawHide(playerid, TDGasolina[playerid]);
		PlayerTextDrawHide(playerid, TDVelocidade[playerid]);
		if(pInfo[playerid][pCP] == CP_GPS) {
			DisablePlayerCheckpoint(playerid);
			pInfo[playerid][pCP] = CP_NONE;
		}
	}
	return 1;
}

forward Velocimetro(playerid);
public Velocimetro(playerid) {
	new vid = GetPlayerVehicleID(playerid);
	if(!vid) { KillTimer(TVelocimetro[playerid]); TVelocimetro[playerid] = 0; }
	new Float:V[4], str[30];
	GetVehicleVelocity(vid, V[0], V[1], V[2]);
	V[3] = floatsqroot(floatpower(V[0], 2) + floatpower(V[1], 2) + floatpower(V[2], 2));
	V[3] *= 162.7;
	format(str, 30, "~w~%.0f~y~Km/h", V[3]);
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
			format(str, 30, "~w~%i~b~/~w~%i~y~L", vInfo[vehicleid][vGas], vGasCap[GetVehicleModel(vid)-400]);
			PlayerTextDrawSetString(i, TDGasolina[i], str);
			break;
		}
	}
	if(vInfo[vehicleid][vGas] <= 0) {
		KillTimer(TGasolimetro[vehicleid]);
		TGasolimetro[vehicleid] = 0;
		Motor(vehicleid, 0);
	}
	return 1;
}

stock GetVehicleIDBySQL(sqlid) {
	new i;
	for(; i < MAX_VEHICLES; i++) {
		if(!IsValidVehicle(i)) continue;
		if(vInfo[i][vSQL] == sqlid) return i;
	}
	if(i == MAX_VEHICLES) return 0;
	return 0;
}

stock SetVehicleInterior(vehicleid, interiorid) {
	if(!IsValidVehicle(vehicleid)) return 0;
	vinteriorid[vehicleid] = interiorid;
	return LinkVehicleToInterior(vehicleid, interiorid);
}

stock GetVehicleInterior(vehicleid) {
	if(!IsValidVehicle(vehicleid)) return 0;
	return vinteriorid[vehicleid];
}

stock GetModelIDFromModelName(const name[]) {
	if(isnull(name)) return 0;
	for(new i = 0; i < 212; i++) {
		if(!strcmp(vModels[i], name, true)) return (i+400);
	}
	return 0;
}

stock GetPlayerIDVehicleSeat(vehicleid, seatid) {
	if(!IsValidVehicle(vehicleid)) return -1;
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

stock GetVehicleBootDistance(modelid, &Float:D) {
	if(modelid < 400 || modelid > 611) return 0;
	D = vBootDist[modelid-400];
	if(!D) return 0;
	else return 1;
}

stock GetVehicleBootSlots(modelid) {
	if(modelid == 609) return 6;
	if(modelid == 482) return 4;
	return 0;
}