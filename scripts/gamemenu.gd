extends Control

onready var vehicle_preview = get_node("vehicle_preview");
onready var vehicle_vp = vehicle_preview.get_node("vp");
onready var vehicle_cam = vehicle_vp.get_node("camera");
onready var vehicle_models = [
	vehicle_vp.get_node("vehicle1"),
	vehicle_vp.get_node("vehicle2")
];
onready var color_changer = [
	get_node("colorchanger/vehicle1"),
	get_node("colorchanger/vehicle2")
];

var camPos = [-4.0, 4.0];
var curCamPos = 0;

func _ready():
	_screen_resized();
	get_tree().connect("screen_resized", self, "_screen_resized");
	
	get_node("navigation/btnRace").connect("pressed", self, "nav_race");
	get_node("navigation/btnColor").connect("pressed", self, "nav_color");
	get_node("navigation/btnReturn").connect("pressed", self, "nav_main");
	
	get_node("colorchanger/btnReturn").connect("pressed", self, "nav_reset");
	
	color_changer[0].connect("color_changed", self, "vehicle_col_changed");
	color_changer[1].connect("color_changed", self, "vehicle_col_changed");
	
	update_vehicle();
	
	set_process(true);
	set_process_input(true);

func nav_race():
	transition.change_scene(transition.main_scene);

func nav_color():
	get_node("navigation").hide();
	get_node("colorchanger").show();

func nav_reset():
	get_node("navigation").show();
	get_node("colorchanger").hide();

func nav_main():
	transition.change_scene(transition.menu_scene);

func _input(ie):
	if (ie.type == InputEvent.KEY):
		if (Input.is_action_just_pressed("ui_left")):
			curCamPos += 1;
		if (Input.is_action_just_pressed("ui_right")):
			curCamPos -= 1;
		
		update_campos();
	
	if (ie.type == InputEvent.SCREEN_TOUCH && ie.pressed):
		if (vehicle_preview.get_global_rect().has_point(ie.pos)):
			curCamPos += 1;
		
		update_campos();

func update_campos():
	if (curCamPos >= camPos.size()):
		curCamPos = 0;
	if (curCamPos < 0):
		curCamPos = camPos.size()-1;
		
func _screen_resized():
	var vp_rect = Rect2(Vector2(), vehicle_preview.get_rect().size);
	
	if (vp_rect.size.width <= 0):
		vp_rect.size.width = 1;
	if (vp_rect.size.height <= 0):
		vp_rect.size.height = 1;
	
	vehicle_vp.set_rect(vp_rect);

func _process(delta):
	var rot = vehicle_models[0].get_rotation_deg();
	rot.y = fmod(rot.y + 30*delta, 360.0);
	vehicle_models[0].set_rotation_deg(rot);
	vehicle_models[1].set_rotation_deg(rot);
	
	vehicle_cam.set_translation(vehicle_cam.get_translation().linear_interpolate(Vector3(camPos[curCamPos], 0, 0), 5*delta));
	vehicle_preview.set_texture(vehicle_vp.get_render_target_texture());

func update_vehicle():
	update_color(vehicle_models[0], globals.vehicleColor[0]);
	update_color(vehicle_models[1], globals.vehicleColor[1]);
	
	color_changer[0].set_color(globals.vehicleColor[0]);
	color_changer[1].set_color(globals.vehicleColor[1]);

func vehicle_col_changed(n):
	if (color_changer[0] == n):
		globals.vehicleColor[0] = n.get_color();
	if (color_changer[1] == n):
		globals.vehicleColor[1] = n.get_color();
	
	update_vehicle();

func update_color(vehicle, col):
	for i in vehicle.get_children():
		if (i extends MeshInstance):
			var mat = i.get_material_override().duplicate();
			mat.set_shader_param("col", col);
			i.set_material_override(mat);
			break;
