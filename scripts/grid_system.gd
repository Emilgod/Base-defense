extends Node3D

const GRID_WIDTH  := 30
const GRID_HEIGHT := 30
const CELL_SIZE   := 2.0  # metres per cell

# Tracks which cells are occupied. Key: Vector2i, Value: Node3D (the building)
var occupied: Dictionary = {}

# The GridMap node (assign in inspector or find by name)
@onready var grid_map: GridMap = $GridMap

# Highlight materials — assign in inspector
@export var mat_hover:    StandardMaterial3D
@export var mat_blocked:  StandardMaterial3D
@export var mat_valid:    StandardMaterial3D

# Currently hovered cells (for highlight cleanup)
var _last_highlight: Array[Vector2i] = []


func _ready() -> void:
	pass
	#_build_floor()

# ── Floor ────────────────────────────────────────────────────────────────────

func _build_floor() -> void:
	# Fill every cell with mesh item 0 (your floor tile)
	for x in range(GRID_WIDTH):
		for z in range(GRID_HEIGHT):
			grid_map.set_cell_item(Vector3i(x, 0, z), 0)


# ── Coordinate helpers ───────────────────────────────────────────────────────

## World position → grid cell (ignores Y)
func world_to_cell(world_pos: Vector3) -> Vector2i:
	return Vector2i(
		int(floor(world_pos.x / CELL_SIZE)),
		int(floor(world_pos.z / CELL_SIZE))
	)

## Grid cell → world position (centred on cell, at y=0)
func cell_to_world(cell: Vector2i) -> Vector3:
	return Vector3(
		cell.x * CELL_SIZE + CELL_SIZE * 0.5,
		0.0,
		cell.y * CELL_SIZE + CELL_SIZE * 0.5
	)

## Returns all cells a building would occupy given its anchor + footprint
## footprint: Vector2i — e.g. Vector2i(2,2) or Vector2i(1,4)
func get_footprint_cells(anchor: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dx in range(footprint.x):
		for dz in range(footprint.y):
			cells.append(anchor + Vector2i(dx, dz))
	return cells


# ── Placement validation ─────────────────────────────────────────────────────

func can_place(anchor: Vector2i, footprint: Vector2i) -> bool:
	for cell in get_footprint_cells(anchor, footprint):
		if not is_in_bounds(cell):
			return false
		if occupied.has(cell):
			return false
	return true

func is_in_bounds(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.x < GRID_WIDTH \
		and cell.y >= 0 and cell.y < GRID_HEIGHT


# ── Placement / removal ──────────────────────────────────────────────────────

func place_building(building: Node3D, anchor: Vector2i, footprint: Vector2i) -> bool:
	if not can_place(anchor, footprint):
		return false

	# Mark cells occupied
	for cell in get_footprint_cells(anchor, footprint):
		occupied[cell] = building

	# Snap building to world position (centred on footprint)
	var centre := _footprint_centre(anchor, footprint)
	building.position = centre
	$BuildingContainer.add_child(building)
	return true

func remove_building(anchor: Vector2i, footprint: Vector2i) -> void:
	var cells := get_footprint_cells(anchor, footprint)
	if cells.is_empty():
		return
	var building: Node3D = occupied.get(cells[0])
	for cell in cells:
		occupied.erase(cell)
	if building:
		building.queue_free()


# ── Hover highlight ──────────────────────────────────────────────────────────

func highlight_cells(anchor: Vector2i, footprint: Vector2i) -> void:
	clear_highlight()
	var cells := get_footprint_cells(anchor, footprint)
	var valid  := can_place(anchor, footprint)
	for cell in cells:
		if is_in_bounds(cell):
			# Item 1 = hover-valid tile, Item 2 = hover-blocked tile
			# (set these up in your GridMap MeshLibrary)
			grid_map.set_cell_item(Vector3i(cell.x, 0, cell.y), 1 if valid else 2)
	_last_highlight = cells

func clear_highlight() -> void:
	for cell in _last_highlight:
		if is_in_bounds(cell):
			grid_map.set_cell_item(Vector3i(cell.x, 0, cell.y), 0)
	_last_highlight.clear()


# ── Internal ─────────────────────────────────────────────────────────────────

func _footprint_centre(anchor: Vector2i, footprint: Vector2i) -> Vector3:
	var half_x := footprint.x * CELL_SIZE * 0.5
	var half_z := footprint.y * CELL_SIZE * 0.5
	return Vector3(
		anchor.x * CELL_SIZE + half_x,
		0.0,
		anchor.y * CELL_SIZE + half_z
	)
