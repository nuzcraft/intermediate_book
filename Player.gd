extends KinematicBody
export(PackedScene) var grenade
export(AudioStream) var sound_grenade_launch: AudioStream
export(AudioStream) var sound_gun: AudioStream
export(AudioStream) var sound_ammo_collect: AudioStream

#next change scene and update score
var moveSpeed:float = 5
var jumpForce:float = 5
var gravity:float=12


#camlook
var minLookAngle:float = -90
var maxlookAngle:float = 90
var sensitivity:float = 10
var velocity:Vector3 = Vector3()
var mouseDelta: Vector2 = Vector2()
#var scoreUI:RichTextLabel
var score = 0
var gun_ammo = 10


onready var camera :Camera = get_node("Camera")#only when node is initialized
onready var user_message:Label = get_node("../message")
onready var message_timer:Timer = get_node("../messageTimer")
onready var score_label:Label = get_node("../scoreLabel")
onready var sound_fx := $sound_fx
var ray:RayCast

var inventory: WeaponInventory
var reload_timer: Timer
var can_shoot = true

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	user_message.set_text("")
	score_label.set_text(str(score))
	ray = RayCast.new()
	ray.enabled = true
	camera.add_child(ray)
	ray.cast_to = Vector3(0, 0, -100)
	reload_timer = Timer.new()
	add_child(reload_timer)
	reload_timer.connect("timeout", self, "reload_timer_timeout")
	inventory = WeaponInventory.new()
	update_UI()
	
	
func _physics_process(delta):#called 60 times per sec
	velocity.x = 0
	velocity.z = 0
	var input:Vector2 = Vector2()
	if Input.is_action_pressed("move_forward"):
		input.y+=1
	if Input.is_action_pressed("move_back"):
		input.y-=1	
	if Input.is_action_pressed("move_left"):
		input.x+=1		
	if Input.is_action_pressed("move_right"):
		input.x-=1		
	input.normalized();
	
	if Input.is_action_pressed("fire"):
		var condition1 = inventory.weapon_index == Weapon.TYPE_GUN
		var condition2 = inventory.weapon_index == Weapon.TYPE_AUTO_GUN
		var condition3 = inventory.has_ammo_for_current()
		var condition4 = can_shoot
		var condition5 = inventory.weapon_index == Weapon.TYPE_GRENADE
		if (condition1 or condition2) and condition3 and condition4:
			inventory.decrease_curr_ammo()
			update_UI()
			can_shoot = false
			reload_timer.wait_time = inventory.get_curr_reload_time()
			reload_timer.start()
			sound_fx.stream = sound_gun
			sound_fx.play()
			if ray.is_colliding():
				var obj = ray.get_collider()
				if obj.is_in_group("target"):
					obj.got_hit()
		elif condition5 and condition3 and condition4:
			inventory.decrease_curr_ammo()
			update_UI()
			var new_grenade = grenade.instance()
			can_shoot = false
			reload_timer.wait_time = inventory.get_curr_reload_time()
			reload_timer.start()
			get_node("../../Spatial").add_child(new_grenade)
			var zPos = global_transform.basis.z
			var xPos = global_transform.basis.x
			new_grenade.global_transform.origin += get_global_transform().origin
			new_grenade.global_transform.origin += transform.basis.xform(Vector3(0, 2, 1))
			new_grenade.linear_velocity  = transform.basis.xform(Vector3.FORWARD)* -20
			sound_fx.stream = sound_grenade_launch
			sound_fx.play()
	
	var forward = global_transform.basis.z;
	var right = global_transform.basis.x;
	
	var relativeDirection = (forward * input.y + right*input.x);
	velocity.x = relativeDirection.x * moveSpeed
	velocity.z = relativeDirection.z * moveSpeed
	
	velocity.y -=gravity*delta;#every second we remove delta
	velocity=  move_and_slide(velocity, Vector3.UP);
	
	pass
	if (Input.is_action_pressed("jump")) and is_on_floor():
		velocity.y = jumpForce
	
	for index in get_slide_count():	
		var collision = get_slide_collision(index)	
		if (collision.collider.is_in_group("collect")):
			user_message.set_text("You have collected an object")
			message_timer.start()
			print("Collision with " + collision.collider.name)
			score += 1
			print ("score " + str(score))
			collision.collider.queue_free()
			score_label.set_text(str(score))
		elif (collision.collider.name == "end" && score == 4):
			print("Congratulations!")
			user_message.set_text("CONGRATULATIONS")
			message_timer.start()
		elif collision.collider.is_in_group("ammo_gun"):
			inventory.weapons[Weapon.TYPE_GUN].increase_ammo(10)
			collision.collider.queue_free()
			update_UI()
			sound_fx.stream = sound_ammo_collect
			sound_fx.play()
			user_message.set_text("COLLECTED GUN AMMO")
			message_timer.start()
		elif collision.collider.is_in_group("auto_ammo_gun"):
			inventory.weapons[Weapon.TYPE_AUTO_GUN].increase_ammo(10)
			collision.collider.queue_free()
			update_UI()
			sound_fx.stream = sound_ammo_collect
			sound_fx.play()
			user_message.set_text("COLLECTED AUTOGUN AMMO")
			message_timer.start()
		elif collision.collider.is_in_group("ammo_grenade"):
			inventory.weapons[Weapon.TYPE_GRENADE].increase_ammo(10)
			collision.collider.queue_free()
			update_UI()
			sound_fx.stream = sound_ammo_collect
			sound_fx.play()
			user_message.set_text("COLLECTED GRENADES")
			message_timer.start()
			
	if Input.is_action_just_pressed("change weapon"):
		inventory.change_weapon()
		update_UI()
		reload_timer.wait_time=inventory.get_curr_reload_time()

	
func _process(delta):#not physics related
	camera.rotation_degrees.x -= mouseDelta.y*sensitivity*delta
	
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle,maxlookAngle)
	#around y axis
	rotation_degrees.y -= mouseDelta.x*sensitivity*delta
	
	#reset mousedelta
	mouseDelta = Vector2()
func _input(event):
	#print("Test")
	if event is InputEventMouseMotion	:
		mouseDelta = event.relative
	if event.is_action_pressed("exit_game"):
#		get_tree().quit()
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_messageTimer_timeout():
	user_message.set_text("")
	update_UI()
	
func reload_timer_timeout():
	can_shoot = true
	reload_timer.stop()
	
func update_UI():
	var message = inventory.get_curr_weapon_name()
	message += "(" + str(inventory.get_curr_weapon_ammo()) + ")"
	user_message.set_text(message)
