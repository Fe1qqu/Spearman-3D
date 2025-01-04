extends Node3D

var current_stage = 0 # Текущий этаж

const ROOM_SCENE = preload("res://level/room/room.tscn")
const MAP_SIZE = 6 # Размер карты (6x6 комнат)

var map = [] # Карта уровня
var current_room_position = Vector2(0, 0) # Текущая позиция на карте
var current_room = null

var enemy_scenes = [
	preload("res://characters/enemies/enemy1/enemy1.tscn"),
	preload("res://characters/enemies/enemy2/enemy2.tscn"),
	preload("res://characters/enemies/enemy3/enemy3.tscn")
]

var enemy_layout = [
	[[0, 0], [0, 0, 1], [0, 0, 0]],      # Этаж 1
	[[1, 1], [1, 2], [0, 1, 1]],         # Этаж 2
	[[2, 2], [1, 1, 2], [0, 0, 0, 0]],   # Этаж 3
	[[0, 1, 2], [1, 2, 2], [1, 1, 1, 1]] # Этаж 4
]

var enemy_positions_layout = [
	[[Vector3(8, 0, -8), Vector3(-8, 0, 8)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)]], # Этаж 1
	[[Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(0, 0, 0), Vector3(8, 0, -8), Vector3(-8, 0, 8)]], # Этаж 2
	[[Vector3(2, 0, 2), Vector3(-2, 0, -2)], [Vector3(-1, 0, 0), Vector3(1, 0, 1), Vector3(1, 0, -1)], [Vector3(8, 0, 8), Vector3(8, 0, -8), Vector3(-8, 0, 8), Vector3(-8, 0, -8)]], # Этаж 3
	[[Vector3(-2, 0, 0), Vector3(2, 0, 2), Vector3(2, 0, -2)], [Vector3(-2, 0, 0), Vector3(2, 0, 2), Vector3(2, 0, -2)], [Vector3(8, 0, 8), Vector3(8, 0, -8), Vector3(-8, 0, 8), Vector3(-8, 0, -8)]] # Этаж 4
]

func _ready():
	generate_level()
	load_room(current_room_position, -1)
	print_map()


func generate_level():
	# Создаём пустую карту
	map = []
	for i in range(MAP_SIZE):
		map.append([])
		for j in range(MAP_SIZE):
			map[i].append(0)
	
	var start_x = randi() % MAP_SIZE
	var start_y = randi() % MAP_SIZE
	current_room_position = Vector2(start_x, start_y)
	map[start_x][start_y] = 4 # Стартовая комната
	
	var boss_x
	var boss_y
	while true:
		boss_x = randi() % MAP_SIZE
		boss_y = randi() % MAP_SIZE
		if abs(boss_x - start_x) + abs(boss_y - start_y) > 2:
			map[boss_x][boss_y] = 3 # Комната с боссом
			break

	var item_x
	var item_y
	while true:
		item_x = randi() % MAP_SIZE
		item_y = randi() % MAP_SIZE
		if abs(item_x - start_x) + abs(item_y - start_y) > 2 and abs(item_x - boss_x) + abs(item_y - boss_y) > 2:
			map[item_x][item_y] = 2 # Комната с предметом
			break
	
	connect_rooms(start_x, start_y, boss_x, boss_y)
	connect_rooms(start_x, start_y, item_x, item_y)


func connect_rooms(x1, y1, x2, y2):
	var target_room_type = map[x2][y2]
	
	while x1 != x2 or y1 != y2:
		if randf() < 0.5 and x1 != x2:
			x1 += sign(x2 - x1)
		elif y1 != y2:
			y1 += sign(y2 - y1)
		
		if map[x1][y1] == 0:
			map[x1][y1] = 1 # Обычная комната
	
	map[x2][y2] = target_room_type


func load_room(position: Vector2, direction: int):
	print(current_room_position)
	
	if current_room:
		current_room.queue_free()
	
	current_room = ROOM_SCENE.instantiate()
	current_room.position = Vector3(0, 0, 0)
	add_child(current_room)
	
	var room_type = map[position.x][position.y]
	current_room.set_room_type(room_type, direction)
	
	update_doors(current_room_position)


func update_doors(room_position: Vector2):
	var neighbors = [
		Vector2(room_position.x - 1, room_position.y), # Сосед сверху
		Vector2(room_position.x, room_position.y + 1), # Сосед справа
		Vector2(room_position.x + 1, room_position.y), # Сосед снизу
		Vector2(room_position.x, room_position.y - 1) # Сосед слева
	]
	
	for i in range(4):
		if is_valid_position(neighbors[i]) and map[neighbors[i].x][neighbors[i].y] != 0:
			current_room.show_door(i)
		else:
			current_room.hide_door(i)


func is_valid_position(room_position: Vector2) -> bool:
	return room_position.x >= 0 and room_position.x < MAP_SIZE and room_position.y >= 0 and room_position.y < MAP_SIZE


func move_to_room(direction: int):
	var new_position = current_room_position
	
	if direction == 0: # Вверх
		new_position.x -= 1
	elif direction == 1: # Вправо
		new_position.y += 1
	elif direction == 2: # Вниз
		new_position.x += 1
	elif direction == 3: # Влево
		new_position.y -= 1
	else:
		return
	
	if is_valid_position(new_position) and map[new_position.x][new_position.y] != 0:
		current_room_position = new_position
		load_room(current_room_position, direction)


func print_map():
	for row in map:
		print(row)
