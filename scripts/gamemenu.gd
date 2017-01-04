extends Control

enum SECTION {
	VEHICLE = 0,
	TRACK
};

var curPage = -1;
var nextSwitch = 0.0;

func _ready():
	curPage = SECTION.VEHICLE;
	
	get_node("sectionVehicle").show();
	get_node("sectionTrack").hide();
	
	get_node("btnPrev").connect("pressed", self, "nav_prev");
	get_node("btnNext").connect("pressed", self, "nav_next");
	
	globals.handle_quitRequest(self, "nav_prev");

func nav_prev():
	if (globals.globalTime < nextSwitch):
		return;
	
	if (curPage == SECTION.VEHICLE):
		transition.change_scene(transition.menu_scene);
	
	elif (curPage == SECTION.TRACK):
		get_node("sectionVehicle/animation").play("fadeIn");
		get_node("sectionTrack/animation").play("fadeOut");
		curPage = SECTION.VEHICLE;
	
	nextSwitch = globals.globalTime + 0.5;

func nav_next():
	if (globals.globalTime < nextSwitch):
		return;
	
	if (curPage == SECTION.VEHICLE):
		get_node("sectionVehicle/animation").play("fadeOut");
		get_node("sectionTrack/animation").play("fadeIn");
		curPage = SECTION.TRACK;
	
	elif (curPage == SECTION.TRACK):
		transition.change_scene(transition.main_scene);
	
	nextSwitch = globals.globalTime + 0.1;
