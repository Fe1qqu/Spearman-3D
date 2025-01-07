class_name Spearman
extends CharacterBody3D

var health: int = 3
var speed: int = 12

const ACCELERATION: float = 8.0

var input_rotation_x: float = 0.0
var input_rotation_y: float = 0.0
var current_rotation_x: float = 0.0
var current_rotation_y: float = 0.0

const MOUSE_SENSITIVITY: float = 0.1
const JOYSTICK_SENSITIVITY: float = 0.02
const SMOOTHING: float = 10.0
const MAX_VERTICAL_ANGLE: float = PI / 2.2

@onready var camera = $Camera3D
@onready var spear = $Spear
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	update_heath_label()
	update_speed_label()
	update_damage_label()
	update_spear_lenght_label()


func _process(delta: float):
	var stick_x = Input.get_action_strength("look_right") - Input.get_action_strength("look_left")
	var stick_y = Input.get_action_strength("look_down") - Input.get_action_strength("look_up")
	
	if abs(stick_x) > 0 or abs(stick_y) > 0:
		input_rotation_x = -stick_y * JOYSTICK_SENSITIVITY
		input_rotation_y = -stick_x * JOYSTICK_SENSITIVITY
	
	current_rotation_x = lerp(current_rotation_x, input_rotation_x, SMOOTHING * delta)
	current_rotation_y = lerp(current_rotation_y, input_rotation_y, SMOOTHING * delta)
	
	input_rotation_x = 0.0
	input_rotation_y = 0.0
	
	camera.rotation.x += current_rotation_x
	camera.rotation.x = clamp(camera.rotation.x, -MAX_VERTICAL_ANGLE, MAX_VERTICAL_ANGLE)
	rotation.y += current_rotation_y


func _physics_process(delta):
	var direction = Vector2(
		Input.get_action_strength("back") - Input.get_action_strength("forward"),
		Input.get_action_strength("left") - Input.get_action_strength("right")
	).normalized()
	
	direction = direction.rotated(-rotation.y)
	
	velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.y * speed, ACCELERATION * delta)
	
	move_and_slide()
 

func _input(event):
	if event is InputEventMouseMotion:
		input_rotation_x = -deg_to_rad(event.relative.y) * MOUSE_SENSITIVITY
		input_rotation_y = -deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY
	
	if event.is_action_pressed("attack"):
		spear.call("attack")


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		game_over()
	
	update_heath_label()


func game_over():
	get_tree().call_deferred("change_scene_to_file", "res://other/game_over.tscn")


func update_heath_label():
	$Hud/HealthLabel.text = str(health)


func update_speed_label():
	$Hud/SpeedLabel.text = str(speed / 2.0)


func update_damage_label():
	$Hud/DamageLabel.text = str(spear.damage / 2.0)


func update_spear_lenght_label():
	$Hud/SpearLenghtLabel.text = str(spear.lenght / 2.0)


func add_health(amount: int = 2):
	health += amount
	update_heath_label()


func add_speed(amount: int = 2):
	speed += amount
	update_speed_label()


func add_damage(amount: int = 4):
	spear.call("set_damage", spear.damage + amount)
	update_damage_label()


func add_spear_lenght(amount: int = 8):
	spear.lenght += amount
	spear.scale.x += amount / 20.0
	update_spear_lenght_label()


func pick_item(item_type: String):
	match item_type:
		"hearth":
			add_health()
		"lightning":
			add_speed()
		"stick_rope":
			add_spear_lenght()
		"dumbbell":
			add_damage()
		_:
			print("Unknown item type:", item_type)
			return
	
	add_item_to_hud("res://textures/" + item_type + ".png")


func add_item_to_hud(texture_path: String) -> void:
	var texture = load(texture_path)
	if not texture:
		print("Failed to load texture:", texture_path)
		return
	
	var item_icon = TextureRect.new()
	item_icon.texture = texture
	
	$Hud/ItemsGridContainer.add_child(item_icon)
