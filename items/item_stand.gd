extends Area3D

var current_item_name: String

var item_scenes = {
	"dumbbell": preload("res://items/dumbbell.glb"),
	"hearth": preload("res://items/hearth.glb"),
	"lightning": preload("res://items/lightning.glb"),
	"stick_tape": preload("res://items/stick_tape.glb")
}

signal item_picked

func _ready() -> void:
	spawn_random_item()
	$AnimationPlayer.play("animation")

func spawn_random_item() -> void:
	var item_names = item_scenes.keys()
	current_item_name = item_names[randi() % item_names.size()]
	
	clear_item()
	
	var item_instance = item_scenes[current_item_name].instantiate()
	$Item.add_child(item_instance)

func clear_item():
	for child in $Item.get_children():
		child.queue_free()

func _on_spearman_entered(body: Spearman) -> void:
	body.pick_item(current_item_name)
	clear_item()
	$CollisionShape3D.set_deferred("disabled", true)
	item_picked.emit()
