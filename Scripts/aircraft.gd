extends KinematicBody

const MOUSE_SENSITIVITY = 0.01

onready var debugLabel = null
onready var shoot_scn = preload("res://shoot.tscn")
var crash = false
var collision = null
var is_shooting = false

#Aircraft physics
var velocity = Vector3()
var min_velocity = 20
var min_trust = 10
var engine = 25
var accel = 0.002
var trust = 20
var drag = 0 #0.001
var lift = 0
var weight = 9.8
var pitch = 0
var yaw = 0
var roll = 0
var trg_pitch = 0
var trg_yaw = 0
var trg_roll = 0
var z_ang
var m_vel
var aileron_accel = 0.25


func _ready():
	debugLabel = get_parent().get_node("debugLabel")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	_draw_debug_label()
	_get_inputs()
	
	#Calculate
	Globals.aircraft_pos = get_translation()
	m_vel = _module(velocity) 
	if crash or trg_roll == 0:
		z_ang = 0
	else:
		z_ang = rotation.z / 1000
		
	aileron_accel = lerp(aileron_accel, m_vel / 300, 0.5)
	pitch = lerp(pitch, trg_pitch - abs(z_ang), aileron_accel)
	roll = lerp(roll, trg_roll, aileron_accel )
	yaw = lerp(yaw, trg_yaw - z_ang, aileron_accel * 2)
	trg_pitch = lerp(trg_pitch, 0, aileron_accel / 10)
	trg_roll = lerp(trg_roll, 0, aileron_accel / 10)
	trg_yaw = lerp(trg_yaw, 0, aileron_accel /2)
	#trust = lerp(trust, 30, accel * engine / 100)
	trust = lerp(trust, min_trust + (engine * 0.8), accel)
	drag = lerp(drag, (0.25 + abs(trg_pitch * 50)) *  m_vel, accel)
	#lift = m_vel / 10
	#trust = lerp(trust,0, drag)
	
	if crash:
		velocity.y -= 0.5
		velocity.x =lerp(velocity.x, 0 , 0.025)
		velocity.z =lerp(velocity.z, 0 , 0.025)
		if floor(m_vel) > 2:
			trg_pitch += rand_range(-0.005,0.005)
			trg_roll += rand_range(-0.005,0.005)
			trg_yaw += rand_range(-0.005,0.005)
		else:
			pitch = 0 #lerp(trg_pitch, 0, aileron_accel * 0.5)
			roll =  0 #lerp(trg_roll, 0, aileron_accel * 0.5)
			yaw =  0 #lerp(trg_yaw, 0, aileron_accel * 0.5)
	else:
		velocity =  (min_velocity + trust - drag) * transform.basis.z 
		
	#velocity =  lift * transform.basis.y + (trust - drag) * transform.basis.z
	#velocity.y -= weight
	#Apply
	rotate_object_local(Vector3(1, 0, 0),pitch)
	rotate_object_local(Vector3(0, 1, 0),yaw)
	rotate_object_local(Vector3(0, 0, 1),roll)
	velocity = move_and_slide(velocity,Vector3(0,1,0))
	
	if get_slide_count() != 0:
		crash = true
		collision = get_slide_collision(get_slide_count() - 1)
		velocity = velocity.bounce(collision.normal)
		

func _input(event):
	if crash:
		return
		
	if event is InputEventMouseMotion:
		var mouse_rel = event.get_relative()
		trg_roll += deg2rad(MOUSE_SENSITIVITY*mouse_rel.x )
		trg_pitch -= deg2rad(MOUSE_SENSITIVITY*mouse_rel.y / 2)
		trg_roll = clamp(trg_roll, -0.02, 0.02)		#Roll limits
		trg_pitch = clamp(trg_pitch, -0.01, 0.005)	#Pitch limits



func _get_inputs():
	if crash:
		return
	
	is_shooting = Input.is_action_pressed("ui_accept")
	
	if Input.is_action_pressed("ui_left"):
		trg_yaw += deg2rad(0.02)
		#trg_yaw = clamp(trg_yaw, -0.005, 0.005)
	elif Input.is_action_pressed("ui_right"):
		trg_yaw -= deg2rad(0.02)
		#trg_yaw = clamp(trg_yaw, -0.005, 0.005)
	
	if Input.is_action_pressed("ui_up"):
		if engine >= 100:
			engine = 175
		else:
			engine += 1
			engine  = clamp(engine, 0 , 100)
			
	elif Input.is_action_just_released("ui_up"):
		engine  = clamp(engine, 0 , 100)
		
	elif Input.is_action_pressed("ui_down"):
		engine -= 1
		engine  = clamp(engine, 0 , 100)

func _module(v:Vector3):
	var m = sqrt(v.x * v.x + v.y * v.y + v.z * v.z) 
	return m

func _draw_debug_label():
	debugLabel.text = "voxel Wings (prototype) - debug label"
	debugLabel.text += "\nFPS: " + str(Engine.get_frames_per_second())
	debugLabel.text += "\nEngine: " + str(engine)
	debugLabel.text += "\nTrust: " + str(trust)
	debugLabel.text += "\nDrag: " + str(drag)
	debugLabel.text += "\nLift: " + str(lift)
	debugLabel.text += "\nVelocity " + str(velocity)
	debugLabel.text += "\nmVelocity: " + str(_module(velocity))
	debugLabel.text += "\nPitch: " + str(pitch)
	debugLabel.text += "\nYaw: " + str(yaw)
	debugLabel.text += "\nRoll: " + str(roll)
	debugLabel.text += "\nZ_angle: " + str(z_ang)
	debugLabel.text += "\nAileron accel: " + str(aileron_accel)


func _on_ShootInterval_timeout():
	$ShootInterval.start()
	if is_shooting:
		var shootL = shoot_scn.instance()
		var shootR = shoot_scn.instance()
		get_parent().add_child(shootL)
		get_parent().add_child(shootR)
		shootL.set_translation(get_translation() + 0.5 * transform.basis.x)
		shootL.rotation = rotation
		shootL.velocity =  5 * transform.basis.z
		shootR.set_translation(get_translation() - 0.5 * transform.basis.x)
		shootR.rotation = rotation
		shootR.velocity =  5 * transform.basis.z
		
