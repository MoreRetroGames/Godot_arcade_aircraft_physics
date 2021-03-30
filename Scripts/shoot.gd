extends KinematicBody

onready var velocity = Vector3()
onready var collision
onready var disolve_scn = preload("res://Particles/disolve.tscn")

func _ready():
	pass 

func _physics_process(delta):
	collision = move_and_collide(velocity)
	if collision != null:
		if collision.collider.is_in_group("Targets"):
			collision.collider._hit(1)
		var disolve = disolve_scn.instance()
		get_parent().add_child(disolve)
		disolve.set_translation(collision.position)
		disolve.emitting = true
		
		queue_free()


func _on_Timer_timeout():
	queue_free()
