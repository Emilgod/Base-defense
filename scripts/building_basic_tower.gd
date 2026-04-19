extends Building
@onready var projectile_scene = preload("res://scenes/buildings/basic_tower_projectile.tscn")

func _process(delta: float) -> void:
	var target = find_target()
	if target and fire_rate.is_stopped():
		print("shootin")
		shoot(target)
		fire_rate.start()

func shoot(target: Node3D):
	var projectile = projectile_scene.instantiate()
	projectile.global_position = $Marker3D.global_position
	projectile.damage = damage
	get_parent().add_child(projectile)
	
	var target_center = target.global_position + Vector3(0, target.get_node("CollisionShape3D").shape.radius, 0)
	var direction = (target_center - projectile.global_position).normalized()
	projectile.velocity = direction * projectile.speed
