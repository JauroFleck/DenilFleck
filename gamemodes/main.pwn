// DenilFleck Roleplay

#include <	a_samp		>
#include <	zcmd		>
#include <	sscanf2		>
#include <	easyDialog	>
#include < 	a_mysql		>
#include <	colors 		>
#include < 	streamer 	>

#define GameMode

#undef MAX_PLAYERS
#define MAX_PLAYERS 50
#undef MAX_VEHICLES
#define MAX_VEHICLES 200

#define SKIN_BEGINNER			35

#define ACTION_RANGE			(15.0)

#define CP_NONE					0
#define CP_BUS_ROUTE			1

#define Player 					0
#define Ajudante				1
#define Fiscalizador			2
#define Administrador			3
#define Senior 					4
#define Fundador				5

main() {}

native IsValidVehicle(vehicleid);

enum VSTAFF_INFO {
	vsID,
	vsPSQL,
	vsModel,
	vsColor[2],
	Float:vsSpawn[4],
	vsVW,
	vsInterior
};

new vStaff[MAX_PLAYERS][VSTAFF_INFO];

enum PLAYER_INFO {
	pSQL,
	pBus,
	pCP,
	pSpawnado,
	pLogged,
	pAdmin,
	pSkin,
	pUSECMD_motor
};

new pInfo[MAX_PLAYERS][PLAYER_INFO];

// TextDraws

new Text:TDLogin[2];
new Text:TDGas[3];
new PlayerText:TDGasolina[MAX_PLAYERS];
new PlayerText:TDVelocidade[MAX_PLAYERS];

// Systems

#include "../systems/sql.pwn"
#include "../systems/time.pwn"
#include "../systems/vehicle.pwn"
#include "../systems/admin.pwn"
#include "../systems/business.pwn"
#include "../systems/bus.pwn"
#include "../systems/postodegasolina.pwn"
#include "../systems/refinaria.pwn"

stock ResetVars(playerid) {
	pInfo[playerid][pSQL] = 0;
	pInfo[playerid][pBus] = -1;
	pInfo[playerid][pSpawnado] = 0;
	pInfo[playerid][pLogged] = 0;
	pInfo[playerid][pAdmin] = 0;
	bIDV[playerid] = 0;
	sbBombaMG[playerid] = 0;
	return 1;
}

//

CMD:dardinheiro(playerid, params[]) {
	new id, mon;
	if(sscanf(params, "ii", id, mon)) return AdvertCMD(playerid, "/DarDinheiro [ID] [Dinheiro]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player desconectado.");
	if(mon < 1 || mon > GetPlayerMoney(playerid)) return Advert(playerid, "Quantia inválida de dinheiro.");
	new Float:P[3];
	GetPlayerPos(id, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, P[0], P[1], P[2])) return Advert(playerid, "Você deve estar próximo a quem deseja entregar o dinheiro.");
	GivePlayerMoney(playerid, -mon);
	GivePlayerMoney(id, mon);
	new str[144];
	format(str, 144, "%s te entregou $%i.", pName(playerid), mon);
	Success(id, str);
	format(str, 144, "retirou dinheiro da carteira e entregou para %s.", pName(id));
	Act(playerid, str);
	return 1;
}

CMD:entrar(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 214.2, -155.5, 1.6)) return SetPlayerPos(playerid, 212.9, -155.5, 1.7);
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 210.2, -151.4, 1.6)) return SetPlayerPos(playerid, 210.2, -152.7, 1.7);
	for(new i = 0; i < MAX_BUSINESS; i++) { // É necessário passar pelas empresas para setar o VirtualWorld
		if(!bInfo[i][bSQL]) continue;
		for(new j = 0; j < MAX_ENTRADAS; j++) {
			if(!bInfo[i][bEntradas][j]) continue;
			if(IsPlayerInRangeOfPoint(playerid, 2.5, eInfo[i][j][eP][0], eInfo[i][j][eP][1], eInfo[i][j][eP][2])) {
				SetPlayerPos(playerid, eInfo[i][j][sP][0], eInfo[i][j][sP][1], eInfo[i][j][sP][2]);
				SetPlayerFacingAngle(playerid, eInfo[i][j][sP][3]);
				SetPlayerInterior(playerid, eInfo[i][j][sInt]);
				SetPlayerVirtualWorld(playerid, i);
				Streamer_UpdateEx(playerid, eInfo[i][j][sP][0], eInfo[i][j][sP][1], eInfo[i][j][sP][2], i, eInfo[i][j][sInt]);
				return 1;
			}
		}
	}
	return 1;
}

