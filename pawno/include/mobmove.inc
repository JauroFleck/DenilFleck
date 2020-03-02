//////////	THIS INCLUDE IS RECOMMENDED JUST IF YOUR MOBILE CLIENT DO NOT HAVE SUPPORT FOR SA-MP NATIVE MOVING OBJECTS FUNCTIONS
//////////	AUTHOR: Jauro Fleck
//////////	REPOSITORY: www.github.com/JauroFleck/mobmove
//////////	VERSION: 0.1

//////////	MoveObject

#define MAX_SIMULTANEOUS_MOVING_OBJECTS			(100)		// DO NOT CHANGE THIS VALUE TO SOMETHING HIGHER THAN 1000
#define MS_MOVING_RATE							(100)		// AVOID CHANGING THIS RATE UNLESS YOU KNOW WHAT YOU ARE DOING

enum MobileMovingObjects_enum { mobmove_objectid, Float:mobmove_speed, Float:mobmove_tox, Float:mobmove_toy, Float:mobmove_toz, Float:mobmove_torotx, Float:mobmove_toroty, Float:mobmove_torotz };

new Mobile_MovingObjects[MAX_SIMULTANEOUS_MOVING_OBJECTS][MobileMovingObjects_enum];

stock Mobile_MoveObject(objectid, Float:x, Float:y, Float:z, Float:speed, Float:rotx = -1000.0, Float:roty = -1000.0, Float:rotz = -1000.0) {
	new i = 0, p = -1;
	for(; i != MAX_SIMULTANEOUS_MOVING_OBJECTS; i++) {
		if(Mobile_MovingObjects[i][mobmove_objectid] == objectid) break;
		else if(p == -1) {
			if(!Mobile_MovingObjects[i][mobmove_objectid]) { p = i; }
		}
	}
	if(i == MAX_SIMULTANEOUS_MOVING_OBJECTS) {
		if(p == -1) return printf("MOBMOVE.INC - AN ERROR HAS OCCURRED: PLEASE INCREASE 'MAX_SIMULTANEOUS_MOVING_OBJECTS' TO SOMETHING HIGHER THAN (%i).", MAX_SIMULTANEOUS_MOVING_OBJECTS);
		else {
			i = p;
			Mobile_MovingObjects[i][mobmove_objectid] = objectid;
			Mobile_MovingObjects[i][mobmove_speed] = speed;
			Mobile_MovingObjects[i][mobmove_tox] = x;
			Mobile_MovingObjects[i][mobmove_toy] = y;
			Mobile_MovingObjects[i][mobmove_toz] = z;
			Mobile_MovingObjects[i][mobmove_torotx] = rotx;
			Mobile_MovingObjects[i][mobmove_toroty] = roty;
			Mobile_MovingObjects[i][mobmove_torotz] = rotz;
		}
	}
	new Float:P[3];
	GetObjectPos(objectid, P[0], P[1], P[2]);
	new Float:xdistance = x-P[0], Float:ydistance = y-P[1], Float:zdistance = z-P[2];
	new Float:totaldistance = VectorSize(xdistance, ydistance, zdistance);
	new Float:time = floatdiv(totaldistance, speed)*1000.0;
	new Float:xtinydistance = (xdistance/time)*MS_MOVING_RATE;
	new Float:ytinydistance = (ydistance/time)*MS_MOVING_RATE;
	new Float:ztinydistance = (zdistance/time)*MS_MOVING_RATE;
	if(VectorSize(xtinydistance, ytinydistance, ztinydistance) >= totaldistance) {
		SetObjectPos(objectid, x, y, z);
		if(rotx != -1000.0 && roty != -1000.0 && rotz != -1000.0) {
			SetObjectRot(objectid, rotx, roty, rotz);
		}
		Mobile_MovingObjects[i][mobmove_objectid] = 0;
		Mobile_MovingObjects[i][mobmove_speed] = 0.0;
		Mobile_MovingObjects[i][mobmove_tox] = 0.0;
		Mobile_MovingObjects[i][mobmove_toy] = 0.0;
		Mobile_MovingObjects[i][mobmove_toz] = 0.0;
		Mobile_MovingObjects[i][mobmove_torotx] = 0.0;
		Mobile_MovingObjects[i][mobmove_toroty] = 0.0;
		Mobile_MovingObjects[i][mobmove_torotz] = 0.0;
	} else {
		SetObjectPos(objectid, P[0]+xtinydistance, P[1]+ytinydistance, P[2]+ztinydistance);
		if(rotx != -1000.0 && roty != -1000.0 && rotz != -1000.0) {
			new Float:R[3];
			GetObjectRot(objectid, R[0], R[1], R[2]);
			new Float:deltarotx = rotx-R[0], Float:deltaroty = roty-R[1], Float:deltarotz = rotz-R[2];
			new Float:tinydeltarotx = (deltarotx/time)*MS_MOVING_RATE;
			new Float:tinydeltaroty = (deltaroty/time)*MS_MOVING_RATE;
			new Float:tinydeltarotz = (deltarotz/time)*MS_MOVING_RATE;
			SetObjectRot(objectid, R[0]+tinydeltarotx, R[1]+tinydeltaroty, R[2]+tinydeltarotz);
		}
		SetTimerEx("Mobile_ObjectMoving", MS_MOVING_RATE, false, "i", objectid);
	}
	return floatround(time);
}

