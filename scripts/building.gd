class_name Building
extends StaticBody3D

@export var max_health: float 
var current_health: float

func _ready():
	current_health = max_health

func take_damage(damage: float):
	current_health -= damage
	if current_health <= 0:
		die()

func die():
	queue_free()

func get_health_percent() -> float:
	return current_health / max_health
