extends Control

enum TYPE {
	CHECK = 0,
	OPTION
};

var configs = {};

func _ready():
	get_node("btnReturn").connect("pressed", self, "_return");
	
	bind_config("showfps", "cfgShowFPS", TYPE.CHECK, false);
	bind_config("fullscreen", "cfgFullscreen", TYPE.CHECK, true);
	bind_config("lowprocess", "cfgLowProcess", TYPE.CHECK, false);
	bind_config("shadows", "cfgShadows", TYPE.CHECK, true);
	bind_config("shadows_quality", "cfgShadowsQuality/list", TYPE.OPTION, 1);
	bind_config("targetfps", "cfgTargetFPS/list", TYPE.OPTION, 0);
	
	load_configs();

func bind_config(key, nodeName, type, defval):
	configs[key] = {
		'node': get_node(nodeName),
		'type': type,
		'defval': defval
	};

func load_configs():
	for i in configs.keys():
		var cfg = configs[i];
		var key = 'cfg_'+str(i);
		var data = globals.get_gamedata(key, cfg.defval);
		
		if (cfg.type == TYPE.CHECK):
			cfg.node.set_pressed(data);
		if (cfg.type == TYPE.OPTION):
			cfg.node.select(data);

func _return():
	for i in configs.keys():
		var cfg = configs[i];
		var key = 'cfg_'+str(i);
		
		if (cfg.type == TYPE.CHECK):
			globals.set_gamedata(key, cfg.node.is_pressed());
		if (cfg.type == TYPE.OPTION):
			globals.set_gamedata(key, cfg.node.get_selected());
	
	globals.apply_configs();
	globals.save_game();
	transition.change_scene(transition.menu_scene);
