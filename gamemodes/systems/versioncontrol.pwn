forward OnGameModeInit@version();
public OnGameModeInit@version() {
	new File:file = fopen("VERSION", io_read);
	new str[30];
	new len = fread(file, str);
	new i = 0, k = 0;
	fclose(file);
	for(; i != len; i++) {
		if(str[i] == '.') {
			k++;
			if(k == 2) break;
		}
	}
	new compilation = strval(str[i+1]) + 1;
	strdel(str, i+1, len);
	format(str, 30, "%s%i", str, compilation);
	file = fopen("VERSION", io_write);
	fwrite(file, str);
	fclose(file);
	format(str, 30, "[DF:RP] PT-BR (v%s)", str);
	SetGameModeText(str);
	return 1;
}