CMD:sair(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 212.9, -155.5, 1.7)) return SetPlayerPos(playerid, 214.2, -155.5, 1.6);
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 210.2, -152.7, 1.7)) return SetPlayerPos(playerid, 210.2, -151.4, 1.6);
	new i = GetPlayerVirtualWorld(playerid);
	if(bInfo[i][bSQL]) {
		for(new j = 0; j < MAX_ENTRADAS; j++) {
			if(!bInfo[i][bEntradas][j]) continue;
			if(IsPlayerInRangeOfPoint(playerid, 2.5, eInfo[i][j][sP][0], eInfo[i][j][sP][1], eInfo[i][j][sP][2])) {
				SetPlayerPos(playerid, eInfo[i][j][eP][0], eInfo[i][j][eP][1], eInfo[i][j][eP][2]);
				SetPlayerFacingAngle(playerid, eInfo[i][j][eP][3]);
				SetPlayerInterior(playerid, 0);
				SetPlayerVirtualWorld(playerid, 0);
				Streamer_UpdateEx(playerid, eInfo[i][j][eP][0], eInfo[i][j][eP][1], eInfo[i][j][eP][2], 0, 0);
				return 1;
			}
		}
	}
	return 1;
}

CMD:me(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/Me [Ação]");
	Act(playerid, params);
	return 1;
}

CMD:do(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/Do [Ação]");
	new str[144], Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 144, "%s (( %s ))", params, pName(playerid));
	Amb(P[0], P[1], P[2], str);
	return 1;
}

CMD:gps(playerid) {
	static gps[MAX_PLAYERS];
	if(!gps[playerid]) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFFFF);
			Info(playerid, "GPS ligado.");
		}
		gps[playerid] = 1;
	} else {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
			Info(playerid, "GPS desligado.");
		}
		gps[playerid] = 0;
	}
	return 1;
}

CMD:box(playerid) {
	SetPlayerFightingStyle(playerid, 5);
	return 1;
}

CMD:kungfu(playerid) {
	SetPlayerFightingStyle(playerid, 6);
	return 1;
}

CMD:joelhada(playerid) {
	SetPlayerFightingStyle(playerid, 7);
	return 1;
}

CMD:padrao(playerid) {
	SetPlayerFightingStyle(playerid, 15);
	return 1;
}

CMD:cotovelada(playerid) {
	SetPlayerFightingStyle(playerid, 16);
	return 1;
}

Dialog:DialogRegister(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Advert(playerid, "Você cancelou o cadastramento de sua conta e não poderá prosseguir para o servidor.");
		KickPlayer(playerid);
		return 1;
	}
	if(strlen(inputtext) < 6 || strlen(inputtext) > 20) {
		Advert(playerid, "A senha deve conter entre 6 e 20 dígitos.");
		new str[300];
		format(str, 300, BRANCO"%s, seja bem-vindo ao servidor DenilFleck Roleplay.\nPodemos verificar em nosso banco de dados que é a primeira vez que você aparece por aqui.\nPara continuar, precisamos que você crie uma conta, começando pela senha.\n\nAbaixo, cadastre uma senha para sua conta.", pNick(playerid));
		Dialog_Show(playerid, "DialogRegister", DIALOG_STYLE_INPUT, "REGISTRE-SE", str, "Cadastrar", "Cancelar");
		return 1;
	}
	LimparChat(playerid);
	Success(playerid, "Cadastrado com sucesso!");
	Info(playerid, "Somos um servidor em desenvolvimento, atualmente na versão "CIANO"ALFA"BRANCO".");
	Info(playerid, "Quaisquer erros notados, por favor, reportem para a administração por meio do "AMARELO"/Ajuda"BRANCO".");
	Info(playerid, "Além disso, bom divertimento, e lembre-se: "AZUL"o roleplay é soberano!");
	new query[150];
	mysql_format(conn, query, 150, "INSERT INTO `playerinfo` (`nickname`, `senha`) VALUES ('%s', '%s')", pNick(playerid), inputtext);
	mysql_tquery(conn, query, "PlayerRegister", "i", playerid);
	pInfo[playerid][pLogged] = 2;
	return 1;
}

