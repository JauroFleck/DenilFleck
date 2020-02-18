/*														DENILFLECK ROLEPLAY vBETA



													JAMAIS ESQUEÇA DE EFETUAR BACKUPS
														DO SERVIDOR E DA DATABASE




			INFORMAÇÕES IMPORTANTES
	- Fórmula para TOTAL de experiência conforme o nível: T(n) = (n³/6 + n²/2 + n/3)*100
	- Fórmula para experiência de CADA nível: F(n) = (n²+n)*50
	- Virtual Worlds: 0 - Mundo RP | 0 ~ MAX_BUSINESS-1 - Empresas | MAX_BUSINESS ~ MAX_BUSINESS+MAX_HOUSES-1 - Casas

			LEMBRETES
	- Setar > Casas, veículos e parâmetros de player (armor, score, BRL)
	- Sistema veicular (Ao deixar veículo ligado, chave fica na ignição)
	- GPS no celular (Ao invés de Waze, Wize)
	- Sotaques na fala
	- /Inventario
	- /Punir (FIS) + /Despunir
	- Sistema de organizações - RCSD
																																		*/

#include <	a_samp		>
#include <	zcmd		>
#include <	sscanf2		>
#include <	easyDialog	>
#include < 	a_mysql		>
#include <	colors 		>
#include < 	streamer 	>
#include <	windosi		>

#define GameMode

#undef 	MAX_PLAYERS
#define MAX_PLAYERS 100
#undef 	MAX_VEHICLES
#define MAX_VEHICLES 200

#define MAX_BUSINESS			15
#define MAX_CARGOS				10 		// Lembre-se de mudar no banco de dados.
#define MAX_PRODUTOS			10		// 					"
#define MAX_BUSINESS_VEHICLES	10		// 					"
#define MAX_ENTRADAS			3		//					"

#define SKIN_BEGINNER			35

#define ACTION_RANGE			(15.0)

#define CP_NONE					0
#define CP_BUS_ROUTE			1
#define CP_AVAUTO				2
#define CP_GPS 					3
#define CP_REFINARIA			4
#define CP_TRASHMASTER			5
#define CP_GARBAGE				6

#define Player  				0
#define Plantonista				1
#define Ajudante				2
#define Fiscalizador			3
#define Administrador			4
#define Senior 					5
#define Fundador				6

main() {}

native IsValidVehicle(vehicleid);

enum BUSINESS_INFO {
	bSQL,
	bOwner[24],
	bName[40],
	bValue,
	bReceita,
	bVehicles[MAX_BUSINESS_VEHICLES],
	bCargos[MAX_CARGOS],
	bProdutos[MAX_PRODUTOS],
	bEntradas[MAX_ENTRADAS],
	bType,
	bCaixa,
	Float:bcP[3],
	bTrancas[3]
};

new bInfo[MAX_BUSINESS][BUSINESS_INFO];

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
	pUSECMD_motor,
	pUSECMD_anim,
	pXP,
	pLevel,
	pAtd,
	pDuty,
	pAnim,
	pComprovante,
	pTDSelect,
	pDialogParam[3],
	pHab,
	Float:pVoltar[3],
	pVoltarInt,
	pVoltarVW,
	pSpec,
	ptPrisao,
	pMon,
	pHUD,
	pPapo,
	pMoney,
	pOrg,
	pMP
	//pFinishedDownload
};

new pInfo[MAX_PLAYERS][PLAYER_INFO];

#define MAX_ATENDIMENTOS		5

new SolAtd[MAX_ATENDIMENTOS];

static const AnimsEnum[][] = {
    "AIRPORT",      "Attractors",   "BAR",          "BASEBALL",     "BD_FIRE",
    "BEACH",        "benchpress",   "BF_injection", "BIKED",        "BIKEH",
    "BIKELEAP",     "BIKES",        "BIKEV",        "BIKE_DBZ",     "BLOWJOBZ",
    "BMX",          "BOMBER",       "BOX",          "BSKTBALL",     "BUDDY",
    "BUS",          "CAMERA",       "CAR",          "CARRY",        "CAR_CHAT",
    "CASINO",       "CHAINSAW",     "CHOPPA",       "CLOTHES",      "COACH",
    "COLT45",       "COP_AMBIENT",  "COP_DVBYZ",    "CRACK",        "CRIB",
    "DAM_JUMP",     "DANCING",      "DEALER",       "DILDO",        "DODGE",
    "DOZER",        "DRIVEBYS",     "FAT",          "FIGHT_B",      "FIGHT_C",
    "FIGHT_D",      "FIGHT_E",      "FINALE",       "FINALE2",      "FLAME",
    "Flowers",      "FOOD",         "Freeweights",  "GANGS",        "GHANDS",
    "GHETTO_DB",    "goggles",      "GRAFFITI",     "GRAVEYARD",    "GRENADE",
    "GYMNASIUM",    "HAIRCUTS",     "HEIST9",       "INT_HOUSE",    "INT_OFFICE",
    "INT_SHOP",     "JST_BUISNESS", "KART",         "KISSING",      "KNIFE",
    "LAPDAN1",      "LAPDAN2",      "LAPDAN3",      "LOWRIDER",     "MD_CHASE",
    "MD_END",       "MEDIC",        "MISC",         "MTB",          "MUSCULAR",
    "NEVADA",       "ON_LOOKERS",   "OTB",          "PARACHUTE",    "PARK",
    "PAULNMAC",     "ped",          "PLAYER_DVBYS", "PLAYIDLES",    "POLICE",
    "POOL",         "POOR",         "PYTHON",       "QUAD",         "QUAD_DBZ",
    "RAPPING",      "RIFLE",        "RIOT",         "ROB_BANK",     "ROCKET",
    "RUSTLER",      "RYDER",        "SCRATCHING",   "SHAMAL",       "SHOP",
    "SHOTGUN",      "SILENCED",     "SKATE",        "SMOKING",      "SNIPER",
    "SPRAYCAN",     "STRIP",        "SUNBATHE",     "SWAT",         "SWEET",
    "SWIM",         "SWORD",        "TANK",         "TATTOOS",      "TEC",
    "TRAIN",        "TRUCK",        "UZI",          "VAN",          "VENDING",
    "VORTEX",       "WAYFARER",     "WEAPONS",      "WUZI"
};

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// TEXTDRAWS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

new Text:TDLogin;
new Text:TDGas[4];
new Text:TDManager[29];
new Text:TDBarra[15];
new PlayerText:TDName[MAX_PLAYERS];
new PlayerText:TDScore[MAX_PLAYERS];
new PlayerText:TDXPBox[MAX_PLAYERS];
new PlayerText:TDXPNumber[MAX_PLAYERS];
new PlayerText:TDXPPercent[MAX_PLAYERS];
new PlayerText:TDGasolina[MAX_PLAYERS];
new PlayerText:TDVelocidade[MAX_PLAYERS];
new PlayerText:PTDManager[MAX_PLAYERS][70];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// SYSTEMS /////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "systems/als.pwn"
#include "systems/sql.pwn"
#include "systems/vehicle.pwn"
#include "systems/admin.pwn"
#include "systems/time.pwn"
#include "systems/animations.pwn"
#include "systems/business.pwn"
#include "systems/bus.pwn"
#include "systems/posto.pwn"
#include "systems/refinaria.pwn"
#include "systems/bancopalomino.pwn"
#include "systems/casa.pwn"
#include "systems/autoescola.pwn"
#include "systems/concessionaria.pwn"
#include "systems/rcsd.pwn"
#include "systems/transp.pwn"
#include "systems/imobiliaria.pwn"
#include "systems/lixeiro.pwn"
#include "systems/bbliquor.pwn"
#include "systems/org.pwn"

stock ResetVars(playerid) {
	pInfo[playerid][pSQL] = 0;
	pInfo[playerid][pBus] = -1;
	pInfo[playerid][pSpawnado] = 0;
	pInfo[playerid][pLogged] = 0;
	pInfo[playerid][pAdmin] = 0;
	pInfo[playerid][pAtd] = 0;
	pInfo[playerid][pXP] = 0;
	pInfo[playerid][pLevel] = 0;
	pInfo[playerid][pSkin] = 0;
	pInfo[playerid][pCP] = 0;
	pInfo[playerid][pAnim] = 0;
	pInfo[playerid][pUSECMD_anim] = 0;
	pInfo[playerid][pComprovante] = 0;
	pInfo[playerid][pTDSelect] = 0;
	pInfo[playerid][pDialogParam][0] = 0;
	pInfo[playerid][pDialogParam][1] = 0;
	pInfo[playerid][pDialogParam][2] = 0;
	pInfo[playerid][pVoltar][0] = 0.0;
	pInfo[playerid][pVoltar][1] = 0.0;
	pInfo[playerid][pVoltar][2] = 0.0;
	pInfo[playerid][pVoltarInt] = 0;
	pInfo[playerid][pVoltarVW] = 0;
	pInfo[playerid][pSpec] = 0;
	pInfo[playerid][ptPrisao] = 0;
	pInfo[playerid][pHab] = 0;
	pInfo[playerid][pMon] = 0;
	pInfo[playerid][pHUD] = 1;
	pInfo[playerid][pPapo] = 1;
	pInfo[playerid][pMoney] = 0;
	pInfo[playerid][pOrg] = -1;
	pInfo[playerid][pMP] = 1;
	bIDV[playerid] = 0;
	sbBomba[playerid] = 0;
	ResetSheriffVar(playerid);
	ClearParametersACB(playerid);
	ClearParametrosCFR(playerid);
	for(new i = 0; i < MAX_ATENDIMENTOS; i++) {
		if(SolAtd[i] == playerid+1) { SolAtd[i] = 0; }
	}
	for(new i = 0; i < MAX_FICHAS; i++) {
		if(fInfo[i][fID] == playerid+1) { fInfo[i][fID] = 0; }
	}
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// COMANDOS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

CMD:entrar(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 214.2, -155.5, 1.6)) return SetPlayerPos(playerid, 212.9, -155.5, 1.7);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 210.2, -151.4, 1.6)) return SetPlayerPos(playerid, 210.2, -152.7, 1.7);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 511.9594,204.2914,1049.9912)) return SetPlayerPos(playerid, 511.9066,203.0040,1049.9912);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 663.7539,-552.2118,16.3359)) return SetPlayerPos(playerid, 663.8229,-553.7640,16.3184);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 661.3217,-573.4470,16.3359)) return SetPlayerPos(playerid, 662.6781,-573.4605,16.3359);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 254.4281,-62.2512,1.5781)) { // bbliquor entrada
		if(bInfo[BUSID_LSHOP][bTrancas][0]) return Act(playerid, "tenta abrir a porta mas não consegue.");
		SetPlayerPos(playerid, 254.5288,-60.9236,1.5703);
		return 1;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 244.1996,-51.3659,1.5781)) { // bbliquor fundos
		if(bInfo[BUSID_LSHOP][bTrancas][1]) return Act(playerid, "tenta abrir a porta mas não consegue.");
		SetPlayerPos(playerid, 244.1492,-52.7594,1.5703);
		return 1;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 627.0251,-571.7915,17.9145)) {
		SetPlayerPos(playerid, 246.3780,107.3681,1003.2188);
		SetPlayerFacingAngle(playerid, 270.0);
		SetPlayerInterior(playerid, 10);
		return 1;
	}
	for(new i = 0; i < MAX_BUSINESS; i++) { // É necessário passar pelas empresas para setar o VirtualWorld
		if(!bInfo[i][bSQL]) continue;
		for(new j = 0; j < MAX_ENTRADAS; j++) {
			if(!bInfo[i][bEntradas][j]) continue;
			if(IsPlayerInRangeOfPoint(playerid, 2.5, eInfo[i][j][eP][0], eInfo[i][j][eP][1], eInfo[i][j][eP][2])) {
				SetPlayerFacingAngle(playerid, eInfo[i][j][sP][3]);
				SetPlayerInterior(playerid, eInfo[i][j][sInt]);
				SetPlayerVirtualWorld(playerid, i);
				Streamer_UpdateEx(playerid, eInfo[i][j][sP][0], eInfo[i][j][sP][1], eInfo[i][j][sP][2], i, eInfo[i][j][sInt], -1, 1500);
				return 1;
			}
		}
	}
	for(new i = 0; i < MAX_HOUSES; i++) {
		if(!hInfo[i][hSQL]) continue;
		if(IsPlayerInRangeOfPoint(playerid, 2.0, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2])) {
			if(!hInfo[i][hInterior]) return Advert(playerid, "Essa casa não foi configurada interiormente.");
			if(hInfo[i][hLock]) return Advert(playerid, "Casa trancada.");
			SetPlayerInterior(playerid, hData[hInfo[i][hInterior]-1][hdInt]);
			SetPlayerFacingAngle(playerid, hData[hInfo[i][hInterior]-1][hdP][3]);
			SetPlayerVirtualWorld(playerid, i+MAX_BUSINESS);
			Streamer_UpdateEx(playerid, hData[hInfo[i][hInterior]-1][hdP][0], hData[hInfo[i][hInterior]-1][hdP][1], hData[hInfo[i][hInterior]-1][hdP][2], -1, -1, -1, 1500);
			return 1;
		}
	}
	return 1;
}

