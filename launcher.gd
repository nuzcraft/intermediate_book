extends CSGBox

export (PackedScene) var ball

var shoot_timer: Timer

func _ready():
	shoot_timer = Timer.new()
	add_child(shoot_timer)
	shoot_timer.wait_time = 2
	shoot_timer.connect("timeout", self, "throw_projectile")
	shoot_timer.start()

func throw_projectile():
	var new_ball = ball.instance()
	add_child(new_ball)
	
	var timer = Timer.new()
	new_ball.add_child(timer)
	new_ball.set_contact_monitor(true)
	new_ball.set_max_contacts_reported(5)
	new_ball.connect("body_entered", self, "ball_collision")
	timer.connect("timeout", new_ball, "queue_free")
	timer.set_wait_time(2)
	timer.start()
	
	look_at(get_node("../player").global_transform.origin, Vector3.UP)
	new_ball.linear_velocity = transform.basis.xform(Vector3.FORWARD) * 20
	
func ball_collision(body):
	if (body.name == "player"):
		get_node("../player").transform.origin = get_node("../start").transform.origin + Vector3.UP
		print('hit player')
		
