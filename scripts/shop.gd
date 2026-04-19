extends Control
@export var card_hand: HBoxContainer

@export var available_cards: Array[CardData]
# Called when the node enters the scene tree for the first time.
var card_buttons: Array[Button]  = []
@export var wall_card: Button
@export var house_card: Button
@export var tower_card: Button
@export var placement_manager: Node3D

func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass


func _on_wall_card_pressed() -> void:
	buy_card(available_cards[0])


func _on_house_card_pressed() -> void:
	buy_card(available_cards[1])
	pass # Replace with function body.


func _on_tower_card_pressed() -> void:
	buy_card(available_cards[2])
	pass # Replace with function body.

func buy_card(card: CardData):
	if GameManager.gold >= card.cost:
		GameManager.add_gold(-card.cost)
		add_card_to_hand(card)
		print("bought: ", card.card_name)
		
func add_card_to_hand(card: CardData):
	var card_ui_scene = preload("res://scenes/UI/cards_ui.tscn")
	var card_instance = card_ui_scene.instantiate()
	card_instance.card_data = card
	card_instance.placement_manager = placement_manager
	card_instance.update_display()
	card_hand.add_child(card_instance)