CMD:sair(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 1.0, 212.9, -155.5, 1.7)) return SetPlayerPos(playerid, 214.2, -155.5, 1.6);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 210.2, -152.7, 1.7)) return SetPlayerPos(playerid, 210.2, -151.4, 1.6);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 511.9066,203.0040,1049.9912)) return SetPlayerPos(playerid, 511.9594,204.2914,1049.9912);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 663.8229,-553.7640,16.3184)) return SetPlayerPos(playerid, 663.7539,-552.2118,16.3359);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 662.6781,-573.4605,16.3359)) return SetPlayerPos(playerid, 661.3217,-573.4470,16.3359);
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 254.6243,-60.9710,1.5703)) { // bbliquor entrada
		if(bInfo[BUSID_LSHOP][bTrancas][0] == 1) return Act(playerid, "tenta abrir a porta mas não consegue.");
		SetPlayerPos(playerid, 254.4281,-62.2512,1.5781);
		return 1;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 244.1492,-52.7594,1.5703)) { // bbliquor fundos
		if(bInfo[BUSID_LSHOP][bTrancas][1] == 1) return Act(playerid, "tenta abrir a porta mas não consegue.");
		SetPlayerPos(playerid, 244.1996,-51.3659,1.5781);
		return 1;
	}
	else if(IsPlayerInRangeOfPoint(playerid, 1.0, 246.3780,107.3681,1003.2188)) {
		SetPlayerPos(playerid, 627.0251,-571.7915,17.9145);
		SetPlayerFacingAngle(playerid, 0.0);
		SetPlayerInterior(playerid, 0);
		return 1;
	}
	new i = GetPlayerVirtualWorld(playerid);
	if(i >= 0 && i < MAX_BUSINESS) {
		if(bInfo[i][bSQL]) {
			for(new j = 0; j < MAX_ENTRADAS; j++) {
				if(!bInfo[i][bEntradas][j]) continue;
				if(IsPlayerInRangeOfPoint(playerid, 2.5, eInfo[i][j][sP][0], eInfo[i][j][sP][1], eInfo[i][j][sP][2])) {
					SetPlayerFacingAngle(playerid, eInfo[i][j][eP][3]);
					SetPlayerInterior(playerid, 0);
					SetPlayerVirtualWorld(playerid, 0);
					Streamer_UpdateEx(playerid, eInfo[i][j][eP][0], eInfo[i][j][eP][1], eInfo[i][j][eP][2], 0, 0, -1, 1500);
					return 1;
				}
			}
		}
	} else if(i >= MAX_BUSINESS && i < MAX_BUSINESS+MAX_HOUSES) {
		i -= MAX_BUSINESS;
		if(hInfo[i][hSQL]) {
			if(!hInfo[i][hInterior]) return Advert(playerid, "Algum staff troll te bugou manito. Solicita atendimento ae.");
			if(IsPlayerInRangeOfPoint(playerid, 2.0, hData[hInfo[i][hInterior]-1][hdP][0], hData[hInfo[i][hInterior]-1][hdP][1], hData[hInfo[i][hInterior]-1][hdP][2])) {
				if(hInfo[i][hLock]) return Advert(playerid, "Casa trancada.");
				SetPlayerVirtualWorld(playerid, 0);
				SetPlayerInterior(playerid, 0);
				SetPlayerFacingAngle(playerid, hInfo[i][hP][3]);
				Streamer_UpdateEx(playerid, hInfo[i][hP][0], hInfo[i][hP][1], hInfo[i][hP][2], -1, -1, -1, 1500);
				return 1;
			}
		}
	}
	return 1;
}

CMD:garagem(playerid) {
	new vid = GetPlayerVehicleID(playerid);
	if(!vid) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, 336.6123,193.3695,1083.7954)) { // Autoescola Dillimore 
			Streamer_UpdateEx(playerid, 638.7398,-499.9424,15.9664, -1, -1, -1, 1500);
			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 638.7398,-499.9424,15.9664)) { // Autoescola Dillimore 
			Streamer_UpdateEx(playerid, 336.6123,193.3695,1083.7954, -1, -1, -1, 1500);
			SetPlayerInterior(playerid, 1);
			SetPlayerVirtualWorld(playerid, BUSID_AUTO);
		} else if(IsPlayerInRangeOfPoint(playerid, 1.0, 256.9578,28.7877,2.4587)) { // Transportadora Blueberry
			if(pInfo[playerid][pBus] == BUSID_TRANSP) {
				static usecmd;
				if(gettime() < usecmd) return 1;
				if(PortaoTranspBB > 0) {
					usecmd = gettime() + (MoveDynamicObject(PortaoTranspBB, 257.462188, 25.389562, 4.969690, 0.8, 0.000000, 82.700012, 10.800003)/1000) + 1;
					PortaoTranspBB *= -1;
				} else {
					PortaoTranspBB *= -1;
					usecmd = gettime() + (MoveDynamicObject(PortaoTranspBB, 256.627197, 25.230287, 3.229691, 0.8, 0.000000, 0.000007, 10.800003)/1000) + 1;
				}
			}
		} else if(IsPlayerInRangeOfPoint(playerid, 3.0, 797.58588, -614.49469, 16.3000)) {
			if(pInfo[playerid][pBus] == BUSID_CONC) {
				static usecmd;
				if(gettime() < usecmd) return 1;
				if(GaragemConc > 0) {
					usecmd = gettime() + (MoveDynamicObject(GaragemConc, 797.58588, -614.49469, 21.1105, 1.0)/1000) + 1;
					GaragemConc *= -1;
				} else {
					GaragemConc *= -1;
					usecmd = gettime() + (MoveDynamicObject(GaragemConc, 797.58588, -614.49469, 17.26250, 1.0)/1000) + 1;
				}
			}
		}
	} else if(IsVehicleInRangeOfPoint(vid, 3.0, 336.6123,193.3695,1083.7954)) { // Autoescola Dillimore
		SetVehiclePos(vid, 638.7398,-499.9424,15.9664);
		SetVehicleInterior(vid, 0);
		SetVehicleVirtualWorld(vid, 0);
	} else if(IsVehicleInRangeOfPoint(vid, 3.0, 638.7398,-499.9424,15.9664)) { // Autoescola Dillimore
		SetVehiclePos(vid, 336.6123,193.3695,1083.7954);
		SetVehicleInterior(vid, 1);
		SetVehicleVirtualWorld(vid, BUSID_AUTO);
	}
	return 1;
}

CMD:pagar(playerid, params[]) {
	new id, mon;
	if(sscanf(params, "ii", id, mon)) return AdvertCMD(playerid, "/Pagar [ID] [Dinheiro]");
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

CMD:me(playerid, params[]) {
	new msg[180];
	if(sscanf(params, "s[180]", msg)) return AdvertCMD(playerid, "/Me [Ação]");
	Act(playerid, msg);
	return 1;
}

CMD:do(playerid, params[]) {
	new str[180];
	if(sscanf(params, "s[180]", str)) return AdvertCMD(playerid, "/Do [Ação]");
	new Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 144, "%s (( %s ))", str, pName(playerid));
	Amb(P[0], P[1], P[2], str);
	return 1;
}

CMD:b(playerid, params[]) {
	new msg[124];
	if(sscanf(params, "s[124]", msg)) return AdvertCMD(playerid, "/B [Mensagem]");
	new str[180], Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 180, "(( %s: %s ))", pNick(playerid), msg);
	new len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendRangedMessage(0xB8BAC6FF, str, ACTION_RANGE, P[0], P[1], P[2]);
		SendRangedMessage(0xB8BAC6FF, str2, ACTION_RANGE, P[0], P[1], P[2]);
	} else {
		SendRangedMessage(0xB8BAC6FF, str, ACTION_RANGE, P[0], P[1], P[2]);
	}
	return 1;
}

