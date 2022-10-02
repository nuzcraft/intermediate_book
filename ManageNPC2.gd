extends KinematicBody

var health: int
enum{
	HIT,
	IDLE,
	DYING,
}
var current_state = IDLE

func _ready():
	health = 100
	get_node("NPC/AnimationPlayer").get_animation("IDLE").loop = true
	get_node("NPC/AnimationPlayer").get_animation("Dying").loop = false
	get_node("NPC/AnimationPlayer").get_animation("Hit").loop = false

func got_hit():
	health -= 20
#	print("Health: " + str(health))
	if health <= 0:
		destroy_target()
		
func destroy_target():
	queue_free()
	
func _process(delta):
	match current_state:
		IDLE:
			print("I am in the state IDLE")
			get_node("NPC/AnimationPlayer").play("IDLE")
