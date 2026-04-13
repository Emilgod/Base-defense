class_name Enemy
extends RigidBody3D

@export var max_health: float = 20.0
@export var damage: float = 1.0
@export var attack_rate: float = 1.0
@export var gold_reward: int = 10
@export var move_speed: float = 5.0
@export var wave_value: int = 1
var current_health: float
var attack_cooldown: float = 0.0

func _ready():
	current_health = max_health

func _process(delta):
	attack_cooldown -= delta

func take_damage(damage: float):
	current_health -= damage
	if current_health <= 0:
		die()

func can_attack() -> bool:
	return attack_cooldown <= 0.0

func attack(target: Building):
	if can_attack():
		target.take_damage(damage)
		attack_cooldown = 1.0 / attack_rate
		

func die():
	# TODO: Play death effect, award gold
	queue_free()
