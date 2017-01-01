extends Spatial

var level = "res://models/levels/desert/level.scn"
var curPos = Vector3();
var nextUpdate = 0;

func _ready():
	level = load(level);
	curPos = Vector3();

func update_level():
	if (curPos.z > nextUpdate):
		return;
	
	for i in get_children():
		i.queue_free();
	
	var startPos = curPos.snapped(80.0);
	
	for i in range(2):
		var inst = level.instance();
		inst.set_name("block_"+str(i));
		inst.set_translation(startPos+Vector3(0, 0, -80*i));
		add_child(inst);
		
		nextUpdate -= 40.0;
