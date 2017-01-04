extends Control

onready var vehicle_preview = get_node("previewPane");
onready var vehicle_vp = vehicle_preview.get_node("vp");
onready var vehicle_cam = vehicle_vp.get_node("camera");
onready var vehicle_models = [
	vehicle_vp.get_node("vehicle1"),
	vehicle_vp.get_node("vehicle2")
];

onready var color_selector = get_node("colorSelector");
onready var selectorButton = load("res://scenes/ui/selector_button.tscn");

var vehiclePos = [-4.0, 4.0];
var curVehicle = 0;

func _ready():
	_screen_resized();
	get_tree().connect("screen_resized", self, "_screen_resized");
	
	fill_color_selector();
	update_vehicle();
	
	vehicle_cam.set_translation(Vector3(vehiclePos[curVehicle], 0, 0));
	
	set_process(true);
	set_process_input(true);

func _input(ie):
	if (!is_visible()):
		return;
	
	if (ie.type == InputEvent.KEY):
		if (Input.is_action_just_pressed("ui_select")):
			curVehicle += 1;
		if (Input.is_action_just_pressed("ui_left")):
			curVehicle += 1;
		if (Input.is_action_just_pressed("ui_right")):
			curVehicle -= 1;
		
		update_curvehicle();
	
	if ((ie.type == InputEvent.SCREEN_TOUCH || ie.type == InputEvent.MOUSE_BUTTON) && ie.pressed):
		if (vehicle_preview.get_global_rect().has_point(ie.pos)):
			curVehicle += 1;
		
		update_curvehicle();

func update_curvehicle():
	if (curVehicle >= vehiclePos.size()):
		curVehicle = 0;
	if (curVehicle < 0):
		curVehicle = vehiclePos.size()-1;
		
func _screen_resized():
	var vp_rect = Rect2(Vector2(), vehicle_preview.get_rect().size);
	
	if (vp_rect.size.width <= 0):
		vp_rect.size.width = 1;
	if (vp_rect.size.height <= 0):
		vp_rect.size.height = 1;
	
	vehicle_vp.set_rect(vp_rect);

func _process(delta):
	if (!is_visible()):
		return;
	
	var rot = vehicle_models[0].get_rotation_deg();
	rot.y = fmod(rot.y + 30*delta, 360.0);
	vehicle_models[0].set_rotation_deg(rot);
	vehicle_models[1].set_rotation_deg(rot);
	
	vehicle_cam.set_translation(vehicle_cam.get_translation().linear_interpolate(Vector3(vehiclePos[curVehicle], 0, 0), 5*delta));
	vehicle_preview.set_texture(vehicle_vp.get_render_target_texture());

func update_vehicle():
	update_color(vehicle_models[0], globals.vehicleColor[0]);
	update_color(vehicle_models[1], globals.vehicleColor[1]);

func color_changed(node):
	if (curVehicle < 0 || curVehicle >= globals.vehicleColor.size()):
		return;
	if (node.is_locked()):
		return;
	
	globals.vehicleColor[curVehicle] = node.get_color();
	update_vehicle();

func update_color(vehicle, col):
	for i in vehicle.get_children():
		if (i extends MeshInstance):
			var mat = i.get_material_override().duplicate();
			mat.set_shader_param("col", col);
			i.set_material_override(mat);
			break;

func fill_color_selector():
	for i in range(globals.vehicleColorSet.size()):
		var col = globals.vehicleColorSet[i];
		var lock = i != 0 && i != 1 && !globals.unlockedColorSet.has(i);
		var inst = selectorButton.instance();
		inst.set_name(col.to_html(false));
		inst.set_colorFrame();
		inst.set_color(col);
		inst.set_locked(lock);
		inst.connect("selected", self, "color_changed");
		color_selector.add_child(inst);
