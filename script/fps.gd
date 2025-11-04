extends Node


const SPEED = 5.0
const JUMP_VELOCITY = 10
const COOL_BONE = 3

var mouse_prev_pos
@export var charecter: CharacterBody3D
@export var camera: Camera3D
@export var neck: Node3D


var intendedDir = 0

func _ready() -> void:
	mouse_prev_pos = get_viewport().get_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var sensativity = 5
var delay = 0
func _process(delta: float) -> void:
	if charecter.position.y < -100:
		charecter.position = Vector3.ZERO
	# charecter.rotation.y += intendedDir - charecter.rotation.y
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if delay > 0:
		delay -= delta
		return

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		camera.rotate_x(deg_to_rad(-event.relative.y * 0.1 * sensativity))
		neck.rotate_y(deg_to_rad(event.relative.x * 0.1 * -1 * sensativity))
		var camera_rot = neck.rotation_degrees
		neck.rotation_degrees = camera_rot
		neck.rotation.x = clamp(neck.rotation.x, -1, 1)
		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not charecter.is_on_floor():
		charecter.velocity += charecter.get_gravity() * delta
	if Input.is_action_just_pressed("jump") and charecter.is_on_floor():
		charecter.velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (charecter.transform.basis * Vector3(input_dir.x * sin(neck.rotation.y + PI / 2) + input_dir.y * sin(neck.rotation.y), 0, input_dir.x * cos(neck.rotation.y + PI / 2) + input_dir.y * cos(neck.rotation.y))).normalized()

	camera.fov = clamp(50 + charecter.velocity.length() * 2, 60, 120)
	if direction:
		alignCharecter(direction)
		charecter.velocity.x += SPEED * direction.x * delta * 2
		charecter.velocity.z += SPEED * direction.z * delta * 2
		charecter.velocity.x *= 0.99
		charecter.velocity.z *= 0.99
	else:
		charecter.velocity.x *= 0.95
		charecter.velocity.z *= 0.95
	charecter.move_and_slide()

func alignCharecter(dir):
	intendedDir = - Vector2(dir.x, dir.z).angle() + PI / 2