#if defined _ALS_MoveObject
    #undef MoveObject
#else
    #define _ALS_MoveObject
#endif
#define MoveObject Mobile_MoveObject

//////////	IsObjectMoving

stock Mobile_IsObjectMoving(objectid) {
	for(new i = 0; i != MAX_SIMULTANEOUS_MOVING_OBJECTS; i++) {
		if(Mobile_MovingObjects[i][mobmove_objectid] == objectid) return true;
	}
	return false;
}

#if defined _ALS_IsObjectMoving
    #undef IsObjectMoving
#else
    #define _ALS_IsObjectMoving
#endif
#define IsObjectMoving Mobile_IsObjectMoving

////////// Streamer Functions

#if defined _streamer_included
	stock Mobile_MoveDynamicObject(STREAMER_TAG_OBJECT:objectid, Float:x, Float:y, Float:z, Float:speed, Float:rotx = -1000.0, Float:roty = -1000.0, Float:rotz = -1000.0) {
		new i = 0, p = -1;
		for(; i != MAX_SIMULTANEOUS_MOVING_OBJECTS; i++) {
			if(Mobile_MovingObjects[i][mobmove_objectid] == objectid) break;
			else if(p == -1) {
				if(!Mobile_MovingObjects[i][mobmove_objectid]) { p = i; }
			}
		}
		if(i == MAX_SIMULTANEOUS_MOVING_OBJECTS) {
			if(p == -1) return printf("MOBMOVE.INC - AN ERROR HAS OCCURRED: PLEASE INCREASE 'MAX_SIMULTANEOUS_MOVING_OBJECTS' TO SOMETHING HIGHER THAN (%i).", MAX_SIMULTANEOUS_MOVING_OBJECTS);
			else {
				i = p;
				Mobile_MovingObjects[i][mobmove_objectid] = objectid;
				Mobile_MovingObjects[i][mobmove_speed] = speed;
				Mobile_MovingObjects[i][mobmove_tox] = x;
				Mobile_MovingObjects[i][mobmove_toy] = y;
				Mobile_MovingObjects[i][mobmove_toz] = z;
				Mobile_MovingObjects[i][mobmove_torotx] = rotx;
				Mobile_MovingObjects[i][mobmove_toroty] = roty;
				Mobile_MovingObjects[i][mobmove_torotz] = rotz;
			}
		}
		new Float:P[3];
		GetDynamicObjectPos(objectid, P[0], P[1], P[2]);
		new Float:xdistance = x-P[0], Float:ydistance = y-P[1], Float:zdistance = z-P[2];
		new Float:totaldistance = VectorSize(xdistance, ydistance, zdistance);
		new Float:time = floatdiv(totaldistance, speed)*1000.0;
		new Float:xtinydistance = (xdistance/time)*MS_MOVING_RATE;
		new Float:ytinydistance = (ydistance/time)*MS_MOVING_RATE;
		new Float:ztinydistance = (zdistance/time)*MS_MOVING_RATE;
		if(VectorSize(xtinydistance, ytinydistance, ztinydistance) >= totaldistance) {
			SetDynamicObjectPos(objectid, x, y, z);
			if(rotx != -1000.0 && roty != -1000.0 && rotz != -1000.0) {
				SetDynamicObjectRot(objectid, rotx, roty, rotz);
			}
			Mobile_MovingObjects[i][mobmove_objectid] = 0;
			Mobile_MovingObjects[i][mobmove_speed] = 0.0;
			Mobile_MovingObjects[i][mobmove_tox] = 0.0;
			Mobile_MovingObjects[i][mobmove_toy] = 0.0;
			Mobile_MovingObjects[i][mobmove_toz] = 0.0;
			Mobile_MovingObjects[i][mobmove_torotx] = 0.0;
			Mobile_MovingObjects[i][mobmove_toroty] = 0.0;
			Mobile_MovingObjects[i][mobmove_torotz] = 0.0;
		} else {
			SetDynamicObjectPos(objectid, P[0]+xtinydistance, P[1]+ytinydistance, P[2]+ztinydistance);
			if(rotx != -1000.0 && roty != -1000.0 && rotz != -1000.0) {
				new Float:R[3];
				GetDynamicObjectRot(objectid, R[0], R[1], R[2]);
				new Float:deltarotx = rotx-R[0], Float:deltaroty = roty-R[1], Float:deltarotz = rotz-R[2];
				new Float:tinydeltarotx = (deltarotx/time)*MS_MOVING_RATE;
				new Float:tinydeltaroty = (deltaroty/time)*MS_MOVING_RATE;
				new Float:tinydeltarotz = (deltarotz/time)*MS_MOVING_RATE;
				SetDynamicObjectRot(objectid, R[0]+tinydeltarotx, R[1]+tinydeltaroty, R[2]+tinydeltarotz);
			}
			SetTimerEx("Mobile_DynamicObjectMoving", MS_MOVING_RATE, false, "i", objectid);
		}
		return floatround(time);
	}

	#if defined _ALS_MoveDynamicObject
	    #undef MoveDynamicObject
	#else
	    #define _ALS_MoveDynamicObject
	#endif
	#define MoveDynamicObject Mobile_MoveDynamicObject
