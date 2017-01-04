extends Node

onready var lblScore = get_node("gui/score");
onready var lblScore2 = get_node("gui/score2");
onready var lblCoins = get_node("gui/coins");

onready var camera = get_node("world/cam_base");
onready var level = get_node("world/level");

onready var vehicle = load("res://scenes/vehicle.tscn");
onready var vehicle_node = get_node("world/vehicle");

onready var vehicle_ai = load("res://scenes/vehicle_ai.tscn");
onready var vehicle_aiNode = get_node("world/vehicle_ai");

onready var item_coin = load("res://scenes/items/coin.tscn");
onready var items_node = get_node("world/items");

var curPos = Vector3();
var curSpeed = 0.0;
var vehiclePos = [0, 0];
var curRunLength = 0.0;
var curCoins = 0;

var viewportSize = Vector2();

var gameTime = 0.0;
var gameStarted = false;
var gameOver = false;
var nextSpawnAI = 0.0;
var nextSpawnItems = 0.0;
var vehicles = [null, null];

func _init():
	# Randomize random seed
	randomize();

func _ready():
	globals.handle_quitRequest(self, "goto_mainmenu");
	
	init_game();
	start_game();
	
	set_process(true);
	set_process_input(true);
	set_fixed_process(true);

func goto_mainmenu():
	transition.change_scene(transition.menu_scene);

func init_game():
	curPos = Vector3();
	curSpeed = 14.0;
	vehiclePos = [0, 0];
	curRunLength = 0.0;
	curCoins = 0;
	
	viewportSize = get_viewport().get_rect().size;
	
	gameTime = 0.0;
	gameStarted = false;
	gameOver = false;
	nextSpawnAI = 0.0;
	nextSpawnItems = 0.0;
	
	spawn_vehicle();
	
	vehicles[0].gameMain = self;
	vehicles[1].gameMain = self;
	
	get_node("gui/startGame").show();
	get_node("gui/gameOver").hide();
	
	get_node("gui/startGame/btnPlay").connect("pressed", self, "start_game");
	get_node("gui/gameOver/btnPlay").connect("pressed", self, "restart_game");
	get_node("gui/gameOver/btnReturn").connect("pressed", self, "goto_menu");
	
	level.build_level(2);

func _input(ie):
	if (!gameStarted || gameOver):
		return;
	
	if (ie.type == InputEvent.KEY):
		if (Input.is_action_just_pressed("ui_left")):
			vehiclePos[0] = !vehiclePos[0];
		if (Input.is_action_just_pressed("ui_right")):
			vehiclePos[1] = !vehiclePos[1];
	
	if (ie.type == InputEvent.SCREEN_TOUCH && ie.pressed):
		if (ie.x < viewportSize.width/2):
			vehiclePos[0] = !vehiclePos[0];
		if (ie.x > viewportSize.width/2):
			vehiclePos[1] = !vehiclePos[1];

func _process(delta):
	if (gameStarted):
		gameTime += delta;
	
	lblScore.set_text(str(curRunLength).pad_decimals(2) + " Km");
	lblScore2.set_text("Best: " + str(globals.bestRun).pad_decimals(2) + " Km");
	lblCoins.set_text(str(curCoins).pad_zeros(5));

func _fixed_process(delta):
	if (gameStarted && !gameOver):
		curSpeed = min(curSpeed+0.8*delta, 24.0);
	else:
		curSpeed = 14.0;
	
	curPos.z -= curSpeed*delta;
	
	if (gameStarted && !gameOver):
		curRunLength += curSpeed*delta*0.001;
	
	camera.set_translation(camera.get_translation().linear_interpolate(curPos, 10*delta));
	
	level.curPos = curPos;
	level.update_level();
	
	vehicles[0].targetPos = curPos;
	vehicles[0].targetPos.x = -2.0-(2.5*vehiclePos[0]);
	
	vehicles[1].targetPos = curPos;
	vehicles[1].targetPos.x = 2.0+(2.5*vehiclePos[1]);
	
	spawn_ai();
	spawn_items();

func spawn_vehicle():
	var spawnPos = Vector3(-2.0, 0, 0);
	vehicles[0] = vehicle.instance();
	vehicles[0].add_to_group("vehicle");
	vehicles[0].set_name("vehicle1");
	vehicles[0].change_color(globals.vehicleColor[0]);
	vehicles[0].set_translation(spawnPos);
	vehicle_node.add_child(vehicles[0]);
	
	spawnPos = Vector3(2.0, 0, 0);
	vehicles[1] = vehicle.instance();
	vehicles[1].add_to_group("vehicle");
	vehicles[1].set_name("vehicle2");
	vehicles[1].change_color(globals.vehicleColor[1]);
	vehicles[1].set_translation(spawnPos);
	vehicle_node.add_child(vehicles[1]);

func spawn_ai():
	if (!gameStarted || gameTime < nextSpawnAI):
		return;
	
	if (vehicle_aiNode.get_child_count() > 4):
		for i in range(2):
			vehicle_aiNode.get_child(i).queue_free();
	
	var randPos = [[-4.5, -2.0], [2.0, 4.5]];
	
	for i in range(2):
		var spawnPos = curPos;
		spawnPos.x = randPos[i][int(rand_range(0, randPos[i].size()))];
		spawnPos.z -= rand_range(28.0, 32.0);
		
		var inst = vehicle_ai.instance();
		inst.set_name("ai");
		var col = globals.vehicleColorSet[rand_range(0, globals.vehicleColorSet.size())];
		inst.change_color(col);
		inst.moveSpeed = rand_range(7.0, 8.0);
		inst.set_translation(spawnPos);
		vehicle_aiNode.add_child(inst);
		
	if (gameTime < 15.0 || gameOver):
		nextSpawnAI = gameTime + rand_range(2.0, 3.0);
	elif (gameTime >= 15.0 && gameTime < 30.0):
		nextSpawnAI = gameTime + rand_range(1.0, 2.0);
	else:
		nextSpawnAI = gameTime + rand_range(0.8, 1.5);

func spawn_items():
	if (!gameStarted || gameOver || gameTime < nextSpawnItems):
		return;
	
	if (items_node.get_child_count() > 4):
		items_node.get_child(0).queue_free();
	
	var randPos = [-4.5, -2.0, 2.0, 4.5];
	var spawnPos = curPos;
	spawnPos.x = randPos[int(rand_range(0, randPos.size()))];
	spawnPos.y += 0.5;
	spawnPos.z -= rand_range(25.0, 30.0);
	
	var inst = item_coin.instance();
	inst.set_name("item");
	inst.set_gamemgr(self);
	inst.set_translation(spawnPos);
	items_node.add_child(inst);
	
	nextSpawnItems = gameTime + rand_range(0.5, 1.0);

func item_collected(item):
	if (!gameStarted || gameOver):
		return;
	
	curCoins += 1;
	item.queue_free();

func restart_game():
	#get_tree().reload_current_scene();
	transition.change_scene(transition.game_scene);

func goto_menu():
	transition.change_scene(transition.menu_scene);

func start_game():
	if (gameStarted || gameOver):
		return;
	
	gameStarted = true;
	gameOver = false;
	
	get_node("gui/startGame").hide();

func end_game():
	if (!gameStarted || gameOver):
		return;
	
	gameStarted = true;
	gameOver = true;
	
	if (curRunLength > globals.bestRun):
		globals.bestRun = curRunLength;
	
	globals.totalCoins += curCoins;
	globals.save_game();
	
	get_node("gui/gameOver").show();
