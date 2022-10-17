extends KinematicBody2D

export (int) var detect_radius
var target
var Player = null 
var move = Vector2.ZERO 
var speed = 15 #su velocidad
var hit_pos
var vis_color = Color(.867, .91, .247, 0.1)
var laser_color = Color(1.0, 1.329, 1.298)

#Mirando
var left
var right

#Rangos
var hit = 0
var hit1 = 0
var atack = 0
var los = 0

#Timers
var timer
var reajustar
var hurtbox

onready var tween = $Tween

var hp = 3


signal take_damage

func _ready():
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)
	timer.set_wait_time(0.8)
	
	reajustar = Timer.new()
	reajustar.connect("timeout",self,"_on_reajustar_timeout") 
	add_child(reajustar)
	reajustar.set_wait_time(0.4)
	
	hurtbox = Timer.new()
	hurtbox.connect("timeout",self,"_on_hurtbox_timeout") 
	add_child(hurtbox)
	hurtbox.set_wait_time(0.3)

func _physics_process(delta):
	update()
	move = Vector2.ZERO
	hit_pos = []
	if Player and atack == 0:
		var space_state = get_world_2d().direct_space_state
		var nw = Player.position
		for pos in [Player.position, nw]:
			var result = space_state.intersect_ray(position,
					pos, [self], collision_mask)
			if result:
				hit_pos.append(result.position)
				move = position.direction_to(Player.position) * speed
				if move.x < 0:
					$AnimatedSprite.flip_h = true
					right = 1
					left = 0
				if move.x > 0:
					$AnimatedSprite.flip_h = false
					right = 1
					left = 0
	move = move.normalized() #para que funcione mejor
	move = move_and_collide(move) #para moverse

func _draw():
	draw_circle(Vector2(), detect_radius, vis_color)
	if target:
		for hit in hit_pos:
			draw_circle((hit - position).rotated(-rotation), 5, laser_color)
			draw_line(Vector2(), (hit - position).rotated(-rotation), laser_color)

func prep():
	timer.start()
	$AnimatedSprite.play("Prep")
	atack = 1

func atack():
	hurtbox.start()
	$AnimatedSprite.play("Ata")
	if hit == 1 and $AnimatedSprite.flip_h == false:
		emit_signal("take_damage",1)
	if hit1 == 1 and $AnimatedSprite.flip_h == true:
		emit_signal("take_damage",1)
		
func _on_reajustar_timeout():
	reajustar.stop()
	if los == 0 and atack == 0:
		atack = 0
		reajustar.start()
	if los == 1 and atack == 0:
		prep()

func _on_timer_timeout():
	timer.stop()
	atack()

func _on_hurtbox_timeout():
	hurtbox.stop()
	reajustar.start()
	$AnimatedSprite.play("Run")
	atack = 0

func _on_Vision_body_entered(body):
	if body.is_in_group('Player') and atack == 0:
		Player = body
		target = Player
		$AnimatedSprite.play("Run")
		
		
func _on_Los_atk_body_entered(body):
	if body.is_in_group('Player') and atack == 0:
		los = 1
		prep()



func _on_Los_atk_body_exited(body):
	los = 0




func _on_Player_make_damage(body):

	if self == body:
		hp -= 1
		self.tween.interpolate_property($AnimatedSprite,"modulate:a",1,0,0.3)
		self.tween.start()
		yield(tween, "tween_completed")
		self.tween.interpolate_property($AnimatedSprite,"modulate:a",0,1,0.1)
		self.tween.start()
		if hp <= 0:
			queue_free()