#endif

forward Mobile_ObjectMoving(objectid);
public Mobile_ObjectMoving(objectid) {
	new i = 0;
	for(; i != MAX_SIMULTANEOUS_MOVING_OBJECTS; i++) {
		if(Mobile_MovingObjects[i][mobmove_objectid] == objectid) break;
	}
	if(i == MAX_SIMULTANEOUS_MOVING_OBJECTS) return false;
	else return Mobile_MoveObject(objectid, Mobile_MovingObjects[i][mobmove_tox], Mobile_MovingObjects[i][mobmove_toy], Mobile_MovingObjects[i][mobmove_toz], Mobile_MovingObjects[i][mobmove_speed], Mobile_MovingObjects[i][mobmove_torotx], Mobile_MovingObjects[i][mobmove_toroty], Mobile_MovingObjects[i][mobmove_torotz]);
}

forward Mobile_DynamicObjectMoving(objectid);
public Mobile_DynamicObjectMoving(objectid) {
	new i = 0;
	for(; i != MAX_SIMULTANEOUS_MOVING_OBJECTS; i++) {
		if(Mobile_MovingObjects[i][mobmove_objectid] == objectid) break;
	}
	if(i == MAX_SIMULTANEOUS_MOVING_OBJECTS) return false;
	else return Mobile_MoveDynamicObject(objectid, Mobile_MovingObjects[i][mobmove_tox], Mobile_MovingObjects[i][mobmove_toy], Mobile_MovingObjects[i][mobmove_toz], Mobile_MovingObjects[i][mobmove_speed], Mobile_MovingObjects[i][mobmove_torotx], Mobile_MovingObjects[i][mobmove_toroty], Mobile_MovingObjects[i][mobmove_torotz]);
}