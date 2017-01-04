extends Control

var track_resources = {};
var curTrack = 0;

func _ready():
	curTrack = 0;
	
	load_resources();
	select(curTrack);
	
	get_node("previewPane").connect("pressed", self, "_previewPane_pressed");
	
	set_process_input(true);

func _input(ie):
	if (!is_visible()):
		return;
	
	if (ie.type == InputEvent.KEY):
		var dir = 0;
		if (Input.is_action_just_pressed("ui_left")):
			dir -= 1;
		if (Input.is_action_just_pressed("ui_right")):
			dir += 1;
		
		if (dir != 0):
			curTrack += dir;
			if (curTrack >= globals.trackList.size()):
				curTrack = 0;
			if (curTrack < 0):
				curTrack = globals.trackList.size()-1;
			select(curTrack);

func load_resources():
	for i in range(globals.trackList.size()):
		if (track_resources.has(i)):
			continue;
		var name = globals.trackList[i].name;
		var img = load("res://tracks/"+name+"/image.jpg");
		track_resources[i] = {'img': img};

func track_changed(node):
	select(node.get_id());

func _previewPane_pressed():
	curTrack += 1;
	if (curTrack >= globals.trackList.size()):
		curTrack = 0;
	select(curTrack);

func select(id):
	if (id < 0 || id >= globals.trackList.size()):
		return;
	
	curTrack = id;
	globals.trackSelected = id;
	get_node("previewPane/animation").play("changed");

func change_preview():
	if (curTrack < 0 || curTrack >= globals.trackList.size()):
		return;
	
	var id = curTrack;
	var name = globals.trackList[id].name;
	var title = globals.trackList[id].title;
	
	get_node("previewPane").set_texture(track_resources[id].img);
	get_node("previewPane/trackName").set_text(title);
