class_name LevelManager
extends Node3D

signal room_changed(new_position, visible_map)

var current_stage: int = 0 # Current floor
const MAX_STAGE: int = 4
const MAP_SIZE: int = 6 # Map size (6x6 rooms)

const ROOM_SCENE: PackedScene = preload("res://level/room/room.tscn")
const Direction = preload("res://utils/direction.gd").Direction
const Room = preload("res://utils/room_type.gd").Room

var map: Array = [] # Level map
var visible_on_map_rooms: Array = [] # An array for storing visited rooms and their neighbors
var current_room_position: Vector2 = Vector2(0, 0) # Current position on the map
var room_instance: Node3D = null

var enemy_scenes: Array[PackedScene] = [
	preload("res://characters/enemies/enemy1/enemy1.tscn"),
	preload("res://characters/enemies/enemy2/enemy2.tscn"),
	preload("res://characters/enemies/enemy3/enemy3.tscn")
]

var boss_scenes: Array[PackedScene] = [
	preload("res://characters/enemies/enemy4/enemy4.tscn"),
	preload("res://characters/enemies/enemy5/enemy5.tscn"),
	preload("res://characters/enemies/enemy6/enemy6.tscn"),
	preload("res://characters/enemies/enemy7/enemy7.tscn")
]

var item_stand_scene: PackedScene = preload("res://items/item_stand.tscn")

var enemy_layout: Array = [
	[[0, 0], [0, 0, 1], [0, 0, 0]],      # Floor 1
	[[1, 1], [1, 2], [0, 1, 1]],         # Floor 2
	[[2, 2], [1, 1, 2], [0, 0, 0, 0]],   # Floor 3
	[[0, 1, 2], [1, 2, 2], [1, 1, 1, 1]] # Floor 4
]

var enemy_positions_layout: Array = [
	[[Vector3(8, 0, -8), Vector3(-8, 0, 8)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)]], # Floor 1
	[[Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(0, 0, 0), Vector3(8, 0, -8), Vector3(-8, 0, 8)]], # Floor 2
	[[Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)], [Vector3(8, 0, 8), Vector3(8, 0, -8), Vector3(-8, 0, 8), Vector3(-8, 0, -8)]], # Floor 3
	[[Vector3(-2, 0, 0), Vector3(2, 0, 2), Vector3(2, 0, -2)], [Vector3(-2, 0, 0), Vector3(2, 0, 2), Vector3(2, 0, -2)], [Vector3(8, 0, 8), Vector3(8, 0, -8), Vector3(-8, 0, 8), Vector3(-8, 0, -8)]] # Floor 4
]

func _ready() -> void:
	generate_level()
	load_room(Direction.NO_DIRECTION)

func generate_level() -> void:
	map = []
	visible_on_map_rooms = []
	
	# Create an empty map
	for i in range(MAP_SIZE):
		map.append([])
		visible_on_map_rooms.append([])
		for j in range(MAP_SIZE):
			map[i].append(Room.EMPTY)
			visible_on_map_rooms[i].append(Room.EMPTY)
	
	var start_x: int = randi() % MAP_SIZE
	var start_y: int = randi() % MAP_SIZE
	current_room_position = Vector2(start_x, start_y)
	map[start_x][start_y] = Room.START
	visible_on_map_rooms[start_x][start_y] = Room.START # Mark the starting room as visited
	
	var boss_x: int
	var boss_y: int
	while true:
		boss_x = randi() % MAP_SIZE
		boss_y = randi() % MAP_SIZE
		if abs(boss_x - start_x) + abs(boss_y - start_y) > 2:
			map[boss_x][boss_y] = Room.BOSS # Boss room
			break

	var item_x: int
	var item_y: int
	while true:
		item_x = randi() % MAP_SIZE
		item_y = randi() % MAP_SIZE
		if abs(item_x - start_x) + abs(item_y - start_y) > 2 and abs(item_x - boss_x) + abs(item_y - boss_y) > 2:
			map[item_x][item_y] = Room.ITEM # Room with an item
			break
	
	connect_rooms(start_x, start_y, boss_x, boss_y)
	connect_rooms(start_x, start_y, item_x, item_y)

func connect_rooms(x1: int, y1: int, x2: int, y2: int) -> void:
	var target_room_type: Room = map[x2][y2]
	
	while x1 != x2 or y1 != y2:
		if randf() < 0.5 and x1 != x2:
			x1 += sign(x2 - x1)
		elif y1 != y2:
			y1 += sign(y2 - y1)
		
		if map[x1][y1] == Room.EMPTY:
			map[x1][y1] = Room.DEFAULT # Normal room with enemies
	
	map[x2][y2] = target_room_type

func load_room(direction: Direction) -> void:
	if not room_instance:
		room_instance = ROOM_SCENE.instantiate()
		add_child(room_instance)
	
	update_doors_visibility(current_room_position)
	
	var room_type: Room = map[current_room_position.x][current_room_position.y]
	room_instance.set_room_type(room_type, direction)
	
	emit_signal("room_changed", current_room_position, visible_on_map_rooms)

func update_doors_visibility(room_position: Vector2) -> void:
	var neighbors: Array[Vector2] = [
		Vector2(room_position.x - 1, room_position.y), # Upstairs neighbor 
		Vector2(room_position.x, room_position.y + 1), # Neighbor on the right
		Vector2(room_position.x + 1, room_position.y), # Downstairs neighbor
		Vector2(room_position.x, room_position.y - 1)  # Neighbor on the left
	]
	
	for i in range(4):
		if is_valid_position(neighbors[i]) and map[neighbors[i].x][neighbors[i].y] != Room.EMPTY:
			room_instance.show_door(i)
			
			# Mark neighbors as possible to visit
			visible_on_map_rooms[neighbors[i].x][neighbors[i].y] = map[neighbors[i].x][neighbors[i].y]
		else:
			room_instance.hide_door(i)

func is_valid_position(room_position: Vector2) -> bool:
	return room_position.x >= 0 and room_position.x < MAP_SIZE and room_position.y >= 0 and room_position.y < MAP_SIZE

func move_to_room(direction: Direction) -> void:
	var new_position: Vector2 = current_room_position
	
	match direction:
		Direction.UP:
			new_position.x -= 1
		Direction.RIGHT:
			new_position.y += 1
		Direction.DOWN:
			new_position.x += 1
		Direction.LEFT:
			new_position.y -= 1
		_:
			return
	
	if is_valid_position(new_position) and map[new_position.x][new_position.y] != Room.EMPTY:
		current_room_position = new_position
		load_room(direction)

func go_to_next_stage() -> void:
	current_stage += 1
	
	if current_stage == MAX_STAGE:
		game_won()
	
	generate_level()
	load_room(Direction.NO_DIRECTION)
 
func game_won() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://other/game_won.tscn")
