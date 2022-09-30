class_name WeaponInventory

var Weapon = load("res://Weapon.gd")
var weapons = []
var weapon_index: int = 0

func _init():
	var weapon1 = Weapon.new(Weapon.TYPE_GUN)
	var weapon2 = Weapon.new(Weapon.TYPE_AUTO_GUN)
	var weapon3 = Weapon.new(Weapon.TYPE_GRENADE)
	weapons = [weapon1, weapon2, weapon3]
	
func change_weapon():
	weapon_index += 1
	if weapon_index > 2:
		weapon_index = 0
		
func has_ammo_for_current():
	return weapons[weapon_index].ammos > 0
	
func decrease_curr_ammo(amount: int = 1):
	weapons[weapon_index].decrease_ammo(amount)

func get_curr_reload_time():
	return weapons[weapon_index].reload_time
	
func get_curr_weapon_name():
	return weapons[weapon_index].name
	
func get_curr_weapon_ammo():
	return weapons[weapon_index].ammo