CMD:g(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/G [Grito]");
	new Float:P[6], str[180];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		GetPlayerPos(i, P[3], P[4], P[5]);
		new Float:D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
		if(D > ACTION_RANGE*2.5) continue;
		new color = floatround(255.0 - 153.0*D/(ACTION_RANGE*2.5));
		color = (color*0x1000000 + color*0x10000 + color*0x100 + 0xAA);
		format(str, 180, "- %s grita: "BRANCO"%s", pName(playerid), params);
		new len = strlen(str);
		if(len > 100) {
			new str2[60];
			strmid(str2, str, 100, len);
			strdel(str, 100, 180);
			strins(str, "[...]", 100);
			strins(str2, "[...]", 0);
			SendClientMessage(i, color, str);
			SendClientMessage(i, color, str2);
		} else {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

CMD:ba(playerid, params[]) return cmd_baixo(playerid, params);

CMD:baixo(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/Ba [Fala]");
	new Float:P[6], str[180];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		GetPlayerPos(i, P[3], P[4], P[5]);
		new Float:D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
		if(D > ACTION_RANGE*0.25) continue;
		new color = floatround(255.0 - 153.0*D/(ACTION_RANGE*0.25));
		color = (color*0x1000000 + color*0x10000 + color*0x100 + 0xAA);
		format(str, 180, "[Baixo] %s: "BRANCO"%s", pName(playerid), params);
		new len = strlen(str);
		if(len > 100) {
			new str2[60];
			strmid(str2, str, 100, len);
			strdel(str, 100, 180);
			strins(str, "[...]", 100);
			strins(str2, "[...]", 0);
			SendClientMessage(i, color, str);
			SendClientMessage(i, color, str2);
		} else {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

CMD:lmc(playerid) {
	for(new i = 0; i < 30; i++)SendClientMessage(playerid, 0, "");
	return 1;
}

CMD:ajuda(playerid) {
	new i = 0;
	for(; i < MAX_ATENDIMENTOS; i++) { if(SolAtd[i] == playerid+1) { break; } }
	new str[100];
	format(str, 100, BRANCO"Nível\nProfissão\n%s", (i == MAX_ATENDIMENTOS) ? (AMARELO"Solicitar atendimento") : (VERMELHO"Cancelar solicitação"));
	Dialog_Show(playerid, "DialogAjuda", DIALOG_STYLE_LIST, "AJUDA", str, "Selecionar", "Cancelar");
	return 1;
}

CMD:pegarchave(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 3.0, 237.1545,123.1376,1003.2188)) {
		if(!sInfo[playerid][sSQL]) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		new i = 0;
		for(; i < MAX_VIATURAS; i++) {
			if(Viatura[i] == vid) break;
		}
		if(i == MAX_VIATURAS) return Advert(playerid, "Esse IDV não corresponde a uma viatura.");
		if(vInfo[vid][vChave] != CLOC_RCSD) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 529.8980,210.2571,1049.9844)) {
		if(pInfo[playerid][pBus] != BUSID_REF) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		for(new j = 0, idv = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[BUSID_REF][bVehicles][j]) continue;
			idv = GetVehicleIDBySQL(bInfo[BUSID_REF][bVehicles][j]);
			if(!idv) continue;
			if(vInfo[idv][vChave] == pInfo[playerid][pSQL]) {
				if(GetVehicleModel(idv) == GetVehicleModel(vid)) return Advert(playerid, "Você só pode pegar uma chave de caminhão de uma de carga.");
			}
		}
		if(vInfo[vid][vChave] != CLOC_REF) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 28.5668,-1165.8140,8.4483)) {
		if(pInfo[playerid][pBus] != BUSID_GARBAGE) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		if(EquipamentoLixeiro[playerid]) return Advert(playerid, "Você não pode pegar chave do caminhão usando equipamento.");
		for(new j = 0, idv = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[BUSID_GARBAGE][bVehicles][j]) continue;
			idv = GetVehicleIDBySQL(bInfo[BUSID_GARBAGE][bVehicles][j]);
			if(!idv) continue;
			if(vInfo[idv][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você só pode pegar uma chave da empresa por vez.");
		}
		if(vInfo[vid][vChave] != CLOC_GARBAGE) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 260.3185,34.9675,2.4587) || IsPlayerInRangeOfPoint(playerid, 2.0, 267.7446,18.9372,2.4412)) {
		if(pInfo[playerid][pBus] != BUSID_TRANSP) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		for(new j = 0, idv = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[BUSID_TRANSP][bVehicles][j]) continue;
			idv = GetVehicleIDBySQL(bInfo[BUSID_TRANSP][bVehicles][j]);
			if(!idv) continue;
			if(vInfo[idv][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você só pode pegar uma chave da empresa por vez.");
		}
		if(vInfo[vid][vChave] != CLOC_TRANSP) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, -1936.6091,263.9367,1190.8627)) {
		if(pInfo[playerid][pBus] != BUSID_CONC) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		if(vInfo[vid][vChave] != CLOC_CONC) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 1490.7520,1306.3990,1093.2964)) {
		if(pInfo[playerid][pBus] != BUSID_BUSBB) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		for(new j = 0, idv = 0; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[BUSID_BUSBB][bVehicles][j]) continue;
			idv = GetVehicleIDBySQL(bInfo[BUSID_TRANSP][bVehicles][j]);
			if(!idv) continue;
			if(vInfo[idv][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você só pode pegar uma chave da empresa por vez.");
		}
		if(vInfo[vid][vChave] != CLOC_EDOBB) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 361.4470,198.5358,1084.1685)) {
		if(pInfo[playerid][pBus] != BUSID_AUTO) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		if(vInfo[vid][vChave] != CLOC_AUTO) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	}
	return 1;
}

CMD:guardarchave(playerid, params[]) {
	if(IsPlayerInRangeOfPoint(playerid, 3.0, 237.1545,123.1376,1003.2188)) {
		if(!sInfo[playerid][sSQL]) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		new i = 0;
		for(; i < MAX_VIATURAS; i++) {
			if(Viatura[i] == vid) break;
		}
		if(i == MAX_VIATURAS) return Advert(playerid, "Esse IDV não corresponde a uma viatura.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_RCSD;
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 28.5668,-1165.8140,8.4483)) {
		if(pInfo[playerid][pBus] != BUSID_GARBAGE) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_GARBAGE;
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 529.8980,210.2571,1049.9844)) {
		if(pInfo[playerid][pBus] != BUSID_REF) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_REF;

		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 260.3185,34.9675,2.4587) || IsPlayerInRangeOfPoint(playerid, 2.0, 267.7446,18.9372,2.4412)) {
		if(pInfo[playerid][pBus] != BUSID_TRANSP) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_TRANSP;
			if(pInfo[playerid][pMon]) {
				new str[144];
				format(str, 15, "~g~+$%i", pInfo[playerid][pMon]);
				GameTextForPlayer(playerid, str, 1000, 1);
				format(str, 144, "Você recebeu "VERDEMONEY"$%i"BRANCO" pelo serviço prestado.", pInfo[playerid][pMon]);
				Success(playerid, str);
				GivePlayerMoney(playerid, pInfo[playerid][pMon]);
				pInfo[playerid][pMon] = 0;
			}
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, -1936.6091,263.9367,1190.8627)) {
		if(pInfo[playerid][pBus] != BUSID_CONC) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_CONC;
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 1490.7520,1306.3990,1093.2964)) {
		if(pInfo[playerid][pBus] != BUSID_BUSBB) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_EDOBB;
			if(pInfo[playerid][pMon]) {
				new str[144];
				format(str, 15, "~g~+$%i", pInfo[playerid][pMon]);
				GameTextForPlayer(playerid, str, 1000, 1);
				format(str, 144, "Você recebeu "VERDEMONEY"$%i"BRANCO" pelo serviço prestado.", pInfo[playerid][pMon]);
				Success(playerid, str);
				GivePlayerMoney(playerid, pInfo[playerid][pMon]);
				pInfo[playerid][pMon] = 0;
			}
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 361.4470,198.5358,1084.1685)) {
		if(pInfo[playerid][pBus] != BUSID_AUTO) return Advert(playerid, "Você não tem a chave dessa gaveta.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/GuardarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Chave inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Chave não registrada no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Essa chave não pertence a sua empresa.");
		if(vInfo[vid][vChave] != pInfo[playerid][pSQL]) {
			Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO" para checar quais você tem.");
		} else {
			Act(playerid, "guarda uma chave dentro da gaveta.");
			vInfo[vid][vChave] = CLOC_AUTO;
		}
	}
	return 1;
}

CMD:entregarchave(playerid, params[]) {
	new id, key;
	if(sscanf(params, "ii", id, key)) return AdvertCMD(playerid, "/EntregarChave [ID] [IDV da chave]");
	if(!IsPlayerConnected(id) || id == playerid) return Advert(playerid, "ID inválido.");
	if(!IsValidVehicle(key)) return Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO".");
	if(!vInfo[key][vSQL] || vInfo[key][vChave] != pInfo[playerid][pSQL]) return Advert(playerid, "Você não possui essa chave. Use "AMARELO"/Chaves"BRANCO".");
	new Float:P[3];
	GetPlayerPos(id, P[0], P[1], P[2]);
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, P[0], P[1], P[2]) || GetPlayerInterior(playerid) != GetPlayerInterior(id) || GetPlayerVirtualWorld(playerid) != GetPlayerVirtualWorld(id)) return Advert(playerid, "Você deve estar próximo a quem deseja entregar a chave.");
	vInfo[key][vChave] = pInfo[id][pSQL];
	new str[144];
	format(str, 144, "entrega uma chave para %s.", pName(id));
	Act(playerid, str);
	return 1;
}

CMD:info(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 1490.7520,1306.3990,1093.2964)) {
		new str[150];
		if(pInfo[playerid][pBus] == BUSID_BUSBB) {
			format(str, 150, "Quero fazer uma rota.\nDesejo falar com o gerente.\nQuero pedir minhas contas.");
		} else {
			format(str, 150, "Gostaria de trabalhar aqui.\nComo falo com o gerente daqui?");
		}
		Dialog_Show(playerid, "MenuBusBB", DIALOG_STYLE_LIST, "Selecione sua fala", str, "Selecionar", "Cancelar");
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 534.1007,208.7319,1049.9844)) {
		new str[100];
		if(pInfo[playerid][pBus] == BUSID_REF) {
			format(str, 100, "Desejo falar com o gerente.\nQuero pedir minhas contas.");
		} else {
			format(str, 100, "Gostaria de trabalhar aqui.\nComo falo com o gerente daqui?");
		}
		Dialog_Show(playerid, "MenuRef", DIALOG_STYLE_LIST, "Selecione sua fala", str, "Selecionar", "Cancelar");
		return 1;
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 260.3185,34.9675,2.4587) || IsPlayerInRangeOfPoint(playerid, 2.0, 267.7446,18.9372,2.4412)) {
		new str[100];
		if(pInfo[playerid][pBus] == BUSID_TRANSP) {
			format(str, 100, "Desejo falar com o gerente.\nQuero pedir minhas contas.");
		} else {
			format(str, 100, "Gostaria de trabalhar aqui.\nComo falo com o gerente daqui?");
		}
		Dialog_Show(playerid, "MenuTransp", DIALOG_STYLE_LIST, "Selecione sua fala", str, "Selecionar", "Cancelar");
		return 1;
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 577.6893,-337.5042,1484.8677)) {
		new str[] = "Gostaria de comprar uma propriedade\n\
					 Quem é o gerente daqui?\n\
					 Como faço para trabalhar aqui?";
		Dialog_Show(playerid, "MenuImob", DIALOG_STYLE_LIST, "Selecione sua fala", str, "Selecionar", "Cancelar");
		return 1;
	} else if(IsPlayerInRangeOfPoint(playerid, 2.0, 26.6980,-1162.7847,8.4483)) {
		new str[100];
		if(pInfo[playerid][pBus] == BUSID_GARBAGE) {
			format(str, 100, "Desejo falar com o gerente.\nQuero pedir minhas contas.");
		} else {
			format(str, 100, "Gostaria de trabalhar aqui.\nComo falo com o gerente daqui?");
		}
		Dialog_Show(playerid, "MenuLixeiro", DIALOG_STYLE_LIST, "Selecione sua fala", str, "Selecionar", "Cancelar");
		return 1;
	}
	return 1;
}

