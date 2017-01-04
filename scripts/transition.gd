extends CanvasLayer

const menu_scene = "res://scenes/mainmenu.tscn"
const game_scene = "res://scenes/gamemenu.tscn"
const settings_scene = "res://scenes/settings.tscn"
const main_scene = "res://scenes/game.tscn"

onready var animationPlayer = get_node("AnimationPlayer");

var loader = null;
var nextThink = 0.0;
var quitGame = false;

func _ready():
	animationPlayer.play("fade_out");

func change_scene(path):
	if (is_processing() || quitGame):
		return;
	
	loader = ResourceLoader.load_interactive(path);
	if (!loader):
		return;
	animationPlayer.play("fade_in");
	set_process(true);
	nextThink = 0.1;

func quit_game():
	quitGame = true;
	animationPlayer.play("quit");

func _process(delta):
	if (!loader):
		set_process(false);
		return;
	
	nextThink -= delta;
	if (nextThink > 0.0):
		return;
	
	var err = loader.poll();
	if (err == ERR_FILE_EOF):
		var resource = loader.get_resource();
		globals.handle_quitRequest(null);
		_set_scene(resource);
		animationPlayer.play("fade_out");
		loader = null;
		set_process(false);
	elif (err != OK):
		loader = null;
		set_process(false);

func _quit_game():
	get_tree().quit();

func _set_scene(scn):
	get_tree().change_scene_to(scn);
