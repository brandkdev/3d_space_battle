extends CharacterBody3D

var projectile_1 = preload("res://Modules/Projectiles/projectile_1_enemy.tscn")
var instance
var player = null
var timer = null
var projectile_delay = 0.5
var can_shoot = true
var follow_range = 100.0

@export var health = 100
@onready var health_bar = $health_bar

@export var max_speed = 45.0
@export var acceleration = 5.0

var forward_speed = 0.0


func _ready() -> void:
	timer = Timer.new()
	timer.set_one_shot(true)
	timer.set_wait_time(projectile_delay)
	timer.connect("timeout", on_timeout_complete)
	add_child(timer)
	health_bar.text = str(health)

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if player:
		var player_direction = position.direction_to(player.position)
		var distance_to_player = position.distance_to(player.position)
		
		look_at(player.position, Vector3(0,1,0), 0)
		
		if distance_to_player > follow_range:
			forward_speed = lerp(forward_speed, max_speed, acceleration * delta)
			velocity = player_direction * forward_speed
		else:
			forward_speed = lerp(forward_speed, 0.0, acceleration * delta)
			velocity = player_direction * forward_speed
			
		if can_shoot == true:
			shoot()
			can_shoot = false
			timer.start()
			
	move_and_slide()
	
func shoot():
		instance = projectile_1.instantiate()
		instance.position = position
		instance.transform.basis = transform.basis
		get_parent().add_child(instance)

func _on_detect_radius_body_entered(body: Node3D) -> void:
	if body.is_in_group("friendly"):
		player = body


func _on_detect_radius_body_exited(body: Node3D) -> void:
	if body.is_in_group("friendly"):
		player = null
		

func on_timeout_complete():
	can_shoot = true

func get_damaged_by_plasma(dmg) -> void:
	health -= dmg
	health_bar.text = str(health)
	if health <= 0:
		die()
	
func die() -> void:
	queue_free()

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("plasma"):
		get_damaged_by_plasma(ProjectileDmgs.plasma_dmg)