CMD:portao(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 8.0, -1039.6951,-588.2967,32.0126)) {
		if(pInfo[playerid][pBus] != BUSID_REF) return Advert(playerid, "É necessário o cartão de identificação da refinaria para ativar o comando.");
		static usecmd;
		if(gettime() < usecmd) return 1;
		if(PortaoRefinaria > 0) {
			usecmd = gettime() + (MoveDynamicObject(PortaoRefinaria, -1022.0464, -589.1002, 33.7811, 2.0, 0.0000, 0.0000, -1.6200)/1000) + 1;
			PortaoRefinaria *= -1;
		} else {
			PortaoRefinaria *= -1;
			usecmd = gettime() + (MoveDynamicObject(PortaoRefinaria, -1033.3864, -588.7602, 33.7811, 2.0, 0.0000, 0.0000, -3.0400)/1000) + 1;
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 1.0, 329.8077,-60.2081,1.5491)) {
		if(pInfo[playerid][pBus] != BUSID_BUSBB) return Advert(playerid, "É necessário o cartão de identificação da estação de ônibus para usar o portão.");
		static usecmd;
		if(gettime() < usecmd) return 1;
		if(PortaoBusBB > 0) {
			usecmd = gettime() + (MoveDynamicObject(PortaoBusBB, 328.48309, -59.97890, 1.94470, 0.001, -0.72, -90.78, -0.42)/1000) + 1;
			PortaoBusBB *= -1;
		} else {
			PortaoBusBB *= -1;
			usecmd = gettime() + (MoveDynamicObject(PortaoBusBB, 328.48309, -59.97890, 1.94570, 0.001, -1.32000, 2.88000, 4.00000)/1000) + 1;
		}
	} else if(IsPlayerInRangeOfPoint(playerid, 5.0, 16.5960,-1183.0790,7.2392)) {
		if(pInfo[playerid][pBus] != BUSID_GARBAGE) return Advert(playerid, "É necessário o cartão de identificação da coletora de lixo para usar o portão.");
		static usecmd;
		if(gettime() < usecmd) return 1;
		if(PortaoLixeiro > 0) {
			usecmd = gettime() + (MoveDynamicObject(PortaoLixeiro, 16.183443, -1174.960327, 7.910368, 1.0, 0.000000, 0.000000, 90.000000)/1000) + 1;
			PortaoLixeiro *= -1;
		} else {
			PortaoLixeiro *= -1;
			usecmd = gettime() + (MoveDynamicObject(PortaoLixeiro, 16.183443, -1182.962158, 7.910369, 1.0, 0.000000, 0.000000, 90.000000)/1000) + 1;
		}
	}
	return 1;
}

CMD:iniciarrota(playerid, params[]) {
	if(pInfo[playerid][pBus] == -1) return Advert(playerid, "Você é desempregado.");
	if(pInfo[playerid][pBus] == BUSID_BUSBB) {
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um dos ônibus da empresa.");
		for(new i = 0; i < MAX_ROUTES; i++) {
			if(pRoute[playerid][i][proutePoint]) return Advert(playerid, "Você já iniciou a rota. Cancele ou finalize-a. /CancelarRota | /FinalizarRota.");
		}
		new r;
		if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/IniciarRota [1-3]");
		if(r < 1 || r > 3) return AdvertCMD(playerid, "/IniciarRota [1-3]");
		if(!BusRoute[pInfo[playerid][pBus]][r-1][brNum]) return Advert(playerid, "Essa rota não foi definida ainda.");
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!bInfo[pInfo[playerid][pBus]][bVehicles][i]) continue;
			new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
			if(IsPlayerInVehicle(playerid, vid)) {
				if(!IsVehicleInRangeOfPoint(vid, 15.0, 363.4124,-80.2795,1.4632)) return SendClientMessage(playerid, -1, "Você deve estar na Estação de Ônibus de Blueberry.");
				new id = 0;
				for(new j = 0; j < MAX_PLAYERS; j++) {
					if(pInfo[j][pBus] != BUSID_BUSBB) continue;
					if(j == playerid) continue;
					if(IsPlayerInVehicle(j, vid)) {
						if(id) return Advert(playerid, "Há 2 cobradores no ônibus. Não é possível iniciar a rota dessa forma.");
						id = j+1;
					}
				}
				Success(playerid, "Rota iniciada. Siga os checkpoints marcados no mapa e pare nos pontos de ônibus para os passageiros subirem e descerem.");
				pRoute[playerid][r-1][proutePoint] = 1;
				//pRoute[playerid][r-1][proutePartner] = id;
				pRoute[playerid][r-1][prouteVehicle] = vid;
				pInfo[playerid][pCP] = CP_BUS_ROUTE;
				SetPlayerCheckpoint(playerid, BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][0], BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][1], BusStops[brCP[pInfo[playerid][pBus]][r-1][pRoute[playerid][r-1][proutePoint]-1]][2], 3.0);
				return 1;
			}
		}
		Advert(playerid, "Você deve estar conduzindo um dos ônibus da empresa.");
	} else if(pInfo[playerid][pBus] == BUSID_GARBAGE) {
		if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return Advert(playerid, "Você deve estar conduzindo um caminhão de lixo.");
		if(gRoute[playerid][groutePoint]) return Advert(playerid, "Você já iniciou a rota. Cancele ou finalize-a. /CancelarRota | /FinalizarRota.");
		new r;
		if(sscanf(params, "i", r)) return AdvertCMD(playerid, "/IniciarRota [1-2]");
		if(r < 1 || r > MAX_GROUTES) return AdvertCMD(playerid, "/IniciarRota [1-2]");
		if(r != 1) return Advert(playerid, "Temporariamente há apenas a rota de número 1 criada.");
		for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
			if(!bInfo[pInfo[playerid][pBus]][bVehicles][i]) continue;
			new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][i]);
			if(IsPlayerInVehicle(playerid, vid)) {
				if(!IsVehicleInRangeOfPoint(vid, 15.0, 33.2594,-1177.1040,7.7811)) return SendClientMessage(playerid, -1, "Você deve estar na coletora de lixo.");
				gRoute[playerid][grouteRoute] = r;
				gRoute[playerid][grouteVehicle] = vid;
				Dialog_Show(playerid, "CollectorsQuant", DIALOG_STYLE_MSGBOX, "INÍCIO DE ROTA", "Agora que vai iniciar uma rota, deseja iniciá-la\ncom um parceiro para coletar o lixo ou dois?", "Um", "Dois");
				return 1;
			}
		}
		Advert(playerid, "Você deve estar conduzindo um caminhão de lixo.");
	}
	return 1;
}

CMD:finalizarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(pInfo[playerid][pBus] == BUSID_BUSBB) {
		new r;
		for(; r < MAX_ROUTES; r++) {
			if(pRoute[playerid][r][proutePoint]) break;
		}
		if(r == MAX_ROUTES) return Advert(playerid, "Você não iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
		if(pRoute[playerid][r][proutePoint] < BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Você ainda não passou por todos os pontos obrigatórios da rota.");
		new j = 0;
		for(; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
			if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
		}
		if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Você deve estar conduzindo um ônibus da empresa.");
		new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
		if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Você deve estar no estacionamento deste ônibus.");

		pInfo[playerid][pMon] += BusRoute[pInfo[playerid][pBus]][r][brVal];
		//GivePlayerMoney(pRoute[playerid][r][proutePartner]-1, floatround(0.8*BusRoute[pInfo[playerid][pBus]][r][brVal]));

		new str[144];
		Success(playerid, "Rota finalizada com sucesso.");
		//Success(pRoute[playerid][r][proutePartner]-1, "Rota finalizada com sucesso.");
		format(str, 144, "Foram adicionados $%i pela rota.", BusRoute[pInfo[playerid][pBus]][r][brVal]);
		Success(playerid, str);
		Success(playerid, "Você pode continuar fazendo outras rotas ou receber seu dinheiro agora guardando a chave do ônibus na secretaria.");
		//format(str, 144, "Você foi pago em $%i pela rota.", floatround(0.8*BusRoute[pInfo[playerid][pBus]][r][brVal]));
		//Success(pRoute[playerid][r][proutePartner]-1, str);
		pRoute[playerid][r][proutePoint] = 0;
		//pRoute[playerid][r][proutePartner] = 0;
		pRoute[playerid][r][prouteVehicle] = 0;
		bInfo[BUSID_BUSBB][bReceita] += floatround(floatdiv(BusRoute[pInfo[playerid][pBus]][r][brVal], 5));
	}
	return 1;
}

CMD:cancelarrota(playerid) {
	if(pInfo[playerid][pBus] == -1) return SendClientMessage(playerid, -1, "Você é desempregado.");
	if(pInfo[playerid][pBus] == BUSID_BUSBB) {
		new r;
		for(; r < MAX_ROUTES; r++) {
			if(pRoute[playerid][r][proutePoint]) break;
		}
		if(r == MAX_ROUTES) return Advert(playerid, "Você não iniciou a rota. Para isso, use "AMARELO"/IniciarRota"BRANCO".");
		if(pRoute[playerid][r][proutePoint] == BusRoute[pInfo[playerid][pBus]][r][brNum]+2) return Advert(playerid, "Você já passou por todos os pontos obrigatórios da rota. Use "AMARELO"/FinalizarRota"BRANCO".");
		new j = 0;
		for(; j < MAX_BUSINESS_VEHICLES; j++) {
			if(!bInfo[pInfo[playerid][pBus]][bVehicles][j]) continue;
			if(IsPlayerInVehicle(playerid, GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]))) break;
		}
		if(j == MAX_BUSINESS_VEHICLES) return SendClientMessage(playerid, -1, "Você deve estar conduzindo um ônibus da empresa.");
		new vid = GetVehicleIDBySQL(bInfo[pInfo[playerid][pBus]][bVehicles][j]);
		if(!IsVehicleInRangeOfPoint(vid, 3.0, vInfo[vid][vSpawn][0], vInfo[vid][vSpawn][1], vInfo[vid][vSpawn][2])) return SendClientMessage(playerid, -1, "Você deve estar no estacionamento deste ônibus.");
		Info(playerid, "Rota cancelada.");
		pInfo[playerid][pCP] = 0;
		DisablePlayerCheckpoint(playerid);
		pRoute[playerid][r][proutePoint] = 0;
	}
	return 1;
}

CMD:mp(playerid, params[]) {
	new id, msg[125], str[180];
	if(sscanf(params, "is[125]", id, msg)) return AdvertCMD(playerid, "/MP [ID] [Mensagem]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(playerid == id) return Advert(playerid, "Não seja tão solitário a ponto de enviar mensagem privada para si próprio :(");
	if(!pInfo[id][pMP]) return Advert(playerid, "Esse player bloqueou o recebimento de mensagens privadas.");
	format(str, 180, "[MP de %s]"BRANCO" %s", pNick(playerid), msg);
	new len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendClientMessage(id, RoxoClaro, str);
		SendClientMessage(id, Branco, str2);
	} else {
		SendClientMessage(id, RoxoClaro, str);
	}
	format(str, 180, "[MP para %s]"BRANCO" %s", pNick(id), msg);
	len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendClientMessage(playerid, RoxoClaro, str);
		SendClientMessage(playerid, Branco, str2);
	} else {
		SendClientMessage(playerid, RoxoClaro, str);
	}
	return 1;
}

