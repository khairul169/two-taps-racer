extends Node

var globalTime = 0.0;

var vehicleColorSet = [
	Color("2c5f93"),
	Color("932c2c"),
	Color("222222"),
	Color("ababab"),
	Color("cfcd42"),
	Color("5c982c"),
	Color("bf5b9d"),
	Color("e55731")
];

var unlockedColorSet = [];
var vehicleColor = [vehicleColorSet[0], vehicleColorSet[1]];

var trackList = [
	{'name': "desert", 'title': "Desert"},
	{'name': "plains", 'title': "Plains"}
];
var trackSelected = -1;

var bestRun = 0;
var totalCoins = 0;

var filePass = str("myuniquepassword").md5_text();
var saveGame = "user://savegame.dat";
var gameData = {};
var encrypedSavegame = false;
var targetFPS = [0, 30, 60, 120];
var fpsLabel;
var fpsNextUpdate = 0.0;

enum SHADOWS {
	VERY_LOW = 0,
	LOW,
	MEDIUM,
	HIGH,
	VERY_HIGH
};

var quitRequestHandler = null;

func _ready():
	get_tree().set_auto_accept_quit(false);
	
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
	
	# Test
	for i in range(0, vehicleColorSet.size()):
		unlockedColorSet.push_back(i);
	
	set_process(true);

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		if (quitRequestHandler != null):
			quitRequestHandler.node.call(quitRequestHandler.method);
		else:
			get_tree().quit();

func handle_quitRequest(node = null, method = ""):
	if (!node):
		quitRequestHandler = null;
	else:
		quitRequestHandler = {'node': node, 'method': method};

func _process(delta):
	globalTime += delta;
	
	if (fpsLabel.is_visible() && globalTime > fpsNextUpdate):
		fpsLabel.set_text("FPS: "+str(OS.get_frames_per_second()));
		fpsNextUpdate = globalTime+1.0;

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
	
	unlockedColorSet = get_gamedata('color_unlocked', []);
	var col = get_gamedata('vehicle_color', [vehicleColorSet[0].to_html(false), vehicleColorSet[1].to_html(false)]);
	vehicleColor = [Color(col[0]), Color(col[1])];
	
	bestRun = get_gamedata('bestrun', 0);
	totalCoins = get_gamedata('coins', 0);

func save_game():
	set_gamedata('color_unlocked', unlockedColorSet);
	set_gamedata('vehicle_color', [vehicleColor[0].to_html(false), vehicleColor[1].to_html(false)]);
	set_gamedata('bestrun', bestRun);
	set_gamedata('coins', totalCoins);
	
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
