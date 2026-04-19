extends Area3D

@export var speed: float = 20.0

var damage: float
var velocity: Vector3 = Vector3.ZERO
func _ready() -> void:
	await get_tree().create_timer(5).timeout
	queue_free()
func _process(delta: float) -> void:
	global_position += velocity * delta
	if velocity.length() > 0:
		look_at(global_position + velocity, Vector3.UP)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		print("take dmg")
		queue_free()
