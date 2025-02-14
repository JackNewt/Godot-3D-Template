 extends KinematicBody

onready var Camera = $Pivot/Camera


var reloading = 0

var gravity = -30
var max_speed = 8
var mouse_sensitivity = 0.002
var mouse_range = 1.2

onready var rc = $Pivot/RayCast

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var velocity = Vector3()

func get_input():
	var input_dir = Vector3()
	if Input.is_action_pressed("forward"):
		input_dir += -Camera.global_transform.basis.z
	if Input.is_action_pressed("back"):
		input_dir += Camera.global_transform.basis.z
	if Input.is_action_pressed("left"):
		input_dir += -Camera.global_transform.basis.x
	if Input.is_action_pressed("right"):
		input_dir += Camera.global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir

func _unhandled_input(event):
	if event is InputEventMouseMotion:

		$Pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		rotate_y(-event.relative.x * mouse_sensitivity)
		$Pivot.rotation.x = clamp($Pivot.rotation.x, -mouse_range, mouse_range)
	

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	
	if Input.is_action_just_pressed("reload"):
		if reloading == 0:
			Global.ammo = -1
			$Pivot/Camera/Gun/Reload.start()
			$Pivot/Camera/Gun.reload()
			print("reloading")
			reloading = 1
			
	if Input.is_action_just_pressed("shoot"):
		if Global.ammo > 0:
			Global.ammo -= 1
			$Pivot/Camera/Gun.shoot()
			if rc.is_colliding():
				print("hit")
				var c = rc.get_collider()
				if c.has_method("damage"):
					c.damage(5)
		elif Global.ammo <= 0:
			if reloading == 0:
				Global.ammo -= 1
				$Pivot/Camera/Gun/Reload.start()
				$Pivot/Camera/Gun.reload()
				reloading = 1

func damage(d):
	Global.health -= d
	if Global.health <= 0:
# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Menus/End_Screen.tscn")





func _on_Reload_timeout():
	Global.ammo = 6
	reloading = 0
