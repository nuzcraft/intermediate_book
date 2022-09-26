extends Node
var time:float = 0
var counter:int = 100



# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
onready var timer_ui:Label = get_node("../timerUI")
onready var user_message_ui:Label = get_node("../userMessageUI")


func _ready():
	timer_ui.set_text("")
	user_message_ui.set_text("")
	pass	

func _process(delta):
	time += delta
	if (time > 1):
		counter+=1;
		var seconds = counter%60
		var minutes = counter / 60
		time = 0;
		#print("Time:" + str(counter))	
		#print ("Minutes: %d Seconds: %d" %[minutes,seconds])
		#print ("%d:%d" %[minutes,seconds])
		timer_ui.set_text("%d:%d" %[minutes,seconds])
		if (counter >118) :
			user_message_ui.set_text("Time Almost Up")

		if (counter > 120):
			#print("Time Up!")
			get_tree().change_scene("res://scene1.tscn")

