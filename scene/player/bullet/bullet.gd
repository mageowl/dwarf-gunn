extends CharacterBody2D

var player: Player
var game: Game

func _physics_process(delta: float) -> void:
	var pos = game.tile_coords(position) + Vector2i(velocity.normalized())
	move_and_slide()
	
	var collisions = get_slide_collision_count()
	if collisions > 0:
		_on_hit(pos, collisions)

func _on_hit(pos: Vector2i, collisions: int) -> void:
	queue_free()
	game.damage_tile(pos, 1)

	for i in collisions:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is Player:
			if collider.dead: continue
			collider.die()
			
			if collider.score_locked:
				player.score = 667
			else:
				player.score += 5
			player._update_score()
