extends Node3D

const ROOM_SCENE = preload("res://level/room/room.tscn")
const MAP_SIZE = 6 # Размер карты (6x6 комнат)

var map = [] # Карта уровня
var current_room_position = Vector2(0, 0) # Текущая позиция на карте
var current_room = null

func _ready():
	generate_level()
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
	map[start_x][start_y] = 4 # 2 - стартовая комната

	var boss_x
	var boss_y
	while true:
		boss_x = randi() % MAP_SIZE
		boss_y = randi() % MAP_SIZE
		if abs(boss_x - start_x) + abs(boss_y - start_y) > 2:
			map[boss_x][boss_y] = 3 # 2 - комната с боссом
			break

	var item_x
	var item_y
	while true:
		item_x = randi() % MAP_SIZE
		item_y = randi() % MAP_SIZE
		if abs(item_x - start_x) + abs(item_y - start_y) > 2 and abs(item_x - boss_x) + abs(item_y - boss_y) > 2:
			map[item_x][item_y] = 2 # 2 - комната с предметом
			break
	
	connect_rooms(start_x, start_y, boss_x, boss_y)
	connect_rooms(start_x, start_y, item_x, item_y)


func connect_rooms(x1, y1, x2, y2):
	while x1 != x2 or y1 != y2:
		if randf() < 0.5 and x1 != x2:
			x1 += sign(x2 - x1)
		elif y1 != y2:
			y1 += sign(y2 - y1)
		map[x1][y1] = 1 # 1 - обычная комната


func load_room(position: Vector2):
	if current_room:
		current_room.queue_free()  # Удаляем старую комнату

	# Загружаем новую комнату
	current_room = ROOM_SCENE.instance()
	current_room.position = Vector3(0, 0, 0)  # В центре сцены
	add_child(current_room)

	# Настраиваем комнату
	var room_type = map[position.x][position.y]
	current_room.set_room_type(room_type)

	# Обновляем двери в зависимости от соседей
	update_doors(position)


func update_doors(position: Vector2):
	var neighbors = [
		Vector2(position.x, position.y - 1),  # Сосед сверху
		Vector2(position.x, position.y + 1),  # Сосед снизу
		Vector2(position.x - 1, position.y),  # Сосед слева
		Vector2(position.x + 1, position.y)   # Сосед справа
	]

	for i in range(4):
		if is_valid_position(neighbors[i]) and map[neighbors[i].x][neighbors[i].y] != 0:
			current_room.show_door(i)  # Показываем дверь
		else:
			current_room.hide_door(i)  # Скрываем дверь


func is_valid_position(position: Vector2) -> bool:
	return position.x >= 0 and position.x < MAP_SIZE and position.y >= 0 and position.y < MAP_SIZE


func move_to_room(direction: int):
	var new_position = current_room_position
	if direction == 0:  # Вверх
		new_position.y -= 1
	elif direction == 1:  # Вниз
		new_position.y += 1
	elif direction == 2:  # Влево
		new_position.x -= 1
	elif direction == 3:  # Вправо
		new_position.x += 1

	if is_valid_position(new_position) and map[new_position.x][new_position.y] != 0:
		current_room_position = new_position
		load_room(current_room_position)


func print_map():
	for row in map:
		print(row)