Dialog:DialogLogin(playerid, response, listitem, inputtext[]) {
	if(!response) {
		Advert(playerid, "Você cancelou o login de sua conta e não poderá prosseguir para o servidor.");
		KickPlayer(playerid);
		return 1;
	}
	new query[150], Cache:result, senha[21];
	mysql_format(conn, query, 150, "SELECT `senha` FROM `playerinfo` WHERE `sqlid` = %i", pInfo[playerid][pSQL]);
	result = mysql_query(conn, query);
	cache_get_value_name(0, "senha", senha);
	cache_delete(result);
	static TentativasLogin[MAX_PLAYERS];
	if(!strcmp(senha, inputtext, false) && !isnull(inputtext)) {
		TentativasLogin[playerid] = 0;
		LimparChat(playerid);
		Success(playerid, "Logado com sucesso!");
		Info(playerid, "Somos um servidor em desenvolvimento, atualmente na versão "CIANO"ALFA"BRANCO".");
		Info(playerid, "Quaisquer erros notados, por favor, reportem para a administração por meio do "AMARELO"/Ajuda"BRANCO".");
		Info(playerid, "Além disso, bom divertimento, e lembre-se: "AZUL"o roleplay é soberano!");
		mysql_format(conn, query, 90, "SELECT * FROM `playerinfo` WHERE `sqlid` = %i", pInfo[playerid][pSQL]);
		mysql_tquery(conn, query, "LoadPlayerData", "i", playerid);
		pInfo[playerid][pLogged] = 2;
	} else {
		TentativasLogin[playerid]++;
		new str[300];
		format(str, 144, "Senha incorreta/inválida.          "LARANJAAVERMELHADO"(%i/3)", TentativasLogin[playerid]);
		Advert(playerid, str);
		if(TentativasLogin[playerid] == 3) {
			TentativasLogin[playerid] = 0;
			Advert(playerid, "Você foi expulso do servidor por excesso de tentativas de login.");
			KickPlayer(playerid);
		} else {
			format(str, 300, BRANCO"%s, seja bem-vindo novamente ao servidor DenilFleck Roleplay.\nPodemos verificar em nosso banco de dados que esta conta já é cadastrada por aqui.\n\nAbaixo, insira a senha já cadastrada para sua conta.", pNick(playerid));
			Dialog_Show(playerid, "DialogLogin", DIALOG_STYLE_PASSWORD, "LOGIN", str, "Entrar", "Cancelar");
		}
	}
	return 1;
}

public OnGameModeInit() {

	CallLocalFunction("OnGameModeInit@sql", "");
	CallLocalFunction("OnGameModeInit@vehicle", "");
	CallLocalFunction("OnGameModeInit@time", "");
	CallLocalFunction("OnGameModeInit@business", "");
	CallLocalFunction("OnGameModeInit@bus", "");
	CallLocalFunction("OnGameModeInit@posto", "");
	CallLocalFunction("OnGameModeInit@refinaria", "");

	// MAPAS

	print("Carregando mapas...");
	#include "../maps/bus.pwn"
	#include "../maps/newbiespawn.pwn"
	#include "../maps/postodegasolina.pwn"
	#include "../maps/refinaria.pwn"
	print("Mapas carregados com sucesso.");

	// TEXTDRAWS

	#include "../textdraws/login.pwn"
	#include "../textdraws/gas.pwn"

	//

	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	SetGameModeText("[DF:RP] PT-BR (vBeta)");

	EnableStuntBonusForAll(0);
	ShowNameTags(0);

	return 1;
}

public OnGameModeExit() {
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		else { SavePlayerData(i); }
	}
	CallLocalFunction("OnGameModeExit@refinaria", "");
	CallLocalFunction("OnGameModeExit@time", "");
	CallLocalFunction("OnGameModeExit@vehicle", "");
	CallLocalFunction("OnGameModeExit@sql", "");
	return 1;
}

