extends Control

enum TYPE {
	NONE = 0,
	CHECK,
	OPTION
};

var configs = {};

func _ready():
	get_node("btnReturn").connect("pressed", self, "_return");
	
	bind_config("showfps", "cfgShowFPS", false);
	bind_config("fullscreen", "cfgFullscreen", true);
	bind_config("lowprocess", "cfgLowProcess", false);
	bind_config("shadows", "cfgShadows", true);
	bind_config("shadows_quality", "cfgShadowsQuality/list", 1);
	bind_config("targetfps", "cfgTargetFPS/list", 0);
	
	bind_config("antialiasing", "cfgAntiAliasing", false);
	bind_config("glow", "cfgGlow", false);
	bind_config("dynamicmenu", "cfgDynamicMenu", true);
	
	load_configs();

func bind_config(key, nodeName, defval):
	var node = get_node("scrollContainer/gridContainer/"+nodeName);
	var type = TYPE.NONE;
	
	if (node extends CheckButton):
		type = TYPE.CHECK;
	if (node extends OptionButton):
		type = TYPE.OPTION;
	
	configs[key] = {
		'node': node,
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
