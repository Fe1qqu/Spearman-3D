extends Control

var boss_mark_texture: Texture2D = preload("res://textures/boss_mark.png")

const Room = preload("res://utils/room_type.gd").Room

const ROOM_SIZE: Vector2 = Vector2(12, 8) # Room size on the minimap
const ROOM_SPACING: Vector2 = Vector2(10, 6) # Spaces between rooms
const CORRIDOR_THICKNESS: float = 4.0 # Thickness of connections (corridors)
var map: Array = [] # Level map
var current_room: Vector2 = Vector2(0, 0) # The player's current position

func _draw() -> void:
	var map_size: int = map.size()
	for x in range(map_size):
		for y in range(map_size):
			var room_type: int = map[x][y]
			if room_type == Room.EMPTY:
				continue
			
			var color: Color
			match room_type:
				Room.START, Room.CLEARED:
					color = Color.GREEN
				Room.ITEM:
					color = Color.YELLOW
				Room.DEFAULT, Room.BOSS:
					color = Color.RED
			
			var room_position: Vector2 = Vector2(y, x) * (ROOM_SIZE + ROOM_SPACING)
			draw_rect(Rect2(room_position, ROOM_SIZE), color)
			draw_rect(Rect2(room_position + Vector2(1, 1), ROOM_SIZE - Vector2(1, 1)), Color.BLACK, false, 1)
			
			if y < map_size - 1 and map[x][y + 1] != 0:
				# Horizontal corridor to the neighbor on the right
				var corridor_position: Vector2 = room_position + Vector2(ROOM_SIZE.x, (ROOM_SIZE.y - CORRIDOR_THICKNESS) / 2)
				draw_rect(Rect2(corridor_position, Vector2(ROOM_SPACING.x, 4)), Color.BLACK)
			
			if x < map_size - 1 and map[x + 1][y] != 0:
				# Vertical corridor to the neighbor below
				var corridor_position: Vector2 = room_position + Vector2((ROOM_SIZE.x - CORRIDOR_THICKNESS) / 2, ROOM_SIZE.y)
				draw_rect(Rect2(corridor_position, Vector2(CORRIDOR_THICKNESS, ROOM_SPACING.y)), Color.BLACK)
			
			if room_type == Room.BOSS:
				draw_texture(boss_mark_texture, room_position + Vector2(1, 2))
	
	var player_position: Vector2 = Vector2(current_room.y, current_room.x) * (ROOM_SIZE + ROOM_SPACING)
	draw_rect(Rect2(player_position, ROOM_SIZE), Color("#505050"))
	draw_rect(Rect2(player_position + Vector2(1, 1), ROOM_SIZE - Vector2(1, 1)), Color.BLACK, false, 1)

func update_map(current_room_position: Vector2, visible_on_map_rooms: Array) -> void:
	map = visible_on_map_rooms
	current_room = current_room_position
	queue_redraw()