public OnPlayerConnect(playerid) {
	new Name[24], k;
	GetPlayerName(playerid, Name, 24);
	for(new i = 0; i < 24; i++) { if(Name[i] == '_') { k++; } }
	if(k != 1) {
		LimparChat(playerid);
		Advert(playerid, "Seu nickname não está no padrão exigido pelo servidor.");
		Info(playerid, "Entre novamente no servidor com um nickname no formato "CINZAAZULADO"Nome_Sobrenome"BRANCO".");
		KickPlayer(playerid);
		return 1;
	}
	ResetVars(playerid);
	CallLocalFunction("OnPlayerConnect@refinaria", "i", playerid);
	CallLocalFunction("OnPlayerConnect@bus", "i", playerid);
	#include "../textdraws/pgas.pwn"
	SetTimerEx("SpawnarPlayer", 200, false, "i", playerid);

	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
	}

	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	CallLocalFunction("OnPlayerEnterVehicle@admin", "iii", playerid, vehicleid, ispassenger);
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	CallLocalFunction("OnPlayerDisconnect@bus", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@admin", "i", playerid);
	SavePlayerData(playerid);
	ResetVars(playerid);
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(pInfo[playerid][pLogged] == 2) {
		for(new i = 0; i < sizeof(TDLogin); i++) { TextDrawHideForPlayer(playerid, TDLogin[i]); }
		StopAudioStreamForPlayer(playerid);
		SetPlayerVirtualWorld(playerid, 0);
		pInfo[playerid][pLogged] = 1;
		return 1;
	}
	if(!pInfo[playerid][pLogged]) {
		pInfo[playerid][pSpawnado] = 1;
		TogglePlayerSpectating(playerid, 1);
		SetPlayerPos(playerid, 255.2, -163.7, 1.6);
		SetPlayerCameraPos(playerid, 472.9, -156.9, 42.7);
		SetPlayerCameraLookAt(playerid, 380.4, -143.4, 7.4);
		InterpolateCameraPos(playerid, 472.9, -156.9, 42.7, 405.5, -241.6, 61.6, 60000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid, 380.4, -143.4, 7.4, 318.4, -198.2, 38.5, 60000, CAMERA_MOVE);
		SetPlayerVirtualWorld(playerid, 1);
		SetPlayerColor(playerid, 0xFFFFFFFF);
		PlayAudioStreamForPlayer(playerid, "http://atentivo.com.br/login-music.mp3");
		LimparChat(playerid);
		for(new i = 0; i < sizeof(TDLogin); i++) { TextDrawShowForPlayer(playerid, TDLogin[i]); }
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			SetPlayerMarkerForPlayer(i, playerid, 0xFFFFFF00);
		}
		new query[90], rows;
		mysql_format(conn, query, 90, "SELECT `sqlid` FROM `playerinfo` WHERE `nickname` = '%s'", pNick(playerid));
		new Cache:result = mysql_query(conn, query);
		cache_get_row_count(rows);
		if(rows) { cache_get_value_index_int(0, 0, pInfo[playerid][pSQL]); } else { pInfo[playerid][pSQL] = 0; }
		cache_delete(result);
		if(!pInfo[playerid][pSQL]) { // Iniciante
			new str[300];
			format(str, 300, BRANCO"%s, seja bem-vindo ao servidor DenilFleck Roleplay.\nPodemos verificar em nosso banco de dados que é a primeira vez que você aparece por aqui.\nPara continuar, precisamos que você crie uma conta, começando pela senha.\n\nAbaixo, cadastre uma senha para sua conta.", pNick(playerid));
			Dialog_Show(playerid, "DialogRegister", DIALOG_STYLE_INPUT, "REGISTRE-SE", str, "Cadastrar", "Cancelar");
		} else {
			new str[300];
			format(str, 300, BRANCO"%s, seja bem-vindo novamente ao servidor DenilFleck Roleplay.\nPodemos verificar em nosso banco de dados que esta conta já é cadastrada por aqui.\n\nAbaixo, insira a senha já cadastrada para sua conta.", pNick(playerid));
			Dialog_Show(playerid, "DialogLogin", DIALOG_STYLE_PASSWORD, "LOGIN", str, "Entrar", "Cancelar");
		}
	} else {
		SetPlayerPos(playerid, 1241.8, 327, 19.8);
		SetPlayerFacingAngle(playerid, 25);
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		SendClientMessage(playerid, -1, "Teletransportado temporariamente para o \"hospital\" local.");
	}
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	CallLocalFunction("OnPlayerStateChange@vehicle", "iii", playerid, newstate, oldstate);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	CallLocalFunction("OnPlayerEnterCheckpoint@bus", "i", playerid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	CallLocalFunction("OnPlayerKeyStateChange@vehicle", "iii", playerid, newkeys, oldkeys);
	return 1;
}

