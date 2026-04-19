class_name Enemy
extends RigidBody3D

@export var health_label: Label3D
@export var max_health: float = 20.0
@export var damage: float = 1.0
@export var attack_rate: float = 1.0
@export var gold_reward: int = 10
@export var move_speed: float = 5.0
@export var wave_value: int = 1
@export var targeting_range: Area3D
@export var attack_range: Area3D
@export var attack_timer:Timer
@export var shapecast: ShapeCast3D
@export var gold_value: int


var current_health: float
var attack_cooldown: float = 0.0
var target_position: Vector3
func _ready():
	global_position += Vector3(randf_range(-5, 5), 0, randf_range(-2, 2))
	current_health = max_health
	gravity_scale = 0
	lock_rotation = true
	health_label.text = str(int(current_health))

func _process(delta):
	var nearby_building = find_target_in_detect_range()
	
	if nearby_building:
		look_at(nearby_building.global_position)
		if is_in_attack_range(nearby_building):
			linear_velocity = Vector3.ZERO
			attack(nearby_building)
		else:
			var direction = (nearby_building.global_position - global_position).normalized()
			
			var blocked = false
			if shapecast.is_colliding():
				for i in range(shapecast.get_collision_count()):
					var collider = shapecast.get_collider(i)
					if collider and collider.is_in_group("enemies") and collider.is_in_attack_range(nearby_building):
						blocked = true
						break
			
			if blocked:
				direction = Vector3(direction.z, 0, -direction.x)
			
			var collision = move_and_collide(direction * move_speed * delta)
			if collision:
				move_and_collide(collision.get_normal() * 5 * delta)
				print("pushed")
	else:
		var direction = (target_position - global_position).normalized()
		look_at(target_position)
		var collision = move_and_collide(direction * move_speed * delta)
		if collision:
			move_and_collide(collision.get_normal() * 5 * delta)

func take_damage(damage: float):
	current_health -= damage
	health_label.text = str(int(current_health))
	if current_health <= 0:
		die()


func attack(body: Node3D):
	if attack_timer.is_stopped():
		body.take_damage(damage)
		attack_timer.start()
		print("BLASTING")
	
	

func find_target_in_detect_range() -> Node3D:
	var bodies = targeting_range.get_overlapping_bodies()
	var closest: Node3D = null
	var closest_distance = INF
	
	for body in bodies:
		if body and body.is_in_group("buildings"):
			var distance = global_position.distance_to(body.global_position)
			if distance < closest_distance:
				closest = body
				closest_distance = distance
	
	return closest
	

func is_in_attack_range(body: Node3D) -> bool:
	return attack_range.overlaps_body(body)

func move_towards(position: Vector3, delta):
	look_at(target_position)
	var direction = (position - global_position).normalized()
	linear_velocity = direction * move_speed

func reached_core():
	queue_free()
	
func die():
	gravity_scale = 1.0
	GameManager.add_gold(gold_reward)
	queue_free()
