class_name Player extends CharacterBody2D

signal death
signal score_change

const SPEED := 100.0
const JUMP_VELOCITY := 150.0
const GRAVITY := 1000.0

const BULLET := preload("res://scene/player/bullet/bullet.tscn")
const EXPLOSIVE_BULLET := preload("res://scene/player/bullet/explosive_bullet.tscn")
const BULLET_SPEED := 400.0

const JETPACK_VELOCITY := 70.0
const JETPACK_ACCELERATION := 0.1

@export var input_prefix := ""
@export var game: Game
var score := 0
var score_locked := false
var facing := 1
var dead := false
var pickaxe_power := 2
var jetpack := false
var explosive_ammo := 0

func _ready() -> void:
	# balrogs :3
	if randf() < 0.01:
		$Sprite.texture = preload("res://scene/player/player_demon.png")
		$Sprite/Pickaxe.texture = preload("res://scene/player/item/pickaxe_demon.png")
		pickaxe_power = 100
		jetpack = true
		score = 666
		_update_score()
		score_locked = true
		$UpgradeAudio.stream = preload("res://scene/player/sound/demon.wav")
		$UpgradeAudio.play()

func _movement(delta: float) -> void:
	# Handle jump and gravity.
	if jetpack:
		if Input.is_action_pressed(input_prefix + "jump"):
			$JetpackParticles.emitting = true
			$JumpAudio.playing = true
			velocity.y = move_toward(velocity.y, -JETPACK_VELOCITY, JETPACK_VELOCITY * JETPACK_ACCELERATION)
		else:
			$JetpackParticles.emitting = false
			$JumpAudio.playing = false
			if not is_on_floor():
				velocity.y += GRAVITY * delta
	else:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		
		if Input.is_action_just_pressed(input_prefix + "jump") and is_on_floor():
			velocity.y = -JUMP_VELOCITY
			$JumpAudio.play()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis(input_prefix + "left", input_prefix + "right")
	if direction:
		velocity.x = direction * SPEED
		$Sprite.scale.x = sign(direction)
		facing = sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func _physics_process(delta: float) -> void:
	if dead: return
	
	_movement(delta)
	
	if Input.is_action_pressed(input_prefix + "mine") and not $AnimationPlayer.is_playing():
		$Sprite/Pickaxe.visible = true
		$Sprite/Revolver.visible = false
		
		var direction = Vector2i(facing, 0)
		if Input.is_action_pressed(input_prefix + "up"):
			direction = Vector2i(0, -1)
		elif Input.is_action_pressed(input_prefix + "down"):
			direction = Vector2i(0, 1)
		var pos = game.tile_coords(position) + direction
		var tile_score = game.damage_tile(pos, pickaxe_power)
		if tile_score != -1:
			score += tile_score
			_update_score()
			
			if tile_score > 0:
				$MineGemAudio.play()
			else:
				$MineAudio.play()
		
		$AnimationPlayer.play("mine_forward")
	
	if Input.is_action_just_pressed(input_prefix + "shoot") and not $AnimationPlayer.is_playing():
		$Sprite/Pickaxe.visible = false
		$Sprite/Revolver.visible = true
		
		var direction := Vector2(facing, 0)
		if Input.is_action_pressed(input_prefix + "up"):
			direction = Vector2(0, -1)
		elif Input.is_action_pressed(input_prefix + "down"):
			direction = Vector2(0, 1)
		
		var bullet
		if explosive_ammo > 0:
			explosive_ammo -= 1
			bullet = EXPLOSIVE_BULLET.instantiate()
			if explosive_ammo == 0:
				$ExplosiveDepletedParticles.emitting = true
		else:
			bullet = BULLET.instantiate()
		bullet.velocity = BULLET_SPEED * direction
		bullet.position = position + direction * 8.0
		bullet.player = self
		bullet.game = game
		get_parent().add_child(bullet)
		
		$ShootAudio.play()
		$AnimationPlayer.play("shoot")
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var collider = col.get_collider()
		if collider.is_in_group("kill_area"):
			score = max(score - 10, 0)
			_update_score()
			die()

func die():
	$DeathParticles.emitting = true
	$Sprite.visible = false
	$CollisionShape2D.disabled = true
	dead = true
	
	var tween := create_tween()
	tween.tween_property($PointLight2D, "energy", 0.0, 1.5).set_ease(Tween.EASE_OUT)
	
	await get_tree().create_timer(1.5).timeout
	death.emit()
	queue_free()

func _update_score() -> void:
	if score_locked:
		score = 666
		return
	
	if score > 6 and pickaxe_power < 3:
		pickaxe_power = 3
		$Sprite/Pickaxe.texture = preload("res://scene/player/item/pickaxe_upgraded.png")
		$UpgradeParticles.emitting = true
		$UpgradeAudio.play()
	elif score > 18 and not jetpack:
		jetpack = true
		$Sprite.texture = preload("res://scene/player/player_jetpack.png")
		$UpgradeParticles.emitting = true
		$UpgradeAudio.play()
		$JumpAudio.stream = preload("res://scene/player/sound/jetpack.wav")
	
	score_change.emit()
