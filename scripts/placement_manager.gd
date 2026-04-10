extends Node3D


@export var build_gridmap: GridMap
@export var camera: Camera3D
@export var current_card: CardData

var occupied_cells: Dictionary = {}
var drag_mode: bool = false  # True when card UI is dragging
var preview_instance: Node3D
var valid_tiles: Array[Vector3i] = []

func _ready():
	valid_tiles = build_gridmap.get_used_cells()

func _input(event):
	# Only allow direct clicking if NOT dragging from UI
	if not drag_mode and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pass
			#place_tower()

func _process(delta: float) -> void:
	if preview_instance:
		update_preview_position()

func set_drag_mode(is_dragging: bool):
	drag_mode = is_dragging

func place_tower():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		var local_pos = build_gridmap.to_local(result.position)
		var cell = build_gridmap.local_to_map(local_pos)
		
		spawn_tower(cell, current_card)
	else:
		print("clicked nuffin")

func spawn_tower(cell: Vector3i, card: CardData):
	if card == null or card.scene == null:
		print("Invalid card or scene")
		return
	
	# Check if placement is valid
	var footprint = get_footprint(cell, card.size)
	for foot_cell in footprint:
		if occupied_cells.has(foot_cell):
			print("Cell occupied: ", foot_cell)
			return
	
	# Calculate world position
	var world_pos = build_gridmap.map_to_local(cell)
	
	# Instantiate and place tower
	var tower = card.scene.instantiate()
	tower.global_position = build_gridmap.to_global(world_pos)
	add_child(tower)
	
	# Mark cells as occupied
	for foot_cell in footprint:
		occupied_cells[foot_cell] = true
	
	print("Tower spawned at ", cell)

func get_footprint(origin: Vector3i, size: Vector3i) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for x in range(size.x):
		for z in range(size.z):
			cells.append(origin + Vector3i(x, 0, z))
	return cells

func is_cell_occupied(cell: Vector3i) -> bool:
	return occupied_cells.has(cell)

func show_preview(card: CardData):
	if preview_instance:
		preview_instance.queue_free()
	preview_instance = card.scene.instantiate()
	add_child(preview_instance)

func update_preview_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	
	# Raycast to ground
	var t = -ray_origin.y / ray_normal.y
	var world_pos = ray_origin + ray_normal * t
	var cell = build_gridmap.local_to_map(build_gridmap.to_local(world_pos))
	
	preview_instance.global_position = build_gridmap.map_to_local(cell)
	
	var is_valid = cell in valid_tiles and not occupied_cells.has(cell)
	set_preview_color(is_valid)
	
func set_preview_color(is_valid: bool):
	var color = Color.GREEN if is_valid else Color.RED
	set_color_recursive(preview_instance, color)

func set_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mat = node.get_active_material(0).duplicate()
		mat.albedo_color = color
		node.set_surface_override_material(0, mat)
	
	for child in node.get_children():
		set_color_recursive(child, color)

func hide_preview():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null

func try_place_preview() -> bool:
	if not preview_instance:
		return false
	
	var cell = build_gridmap.local_to_map(build_gridmap.to_local(preview_instance.global_position))
	
	if cell in valid_tiles and not occupied_cells.has(cell):
		spawn_tower(cell, current_card)
		hide_preview()
		await get_tree().process_frame  # Wait one frame
		return true
	else:
		hide_preview()
		return false
