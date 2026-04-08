extends Node3D

@export var build_gridmap: GridMap
@export var camera: Camera3D
@export var current_card: CardData

var occupied_cells: Dictionary = {}
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			place_tower()

func place_tower():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_origin + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	var result = space_state.intersect_ray(query)
	
	if result:
		print("hit")
		var local_pos = build_gridmap.to_local(result.position)
		var cell = build_gridmap.local_to_map(local_pos)
		
		print("cell: ", cell)
		var tile = build_gridmap.get_cell_item(cell)
		print("tile: ", tile)
		spawn_tower(cell, current_card)
		#if tile != -1:
			#spawn_tower(cell)
	else:
		print("no hit :/")

func spawn_tower(cell: Vector3i, card: CardData):
	if current_card == null or card.scene == null:
		print("hmm")
		return
	
	if occupied_cells.has(cell):
		print("full")
		return
	
	var center_offset = Vector3(card.size.x, 0, card.size.z) * 0.5
	var world_pos = build_gridmap.map_to_local(cell) #+ center_offset
	
	var tower = current_card.scene.instantiate()
	tower.global_position = build_gridmap.to_global(world_pos)
	add_child(tower)
	#occupy_cells(cell,card,tower)
	#occupied_cells[cell] = tower
	print("spawning")


func can_place(cell: Vector3i, card: CardData) -> bool:
	for x in range(cell.x, cell.x + card.size.x):
		for z in range(cell.z, cell.z + card.size.z):
			var c = Vector3i(x, cell.y, z)
			if occupied_cells.has(c):
				return false
			if build_gridmap.get_cell_item(c) == -1:
				return false
	return true

func occupy_cells(cell: Vector3i, card: CardData, tower: Node3D):
	for x in range(cell.x, cell.x + card.size.x):
		for z in range(cell.z, cell.z + card.size.z):
			var c = Vector3i(x, cell.y, z)
			occupied_cells[c] = tower
