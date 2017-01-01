extends Node

onready var lblScore = get_node("gui/score");
onready var lblScore2 = get_node("gui/score2");
onready var lblFps = get_node("gui/fps");

onready var camera = get_node("env/cam_base");
onready var level = get_node("env/level");

onready var vehicle = load("res://scenes/vehicle.tscn");
onready var vehicle_node = get_node("env/vehicle");

onready var vehicle_ai = load("res://scenes/vehicle_ai.tscn");
onready var vehicle_ai_node = get_node("env/vehicle_ai");

var curPos = Vector3();
var curSpeed = 0.0;
var vehiclePos = [0, 0];
var curScore = 0.0;

var enableShadow = true;
var viewportSize = Vector2();

var gameTime = 0.0;
var gameStarted = false;
var gameOver = false;
var nextSpawnAI = 0.0;
var vehicles = [null, null];

func _init():
	# Randomize random seed
	randomize();
	
	# Set the frame limit
	OS.set_target_fps(60);

func _ready():
	init_game();
	start_game();
	
	set_process(true);
	set_process_input(true);
	set_fixed_process(true);

func init_game():
	curPos = Vector3();
	curSpeed = 14.0;
	vehiclePos = [0, 0];
	curScore = 0.0;
	
	viewportSize = get_viewport().get_rect().size;
	
	gameTime = 0.0;
	gameStarted = false;
	gameOver = false;
	nextSpawnAI = 0.0;
	
	spawn_vehicle();
	
	vehicles[0].gameMain = self;
	vehicles[1].gameMain = self;
	
	if (OS.get_name() == "Android"):
		enableShadow = false;
	
	get_node("env/sun").set_project_shadows(enableShadow);
	get_node("gui/startGame").show();
	get_node("gui/gameOver").hide();
	
	get_node("gui/startGame/btnPlay").connect("pressed", self, "start_game");
	get_node("gui/gameOver/btnPlay").connect("pressed", self, "restart_game");
	get_node("gui/gameOver/btnReturn").connect("pressed", self, "goto_menu");
	
	level.update_level();

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

func update_camera(delta):
	camera.set_translation(camera.get_translation().linear_interpolate(curPos, 10*delta));

func _process(delta):
	if (gameStarted && !gameOver):
		curScore += 2*delta;
	
	if (gameStarted):
		gameTime += delta;
	
	update_gui();

func update_gui():
	lblScore.set_text(str(int(curScore)).pad_zeros(5));
	lblScore2.set_text(str("High: ", int(globals.highScore)).pad_zeros(5));
	lblFps.set_text(str(int(OS.get_frames_per_second())));

func _fixed_process(delta):
	if (gameStarted && !gameOver):
		curSpeed = min(curSpeed+0.8*delta, 24.0);
	else:
		curSpeed = 14.0;
	
	curPos.z -= curSpeed*delta;
	
	update_camera(delta);
	update_game();
	
	if (gameStarted):
		spawn_ai();

func update_game():
	level.curPos = curPos;
	level.update_level();
	
	vehicles[0].targetPos = curPos;
	vehicles[0].targetPos.x = -2.0-(2.5*vehiclePos[0]);
	
	vehicles[1].targetPos = curPos;
	vehicles[1].targetPos.x = 2.0+(2.5*vehiclePos[1]);

func spawn_vehicle():
	var spawnPos = Vector3(-2.0, 0, 0);
	vehicles[0] = vehicle.instance();
	vehicles[0].set_name("vehicles[0]");
	vehicles[0].change_color(globals.vehicleColor[0]);
	vehicles[0].set_translation(spawnPos);
	vehicle_node.add_child(vehicles[0]);
	
	spawnPos = Vector3(2.0, 0, 0);
	vehicles[1] = vehicle.instance();
	vehicles[1].set_name("vehicles[1]");
	vehicles[1].change_color(globals.vehicleColor[1]);
	vehicles[1].set_translation(spawnPos);
	vehicle_node.add_child(vehicles[1]);

func spawn_ai():
	if (gameTime < nextSpawnAI):
		return;
	
	if (vehicle_ai_node.get_child_count() > 4):
		for i in range(2):
			vehicle_ai_node.get_child(i).queue_free();
	
	var randPos = [[-4.5, -2.0], [2.0, 4.5]];
	
	for i in range(2):
		var spawnPos = curPos;
		spawnPos.x = randPos[i][int(rand_range(0, randPos[i].size()))];
		spawnPos.z -= rand_range(28.0, 32.0);
		
		var inst = vehicle_ai.instance();
		inst.set_name("ai");
		var col = Color(rand_range(0.2, 0.8), rand_range(0.2, 0.8), rand_range(0.2, 0.8));
		inst.change_color(col);
		inst.moveSpeed = rand_range(7.0, 8.0);
		inst.set_translation(spawnPos);
		vehicle_ai_node.add_child(inst);
		
	if (gameTime < 15.0 || gameOver):
		nextSpawnAI = gameTime + rand_range(2.0, 3.0);
	elif (gameTime >= 15.0 && gameTime < 30.0):
		nextSpawnAI = gameTime + rand_range(1.0, 2.0);
	else:
		nextSpawnAI = gameTime + rand_range(0.8, 1.5);

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
	
	if (int(curScore) > globals.highScore):
		globals.highScore = int(curScore);
	
	globals.save_game();
	
	get_node("gui/gameOver").show();
