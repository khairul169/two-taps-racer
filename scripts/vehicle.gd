extends KinematicBody

var gameMain = null;
var lerpSpeed = 5.0;
var targetPos = Vector3();

func _ready():
	set_fixed_process(true);

func change_color(col = Color()):
	for i in get_node("models").get_children():
		if (i extends MeshInstance):
			var mat = i.get_material_override().duplicate();
			mat.set_shader_param("col", col);
			i.set_material_override(mat);
			break;

func _fixed_process(delta):
	var dir = targetPos-get_translation();
	
	move(dir*lerpSpeed*delta);
	
	if (is_colliding()):
		gameMain.end_game();
		set_fixed_process(false);
