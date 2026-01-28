class_name FloorConfig
extends Resource

@export var room_config: Array[RoomConfig] = []
@export var boss_type: EnemyType.Boss

func get_random_room_config() -> RoomConfig:
	if room_config.is_empty():
		push_error("[FloorConfig] room_config array is empty.")
		return null
	
	return room_config.pick_random()
