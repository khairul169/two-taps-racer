extends Control

func _ready():
	get_node("btnPrev").connect("pressed", self, "nav_main");
	get_node("btnNext").connect("pressed", self, "nav_race");

func nav_race():
	transition.change_scene(transition.main_scene);

func nav_main():
	transition.change_scene(transition.menu_scene);