forward SpawnarPlayer(playerid);
public SpawnarPlayer(playerid) {
	if(!pInfo[playerid][pSpawnado]) { SpawnPlayer(playerid); SetTimerEx("SpawnarPlayer", 200, false, "i", playerid); }
	return 1;
}

forward PlayerRegister(playerid);
public PlayerRegister(playerid) {
	TogglePlayerSpectating(playerid, 0);
	SetPlayerPos(playerid, 218.2, -153.5, 1.6);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerSkin(playerid, SKIN_BEGINNER);
	pInfo[playerid][pLogged] = 2;
	pInfo[playerid][pSQL] = cache_insert_id();
	printf("Novo player registrado: %s [SQLID: %i]", pNick(playerid), pInfo[playerid][pSQL]);
	return 1;
}

forward LoadPlayerData(playerid);
public LoadPlayerData(playerid) {
	TogglePlayerSpectating(playerid, 0);
	pInfo[playerid][pLogged] = 2;
	new score, money, skinid, Float:P[4], interiorid, vw;
	cache_get_value_name_int(0, "pbus", pInfo[playerid][pBus]);
	cache_get_value_name_int(0, "score", score);
	cache_get_value_name_int(0, "money", money);
	cache_get_value_name_int(0, "skinid", skinid);
	cache_get_value_name_int(0, "admin", pInfo[playerid][pAdmin]);
	cache_get_value_name_float(0, "sX", P[0]);
	cache_get_value_name_float(0, "sY", P[1]);
	cache_get_value_name_float(0, "sZ", P[2]);
	cache_get_value_name_float(0, "sA", P[3]);
	cache_get_value_name_int(0, "idv", bIDV[playerid]);
	cache_get_value_name_int(0, "interior", interiorid);
	cache_get_value_name_int(0, "vw", vw);
	SetPlayerScore(playerid, score);
	GivePlayerMoney(playerid, money);
	SetPlayerSkin(playerid, skinid);
	SetPlayerPos(playerid, P[0], P[1], P[2]);
	SetPlayerFacingAngle(playerid, P[3]);
	SetPlayerInterior(playerid, interiorid);
	SetPlayerVirtualWorld(playerid, vw);
	Streamer_UpdateEx(playerid, P[0], P[1], P[2]);
	if(pInfo[playerid][pAdmin] >= Fiscalizador) {
		new query[150];
		mysql_format(conn, query, 150, "SELECT * FROM vstaffinfo WHERE psqlid = %i", pInfo[playerid][pSQL]);
		mysql_tquery(conn, query, "LoadvStaff", "i", playerid);
	}
	if(bIDV[playerid]) {
		bIDV[playerid] = 0;
		cmd_idv(playerid);
	}
	return 1;
}

forward TKickPlayer(playerid);
public TKickPlayer(playerid) return Kick(playerid);

stock SavePlayerData(playerid) {
	new Float:P[4];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[3]);
	new query[300];
	mysql_format(conn, query, 300, "UPDATE `playerinfo` SET `interior` = %i, `vw` = %i, `idv` = %i, `admin` = %i, `score` = %i, `skinid` = %i, `money` = %i, `pbus` = %i, `sX` = %f, `sY` = %f, `sZ` = %f, `sA` = %f WHERE `sqlid` = %i",
		GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), bIDV[playerid], pInfo[playerid][pAdmin], GetPlayerScore(playerid), GetPlayerSkin(playerid), GetPlayerMoney(playerid), pInfo[playerid][pBus], P[0], P[1], P[2], P[3], pInfo[playerid][pSQL]);
	mysql_query(conn, query, false);
	if(pInfo[playerid][pAdmin] >= Fiscalizador) {
		if(vStaff[playerid][vsID]) {
			mysql_format(conn, query, 300, "UPDATE `vstaffinfo` SET `model` = %i, `color1` = %i, `color2` = %i, `sX` = %f, `sY` = %f, `sZ` = %f, `sA` = %f, `vw` = %i, `i` = %i WHERE `psqlid` = %i",
				vStaff[playerid][vsModel], vStaff[playerid][vsColor][0], vStaff[playerid][vsColor][1], vStaff[playerid][vsSpawn][0], vStaff[playerid][vsSpawn][1], vStaff[playerid][vsSpawn][2], vStaff[playerid][vsSpawn][3], vStaff[playerid][vsVW], vStaff[playerid][vsInterior], pInfo[playerid][pSQL]);
			mysql_query(conn, query, false);
		} else {
			mysql_format(conn, query, 300, "UPDATE `vstaffinfo` SET `model` = 0 WHERE `psqlid` = %i", pInfo[playerid][pSQL]);
			mysql_query(conn, query, false);
		}
	}
	return 1;
}

