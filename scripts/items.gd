extends Area

var gameMgr;

func _ready():
	connect("body_enter", self, "_on_bodyenter");

func set_gamemgr(mgr):
	gameMgr = mgr;

func _on_bodyenter(body):
	if (!body in get_tree().get_nodes_in_group("vehicle")):
		return;
	gameMgr.item_collected(self);
