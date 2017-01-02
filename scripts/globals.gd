extends Node

var vehicleColorSet = [
	Color("222222"),
	Color("ababab"),
	Color("2c5f93"),
	Color("932c2c"),
	Color("cfcd42"),
	Color("5c982c"),
	Color("bf5b9d"),
	Color("e55731")
];

var vehicleColor = [
	Color("2c5f93"),
	Color("932c2c")
];

var highScore = 0;

var filePass = str("myuniquepassword").md5_text();
var saveGame = "user://savegame.dat";
var gameData = {};
var encrypedSavegame = false;
var targetFPS = [0, 30, 60, 120];
var fpsLabel;

enum SHADOWS {
	VERY_LOW = 0,
	LOW,
	MEDIUM,
	HIGH,
	VERY_HIGH
};

func _ready():
	# Create Canvas Layer for GUI
	var layer = CanvasLayer.new();
	layer.set_layer(5);
	add_child(layer);
	
	# Create FPS Label
	fpsLabel = Label.new();
	fpsLabel.set_name("lblFPS");
	fpsLabel.set_text("");
	fpsLabel.set_pos(Vector2(10, 10));
	layer.add_child(fpsLabel);
	
	load_game();
	apply_configs();
	
	set_process(true);

func _process(delta):
	if (fpsLabel.is_visible()):
		fpsLabel.set_text("FPS: "+str(OS.get_frames_per_second()));

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

func set_gamedata(key, val):
	gameData[key] = val;

func get_gamedata(key, defval):
	if (gameData.has(key)):
		return gameData[key];
	
	return defval;

func apply_configs():
	if (get_gamedata('cfg_showfps', false)):
		fpsLabel.show();
	else:
		fpsLabel.hide();
	
	OS.set_window_fullscreen(get_gamedata('cfg_fullscreen', true));
	OS.set_target_fps(targetFPS[get_gamedata('cfg_targetfps', 0)]);
	OS.set_low_processor_usage_mode(get_gamedata('cfg_lowprocess', false));
	
	var shadows_quality = get_gamedata('cfg_shadows_quality', 0);
	var buffer_size = 2048;
	var shadow_filter = 0;
	
	if (shadows_quality == SHADOWS.VERY_LOW):
		buffer_size = 512;
		shadow_filter = 0;
	if (shadows_quality == SHADOWS.LOW):
		buffer_size = 1024;
		shadow_filter = 0;
	if (shadows_quality == SHADOWS.MEDIUM):
		buffer_size = 2048;
		shadow_filter = 1;
	if (shadows_quality == SHADOWS.HIGH):
		buffer_size = 2048;
		shadow_filter = 2;
	if (shadows_quality == SHADOWS.VERY_HIGH):
		buffer_size = 4096;
		shadow_filter = 2;
	
	Globals.set("rasterizer/max_shadow_buffer_size", buffer_size);
	Globals.set("rasterizer/shadow_filter", shadow_filter);
	
	Globals.save();
