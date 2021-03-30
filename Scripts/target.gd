
extends StaticBody

var num_hits = 6
onready var explosion_scn = preload("res://Particles/explosion.tscn")
func _ready():
	set_physics_process(false)
	set_process(false)

func _hit(val):
	num_hits -= val
	if num_hits <= 0:
		var explosion = explosion_scn.instance()
		get_parent().add_child(explosion)
		explosion.set_translation(get_translation()-Vector3(0,-5,0))
		explosion.emitting = true
		queue_free()
