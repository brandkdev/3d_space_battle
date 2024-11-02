extends Node3D

@export var health = 100
@onready var health_bar = $health_bar

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health_bar.text = str(health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func get_damaged_by_plasma(dmg) -> void:
	health -= dmg
	health_bar.text = str(health)
	if health <= 0:
		die()
	
func die() -> void:
	queue_free()

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("plasma"):
		get_damaged_by_plasma(ProjectileDmgs.plasma_dmg)
