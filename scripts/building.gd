class_name Building
extends StaticBody3D

@export var max_health: float 
@export var health_label:Label3D

var current_health: float

var placement_manager: Node3D
var occupied_cells: Array[Vector3i] = []

func _ready():
	current_health = max_health
	health_label.text = str(int(current_health))

func take_damage(damage: float):
	current_health -= damage
	health_label.text = str(int(current_health))
	if current_health <= 0:
		die()
		
func setup(manager: Node3D, cells: Array[Vector3i]):
	placement_manager = manager
	occupied_cells = cells
	
func die():
	# Release occupied cells
	for cell in occupied_cells:
		placement_manager.occupied_cells.erase(cell)
	
	queue_free()

func get_health_percent() -> float:
	return current_health / max_health
