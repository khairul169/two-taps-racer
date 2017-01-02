extends "res://scripts/ui/custom_button.gd"

signal selected(col);

var color = Color();

func _ready():
	connect("pressed", self, "_on_pressed");

func set_color(col):
	color = col;
	get_node("frame").set_frame_color(col);

func get_color():
	return color;

func _on_pressed():
	emit_signal("selected", color);
