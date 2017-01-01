extends CanvasLayer

const menu_scene = "res://scenes/mainmenu.tscn"
const game_scene = "res://scenes/gamemenu.tscn"
const main_scene = "res://scenes/game.tscn"

onready var animationPlayer = get_node("AnimationPlayer");

var thread = Thread.new();

func change_scene(path):
	if (thread.is_active()):
		thread.wait_to_finish();
		return;
	
	animationPlayer.play("fade_in");
	thread.start(self, "_load_scene", path);

func _load_scene(args):
	var pckscene = load(args);
	call_deferred("_set_scene", pckscene);
	
	animationPlayer.play("fade_out");
	
	thread.wait_to_finish();

func _set_scene(scn):
	get_tree().change_scene_to(scn);
