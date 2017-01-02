extends Control

signal pressed();
signal hovered(toggle);

var hover = false;

func _ready():
	set_process_input(true);

func _input(ie):
	if (!is_visible()):
		return;
	
	if (ie.type == InputEvent.MOUSE_BUTTON || ie.type == InputEvent.SCREEN_TOUCH):
		if (ie.pressed && get_global_rect().has_point(ie.pos)):
			emit_signal("pressed");
	
	if (ie.type == InputEvent.MOUSE_MOTION):
		if (get_global_rect().has_point(ie.pos) && !hover):
			emit_signal("hovered", true);
			hover = true;
		elif (!get_global_rect().has_point(ie.pos) && hover):
			emit_signal("hovered", false);
			hover = false;
