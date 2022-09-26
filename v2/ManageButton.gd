extends Button


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	connect ("pressed",self, "load_level")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func load_level():
	if (get_name() == "RestartButton"):
		get_tree().change_scene("res://starting_scene.tscn")
	else: get_tree().change_scene("res://level1.tscn") 


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
