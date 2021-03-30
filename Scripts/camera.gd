extends Camera

export (NodePath) var targetPath
var target
var offset = 0
var pitch
var yaw
var roll
var weight = 0.05
var mode =  1 #0 fixed

func _ready():
	target = get_node(targetPath)
	pitch = -target.pitch
	yaw = target.yaw
	roll = -target.roll

func _physics_process(delta):
	
	
		
	#Cálculos
	
	if target.crash:
		pitch = lerp (pitch , 0, weight)
		yaw = lerp (yaw, 0, weight)
		roll = lerp (roll, 0, weight)
		offset = lerp(offset, 50, 0.001)
	else:
		pitch =   lerp (pitch , -target.pitch , weight)
		yaw =  lerp (yaw, target.yaw , weight)
		roll = lerp (roll, -target.roll , weight)
		offset = lerp (offset, 15 + (target.engine - 50) / 10, 0.01)
	if Input.is_action_just_pressed("ui_accept"):
		print(pitch," ",yaw," ",roll)
	
	#Aplicar
	var t = target.get_translation()
	set_translation(t)
	if mode == 0:
		rotate_object_local(Vector3(1,0,0), -target.pitch)
		rotate_object_local(Vector3(0,1,0), target.yaw)
		rotate_object_local(Vector3(0,0,1), -target.roll)
	else:
		rotate_object_local(Vector3(1,0,0), pitch)
		rotate_object_local(Vector3(0,1,0), yaw)
		rotate_object_local(Vector3(0,0,1), roll)
	translate(Vector3(0,0,offset))
