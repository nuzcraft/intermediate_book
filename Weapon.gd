class_name Weapon

const TYPE_GUN: int = 0
const TYPE_AUTO_GUN: int = 1
const TYPE_GRENADE: int = 2

var reload_time: float
var name: String
var ammo : int
var max_ammo : int

func _init(weapon_type: int=TYPE_GUN):
	match weapon_type: 
		TYPE_GUN:
			name = "GUN"
			reload_time = 2
			ammo = 10
			max_ammo = 20
		TYPE_AUTO_GUN:
			name = "AUTOMATIC GUN"
			reload_time = 0.5
			ammo = 20
			max_ammo = 20
		TYPE_GRENADE:
			name = "GRENADE"
			reload_time = 3
			ammo = 10
			max_ammo = 5
	print("Created Weapon Type: " + str(weapon_type))
	
func increase_ammo(ammo_increase: int=1):
	if (ammo + ammo_increase <= max_ammo):
		ammo += ammo_increase
		
func decrease_ammo(ammo_decrease: int=1):
	ammo -= ammo_decrease
	if ammo < 0:
		ammo = 0
