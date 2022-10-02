extends RigidBody

export(AudioStream) var sound_grenade_explode: AudioStream

onready var player_sound_fx = get_node("/root/Spatial/player/sound_fx")

var timer: Timer

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = 2
	timer.start()
	timer.connect("timeout", self, "destroy")

func destroy():
	var targets = get_tree().get_nodes_in_group("target")
	var size = targets.size()
	if not targets == null:
		for index in targets:
			var other_node = index
			var distance_to_target = global_transform.origin.distance_to(other_node.global_transform.origin)
			if distance_to_target < 5:
				other_node.queue_free()
	print(player_sound_fx)
	player_sound_fx.stream = sound_grenade_explode
	player_sound_fx.play()
	queue_free()
