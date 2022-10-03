extends KinematicBody

var health: int
enum{
	HIT,
	IDLE,
	DYING,
	SHOOT,
}
var current_state = IDLE

var ray: RayCast
var param_can_see_player = false

var shoot_timer: Timer
var can_inflict_damage = true

func _ready():
	health = 100
	get_node("NPC/AnimationPlayer").get_animation("IDLE").loop = true
	get_node("NPC/AnimationPlayer").get_animation("Dying").loop = false
	get_node("NPC/AnimationPlayer").get_animation("Hit").loop = false
	get_node("NPC/AnimationPlayer").get_animation("Shooting").loop = false
	ray = RayCast.new()
	ray.enabled = true
	add_child(ray)
	ray.global_transform.origin += Vector3.UP
	ray.cast_to = Vector3(0, 0, 100)
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = 1
	shoot_timer.connect("timeout", self, "enable_shooting")

func got_hit():
	health -= 20
#	print("Health: " + str(health))
	current_state = HIT
	if health <= 0:
		current_state = DYING
		
func destroy_target():
	queue_free()
	
func _process(delta):
	match current_state:
		IDLE:
			print("I am in the state IDLE")
			get_node("NPC/AnimationPlayer").play("IDLE")
			if (param_can_see_player):
				current_state = SHOOT
		HIT:
			print("I am in the state HIT")
			get_node("NPC/AnimationPlayer").play("Hit")
			yield(get_node("NPC/AnimationPlayer"), "animation_finished")
			current_state = SHOOT
		DYING:
			print("I am in the state DYING")
			get_node("NPC/AnimationPlayer").play("Dying")
			yield(get_node("NPC/AnimationPlayer"), "animation_finished")
			destroy_target()
		SHOOT:
			look_at(get_node("../player").global_transform.origin, Vector3.UP)
			rotate(Vector3.UP, 3.18)
			get_node("NPC/AnimationPlayer").play("Shooting")
			if can_inflict_damage:
				get_node("../player").got_hit()
				shoot_timer.start()
				can_inflict_damage = false
			
func _input(event):
	if Input.is_key_pressed(KEY_P):
		current_state = HIT
		
func _physics_process(delta):
	if ray.is_colliding():
		var obj = ray.get_collider()
		if (obj.name == "player"):
			param_can_see_player = true
		else:
			param_can_see_player = false
			
func enable_shooting():
	can_inflict_damage = true
