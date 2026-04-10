extends Control

@export var card_data: CardData
@export var description: Label
@export var title: Label
@export var color_rect: ColorRect
@export var placement_manager: Node3D


var is_dragging:bool = false


func _ready():
	if card_data:
		update_display()

func update_display():
	title.text = card_data.card_name
	description.text = card_data.description
	color_rect.modulate = Color.GREEN


func _process(_delta):
	pass


func _input(event: InputEvent):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and is_dragging:
			is_dragging = false
			var success = await placement_manager.try_place_preview()
			if not success:
				show()






func _on_tower_art_mouse_entered() -> void:
	print("hello mouse")


func _on_tower_art_mouse_exited() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		is_dragging = true
		placement_manager.show_preview(card_data)
		hide()
