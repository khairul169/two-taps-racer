extends Control

export(NodePath) var previewColor;
export(NodePath) var sliderR;
export(NodePath) var sliderG;
export(NodePath) var sliderB;

signal color_changed(col);

var color = Color();

func _ready():
	if (typeof(previewColor) == TYPE_NODE_PATH):
		previewColor = get_node(previewColor);
	if (typeof(sliderR) == TYPE_NODE_PATH):
		sliderR = get_node(sliderR);
	if (typeof(sliderG) == TYPE_NODE_PATH):
		sliderG = get_node(sliderG);
	if (typeof(sliderB) == TYPE_NODE_PATH):
		sliderB = get_node(sliderB);
	
	sliderR.connect("value_changed", self, "_color_changed");
	sliderG.connect("value_changed", self, "_color_changed");
	sliderB.connect("value_changed", self, "_color_changed");

func set_color(col):
	sliderR.set_val(col.r);
	sliderG.set_val(col.g);
	sliderB.set_val(col.b);
	color = col;
	previewColor.set_frame_color(col);

func _color_changed(new):
	update_color();
	emit_signal("color_changed", self);

func update_color():
	color = Color();
	color.r = sliderR.get_val();
	color.g = sliderG.get_val();
	color.b = sliderB.get_val();
	previewColor.set_frame_color(color);

func get_color():
	return color;
