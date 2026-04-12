extends Node3D


@export var build_gridmap: GridMap
@export var camera: Camera3D
@export var current_card: CardData

var occupied_cells: Dictionary = {}
var drag_mode: bool = false  # True when card UI is dragging
var preview_instance: Node3D
var valid_tiles: Array[Vector3i] = []
var is_placing: bool = false
var preview_origin_cell: Vector3i
var preview_rotation: float = 0.0

func _ready():
	valid_tiles = build_gridmap.get_used_cells()

func _input(event):
	# Only allow direct clicking if NOT dragging from UI
	if not drag_mode and event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			pass
			
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if preview_instance:
				preview_rotation += PI / 2  # 90 degree rotation
				preview_instance.rotation.y = preview_rotation

func _process(delta: float) -> void:
	if preview_instance:
		update_preview_position()

func set_drag_mode(is_dragging: bool):
	drag_mode = is_dragging

func spawn_tower(cell: Vector3i, card: CardData):
	if card == null or card.scene == null:
		print("Invalid card or scene")
		return
	
	var footprint = get_footprint_rotated(cell, card.size, preview_rotation)
	
	var footprint_center = Vector3.ZERO
	for foot_cell in footprint:
		footprint_center += build_gridmap.map_to_local(foot_cell)
	footprint_center /= footprint.size()
	
	var tower = card.scene.instantiate()
	tower.global_position = footprint_center
	tower.rotation.y = preview_rotation  # Add this
	add_child(tower)
	
	for foot_cell in footprint:
		occupied_cells[foot_cell] = true
	
	print("Tower spawned at ", cell)

func get_footprint(origin: Vector3i, size: Vector3i) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	for x in range(size.x):
		for z in range(size.z):
			cells.append(origin + Vector3i(x, 0, z))
	return cells

func get_footprint_rotated(origin: Vector3i, size: Vector3i, rotation: float) -> Array[Vector3i]:
	var cells: Array[Vector3i] = []
	var rotations = int(rotation / (PI / 2)) % 4
	
	for x in range(size.x):
		for z in range(size.z):
			var pos = Vector3i(x, 0, z)
			
			# Rotate position around origin
			for _i in range(rotations):
				pos = Vector3i(-pos.z, 0, pos.x)
			
			cells.append(origin + pos)
	
	return cells

func is_cell_occupied(cell: Vector3i) -> bool:
	return occupied_cells.has(cell)

func show_preview(card: CardData):
	current_card = card
	preview_rotation = 0.0  # Reset rotation
	if preview_instance:
		preview_instance.queue_free()
	preview_instance = card.scene.instantiate()
	add_child(preview_instance)

func update_preview_position():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_normal = camera.project_ray_normal(mouse_pos)
	
	if ray_normal.y >= -0.01:
		return
	
	var t = -ray_origin.y / ray_normal.y
	if t < 0:
		return
	
	var world_pos = ray_origin + ray_normal * t
	var local_pos = build_gridmap.to_local(world_pos)
	var cell = build_gridmap.local_to_map(local_pos)
	cell.y = 0
	preview_origin_cell = cell
	
	var footprint = get_footprint_rotated(cell, current_card.size, preview_rotation)
	var footprint_center = Vector3.ZERO
	for foot_cell in footprint:
		footprint_center += build_gridmap.map_to_local(foot_cell)
	footprint_center /= footprint.size()
	
	preview_instance.global_position = footprint_center
	preview_instance.rotation.y = preview_rotation
	
	for foot_cell in footprint:
		print("Cell: ", foot_cell, " | Valid: ", foot_cell in valid_tiles)
	var is_valid = true
	for foot_cell in footprint:
		if foot_cell not in valid_tiles or occupied_cells.has(foot_cell):
			is_valid = false
			break
	
	set_preview_color(is_valid)

func set_preview_color(is_valid: bool):
	var color = Color.GREEN if is_valid else Color.RED 
	set_color_recursive(preview_instance, color)

func set_color_recursive(node: Node, color: Color):
	if node is MeshInstance3D:
		var mesh = node.mesh
		if mesh:
			# Color all surfaces
			for i in range(mesh.get_surface_count()):
				var mat = node.get_active_material(i).duplicate()
				mat.albedo_color = color
				mat.disable_receive_shadows = true
				mat.no_depth_test = true
				node.set_surface_override_material(i, mat)
	
	for child in node.get_children():
		set_color_recursive(child, color)

func hide_preview():
	if preview_instance:
		preview_instance.queue_free()
		preview_instance = null

func try_place_preview() -> bool:
	if not preview_instance:
		return false
	
	var footprint = get_footprint_rotated(preview_origin_cell, current_card.size, preview_rotation)
	var is_valid = true
	for foot_cell in footprint:
		if foot_cell not in valid_tiles or occupied_cells.has(foot_cell):
			is_valid = false
			print("Invalid cell: ", foot_cell)
			break
	
	if is_valid:
		spawn_tower(preview_origin_cell, current_card)
		hide_preview()
		is_placing = false
		return true
	else:
		hide_preview()
		is_placing = false
		return false
