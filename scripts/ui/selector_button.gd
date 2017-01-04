extends "res://scripts/ui/custom_button.gd"

signal selected(col);

var id = -1;

func _ready():
	connect("pressed", self, "_on_pressed");

func set_colorFrame():
	get_node("colorFrame").show();
	get_node("texFrame").hide();

func set_texFrame():
	get_node("colorFrame").hide();
	get_node("texFrame").show();

func set_id(i):
	id = i;

func get_id():
	return id;

func set_color(col):
	get_node("colorFrame").set_frame_color(col);

func get_color():
	return get_node("colorFrame").get_frame_color();

func set_tex(tex):
	get_node("texFrame").set_texture(tex);

func get_tex():
	return get_node("texFrame").get_texture();

func set_locked(lock):
	get_node("lockIcon").set_hidden(!lock);

func is_locked():
	return get_node("lockIcon").is_visible();

func _on_pressed():
	emit_signal("selected", self);
