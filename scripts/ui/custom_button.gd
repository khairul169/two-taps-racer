extends Control

signal pressed();

func _ready():
	set_process_input(true);

func _input(ie):
	if (ie.type == InputEvent.MOUSE_BUTTON || ie.type == InputEvent.SCREEN_TOUCH):
		if (ie.pressed && get_global_rect().has_point(ie.pos)):
			emit_signal("pressed");
