/*														DENILFLECK ROLEPLAY vBETA



													JAMAIS ESQUEÇA DE EFETUAR BACKUPS
														DO SERVIDOR E DA DATABASE




			INFORMAÇÕES IMPORTANTES
	- Fórmula para TOTAL de experiência conforme o nível: T(n) = (n³/6 + n²/2 + n/3)*100
	- Fórmula para experiência de CADA nível: F(n) = (n²+n)*50
	- Virtual Worlds: 0 - Mundo RP | 0 ~ MAX_BUSINESS-1 - Empresas | MAX_BUSINESS ~ MAX_BUSINESS+MAX_HOUSES-1 - Casas

			LEMBRETES
	- Setar > Casas, veículos, empresas e parâmetros de player (interior, vw, life, armor, score, money, BRL)
	- Kick, Ban, Spec
	- Sistema veicular (Ao deixar veículo ligado, chave fica na ignição | SetVehicleToRespawn - XYZA + interior + vw)
	- GPS no celular (Ao invés de Waze, Wize)
	- Sotaques na fala
	- /Inventario
	- /Punir (ADM) + /Despunir

																																		*/

#include <	a_samp		>
#include <	zcmd		>
#include <	sscanf2		>
#include <	easyDialog	>
#include < 	a_mysql		>
#include <	colors 		>
#include < 	streamer 	>

#define GameMode

#undef MAX_PLAYERS
#define MAX_PLAYERS 100
#undef MAX_VEHICLES
#define MAX_VEHICLES 200

#define SKIN_BEGINNER			35

#define ACTION_RANGE			(15.0)

#define CP_NONE					0
#define CP_BUS_ROUTE			1
#define CP_AVAUTO				2

#define Player  				0
#define Plantonista				1
#define Ajudante				2
#define Fiscalizador			3
#define Administrador			4
#define Senior 					5
#define Fundador				6

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
	pSpec
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

new Text:TDLogin[2];
new Text:TDGas[3];
new Text:TDManager[29];
new PlayerText:TDGasolina[MAX_PLAYERS];
new PlayerText:TDVelocidade[MAX_PLAYERS];
new PlayerText:PTDManager[MAX_PLAYERS][70];

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////// SYSTEMS /////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include "../systems/als.pwn"
#include "../systems/sql.pwn"
#include "../systems/time.pwn"
#include "../systems/vehicle.pwn"
#include "../systems/admin.pwn"
#include "../systems/animations.pwn"
#include "../systems/business.pwn"
#include "../systems/bus.pwn"
#include "../systems/posto.pwn"
#include "../systems/refinaria.pwn"
#include "../systems/bancopalomino.pwn"
#include "../systems/casa.pwn"
#include "../systems/autoescola.pwn"
#include "../systems/concessionaria.pwn"

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
	bIDV[playerid] = 0;
	sbBomba[playerid] = 0;
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
	if(isnull(params)) return AdvertCMD(playerid, "/Me [Ação]");
	Act(playerid, params);
	return 1;
}

CMD:do(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/Do [Ação]");
	new str[144], Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 144, "%s "BRANCO"(( %s ))", params, pName(playerid));
	Amb(P[0], P[1], P[2], str);
	return 1;
}

