extends StaticBody

var health: int


# Called when the node enters the scene tree for the first time.
func _ready():
	health = 100

func got_hit():
	health -= 20
	print("Health: " + str(health))
	if health <= 0:
		destroy_target()
		
func destroy_target():
	queue_free()
