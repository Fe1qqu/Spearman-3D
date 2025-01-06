extends Control

var boss_mark_texture = preload("res://textures/boss_mark.png")

const room_size = Vector2(12, 8) # Размер комнаты на мини-карте
const spacing = Vector2(10, 6) # Промежутки между комнатами
const corridor_thickness = 4 # Толщина соединений (коридоров)
var map = [] # Карта уровня
var current_room = Vector2(0, 0) # Текущая позиция игрока

func _draw():
	var map_size: int = map.size()
	for x in range(map_size):
		for y in range(map_size):
			var room_type = map[x][y]
			if room_type == 0:
				continue
			
			var color: Color
			if room_type == 4 or room_type == -1:
				color = Color.GREEN
			elif room_type == 2:
				color = Color.YELLOW
			elif room_type == 1 or room_type == 3:
				color = Color.RED
			
			var room_position = Vector2(y, x) * (room_size + spacing)
			draw_rect(Rect2(room_position, room_size), color)
			draw_rect(Rect2(room_position + Vector2(1, 1), room_size - Vector2(1, 1)), Color.BLACK, false, 1)
			
			if y < map_size - 1 and map[x][y + 1] != 0:
				# Горизонтальный коридор к соседу справа
				var corridor_pos = room_position + Vector2(room_size.x, (room_size.y - corridor_thickness) / 2)
				draw_rect(Rect2(corridor_pos, Vector2(spacing.x, 4)), Color.BLACK)
			
			if x < map_size - 1 and map[x + 1][y] != 0:
				# Вертикальный коридор к соседу снизу
				var corridor_pos = room_position + Vector2((room_size.x - corridor_thickness) / 2, room_size.y)
				draw_rect(Rect2(corridor_pos, Vector2(corridor_thickness, spacing.y)), Color.BLACK)
			
			if room_type == 3:
				draw_texture(boss_mark_texture, room_position + Vector2(1, 2))
	
	var player_position = Vector2(current_room.y, current_room.x) * (room_size + spacing)
	draw_rect(Rect2(player_position, room_size), Color("#505050")) # Серый
	draw_rect(Rect2(player_position + Vector2(1, 1), room_size - Vector2(1, 1)), Color.BLACK, false, 1)


func update_map(current_room_position: Vector2, visible_on_map_rooms: Array):
	map = visible_on_map_rooms
	current_room = current_room_position
	queue_redraw()
