extends CharacterBody3D

var projectile_1 = preload("res://Modules/Projectiles/projectile_1.tscn")
var instance
var health = 100
@onready var health_bar = $player_healthbar

@export var max_speed = 50.0
@export var max_strafe_speed = 35.0
@export var max_rev_speed = 25.0
@export var acceleration = 5.0

@onready var camera = $Camera_Controller/Camera_Target/Camera3D
@onready var body = $Cube
@onready var camera_controller = $Camera_Controller

var rayOrigin = Vector3()
var rayEnd = Vector3()

var forward_speed = 0.0
var strafe_speed_r = 0.0
var strafe_speed_l = 0.0
var reverse_speed = 0.0

func get_input(delta):
	if Input.is_action_pressed("forward"):
		forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
		velocity = -transform.basis.z * forward_speed
	else:
		forward_speed = lerp(forward_speed, 0.0, acceleration * delta)
		velocity = -transform.basis.z * forward_speed
	if Input.is_action_pressed("strafe_R"):
		strafe_speed_r = lerp(strafe_speed_r, max_strafe_speed, acceleration * delta)
		velocity += transform.basis.x * strafe_speed_r
	else:
		strafe_speed_r = lerp(strafe_speed_r, 0.0, acceleration * delta)
		velocity -= transform.basis.x * -strafe_speed_r
	if Input.is_action_pressed("strafe_L"):
		strafe_speed_l = lerp(strafe_speed_l, max_strafe_speed, acceleration * delta)
		velocity += -transform.basis.x * strafe_speed_l
	else:
		strafe_speed_l = lerp(strafe_speed_l, 0.0, acceleration * delta)
		velocity -= -transform.basis.x * -strafe_speed_l
	if Input.is_action_pressed("reverse"):
		reverse_speed = lerp(reverse_speed, max_rev_speed, acceleration * delta)
		velocity += transform.basis.z * reverse_speed
	else:
		reverse_speed = lerp(reverse_speed, 0.0, acceleration * delta)
		velocity -= transform.basis.z * -reverse_speed
	if Input.is_action_just_pressed("weapon_1"):
		instance = projectile_1.instantiate()
		instance.position = position
		instance.transform.basis = transform.basis
		get_parent().add_child(instance)
		
		

func _physics_process(delta: float) -> void:
	get_input(delta)
	
	var space_state = get_world_3d().direct_space_state
	
	var mouse_position = get_viewport().get_mouse_position()
	
	rayOrigin = camera.project_ray_origin(mouse_position)
	
	rayEnd = rayOrigin + camera.project_ray_normal(mouse_position) * 2000
	
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	var intersection = space_state.intersect_ray(query)
	
	if not intersection.is_empty():
		var pos = intersection.position
		look_at(Vector3(pos.x, position.y, pos.z), Vector3(0,1,0))
		
	move_and_slide()
	
	# Make camera controller match position of character
	camera_controller.position = lerp(camera_controller.position, position, 0.05)

func get_damaged_by_plasma(dmg) -> void:
	health -= dmg
	health_bar.text = str(health)
	if health <= 0:
		die()
		
		
func die():
	get_tree().paused = true

func _on_player_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("plasma_enemy"):
		get_damaged_by_plasma(ProjectileDmgs.plasma_dmg)
