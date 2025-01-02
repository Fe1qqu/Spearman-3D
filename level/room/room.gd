extends Node3D

@onready var doors = [$Doors/DoorTop, $Doors/DoorBottom,
					  $Doors/DoorLeft, $Doors/DoorRight]

# 4 - старт, 3 - босс, 2 - предмет, 1 - обычная
func set_room_type(type):
	pass
	#match room_type:
		#3:
			#spawn_boss()
		#2:
			#spawn_item()
		#1:
			#spawn_enemies()


func show_door(index):
	doors[index].visible = true


func hide_door(index):
	doors[index].visible = false


#func spawn_boss():
	#var boss = preload("res://Boss.tscn").instance()
	#add_child(boss)

#func spawn_item():
	#var item = preload("res://Item.tscn").instance()
	#add_child(item)

#func spawn_enemies():
	#for i in range(randi() % 3 + 1):
		#var enemy = preload("res://Enemy.tscn").instance()
		#enemy.position = Vector3(randf() * 5, 0, randf() * 5)
		#add_child(enemy)