stock pNick(playerid) {
	new Name[24];
	GetPlayerName(playerid, Name, 24);
	return Name;
}

stock pName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, 24);
	for(new i = 0; i < 24; i++) { if(name[i] == '_') { name[i] = ' '; } }
	return name;
}

stock GetPlayerIDByNickname(nickname[24]) {
	new k = MAX_PLAYERS;
	while(k > -1) {
		if(IsPlayerConnected(k)) {
			if(!strcmp(pNick(k), nickname, true)) break;
		}
		k--;
	}
	return k;
}

stock IsVehicleInRangeOfPoint(vehicleid, Float:range, Float:x, Float:y, Float:z) {
    if(!GetVehicleModel(vehicleid)) return 0;
    new Float:D = GetVehicleDistanceFromPoint(vehicleid, x, y, z);
    if(D <= range) return 1;
    return 0;
}

stock LimparChat(playerid) {
	for(new i = 0; i < 20; i++)
		SendClientMessage(playerid, 0, "");
	return 1;
}

stock Advert(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}%s", msg);
	SendClientMessage(playerid, Vermelho, str);
	return 1;
}

stock AdvertCMD(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}Use {FFFF00}%s{FFFFFF}.", msg);
	SendClientMessage(playerid, Vermelho, str);
	return 1;
}

stock Info(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}%s", msg);
	SendClientMessage(playerid, Amarelo, str);
	return 1;
}

stock Success(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}%s", msg);
	SendClientMessage(playerid, Verde, str);
	return 1;
}

stock Act(playerid, const msg[]) {
	new Float:P[3], str[144];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 144, "* %s %s", pName(playerid), msg);
	SendRangedMessage(CinzaAzulado, str, ACTION_RANGE, P[0], P[1], P[2]);
	return 1;
}

stock Amb(Float:X, Float:Y, Float:Z, const msg[]) {
	new str[144];
	format(str, 144, "* %s", msg);
	SendRangedMessage(CinzaAzulado, str, ACTION_RANGE, X, Y, Z);
	return 1;
}

stock SendRangedMessage(color, const msg[], Float:range, Float:X, Float:Y, Float:Z) {
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(!IsPlayerInRangeOfPoint(i, range, X, Y, Z)) continue;
		SendClientMessage(i, color, msg);
	}
	return 1;
}

stock KickPlayer(playerid) {
	SetTimerEx("TKickPlayer", 100, false, "i", playerid);
	return 1;
}

stock GetXYInFrontOfXY(Float:X, Float:Y, Float:D, Float:A, &Float:dX, &Float:dY) {
	dX = X + D*floatsin(-A, degrees);
	dY = Y + D*floatcos(-A, degrees);
	return 1;
}

stock GetXYInFrontOfPlayer(playerid, Float:D, &Float:dX, &Float:dY) {
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[2]);
	GetXYInFrontOfXY(P[0], P[1], D, P[2], dX, dY);
	return 1;
}

stock GetXYInFrontOfVehicle(vehicleid, Float:D, &Float:dX, &Float:dY) {
	new Float:P[3];
	GetVehiclePos(vehicleid, P[0], P[1], P[2]);
	GetVehicleZAngle(vehicleid, P[2]);
	GetXYInFrontOfXY(P[0], P[1], D, P[2], dX, dY);
	return 1;
}