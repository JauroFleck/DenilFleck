#define HOST 		"198.50.187.244"
#define USER 		"denilfleckr_2567"
#define DATABASE 	"denilfleckr_2567"
#define PASS 		"4jdQ847DQT"

new MySQL:conn;

forward OnGameModeInit@sql();
public OnGameModeInit@sql() {
	conn = mysql_connect(HOST, USER, PASS, DATABASE);

	if(mysql_errno(conn)) { print("SEM CONEXAO A BASE DE DADOS"); return 0; } else { print("CONEXAO A BASE DE DADOS REALIZADA COM SUCESSO"); }
	return 1;
}

forward OnGameModeExit@sql();
public OnGameModeExit@sql() {
	mysql_close(conn);
	return 1;
}