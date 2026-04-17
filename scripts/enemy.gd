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

var current_health: float
var attack_cooldown: float = 0.0
var target_position: Vector3

func _ready():
	global_position += Vector3(randf_range(-2, 2), 0, randf_range(-2, 2))
	current_health = max_health
	gravity_scale = 0
	lock_rotation = true
	
	health_label.text = str(int(current_health))

func _process(delta):
	var nearby_building = find_target_in_detect_range()
	if nearby_building:
		if is_in_attack_range(nearby_building):
			linear_velocity = Vector3.ZERO
			attack(nearby_building)
		else:
			print("IM MOVIN")
			move_towards(nearby_building.global_position, delta)
	else:
		move_towards(target_position, delta)

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
	
	

func find_target_in_detect_range() -> Building:
	for body in targeting_range.get_overlapping_bodies():
		if body.is_in_group("buildings"):
			print("found ya")
			return body
	return null
	

func is_in_attack_range(body: Node3D) -> bool:
	return attack_range.overlaps_body(body)

func move_towards(position: Vector3, delta):
	var direction = (position - global_position).normalized()
	linear_velocity = direction * move_speed

func reached_core():
	queue_free()
	
func die():
	# TODO: Play death effect, award gold
	queue_free()
