extends KinematicBody

var lerpSpeed = 5.0;
var moveSpeed = 8.0;

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
	var moveDir = Vector3(0, 0, -1);

	move(moveDir*moveSpeed*delta);
