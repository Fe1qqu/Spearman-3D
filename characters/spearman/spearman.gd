extends CharacterBody3D
class_name Spearman

var health = 1000

const SPEED: float = 10.0
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
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$Hud/HealthLabel.text = str(health)


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
	
	velocity.x = lerp(velocity.x, direction.x * SPEED, ACCELERATION * delta)
	velocity.z = lerp(velocity.z, direction.y * SPEED, ACCELERATION * delta)
	
	move_and_slide()
 

func _input(event):
	if event is InputEventMouseMotion:
		input_rotation_x = -deg_to_rad(event.relative.y) * MOUSE_SENSITIVITY
		input_rotation_y = -deg_to_rad(event.relative.x) * MOUSE_SENSITIVITY
	
	if event.is_action_pressed("attack"):
		$Spear.call("attack")


func take_damage(amount: int) -> void:
	health = max(0, health - amount)
	if health == 0:
		queue_free()
	
	$Hud/HealthLabel.text = str(health)
