extends Node

var vehicleColor = [
	Color("2c5f93"),
	Color("932c2c")
];

var highScore = 0;

var filePass = str("myuniquepassword").md5_text();
var saveGame = "user://savegame.dat";
var gameData = {};
var encrypedSavegame = true;

func _ready():
	load_game();

func _exit_tree():
	save_game();

func load_game():
	var f = File.new();
	if (!f.file_exists(saveGame)):
		save_game();
	if (encrypedSavegame):
		f.open_encrypted_with_pass(saveGame, f.READ, filePass);
	else:
		f.open(saveGame, f.READ);
	var data = f.get_as_text();
	gameData.parse_json(data);
	f.close();
	
	var vCol = get_gamedata('vehicle_color', ["2c5f93", "932c2c"]);
	vehicleColor[0] = Color(vCol[0]);
	vehicleColor[1] = Color(vCol[1]);
	
	highScore = get_gamedata('highscore', 0);

func save_game():
	gameData['vehicle_color'] = [
		vehicleColor[0].to_html(false),
		vehicleColor[1].to_html(false)
	];
	
	gameData['highscore'] = highScore;
	
	var f = File.new();
	if (encrypedSavegame):
		f.open_encrypted_with_pass(saveGame, f.WRITE, filePass);
	else:
		f.open(saveGame, f.WRITE);
	f.store_string(gameData.to_json());
	f.close();

func get_gamedata(key, defval):
	if (gameData.has(key)):
		return gameData[key];
	
	return defval;
