extends Node3D

@export var spearman = preload("res://characters/spearman/spearman.tscn")
var spearman_instance: Spearman = null

@onready var level_manager = get_parent()

@onready var doors = [$Doors/DoorTop, $Doors/DoorRight,
					  $Doors/DoorBottom, $Doors/DoorLeft]

@onready var spearman_positions = {
					0: Vector3(8, 0, 0), # Верхняя дверь
					1: Vector3(0, 0, 8), # Правая дверь
					2: Vector3(-8, 0, 0), # Нижняя дверь
					3: Vector3(0, 0, -8), # Левая дверь
				}

# Количество противников в комнате
var count_enemies: int

var current_item_stand: Node = null

func set_room_type(type: int, from_door_index: int):
	if not spearman_instance:
			spearman_instance = spearman.instantiate()
			add_child(spearman_instance)
	
	move_spearman_to_door(from_door_index)
	
	match type:
		4: # Стартовая комната
			open_all_doors()
		3: # Комната с боссом
			close_all_doors()
			spawn_boss()
		2: # Комната с предметом
			open_all_doors()
			spawn_item()
		1: # Обычная комната
			close_all_doors()
			spawn_enemies()
		-1: # Зачищенная обычная комната
			open_all_doors()

func show_door(index):
	doors[index].visible = true

func hide_door(index):
	doors[index].visible = false

# Метод для изменения состояния двери
func set_door_state(index: int, is_open: bool):
	var door = doors[index]
	var collision_shape = door.get_node("Area3D").get_node("CollisionShape3D")
	
	if is_open:
		door.texture = load("res://textures/door_opened.png")
		collision_shape.set_deferred("disabled", false)
	else:
		door.texture = load("res://textures/door_closed.png")
		collision_shape.set_deferred("disabled", true)

# Закрываем все двери
func close_all_doors():
	for i in range(doors.size()):
		if doors[i].visible:
			set_door_state(i, false)

# Открываем все двери
func open_all_doors():
	for i in range(doors.size()):
		if doors[i].visible:
			set_door_state(i, true)

func move_spearman_to_door(from_door_index: int):
	var spearman_position = Vector3.ZERO if from_door_index == -1 else spearman_positions[from_door_index]
	spearman_instance.position = spearman_position
	
	# Устанавливаем направление взгляда, если это не стартовая позиция
	if from_door_index != -1:
		spearman_instance.look_at(Vector3.ZERO)
		spearman_instance.rotate_y(-PI / 2)

func spawn_boss():
	var current_stage = level_manager.current_stage
	var boss_instance = level_manager.boss_scenes[current_stage].instantiate()
	boss_instance.position = Vector3(0.1, 0, 0)
	boss_instance.spearman = spearman_instance
	
	boss_instance.connect("tree_exited", self._on_boss_died)
	
	add_child(boss_instance)
	
	set_boss_door_state(false)

func _on_boss_died():
	set_boss_door_state(true)

func set_boss_door_state(is_open: bool):
	var door = $Doors/DoorBoss
	var collision_shape = door.get_node("Area3D").get_node("CollisionShape3D")
	
	if is_open:
		door.texture = load("res://textures/boss_door_opened.png")
		collision_shape.set_deferred("disabled", false)
	else:
		door.texture = load("res://textures/boss_door_closed.png")
		collision_shape.set_deferred("disabled", true)
	
	door.visible = true

func spawn_item():
	var item_stand_instance = level_manager.item_stand_scene.instantiate()
	current_item_stand = item_stand_instance
	
	var position_on_map: Vector2 = level_manager.current_room_position
	level_manager.map[position_on_map.x][position_on_map.y] = -1 # Зачищенная обычная комната
	
	add_child(item_stand_instance)

func clear_item_stand():
	if current_item_stand:
		current_item_stand.queue_free()
		current_item_stand = null

func spawn_enemies():
	var current_stage = level_manager.current_stage
	
	var enemy_set = level_manager.enemy_layout[current_stage]
	var position_set = level_manager.enemy_positions_layout[current_stage]
	
	var random_index = randi() % enemy_set.size()
	var enemies_to_spawn = enemy_set[random_index]
	var positions_to_use = position_set[random_index]
	
	count_enemies = enemies_to_spawn.size()
	
	for i in range(count_enemies):
		var enemy_type_index = enemies_to_spawn[i]
		var enemy_instance = level_manager.enemy_scenes[enemy_type_index].instantiate()
		enemy_instance.position = positions_to_use[i]
		enemy_instance.spearman = spearman_instance
		
		enemy_instance.connect("tree_exited", self._on_enemy_died)
		
		add_child(enemy_instance)

func _on_enemy_died():
	count_enemies -= 1
	if count_enemies == 0:
		open_all_doors()
		var position_on_map: Vector2 = level_manager.current_room_position
		level_manager.map[position_on_map.x][position_on_map.y] = -1 # Зачищенная обычная комната

func _on_door_area_body_entered(_body: Spearman, door_name: String) -> void:
	clear_item_stand()
	
	var direction: int = -1
	
	match door_name:
		"DoorTop":
			direction = 0 # Вверх
		"DoorRight":
			direction = 1 # Вправо
		"DoorBottom":
			direction = 2 # Вниз
		"DoorLeft":
			direction = 3 # Влево
		"DoorBoss":
			set_boss_door_state(false)
			$Doors/DoorBoss.visible = false
			level_manager.go_to_next_stage()
			return
	
	level_manager.move_to_room(direction)
