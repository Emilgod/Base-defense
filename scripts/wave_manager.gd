extends Control

@export var enemy_types: Array[PackedScene]  # Different enemy scenes
@export var wave_value_budget: int # Total value per wave
@export var spawn_point: Marker3D

var current_wave: int = 0
var current_wave_value: int = 0
var is_wave_active: bool = false

@onready var wave_button = $wave_button
@onready var wave_label = $wave_label

func _ready():
	update_ui()
func _process(delta):
	if current_wave_value < wave_value_budget:
		spawn_random_enemy()
	if current_wave_value >= wave_value_budget and get_enemy_count() == 0:
		finish_wave()
func spawn_random_enemy():
	var enemy_scene = enemy_types[randi() % enemy_types.size()]
	var enemy = enemy_scene.instantiate()
	
	var enemy_value = enemy.wave_value
	if current_wave_value + enemy_value <= wave_value_budget:
		enemy.global_position = spawn_point.global_position
		add_child(enemy)
		current_wave_value += enemy_value
		print(current_wave_value)
		
func _on_start_wave():
	if not is_wave_active:
		is_wave_active = true
		wave_button.disabled = true
		current_wave_value = 0
		update_ui()

func update_ui():
	wave_label.text = "Wave: %d" % current_wave
	if is_wave_active:
		wave_label.text += " | Value: %d/%d" % [current_wave_value, wave_value_budget]

func get_enemy_count() -> int:
	return get_tree().get_nodes_in_group("enemies").size()
	
func finish_wave():
	is_wave_active = false
	wave_button.disabled = false
	update_ui()
	wave_label.text = "Wave: %d  completed!" % current_wave

func _on_wave_button_pressed() -> void:
	if is_wave_active == false:
		current_wave += 1