CMD:b(playerid, params[]) {
	if(isnull(params)) return AdvertCMD(playerid, "/B [Mensagem OOC]");
	new str[144], Float:P[3];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	format(str, 144, "(( ID %02i: %s ))", playerid, params);
	SendRangedMessage(Branco, str, ACTION_RANGE, P[0], P[1], P[2]);
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
	if(pInfo[playerid][pBus] == -1) {
		//if(emcasa) ...
		Advert(playerid, "Você é desempregado.");
	} else if(bInfo[pInfo[playerid][pBus]][bType] == BUSINESS_BUS) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 1490.7517,1308.0670,1093.2891)) return Advert(playerid, "As chaves dos ônibus ficam na secretaria da estação.");
		new vid;
		if(sscanf(params, "i", vid)) return AdvertCMD(playerid, "/PegarChave [IDV]");
		if(!IsValidVehicle(vid)) return Advert(playerid, "Veículo inexistente.");
		if(!vInfo[vid][vSQL]) return Advert(playerid, "Veículo não registrado no banco de dados.");
		new i = 0;
		for(; i < MAX_BUSINESS_VEHICLES; i++) {
			if(bInfo[pInfo[playerid][pBus]][bVehicles][i] == vInfo[vid][vSQL]) { break; }
		}
		if(i == MAX_BUSINESS_VEHICLES) return Advert(playerid, "Esse veículo não pertence a sua empresa.");
		if(vInfo[vid][vChave] != CLOC_EDOBB) {
			Act(playerid, "procura por uma chave dentro da gaveta mas não a encontra.");
		} else {
			Act(playerid, "retira de dentro da gaveta uma chave.");
			vInfo[vid][vChave] = pInfo[playerid][pSQL];
		}
	} else if(bInfo[pInfo[playerid][pBus]][bType] == BUSINESS_AUTO) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 361.4470,198.5358,1084.1685)) return Advert(playerid, "As chaves dos veículos ficam na secretaria da autoescola.");
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
	if(pInfo[playerid][pBus] == -1) {
		//if(emcasa) ...
		Advert(playerid, "Você é desempregado.");
	} else if(bInfo[pInfo[playerid][pBus]][bType] == BUSINESS_BUS) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 1490.7517,1308.0670,1093.2891)) return Advert(playerid, "As chaves dos ônibus devem ser guardadas na secretaria da estação.");
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
		}
	} else if(bInfo[pInfo[playerid][pBus]][bType] == BUSINESS_AUTO) {
		if(!IsPlayerInRangeOfPoint(playerid, 2.0, 361.4470,198.5358,1084.1685)) return Advert(playerid, "As chaves dos veículos ficam na secretaria da autoescola.");
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////// DIALOGS ////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Dialog:DialogAjuda(playerid, response, listitem, inputtext[]) {
	if(!response) return 1;
	if(listitem == 0) { //				Nível
		new str[250];
		format(str, 250, "A cada 10 minutos você ganha 10 XP, ações no servidor contabilizam XP extra para você.\n100 XP = Nível 1; 200 XP = Nível 2; assim subsequentemente.\n- Experiência: %i/%iXP\n- Nível: %i", pInfo[playerid][pXP], GetXPNextLevel(pInfo[playerid][pLevel]), pInfo[playerid][pLevel]);
		Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "Nível", str, "Fechar", "");
	} else if(listitem == 1) { //		Profissão
		if(pInfo[playerid][pBus] == -1) return Info(playerid, "Você é desempregado.");
		new str[150], i = 0;
		for(; i < MAX_CARGOS; i++) {
			if(!cInfo[pInfo[playerid][pBus]][i][cSQL]) continue;
			else if(strcmp(cInfo[pInfo[playerid][pBus]][i][cEmp], pName(playerid), true)) continue;
			else break;
		}
		if(i == MAX_CARGOS) return Advert(playerid, "Informe da administração sobre essa mensagem de erro. [COD 011]");
		format(str, 150, "Você trabalha para a empresa %s no cargo de %s.", bInfo[pInfo[playerid][pBus]][bName], cInfo[pInfo[playerid][pBus]][i][cName]);
		Dialog_Show(playerid, "Dialog_None", DIALOG_STYLE_MSGBOX, "PROFISSÃO", str, "Fechar", "");
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

	// MAPAS

	print("Carregando mapas...");
	#include "../maps/bus.pwn"
	#include "../maps/newbiespawn.pwn"
	#include "../maps/postomg.pwn"
	#include "../maps/postodm.pwn"
	#include "../maps/refinaria.pwn"
	#include "../maps/bancopalomino.pwn"
	#include "../maps/palomino.pwn"
	#include "../maps/interiores.pwn"
	#include "../maps/autoescola.pwn"
	#include "../maps/concessionaria.pwn"
	print("Mapas carregados com sucesso.");

	// TEXTDRAWS

	#include "../textdraws/login.pwn"
	#include "../textdraws/gas.pwn"
	#include "../textdraws/manager.pwn"

	//

	ManualVehicleEngineAndLights();
	DisableInteriorEnterExits();
	SetGameModeText("[DF:RP] PT-BR (vBeta)");

	EnableStuntBonusForAll(0);
	ShowNameTags(0);
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);

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
	if(playerid >= MAX_PLAYERS) {
		Advert(playerid, "Notifique a administração sobre essa mensagem de erro imediatamente! [COD000]");
		KickPlayer(playerid);
		return 1;
	}
	new query[150];
	mysql_format(conn, query, 150, "SELECT * FROM kickbans WHERE name = '%s'", pNick(playerid));
	mysql_tquery(conn, query, "Kickbans", "i", playerid);
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
	CallLocalFunction("OnPlayerConnect@posto", "i", playerid);
	CallLocalFunction("OnPlayerConnect@autoescola", "i", playerid);
	#include "../textdraws/pgas.pwn"
	#include "../textdraws/pmanager.pwn"
	SetTimerEx("SpawnarPlayer", 200, false, "i", playerid);

	// Casa 1
	RemoveBuildingForPlayer(playerid, 14528, 2531.2891, -1676.7344, 1004.7344, 0.25);
	RemoveBuildingForPlayer(playerid, 14493, 2535.8516, -1671.5703, 1016.7969, 0.25);
	// Casa da cerca bugada (Palomino)
	RemoveBuildingForPlayer(playerid, 1419, 2213.9063, 106.3906, 26.0078, 0.25);
	RemoveBuildingForPlayer(playerid, 1419, 242.8281, -121.5469, 1.1016, 0.25);

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
			format(str, 144, "- %s fala: "BRANCO"%s", pName(playerid), text);
			SendClientMessage(i, color, str);
		}
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
	CallLocalFunction("OnPlayerDisconnect@bus", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@autoescola", "i", playerid);
	CallLocalFunction("OnPlayerDisconnect@admin", "i", playerid);
	SavePlayerData(playerid);
	ResetVars(playerid);
	return 1;
}

