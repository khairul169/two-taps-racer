extends "res://scripts/ui/custom_button.gd"

onready var animation = get_node("animation");

func _ready():
	connect("pressed", self, "_pressed");
	connect("hovered", self, "_hovered");

func _pressed():
	pass

func _hovered(toggle):
	if (toggle):
		animation.play("hover_in");
	else:
		animation.play("hover_out");
