#define FilterScript

public OnPlayerCommandText(playerid, cmdtext[]) {
	if(!strcmp(cmdtext, "/jump", true)) {
		return 1;
	}
	return 0;
}