public OnPlayerDeath(playerid) {
	pInfo[playerid][pSkin] = GetPlayerSkin(playerid);
	return 1;
}

public OnPlayerSpawn(playerid) {
	if(pInfo[playerid][pLogged] == 2) { // Logou-se com sucesso
		for(new i = 0; i < sizeof(TDLogin); i++) { TextDrawHideForPlayer(playerid, TDLogin[i]); }
		StopAudioStreamForPlayer(playerid);
		SetPlayerVirtualWorld(playerid, 0);
		pInfo[playerid][pLogged] = 1;
		return 1;
	} else if(!pInfo[playerid][pLogged]) { // Conectou-se ao servidor
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

public OnPlayerStateChange(playerid, newstate, oldstate) {
	CallLocalFunction("OnPlayerStateChange@vehicle", "iii", playerid, newstate, oldstate);
	CallLocalFunction("OnPlayerStateChange@admin", "iii", playerid, newstate, oldstate);
	return 1;
}

public OnPlayerEnterCheckpoint(playerid) {
	CallLocalFunction("OnPlayerEnterCheckpoint@bus", "i", playerid);
	CallLocalFunction("OnPlayerEnterCheckpoint@auto", "i", playerid);
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
			Advert(playerid, "Você está banido do servidor.");
			format(str, 144, "Staff: %s | Motivo: %s", name, motivo);
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
	new money, skinid, Float:P[4], interiorid, vw;
	cache_get_value_name_int(0, "pbus", pInfo[playerid][pBus]);
	cache_get_value_name_int(0, "score", pInfo[playerid][pLevel]);
	cache_get_value_name_int(0, "xp", pInfo[playerid][pXP]);
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
	cache_get_value_name_int(0, "comp", pInfo[playerid][pComprovante]);
	cache_get_value_name_int(0, "hab", pInfo[playerid][pHab]);
	SetPlayerScore(playerid, pInfo[playerid][pLevel]);
	GivePlayerMoney(playerid, money);
	SetPlayerSkin(playerid, skinid);
	SetPlayerPos(playerid, P[0], P[1], P[2]);
	SetPlayerFacingAngle(playerid, P[3]);
	SetPlayerInterior(playerid, interiorid);
	SetPlayerVirtualWorld(playerid, vw);
	Streamer_UpdateEx(playerid, P[0], P[1], P[2], vw, interiorid, -1, 1500);
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////// STOCKS ///////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

stock SavePlayerData(playerid) {
	new Float:P[4];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[3]);
	new query[300];
	mysql_format(conn, query, 300, "UPDATE `playerinfo` SET `hab` = %i,`comp` = %i, `xp` = %i, `interior` = %i, `vw` = %i, `idv` = %i, `admin` = %i, `score` = %i, `skinid` = %i, `money` = %i, `pbus` = %i, `sX` = %f, `sY` = %f, `sZ` = %f, `sA` = %f WHERE `sqlid` = %i",
		pInfo[playerid][pHab], pInfo[playerid][pComprovante], pInfo[playerid][pXP], GetPlayerInterior(playerid), GetPlayerVirtualWorld(playerid), bIDV[playerid], pInfo[playerid][pAdmin], pInfo[playerid][pLevel], GetPlayerSkin(playerid), GetPlayerMoney(playerid), pInfo[playerid][pBus], P[0], P[1], P[2], P[3], pInfo[playerid][pSQL]);
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

stock Alert(playerid, const msg[]) {
	new str[144];
	format(str, 144, "[>] {FFFFFF}%s", msg);
	SendClientMessage(playerid, LaranjaAvermelhado, str);
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