CMD:blockmp(playerid) {
	if(pInfo[playerid][pMP]) {
		Info(playerid, "Recebimento de MPs bloqueado.");
		pInfo[playerid][pMP] = 0;
	} else {
		Info(playerid, "Recebimento de MPs desbloqueado.");
		pInfo[playerid][pMP] = 1;
	}
	return 1;
}

CMD:hud(playerid) {
	if(!pInfo[playerid][pHUD]) {
		for(new i = 0; i < sizeof(TDBarra); i++) {
			TextDrawShowForPlayer(playerid, TDBarra[i]);
		}
		new str[24], Float:prop = floatdiv(pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]));
		format(str, 24, "%s", pName(playerid));
		SpaceToUnderline(str);
		PlayerTextDrawSetString(playerid, TDName[playerid], str);
		PlayerTextDrawShow(playerid, TDName[playerid]);
		format(str, 5, "%i", pInfo[playerid][pLevel]);
		PlayerTextDrawSetString(playerid, TDScore[playerid], str);
		PlayerTextDrawShow(playerid, TDScore[playerid]);
		PlayerTextDrawTextSize(playerid, TDXPBox[playerid], 550.5+prop*49.5, 0.0);
		PlayerTextDrawShow(playerid, TDXPBox[playerid]);
		format(str, 20, "%i_/_%i", pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]));
		PlayerTextDrawSetString(playerid, TDXPNumber[playerid], str);
		PlayerTextDrawShow(playerid, TDXPNumber[playerid]);
		format(str, 5, "%i%%", floatround(prop*100));
		PlayerTextDrawSetString(playerid, TDXPPercent[playerid], str);
		PlayerTextDrawShow(playerid, TDXPPercent[playerid]);
		Info(playerid, "HUD habilitada.");
		pInfo[playerid][pHUD] = 1;
	} else {
		for(new i = 0; i < sizeof(TDBarra); i++) {
			TextDrawHideForPlayer(playerid, TDBarra[i]);
		}
		PlayerTextDrawHide(playerid, TDName[playerid]);
		PlayerTextDrawHide(playerid, TDScore[playerid]);
		PlayerTextDrawHide(playerid, TDXPBox[playerid]);
		PlayerTextDrawHide(playerid, TDXPNumber[playerid]);
		PlayerTextDrawHide(playerid, TDXPPercent[playerid]);
		Info(playerid, "HUD desabilitada.");
		pInfo[playerid][pHUD] = 0;
	}
	return 1;
}

CMD:id(playerid, params[]) {
	new id;
	if(sscanf(params, "u", id)) return AdvertCMD(playerid, "/ID [ID/Nome_Sobrenome]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	new str[144];
	format(str, 144, "[ID%03i] %s"BRANCO" - Nível %i - Ping: %ims", id, pNick(id), pInfo[id][pLevel], GetPlayerPing(id));
	SendClientMessage(playerid, Amarelo, str);
	return 1;
}

CMD:tab(playerid) {
	new str[800], l, i;
	for(; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		//if(l == 20) { l = -1; break; }
		format(str, 800, "%s{FFFFFF}[%02i] %s\n", str, i, pNick(i));
		l++;
	}
	Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_LIST, "{FFFFFF}TAB", str, "Fechar", /*((l == -1) ? (">>") : (""))*/"");
	// pInfo[playerid][pDialogParam][0] = funcidx("dialog_Tab");
	// pInfo[playerid][pDialogParam][1] = i;
	// pInfo[playerid][pDialogParam][2] = 1;
	return 1;
}

CMD:s(playerid, params[]) {
	new id, msg[129], str[180];
	if(sscanf(params, "us[128]", id, msg)) return AdvertCMD(playerid, "/S [ID/Nickname] [Sussurro]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "Player offline.");
	format(str, 180, "- %s sussurrou: "BRANCO"%s", pName(playerid), msg);
	new len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendClientMessage(id, Amarelo, str);
		SendClientMessage(id, Amarelo, str2);
	} else {
		SendClientMessage(id, Amarelo, str);
	}
	format(str, 144, "sussurra algo nos ouvidos de %s.", pName(id));
	Act(playerid, str);
	return 1;
}

/*Dialog:Tab(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pDialogParam][0] != funcidx("dialog_Tab")) return ResetDialogParams(playerid);
	new page = pInfo[playerid][pDialogParam][2];
	if(page == 1 && response) return 1;
	for(new i = pInfo[playerid][pDialogParam][1]; i < MAX_PLAYERS; i++) {

	}
	return 1;
}*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////// DIALOGS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Dialog:MenuBusBB(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pBus] == BUSID_BUSBB) {
		if(listitem == 0) {				// Quero fazer uma rota.
			Info(playerid, "Para iniciar uma rota é muito simples. Você pode ter duas opções de serviço aqui nessa empresa.");
			Info(playerid, "Você pode ser motorista, e para isso você precisa de uma habilitação de motorista.");
			Info(playerid, "Ou você pode ser o cobrador, e não precisa de nenhum requisito para isso.");
			Info(playerid, "As duas funções são vitais para que se inicie uma rota. Não há rota sem motorista ou sem cobrador.");
			Info(playerid, "Se você é o cobrador, apenas espere um motorista te chamar para uma rota, mas se você é o motorista,");
			Info(playerid, "Você precisa /PegarChave aqui mesmo, entrar num ônibus, chamar um cobrador e /IniciarRota.");
			Info(playerid, "Quando você acabar sua rota, para receber o dinheiro de volta você deve /FinalizarRota e /GuardarChave.");
		} else if(listitem == 1) {		// Desejo falar com o gerente.
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_BUSBB][bOwner]);
			Info(playerid, str);
		} else if(listitem == 2) {		// Quero pedir minhas contas.
			for(new i = 0; i < MAX_ROUTES; i++) {
				/*for(new j = 0; j < MAX_PLAYERS; j++) {
					if(pRoute[j][i][proutePartner] == playerid+1) return Advert(playerid, "Você não pode se demitir enquanto não cancelar sua rota."); 
				}*/
				if(pRoute[playerid][i][proutePoint]) return Advert(playerid, "Você não pode se demitir enquanto não cancelar sua rota.");
			}
			for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
				if(!bInfo[BUSID_BUSBB][bVehicles][i]) continue;
				if(vInfo[GetVehicleIDBySQL(bInfo[BUSID_BUSBB][bVehicles][i])][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você não pode ficar com as chaves dos ônibus.");
			}
			pInfo[playerid][pBus] = -1;
			Info(playerid, "Você se demitiu e não faz mais parte dessa empresa.");
		}
	} else {
		if(listitem == 0) {				// Gostaria de trabalhar aqui.
			if(pInfo[playerid][pBus] != -1) return Advert(playerid, "Você não pode trabalhar aqui enquanto for funcionário de outra empresa.");
			pInfo[playerid][pBus] = BUSID_BUSBB;
			Info(playerid, "Agora você está contratado e pode trabalhar aqui como motorista ou cobrador da rota de ônibus.");
		} else if(listitem == 1) {		// Como falo com o gerente daqui?
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_BUSBB][bOwner]);
			Info(playerid, str);
		}
	}
	return 1;
}

Dialog:MenuRef(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pBus] == BUSID_REF) {
		if(listitem == 0) {		// Desejo falar com o gerente.
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_REF][bOwner]);
			Info(playerid, str);
		} else if(listitem == 1) {		// Quero pedir minhas contas.
			for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
				if(!bInfo[BUSID_REF][bVehicles][i]) continue;
				if(vInfo[GetVehicleIDBySQL(bInfo[BUSID_REF][bVehicles][i])][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você não pode ficar com as chaves da empresa.");
			}
			pInfo[playerid][pBus] = -1;
			Info(playerid, "Você se demitiu e não faz mais parte dessa empresa.");
		}
	} else {
		if(listitem == 0) {				// Gostaria de trabalhar aqui.
			if(pInfo[playerid][pBus] != -1) return Advert(playerid, "Você não pode trabalhar aqui enquanto for funcionário de outra empresa.");
			pInfo[playerid][pBus] = BUSID_REF;
			Info(playerid, "Agora você está contratado e pode trabalhar aqui como transportador da refinaria.");
		} else if(listitem == 1) {		// Como falo com o gerente daqui?
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_REF][bOwner]);
			Info(playerid, str);
		}
	}
	return 1;
}

Dialog:MenuTransp(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pBus] == BUSID_TRANSP) {
		if(listitem == 0) {		// Desejo falar com o gerente.
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_TRANSP][bOwner]);
			Info(playerid, str);
		} else if(listitem == 1) {		// Quero pedir minhas contas.
			for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
				if(!bInfo[BUSID_TRANSP][bVehicles][i]) continue;
				if(vInfo[GetVehicleIDBySQL(bInfo[BUSID_TRANSP][bVehicles][i])][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você não pode ficar com as chaves da empresa.");
			}
			pInfo[playerid][pBus] = -1;
			Info(playerid, "Você se demitiu e não faz mais parte dessa empresa.");
		}
	} else {
		if(listitem == 0) {				// Gostaria de trabalhar aqui.
			if(pInfo[playerid][pBus] != -1) return Advert(playerid, "Você não pode trabalhar aqui enquanto for funcionário de outra empresa.");
			pInfo[playerid][pBus] = BUSID_TRANSP;
			Info(playerid, "Agora você está contratado e pode trabalhar aqui como entregador da transportadora.");
		} else if(listitem == 1) {		// Como falo com o gerente daqui?
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_TRANSP][bOwner]);
			Info(playerid, str);
		}
	}
	return 1;
}

Dialog:MenuLixeiro(playerid, response, listitem, inputtext[]) {
	if(pInfo[playerid][pBus] == BUSID_GARBAGE) {
		if(listitem == 0) {		// Desejo falar com o gerente.
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_GARBAGE][bOwner]);
			Info(playerid, str);
		} else if(listitem == 1) {		// Quero pedir minhas contas.
			for(new i = 0; i < MAX_BUSINESS_VEHICLES; i++) {
				if(!bInfo[BUSID_GARBAGE][bVehicles][i]) continue;
				if(vInfo[GetVehicleIDBySQL(bInfo[BUSID_GARBAGE][bVehicles][i])][vChave] == pInfo[playerid][pSQL]) return Advert(playerid, "Você não pode ficar com as chaves da empresa.");
			}
			pInfo[playerid][pBus] = -1;
			Info(playerid, "Você se demitiu e não faz mais parte dessa empresa.");
		}
	} else {
		if(listitem == 0) {				// Gostaria de trabalhar aqui.
			if(pInfo[playerid][pBus] != -1) return Advert(playerid, "Você não pode trabalhar aqui enquanto for funcionário de outra empresa.");
			pInfo[playerid][pBus] = BUSID_GARBAGE;
			Info(playerid, "Agora você está contratado e pode trabalhar aqui como coletor de lixo.");
		} else if(listitem == 1) {		// Como falo com o gerente daqui?
			new str[144];
			format(str, 144, "O atual proprietário dessa empresa se chama %s.", bInfo[BUSID_GARBAGE][bOwner]);
			Info(playerid, str);
		}
	}
	return 1;
}

