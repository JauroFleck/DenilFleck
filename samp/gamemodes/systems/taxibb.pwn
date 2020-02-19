forward OnPlayerConnect@taxibb(playerid);
public OnPlayerConnect@taxibb(playerid) {
	RemoveBuildingForPlayer(playerid, 13190, 308.093, -168.727, 4.367, 0.250);
	RemoveBuildingForPlayer(playerid, 13203, 308.093, -168.727, 4.367, 0.250);
	return 1;
}