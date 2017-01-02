extends CanvasLayer

const menu_scene = "res://scenes/mainmenu.tscn"
const game_scene = "res://scenes/gamemenu.tscn"
const settings_scene = "res://scenes/settings.tscn"
const main_scene = "res://scenes/game.tscn"

onready var animationPlayer = get_node("AnimationPlayer");

var loader = null;

func change_scene(path):
	if (is_processing()):
		return;
	
	loader = ResourceLoader.load_interactive(path);
	if (!loader):
		return;
	animationPlayer.play("fade_in");
	set_process(true);

func _process(delta):
	if (!loader):
		set_process(false);
		return;
	
	var err = loader.poll();
	if (err == ERR_FILE_EOF):
		var resource = loader.get_resource();
		_set_scene(resource);
		animationPlayer.play("fade_out");
		loader = null;
		set_process(false);
	elif (err != OK):
		loader = null;
		set_process(false);

func _set_scene(scn):
	get_tree().change_scene_to(scn);
