extends Node

var current_wave:int = 0
var gold: int = 100
var wave_active:bool = false
func _ready() -> void:
	pass

func add_gold(enemy_gold: int):
	gold += enemy_gold
