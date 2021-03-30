extends "res://Scripts/target.gd"

func _physics_process(delta):
	look_at(Globals.aircraft_pos, Vector3(0,-1,0))
