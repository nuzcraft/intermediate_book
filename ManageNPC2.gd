extends KinematicBody

var health: int
enum{
	HIT,
	IDLE,
	DYING,
	CHASE,
	SHOOT,
}
var current_state = CHASE

var ray: RayCast
var param_can_see_player = false

var shoot_timer: Timer
var can_inflict_damage = true

var path = []
var path_node = 0
var speed = 7
onready var nav = get_node("/root/Spatial/Navigation")
onready var player = get_node("/root/Spatial/player")

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
	var distance_to_player = (player.global_transform.origin - global_transform.origin)
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
		CHASE:
			get_node("NPC/AnimationPlayer").play("Walking")
			if (path_node < path.size()):
				var direction = (path[path_node] - global_transform.origin)
				if direction.length() < 1:
					path_node += 1
				else:
					move_and_slide(direction.normalized()*speed, Vector3.UP)
					look_at(global_transform.origin - direction, Vector3.UP)
			if distance_to_player.length() < 1.5:
				current_state = IDLE
					
			
func _input(event):
	if Input.is_key_pressed(KEY_P):
#		current_state = HIT
		calc_path()
		
func _physics_process(delta):
	if ray.is_colliding():
		pass
#		var obj = ray.get_collider()
#		if (obj.name == "player"):
#			param_can_see_player = true
#		else:
#			param_can_see_player = false

func enable_shooting():
	can_inflict_damage = true
	
func calc_path():
	if (current_state == CHASE):
		path = nav.get_simple_path(global_transform.origin, player.global_transform.origin, true)
		path_node = 0
