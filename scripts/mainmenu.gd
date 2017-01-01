extends Control

func _ready():
	get_node("control/btnPlay").connect("pressed", self, "play");
	get_node("control/btnQuit").connect("pressed", self, "quit");

func play():
	transition.change_scene(transition.game_scene);

func quit():
	globals.save_game();
	get_tree().quit();
