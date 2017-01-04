extends Node

onready var vehicle = load("res://scenes/vehicle_ai.tscn");
onready var vehicle_node = get_node("world/vehicles");
onready var spawn_pos = get_node("world/spawnPos").get_translation();

var nextSpawn = 0.0;

func _ready():
	globals.handle_quitRequest(self, "quit");
	randomize();
	
	get_node("gui/btnPlay").connect("pressed", self, "play");
	get_node("gui/btnSettings").connect("pressed", self, "settings");
	get_node("gui/btnQuit").connect("pressed", self, "quit");
	
	if (globals.get_gamedata('cfg_dynamicmenu', true)):
		get_node("gui/bgImage").queue_free();
		build_level();
		set_process(true);
	else:
		get_node("gui/bgImage").show();
		get_node("world").queue_free();

func play():
	transition.change_scene(transition.game_scene);

func settings():
	transition.change_scene(transition.settings_scene);

func quit():
	globals.save_game();
	#get_tree().quit();
	transition.quit_game();

func _process(delta):
	nextSpawn -= delta;
	
	if (nextSpawn <= 0.0):
		spawn_ai();
		nextSpawn = rand_range(4.0, 5.0);

func build_level():
	var startPos = Vector3();
	var trackName = globals.trackList[0].name;
	var scene = load("res://models/levels/"+trackName+"/level.scn");
	
	for i in range(2):
		var inst = scene.instance();
		inst.set_translation(startPos+Vector3(0, 0, -80*i));
		get_node("world").add_child(inst);

func spawn_ai():
	if (vehicle_node.get_child_count() > 2):
		for i in range(2):
			vehicle_node.get_child(i).queue_free();
	
	var randPos = [[-4.5, -2.0], [2.0, 4.5]];
	
	for i in range(2):
		var spawnPos = spawn_pos;
		spawnPos.x = randPos[i][int(rand_range(0, randPos[i].size()))];
		spawnPos.z += rand_range(-5.0, 5.0);
		
		var inst = vehicle.instance();
		inst.set_name("ai");
		var col = globals.vehicleColorSet[rand_range(0, globals.vehicleColorSet.size())];
		inst.change_color(col);
		inst.moveSpeed = rand_range(7.0, 10.0);
		inst.set_translation(spawnPos);
		vehicle_node.add_child(inst);
