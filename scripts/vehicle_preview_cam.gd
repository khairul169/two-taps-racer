extends Spatial

func _ready():
	get_node("Camera").look_at(Vector3(), Vector3(0, 1, 0));
