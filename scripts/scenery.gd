extends Spatial

onready var environment = get_node("environment").get_environment();
onready var sun = get_node("sun");

func _ready():
	load_configs();

func load_configs():
	environment.set_enable_fx(environment.FX_FXAA, globals.get_gamedata('cfg_antialiasing', false));
	environment.set_enable_fx(environment.FX_GLOW, globals.get_gamedata('cfg_glow', false));
	
	sun.set_project_shadows(globals.get_gamedata('cfg_shadows', true));