Dialog:DialogAjuda(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(listitem == 0) { //				Nível
		new str[250];
		format(str, 250, "Você recebe 1 XP por minuto jogado OOC.\nCada nível tem seu total de experiência único, sempre crescente.\n- Experiência: %i/%iXP\n- Nível: %i", pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]), pInfo[playerid][pLevel]);
		Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "Nível", str, "Fechar", "");
	} else if(listitem == 1) { //		Profissão
		if(pInfo[playerid][pBus] == -1) return Info(playerid, "Você é desempregado.");
		new str[300], i = 0;
		for(; i < MAX_CARGOS; i++) {
			if(!cInfo[pInfo[playerid][pBus]][i][cSQL]) continue;
			else if(strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], pName(playerid), true)) continue;
			else break;
		}
		if(i == MAX_CARGOS) {
			format(str, 200, BRANCO"Você atualmente trabalha na empresa %s.\nComandos:\n"AMARELO, bInfo[pInfo[playerid][pBus]][bName]);
			if(pInfo[playerid][pBus] == BUSID_BUSBB) {
				format(str, 300, "%s/IniciarRota [1-3] | /CancelarRota | /FinalizarRota", str);
			} else if(pInfo[playerid][pBus] == BUSID_TRANSP) {
				format(str, 300, "%s(/Et)iqueta [Caixa] | /PegarCaixa [Caixa] | /SoltarCaixa [Caixa]\n/Carregar [IDV] | /Cargas [IDV] | /EntregarCaixa", str);
			} else if(pInfo[playerid][pBus] == BUSID_REF) {
				format(str, 300, "%s/PegarFicha [1-5] | /GuardarFicha | /VerFicha\n/Engatar [IDV] | /Desengatar | /Painel\n/FichasRefinaria", str);
			}
			Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "Ajuda > Profissão", str, "Fechar", "");
		} else {
			format(str, 150, "Você trabalha para a empresa %s no cargo de %s.", bInfo[pInfo[playerid][pBus]][bName], cInfo[pInfo[playerid][pBus]][i][cName]);
			Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "PROFISSÃO", str, "Fechar", "");
		}
	} else if(listitem == 2) { //		Solicitar atendimento / Cancelar solicitação
		new i = 0;
		for(; i < MAX_ATENDIMENTOS; i++) { if(SolAtd[i] == playerid+1) { break; } }
		if(i == MAX_ATENDIMENTOS) {
			Dialog_Show(playerid, "SolicitarAtd", DIALOG_STYLE_MSGBOX, "Solicitar Atendimento", "Ao clicar em 'Solicitar' você estará enviando um pedido de atendimento particular para a STAFF.", "Solicitar", "Cancelar");
		} else {
			SolAtd[i] = 0;
			Info(playerid, "Solicitação de atendimento cancelada.");
		}
	}
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
	Info(playerid, "Somos um servidor em desenvolvimento, atualmente na versão "CIANO"BETA"BRANCO".");
	Info(playerid, "Quaisquer erros notados, por favor, reportem para a administração por meio do "AMARELO"/Ajuda"BRANCO".");
	Info(playerid, "Além disso, bom divertimento, e lembre-se: "AZUL"o roleplay é soberano!");
	new query[150];
	mysql_format(conn, query, 150, "INSERT INTO `playerinfo` (`nickname`, `senha`) VALUES ('%s', '%s')", pNick(playerid), inputtext);
	mysql_tquery(conn, query, "PlayerRegister", "i", playerid);
	pInfo[playerid][pLogged] = 2;
	GivePlayerMoney(playerid, 1000);
	SetPlayerVirtualWorld(playerid, 0);
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
		Info(playerid, "Somos um servidor em desenvolvimento, atualmente na versão "CIANO"BETA"BRANCO".");
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

Dialog:AmICalled(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	Dialog_Show(playerid, "SelectCaller", DIALOG_STYLE_LIST, "Quem te convidou?", "Eduardo Nunes\nWictor Lima\nRian Lourete", "Confirmar", "Cancelar");
	return 1;
}

Dialog:SelectCaller(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	new query[150];
	if(listitem == 0) {
		mysql_format(conn, query, 150, "UPDATE playerinfo SET convidado = 1 WHERE sqlid = %i", pInfo[playerid][pSQL]);
		mysql_query(conn, query, false);
	} else if(listitem == 1) {
		mysql_format(conn, query, 150, "UPDATE playerinfo SET convidado = 2 WHERE sqlid = %i", pInfo[playerid][pSQL]);
		mysql_query(conn, query, false);
	} else if(listitem == 2) {
		mysql_format(conn, query, 150, "UPDATE playerinfo SET convidado = 3 WHERE sqlid = %i", pInfo[playerid][pSQL]);
		mysql_query(conn, query, false);
	}
	Success(playerid, "Obrigado por contribuir conosco. Você recebeu "VERDEMONEY"$1.500"BRANCO" a mais para começar sua vida.");
	GivePlayerMoney(playerid, 1500);
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// PUBLICS /////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public OnGameModeInit() {

	CallLocalFunction("OnGameModeInit@sql", "");
	CallLocalFunction("OnGameModeInit@vehicle", "");
	CallLocalFunction("OnGameModeInit@time", "");
	CallLocalFunction("OnGameModeInit@business", "");
	CallLocalFunction("OnGameModeInit@bus", "");
	CallLocalFunction("OnGameModeInit@posto", "");
	CallLocalFunction("OnGameModeInit@refinaria", "");
	CallLocalFunction("OnGameModeInit@casa", "");
	CallLocalFunction("OnGameModeInit@admin", "");
	CallLocalFunction("OnGameModeInit@conc", "");
	CallLocalFunction("OnGameModeInit@rcsd", "");
	CallLocalFunction("OnGameModeInit@transp", "");
	CallLocalFunction("OnGameModeInit@org", "");

	// MAPAS

	print("Carregando mapas...");
	new tmpobj;
	#include "maps/bus.pwn"
	#include "maps/basketball.pwn"
	#include "maps/postomg.pwn"
	#include "maps/postodm.pwn"
	#include "maps/postofc.pwn"
	#include "maps/refinaria.pwn"
	#include "maps/bancopalomino.pwn"
	#include "maps/palomino.pwn"
	#include "maps/interiores.pwn"
	#include "maps/autoescola.pwn"
	#include "maps/concessionaria.pwn"
	#include "maps/rcsd.pwn"
	#include "maps/transp.pwn"
	#include "maps/imobiliaria.pwn"
	#include "maps/lixeiro.pwn"
	#include "maps/casas.pwn"
	#include "maps/wpump.pwn"
	#include "maps/rcsigns.pwn"
	#include "maps/bbliquor.pwn"
	print("Mapas carregados com sucesso.");

	// TEXTDRAWS

	#include "textdraws/login.pwn"
	#include "textdraws/gas.pwn"
	#include "textdraws/manager.pwn"
	#include "textdraws/barra.pwn"

	//

	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	SetGameModeText("[DF:RP] PT-BR (vBeta)");

	EnableStuntBonusForAll(0);
	//ShowNameTags(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	SetNameTagDrawDistance(15.0);

	CreateDynamicPickup(1239, 1, 1490.7520,1306.3990,1093.2964);							// Estação de ônibus Blueberry
	CreateDynamic3DTextLabel("/Info", Amarelo, 1490.7520,1306.3990,1093.2964, 3.0);
	CreateDynamicPickup(1239, 1, 260.3185,34.9675,2.4587);							// Transportadora de Blueberry
	CreateDynamic3DTextLabel("/Info", Amarelo, 260.3185,34.9675,2.4587, 3.0);
	CreateDynamicPickup(1239, 1, 267.7446,18.9372,2.4412);							// Transportadora de Blueberry (APK)
	CreateDynamic3DTextLabel("/Info", Amarelo, 267.7446,18.9372,2.4412, 3.0);
	CreateDynamicPickup(1239, 1, 577.6893,-337.5042,1484.8677);							// Imobiliária de Palomino Creek
	CreateDynamic3DTextLabel("/Info", Amarelo, 577.6893,-337.5042,1484.8677, 3.0);
	CreateDynamicPickup(1239, 1, 26.6980,-1162.7847,8.4483);							// Coletora de Lixo Red County
	CreateDynamic3DTextLabel("/Info", Amarelo, 26.6980,-1162.7847,8.4483, 3.0);
	CreateDynamicPickup(1239, 1, 534.1007,208.7319,1049.9844);							// Refinaria de Flint County
	CreateDynamic3DTextLabel("/Info", Amarelo, 534.1007,208.7319,1049.9844, 3.0);


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

public OnPlayerSpawn(playerid) {
	if(pInfo[playerid][pLogged] == 2) { // Logou-se com sucesso
		TextDrawHideForPlayer(playerid, TDLogin);
		StopAudioStreamForPlayer(playerid);
		pInfo[playerid][pLogged] = 1;
		for(new i = 0; i < sizeof(TDBarra); i++) {
			TextDrawShowForPlayer(playerid, TDBarra[i]);
		}
		new str[24], Float:prop = floatdiv(pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]));
		format(str, 24, "%s", pName(playerid));
		SpaceToUnderline(str);
		PlayerTextDrawSetString(playerid, TDName[playerid], str);
		PlayerTextDrawShow(playerid, TDName[playerid]);
		format(str, 5, "%i", pInfo[playerid][pLevel]);
		PlayerTextDrawSetString(playerid, TDScore[playerid], str);
		PlayerTextDrawShow(playerid, TDScore[playerid]);
		PlayerTextDrawTextSize(playerid, TDXPBox[playerid], 550.5+prop*49.5, 0.0);
		PlayerTextDrawShow(playerid, TDXPBox[playerid]);
		format(str, 20, "%i_/_%i", pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]));
		PlayerTextDrawSetString(playerid, TDXPNumber[playerid], str);
		PlayerTextDrawShow(playerid, TDXPNumber[playerid]);
		format(str, 5, "%i%%", floatround(prop*100));
		PlayerTextDrawSetString(playerid, TDXPPercent[playerid], str);
		PlayerTextDrawShow(playerid, TDXPPercent[playerid]);
		return 1;
	} else if(!pInfo[playerid][pLogged]) { // Conectou-se ao servidor
		//if(!pInfo[playerid][pFinishedDownload]) return 1;
		pInfo[playerid][pSpawnado] = 1;
		for(new i = 0; i < sizeof(AnimsEnum); i++) {
			ApplyAnimation(playerid, AnimsEnum[i], "null", 4.0, 0, 0, 0, 0, 0, 1);
		}
		TogglePlayerSpectating(playerid, 1);
		SetPlayerPos(playerid, 255.2, -163.7, 1.6);
		SetPlayerCameraPos(playerid, 472.9, -156.9, 42.7);
		SetPlayerCameraLookAt(playerid, 380.4, -143.4, 7.4);
		InterpolateCameraPos(playerid, 472.9, -156.9, 42.7, 405.5, -241.6, 61.6, 60000, CAMERA_MOVE);
		InterpolateCameraLookAt(playerid, 380.4, -143.4, 7.4, 318.4, -198.2, 38.5, 60000, CAMERA_MOVE);
		SetPlayerVirtualWorld(playerid, 1);
		SetPlayerColor(playerid, 0xFFFFFFFF);
		PlayAudioStreamForPlayer(playerid, "http://denilfleck.com.br/login-music.mp3");
		LimparChat(playerid);
		TextDrawShowForPlayer(playerid, TDLogin);
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
	} else if(pInfo[playerid][pSpec]) { // SpecOFF
		Streamer_UpdateEx(playerid, pInfo[playerid][pVoltar][0], pInfo[playerid][pVoltar][1], pInfo[playerid][pVoltar][2], -1, -1, -1, 1500);
		SetPlayerInterior(playerid, pInfo[playerid][pVoltarInt]);
		SetPlayerVirtualWorld(playerid, pInfo[playerid][pVoltarVW]);
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		Info(playerid, "Modo spec desativado.");
		pInfo[playerid][pSpec] = 0;
	} else { // Morreu
		SetPlayerPos(playerid, 1241.8, 327, 19.8);
		SetPlayerFacingAngle(playerid, 25);
		SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
		SendClientMessage(playerid, -1, "Teletransportado temporariamente para o \"hospital\" local.");
	}
	return 1;
}

