extends Node3D

@export var speed = 125.0

@onready var mesh = $proj_1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -speed) * delta
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("friendly"):
		mesh.visible = false
		await get_tree().create_timer(0.1).timeout
		queue_free()
	
func _on_timer_timeout():
	queue_free()
