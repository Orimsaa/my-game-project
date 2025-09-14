extends CharacterBody3D

signal hit

@export var speed = 14
@export var jump_impulse = 20
@export var bounce_impulse = 16
@export var fall_acceleration = 75


func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		basis = Basis.looking_at(direction)
		$AnimationPlayer.speed_scale = 4
	else:
		$AnimationPlayer.speed_scale = 1

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse

	velocity.y -= fall_acceleration * delta
	move_and_slide()

	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				mob.squash()
				velocity.y = bounce_impulse
				break

	rotation.x = PI / 6 * velocity.y / jump_impulse


func die():
	hit.emit()
	queue_free()


func _on_MobDetector_body_entered(_body):
	die()
