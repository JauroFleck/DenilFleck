#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <colors>
#include <streamer>
#include <mobmove>

#define Gamemode

#define ACTION_RANGE			(15.0)

main() {}

public OnPlayerConnect(playerid) {
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
				if(!(name[j+1] == 'M' && name[j+2] == 'c')) { condition = 6; break; }
			} else { condition = 5; break;
			}
		}
	}
	if(condition != 3) {
		Advert(playerid, "Seu nickname está fora do padrão RP exigido pelo servidor.");
		Info(playerid, "Entre novamente mas com um nickname no formato "CINZAAZULADO"Nome_Sobrenome"BRANCO".");
		//KickPlayer(playerid);
		return 1;
	}
	return 1;
}

CMD:testmove(playerid) {
	new Float:P[6];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	GetPlayerFacingAngle(playerid, P[3]);
	new obj = CreateDynamicObject(3799, P[0], P[1], P[2], 0.0, 0.0, P[3]);
	new time = MoveDynamicObject(obj, P[0], P[1]+5.0, P[2], 1.0);
	new str[144];
	format(str, 144, "Objeto ID %05i sendo movido em %ims.", obj, time);
	Info(playerid, str);
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

CMD:name(playerid, params[]) {
	new name[24];
	if(sscanf(params, "s[24]", name)) return AdvertCMD(playerid, "/Name [Nome_Sobrenome]");
	new j = 100, condition = 0, len = strlen(name);
	for(new i = 0; i < len; i++) {
		if(!IsLetter(name[i])) {
			if(name[i] == '_') { j = i; condition++; } else { condition = 4; break; }
		} else if(IsUpperCase(name[i])) {
			if(i == 0) { condition ++;
			} else if(i == j+1) { condition ++;
			} else if(i == j+3) {
				if(!(name[j+1] == 'M' && name[j+2] == 'c')) { condition = 6; break; }
			} else { condition = 5; break;
			}
		}
	}
	if(condition != 3) Advert(playerid, "Nome fora de formato \"Nome_Sobrenome\".");
	else Advert(playerid, "Nome dentro do padrão!!!");
	return 1;
}

public OnPlayerText(playerid, text[]) {
	new Float:P[6], str[180];
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
	return 0;
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
		new color = floatround(255.0 - 153.0*D/ACTION_RANGE*2.5);
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
	if(isnull(params)) return AdvertCMD(playerid, "/G [Grito]");
	new Float:P[6], str[180];
	GetPlayerPos(playerid, P[0], P[1], P[2]);
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(!IsPlayerConnected(i)) continue;
		GetPlayerPos(i, P[3], P[4], P[5]);
		new Float:D = VectorSize(P[0]-P[3], P[1]-P[4], P[2]-P[5]);
		if(D > ACTION_RANGE*0.25) continue;
		new color = floatround(255.0 - 153.0*D/ACTION_RANGE*0.25);
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

CMD:mp(playerid, params[]) {
	new id, msg[125], str[180];
	if(sscanf(params, "is[125]", id, msg)) return AdvertCMD(playerid, "/MP [ID] [Mensagem]");
	if(!IsPlayerConnected(id)) return Advert(playerid, "ID inválido.");
	if(playerid == id) return Advert(playerid, "Não seja tão solitário a ponto de enviar mensagem privada para si próprio :(");
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

stock pName(playerid) {
	new name[24];
	GetPlayerName(playerid, name, 24);
	for(new i = 0; i < 24; i++) { if(name[i] == '_') { name[i] = ' '; } }
	return name;
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

stock pNick(playerid) {
	new Name[24];
	GetPlayerName(playerid, Name, 24);
	return Name;
}

stock IsLetter(c) {
	if((c > 64 && c < 91) || (c > 96 && c < 123)) return true;
	else return false;
}

stock IsUpperCase(c) {
	if(c > 64 && c < 91) return true;
	else return false;
}