public OnVehicleSpawn(vehicleid) {
	CallLocalFunction("OnVehicleSpawn@veh", "i", vehicleid);
	CallLocalFunction("OnVehicleSpawn@transp", "i", vehicleid);
	return 1;
}

public OnVehicleDeath(vehicleid, killerid) {
	CallLocalFunction("OnVehicleDeath@veh", "i", vehicleid);
	CallLocalFunction("OnVehicleDeath@transp", "i", vehicleid);
	return 1;
}

/*forward OnPlayerFinishedDownloading(playerid, virtualworld);
public OnPlayerFinishedDownloading(playerid, virtualworld) {
	pInfo[playerid][pFinishedDownload] = 1;
	Info(playerid, "a");
	return 1;
}*/

public OnPlayerConnect(playerid) {
	if(playerid >= MAX_PLAYERS) {
		Advert(playerid, "Notifique a administração sobre essa mensagem de erro imediatamente! [COD000]");
		KickPlayer(playerid);
		return 1;
	}
	new query[150], ip[16];
	GetPlayerIp(playerid, ip, 16);
	mysql_format(conn, query, 150, "SELECT * FROM kickbans WHERE name = '%s' OR IP = '%s'", pNick(playerid), ip);
	mysql_tquery(conn, query, "Kickbans", "i", playerid);
	new name[24];
	GetPlayerName(playerid, name, 24);
	new j = 100, condition = 0, len = strlen(name);
	for(new i = 0; i < len; i++) {
		if(!IsLetter(name[i])) {
			if(name[i] == '_' && j == 100) { j = i; condition++; } else { condition = 4; break; }
		} else if(IsUpperCase(name[i])) {
			if(i == 0) { condition ++;
			} else if(i == j+1) { condition ++;
			} else if(i == j+3) {
				if(!(name[j+1] == 'M' && name[j+2] == 'c') && !(name[j+1] == 'D' && name[j+2] == 'e')) { condition = 6; break; }
			} else { condition = 5; break;
			}
		}
	}
	if(condition != 3) {
		Advert(playerid, "Seu nickname está fora do padrão RP exigido pelo servidor.");
		Info(playerid, "Entre novamente mas com um nickname no formato "CINZAAZULADO"Nome_Sobrenome"BRANCO".");
		KickPlayer(playerid);
		return 1;
	}
	ResetVars(playerid);
	CallLocalFunction("OnPlayerConnect@refinaria", "i", playerid);
	CallLocalFunction("OnPlayerConnect@bus", "i", playerid);
	CallLocalFunction("OnPlayerConnect@posto", "i", playerid);
	CallLocalFunction("OnPlayerConnect@autoescola", "i", playerid);
	CallLocalFunction("OnPlayerConnect@conc", "i", playerid);
	CallLocalFunction("OnPlayerConnect@rcsd", "i", playerid);
	CallLocalFunction("OnPlayerConnect@transp", "i", playerid);
	CallLocalFunction("OnPlayerConnect@bbliquor", "i", playerid);
	#include "textdraws/pgas.pwn"
	#include "textdraws/pmanager.pwn"
	#include "textdraws/pbarra.pwn"
	SetTimerEx("SpawnarPlayer", 200, false, "i", playerid);

	// Casa 1
	RemoveBuildingForPlayer(playerid, 14528, 2531.2891, -1676.7344, 1004.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 14493, 2535.8516, -1671.5703, 1016.7969, 0.25);
	// Casa da cerca bugada (Palomino)
	RemoveBuildingForPlayer(playerid, 1419, 2213.9063, 106.3906, 26.0078, 0.25);
	RemoveBuildingForPlayer(playerid, 1419, 242.8281, -121.5469, 1.1016, 0.25);
	// rcsigns.pwn
	RemoveBuildingForPlayer(playerid, 1408, 2333.9688, 221.7109, 26.0156, 0.25);
	RemoveBuildingForPlayer(playerid, 1408, 2333.9688, 227.1797, 26.0156, 0.25);
	return 1;
}

public OnPlayerText(playerid, text[]) {
	new p;
	p = CallLocalFunction("OnPlayerText@admin", "is", playerid, text);
	if(p) {
		new Float:P[6], str[144];
		GetPlayerPos(playerid, P[0], P[1], P[2]);
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(!IsPlayerConnected(i)) continue;
			GetPlayerPos(i, P[3], P[4], P[5]);
			new Float:D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
			if(D > ACTION_RANGE) continue;
			new color = floatround(255.0 - 153.0*D/ACTION_RANGE);
			color = (color*0x1000000 + color*0x10000 + color*0x100 + 0xAA);
			format(str, 180, "- %s diz: "BRANCO"%s", pName(playerid), text);
			new len = strlen(str);
			if(len > 100) {
				new str2[60];
				strmid(str2, str, 100, len);
				strdel(str, 100, 180);
				strins(str, "[...]", 100);
				strins(str2, "[...]", 0);
				SendClientMessage(i, color, str);
				SendClientMessage(i, color, str2);
			} else {
				SendClientMessage(i, color, str);
			}
		}
		CallLocalFunction("OnPlayerText@anim", "i", playerid);
	}
	return 0;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger) {
	CallLocalFunction("OnPlayerEnterVehicle@admin", "iii", playerid, vehicleid, ispassenger);
	return 1;
}

public OnPlayerCommandReceived(playerid, cmdtext[]) {
	if(pInfo[playerid][pLogged] != 1) return 0;
	return 1;
}

public OnPlayerCommandPerformed(playerid, cmdtext[], success) {
	if(!success) {
		new str[144];
		format(str, 144, "Comando inexistente - '"BEGE"%s"BRANCO"'.", cmdtext);
		Advert(playerid, str);
		return 1;
	}
	return 1;
}

public OnPlayerDisconnect(playerid, reason) {
	if(pInfo[playerid][pLogged] != 1) return ResetVars(playerid);
	for(new i = 0; i < MAX_VEHICLES; i++) {
		if(!vInfo[i][vSQL]) continue;
		if(vInfo[i][vChave] == pInfo[playerid][pSQL]) {
			for(new j = 0; j < MAX_BUSINESS_VEHICLES; j++) {
				if(bInfo[BUSID_BUSBB][bVehicles][j] == vInfo[i][vSQL]) {
					vInfo[i][vChave] = CLOC_EDOBB;
					SetVehicleToRespawn(i);
				} else if(bInfo[BUSID_AUTO][bVehicles][j] == vInfo[i][vSQL]) {
					vInfo[i][vChave] = CLOC_AUTO;
				} else if(bInfo[BUSID_CONC][bVehicles][j] == vInfo[i][vSQL]) {
					vInfo[i][vChave] = CLOC_CONC;
				} else if(bInfo[BUSID_REF][bVehicles][j] == vInfo[i][vSQL]) {
					vInfo[i][vChave] = CLOC_REF;
					SetVehicleToRespawn(i);
				} else if(bInfo[BUSID_TRANSP][bVehicles][j] == vInfo[i][vSQL]) {
					vInfo[i][vChave] = CLOC_TRANSP;
					SetVehicleToRespawn(i);
				}
			}
		}
	}
	for(new i = 0; i < MAX_VIATURAS; i++) {
		if(vInfo[Viatura[i]][vChave] == pInfo[playerid][pSQL]) {
			vInfo[Viatura[i]][vChave] = CLOC_RCSD;
			SetVehicleToRespawn(Viatura[i]);
		}
	}
	CallLocalFunction("OnPlayerDisconnect@bus", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@autoescola", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@admin", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@transp", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@lixeiro", "i", playerid);
	SavePlayerData(playerid);
	ResetVars(playerid);
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate) {
	CallLocalFunction("OnPlayerStateChange@vehicle", "iii", playerid, newstate, oldstate);
	CallLocalFunction("OnPlayerStateChange@admin", "iii", playerid, newstate, oldstate);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	CallLocalFunction("OnPlayerEnterCheckpoint@bus", "i", playerid);
	CallLocalFunction("OnPlayerEnterCheckpoint@auto", "i", playerid);
	CallLocalFunction("OnPlayerEnterCheckpoint@veh", "i", playerid);
	CallLocalFunction("OnPlayerEnterCheckpoint@ref", "i", playerid);
	CallLocalFunction("OnPlayerEnterCheckpoint@lixeiro", "i", playerid);
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	CallLocalFunction("OnPlayerKeyStateChange@vehicle", "iii", playerid, newkeys, oldkeys);
	return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid) {
	if(!pInfo[playerid][pTDSelect]) return 1;
	if(playertextid == PlayerText:INVALID_TEXT_DRAW) {
		if(pInfo[playerid][pTDSelect]) {
			SelectTextDraw(playerid, AmareloPalido);
		}
		return 1;
	}
	CallLocalFunction("OnPlayerClickPlayerTextDraw@bus", "ii", playerid, _:playertextid);
	return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid) {
	if(!pInfo[playerid][pTDSelect]) return 1;
	if(clickedid == Text:INVALID_TEXT_DRAW) {
		if(pInfo[playerid][pTDSelect]) {
			SelectTextDraw(playerid, AmareloPalido);
		}
		return 1;
	}
	CallLocalFunction("OnPlayerClickTextDraw@bus", "ii", playerid, _:clickedid);
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid) {
	CallLocalFunction("OnPlayerInteriorChange@admin", "iii", playerid, newinteriorid, oldinteriorid);
	return 1;
}

