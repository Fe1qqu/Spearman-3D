extends Node3D

@export var spearman: PackedScene = preload("res://characters/spearman/spearman.tscn")
var spearman_instance: Spearman = null

@onready var level_manager: Node3D = get_parent()

@onready var doors: Array[Sprite3D] = [$Doors/DoorTop, $Doors/DoorRight,
									   $Doors/DoorBottom, $Doors/DoorLeft]

@onready var boss_door: Sprite3D = $Doors/DoorBoss

@onready var spearman_positions: Dictionary[int, Vector3] = {
	Direction.UP: Vector3(ROOM_RADIUS, 0, 0),
	Direction.RIGHT: Vector3(0, 0, ROOM_RADIUS),
	Direction.DOWN: Vector3(-ROOM_RADIUS, 0, 0),
	Direction.LEFT: Vector3(0, 0, -ROOM_RADIUS)
}

const Direction = preload("res://utils/direction.gd").Direction
const Room = preload("res://utils/room_type.gd").Room

const ROOM_RADIUS: float = 8.5

# Number of enemies in the room
var count_enemies: int

var current_item_stand: Node = null

func set_room_type(room_type: Room, from_door_direction: Direction) -> void:
	if not spearman_instance:
		spearman_instance = spearman.instantiate()
		add_child(spearman_instance)
	
	move_spearman_to_door(from_door_direction)
	
	match room_type:
		Room.START:
			open_all_doors()
		Room.BOSS:
			close_all_doors()
			spawn_boss()
		Room.ITEM:
			open_all_doors()
			spawn_item()
		Room.DEFAULT:
			close_all_doors()
			spawn_enemies()
		Room.CLEARED:
			open_all_doors()

func show_door(index) -> void:
	doors[index].visible = true

func hide_door(index) -> void:
	doors[index].visible = false

func set_door_state(index: int, is_open: bool) -> void:
	var door: Sprite3D = doors[index]
	var collision_shape: CollisionShape3D = door.get_node("Area3D").get_node("CollisionShape3D")
	
	if is_open:
		door.texture = load("res://textures/door_opened.png")
		collision_shape.set_deferred("disabled", false)
	else:
		door.texture = load("res://textures/door_closed.png")
		collision_shape.set_deferred("disabled", true)

func close_all_doors() -> void:
	for i in range(doors.size()):
		if doors[i].visible:
			set_door_state(i, false)

func open_all_doors() -> void:
	for i in range(doors.size()):
		if doors[i].visible:
			set_door_state(i, true)

func move_spearman_to_door(from_door_direction: Direction) -> void:
	if from_door_direction == Direction.NO_DIRECTION:
		# Starting position: Spearman in the center of the room
		spearman_instance.position = Vector3.ZERO
	else:
		# If came through the door, place the Spearman next to the door
		spearman_instance.position = spearman_positions[from_door_direction]

func spawn_boss() -> void:
	var current_stage: int = level_manager.current_stage
	var boss_instance: Node3D = level_manager.boss_scenes[current_stage].instantiate()
	boss_instance.position = Vector3(0.1, 0, 0)
	boss_instance.spearman = spearman_instance
	
	boss_instance.connect("tree_exited", self._on_boss_died)
	
	add_child(boss_instance)
	
	set_boss_door_state(false)

func _on_boss_died() -> void:
	set_boss_door_state(true)

func set_boss_door_state(is_open: bool) -> void:
	var collision_shape: CollisionShape3D = boss_door.get_node("Area3D").get_node("CollisionShape3D")
	
	if is_open:
		boss_door.texture = load("res://textures/boss_door_opened.png")
		collision_shape.set_deferred("disabled", false)
	else:
		boss_door.texture = load("res://textures/boss_door_closed.png")
		collision_shape.set_deferred("disabled", true)
	
	boss_door.visible = true

func spawn_item() -> void:
	var item_stand_instance: Node3D = level_manager.item_stand_scene.instantiate()
	current_item_stand = item_stand_instance
	
	var position_on_map: Vector2 = level_manager.current_room_position
	level_manager.map[position_on_map.x][position_on_map.y] = Room.CLEARED
	
	add_child(item_stand_instance)

func clear_item_stand() -> void:
	if current_item_stand:
		current_item_stand.queue_free()
		current_item_stand = null

func spawn_enemies() -> void:
	var current_stage: int = level_manager.current_stage
	
	var enemy_set: Array = level_manager.enemy_layout[current_stage]
	var position_set: Array = level_manager.enemy_positions_layout[current_stage]
	
	var random_index: int = randi() % enemy_set.size()
	var enemies_to_spawn: Array = enemy_set[random_index]
	var positions_to_use: Array = position_set[random_index]
	
	count_enemies = enemies_to_spawn.size()
	
	for i in range(count_enemies):
		var enemy_type_index: int = enemies_to_spawn[i]
		var enemy_instance: Node3D = level_manager.enemy_scenes[enemy_type_index].instantiate()
		enemy_instance.position = positions_to_use[i]
		enemy_instance.spearman = spearman_instance
		
		enemy_instance.connect("tree_exited", self._on_enemy_died)
		
		add_child(enemy_instance)

func _on_enemy_died() -> void:
	count_enemies -= 1
	if count_enemies == 0:
		open_all_doors()
		var position_on_map: Vector2 = level_manager.current_room_position
		level_manager.map[position_on_map.x][position_on_map.y] = Room.CLEARED

func _on_door_area_body_entered(_body: Spearman, door_name: String) -> void:
	clear_item_stand()
	
	var direction: Direction = Direction.NO_DIRECTION
	
	match door_name:
		"DoorTop": 
			direction = Direction.UP
		"DoorRight": 
			direction = Direction.RIGHT
		"DoorBottom": 
			direction = Direction.DOWN
		"DoorLeft": 
			direction = Direction.LEFT
		"DoorBoss":
			set_boss_door_state(false)
			boss_door.visible = false
			level_manager.go_to_next_stage()
			return
	
	level_manager.move_to_room(direction)
