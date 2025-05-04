extends "res://scene/player/bullet/bullet.gd"

func _on_hit(pos: Vector2i, _collisions: int) -> void:
	game.damage_tile(pos, 3)
	game.damage_tile(pos + Vector2i(1, 0), 3)
	game.damage_tile(pos + Vector2i(0, 1), 3)
	game.damage_tile(pos + Vector2i(-1, 0), 3)
	game.damage_tile(pos + Vector2i(0, -1), 3)
	game.damage_tile(pos + Vector2i(1, 1), 2)
	game.damage_tile(pos + Vector2i(-1, 1), 2)
	game.damage_tile(pos + Vector2i(1, -1), 2)
	game.damage_tile(pos + Vector2i(-1, -1), 2)
	
	for body in $Explosion.get_overlapping_bodies():
		if body is Player:
			if body.dead: continue
			if body == player: continue
			body.die()
			
			if body.score_locked:
				player.score = 667
			else:
				player.score += 5
			player._update_score()
	
	$AudioStreamPlayer.play()
	process_mode = Node.PROCESS_MODE_DISABLED
	visible = false
	await $AudioStreamPlayer.finished
	queue_free()