public OnPlayerVirtualWorldChange(playerid, newworldid, oldworldid) {
	CallLocalFunction("OnPlayerVirtualWorldChange@adm", "iii", playerid, newworldid, oldworldid);
	return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// FORWARDS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

forward Kickbans(playerid);
public Kickbans(playerid) {
	new r, t;
	cache_get_row_count(r);
	for(new i = 0; i < r; i++) {
		cache_get_value_name_int(i, "time", t);
		if(t > gettime()) {
			new str[144], name[24], motivo[30];
			cache_get_value_name(i, "staff", name);
			cache_get_value_name(i, "motivo", motivo);
			format(str, 144, "Você está expulso do servidor por mais %i segundos.", (t-gettime()));
			Advert(playerid, str);
			format(str, 144, "Staff: %s | Motivo: %s", name, motivo);
			Info(playerid, str);
			Info(playerid, "Caso queira discutir sobre a validade da sua expulsão, consulte em nosso fórum o tópico");
			Info(playerid, "sobre expulsões, punições e banimentos em "AMARELOPALIDO"denilfleckrp.forumeiros.com");
			KickPlayer(playerid);
			break;
		} else if(t == -1) {
			new str[144], name[24], motivo[30];
			cache_get_value_name(i, "staff", name);
			cache_get_value_name(i, "motivo", motivo);
			if(!strcmp(motivo, "NULL", false)) {
				Advert(playerid, "Seu IP está banido do servidor.");
			} else {
				Advert(playerid, "Sua conta está banida do servidor.");
				format(str, 144, "Staff: %s | Motivo: %s", name, motivo);
			}
			Info(playerid, str);
			Info(playerid, "Caso queira discutir sobre a validade da sua expulsão, consulte em nosso fórum o tópico");
			Info(playerid, "sobre expulsões, punições e banimentos em "AMARELOPALIDO"denilfleckrp.forumeiros.com");
			KickPlayer(playerid);
		}
	}
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
	SetPlayerPos(playerid, 225.0, -152.8 , 1.6);
	SetPlayerFacingAngle(playerid, 270.0);
	SetPlayerSkin(playerid, SKIN_BEGINNER);
	pInfo[playerid][pSkin] = SKIN_BEGINNER;
	pInfo[playerid][pLogged] = 2;
	pInfo[playerid][pSQL] = cache_insert_id();
	printf("Novo player registrado: %s [SQLID: %i]", pNick(playerid), pInfo[playerid][pSQL]);
	new str[250];
	format(str, 250, "Olá %s, seja bem-vindo à DenilFleck RP.\nGostaríamos de saber se você foi convidado por algum de nossos integrantes da equipe da administração.\nSe você foi, poderá receber alguns benefícios para sua conta.", pName(playerid));
	Dialog_Show(playerid, "AmICalled", DIALOG_STYLE_MSGBOX, "Convidado", str, "Sim", "Não");
	return 1;
}

forward LoadPlayerData(playerid);
public LoadPlayerData(playerid) {
	TogglePlayerSpectating(playerid, 0);
	pInfo[playerid][pLogged] = 2;
	new money, Float:P[4], interiorid, vw;
	cache_get_value_name_int(0, "pbus", pInfo[playerid][pBus]);
	cache_get_value_name_int(0, "score", pInfo[playerid][pLevel]);
	cache_get_value_name_int(0, "xp", pInfo[playerid][pXP]);
	cache_get_value_name_int(0, "money", money);
	cache_get_value_name_int(0, "skinid", pInfo[playerid][pSkin]);
	cache_get_value_name_int(0, "admin", pInfo[playerid][pAdmin]);
	cache_get_value_name_float(0, "sX", P[0]);
	cache_get_value_name_float(0, "sY", P[1]);
	cache_get_value_name_float(0, "sZ", P[2]);
	cache_get_value_name_float(0, "sA", P[3]);
	cache_get_value_name_int(0, "idv", bIDV[playerid]);
	cache_get_value_name_int(0, "interior", interiorid);
	cache_get_value_name_int(0, "vw", vw);
	cache_get_value_name_int(0, "comp", pInfo[playerid][pComprovante]);
	cache_get_value_name_int(0, "hab", pInfo[playerid][pHab]);
	cache_get_value_name_int(0, "tprisao", pInfo[playerid][ptPrisao]);
	cache_get_value_name_int(0, "org", pInfo[playerid][pOrg]);
	cache_get_value_name_int(0, "mp", pInfo[playerid][pMP]);
	SetPlayerScore(playerid, pInfo[playerid][pLevel]);
	GivePlayerMoney(playerid, money);
	SetPlayerSkin(playerid, pInfo[playerid][pSkin]);
	SetPlayerPos(playerid, P[0], P[1], P[2]);
	SetPlayerFacingAngle(playerid, P[3]);
	SetPlayerInterior(playerid, interiorid);
	SetPlayerVirtualWorld(playerid, vw);
	Streamer_UpdateEx(playerid, P[0], P[1], P[2], -1, -1, -1, 1500);
	if(pInfo[playerid][pAdmin] >= Ajudante) {
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////// STOCKS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

stock SavePlayerData(playerid) {
	new Float:P[4], ip[16];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[3]);
	GetPlayerIp(playerid, ip, 16);
	new query[400];
	mysql_format(conn, query, 400, "UPDATE `playerinfo` SET `mp` = %i, `ip` = '%s', `org` = %i, `tprisao` = %i, `hab` = %i,`comp` = %i, `xp` = %i, `interior` = %i, `vw` = %i, `idv` = %i, `admin` = %i, `score` = %i, `skinid` = %i, `money` = %i, `pbus` = %i, `sX` = %f, `sY` = %f, `sZ` = %f, `sA` = %f WHERE `sqlid` = %i",
		pInfo[playerid][pMP], ip, pInfo[playerid][pOrg], pInfo[playerid][ptPrisao], pInfo[playerid][pHab], pInfo[playerid][pComprovante], pInfo[playerid][pXP], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), bIDV[playerid], pInfo[playerid][pAdmin], pInfo[playerid][pLevel], pInfo[playerid][pSkin], (GetPlayerMoney(playerid)+pInfo[playerid][pMon]), pInfo[playerid][pBus], P[0], P[1], P[2], P[3], pInfo[playerid][pSQL]);
	mysql_query(conn, query, false);
	if(pInfo[playerid][pAdmin] >= Ajudante) {
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
	new k = MAX_PLAYERS-1;
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

stock Alert(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}%s", msg);
	SendClientMessage(playerid, LaranjaAvermelhado, str);
	return 1;
}

stock Act(playerid, const msg[]) {
	new Float:P[3], str[180];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 180, "* %s %s", pName(playerid), msg);
	new len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendRangedMessage(0xC2A2DAFF, str, ACTION_RANGE, P[0], P[1], P[2]);
		SendRangedMessage(0xC2A2DAFF, str2, ACTION_RANGE, P[0], P[1], P[2]);
	} else {
		SendRangedMessage(0xC2A2DAFF, str, ACTION_RANGE, P[0], P[1], P[2]);
	}
	return 1;
}

stock Amb(Float:X, Float:Y, Float:Z, const msg[]) {
	new str[180];
	format(str, 180, "* %s", msg);
	new len = strlen(str);
	if(len > 100) {
		new str2[60];
		strmid(str2, str, 100, len);
		strdel(str, 100, 180);
		strins(str, "[...]", 100);
		strins(str2, "[...]", 0);
		SendRangedMessage(0xC2A2DAFF, str, ACTION_RANGE, X, Y, Z);
		SendRangedMessage(0xC2A2DAFF, str2, ACTION_RANGE, X, Y, Z);
	} else {
		SendRangedMessage(0xC2A2DAFF, str, ACTION_RANGE, X, Y, Z);
	}
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
	SetTimerEx("TKickPlayer", 250, false, "i", playerid);
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

stock GetXPNextLevel(level) {
	new Float:l = level;
	return (floatround(floatpower(l, 2) + l)*50);
}

stock TextEncoding(string[]) {
	new original[50] = {192,193,194,196,198,199,200,201,202,203,204,205,206,207,210,211,212,214,217,218,219,220,223,224,225,226,228,230,231,232,233,234,235,236,237,238,239,242,243,244,246,249,250,251,252,209,241,191,161,176};
	new fixed[50] = {128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,94,124};
	new len = strlen(string);
	for (new i; i < len; i++) {
		for(new j;j < 50;j++) {
			if(string[i] == original[j]) {
				string[i] = fixed[j];
				break;
			}
		}
	}
	return 1;
}

stock TextDecoding(string[]) {
	new original[50] = {192,193,194,196,198,199,200,201,202,203,204,205,206,207,210,211,212,214,217,218,219,220,223,224,225,226,228,230,231,232,233,234,235,236,237,238,239,242,243,244,246,249,250,251,252,209,241,191,161,176};
	new fixed[50] = {128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,94,124};
	new len = strlen(string);
	for (new i; i < len; i++) {
		for(new j;j < 50;j++) {
			if(string[i] == fixed[j]) {
				string[i] = original[j];
				break;
			}
		}
	}
	return 1;
}

stock UnderlineToSpace(string[]) {
	new len = strlen(string);
	for(new i = 0; i < len; i++) {
		if(string[i] == '_') {
			string[i] = ' ';
		}
	}
	return 1;
}

stock SpaceToUnderline(string[]) {
	new len = strlen(string);
	for(new i = 0; i < len; i++) {
		if(string[i] == ' ') {
			string[i] = '_';
		}
	}
	return 1;
}

stock ResetDialogParams(playerid) {
	pInfo[playerid][pDialogParam][0] = 0;
	pInfo[playerid][pDialogParam][1] = 0;
	pInfo[playerid][pDialogParam][2] = 0;
	return 1;
}

stock PlaySoundAround(soundid, Float:X, Float:Y, Float:Z) {
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		PlayerPlaySound(i, soundid, X, Y, Z);
	}
	return 1;
}

stock IsLetter(c) {
	if((c > 64 && c < 91) || (c > 96 && c < 123)) return true;
	else return false;
}

stock IsUpperCase(c) {
	if(c > 64 && c < 91) return true;
	else return false;
}

stock GetpNickBySQL(sqlid) {
	new name[24], query[100], Cache:result, r;
	mysql_format(conn, query, 100, "SELECT nickname FROM playerinfo WHERE sqlid = %i", sqlid);
	result = mysql_query(conn, query, true);
	cache_get_row_count(r);
	if(!r) { name[0] = EOS; } else { cache_get_value_name(0, "nickname", name); }
	cache_delete(result);
	return name;
}

stock GetSQLBypNick(const nickname[25]) {
	new query[100], Cache:result, r, sql;
	mysql_format(conn, query, 100, "SELECT sqlid FROM playerinfo WHERE nickname = '%s'", nickname);
	result = mysql_query(conn, query, true);
	cache_get_row_count(r);
	if(!r) { sql = 0; } else { cache_get_value_index_int(0, 0, sql); }
	cache_delete(result);
	return sql;
}

stock GetPlayerIDBySQL(sqlid) {
	if(sqlid < 1) return -1;
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		if(pInfo[i][pSQL] == sqlid) return i;
	}
	return -1;
}