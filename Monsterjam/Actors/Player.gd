extends KinematicBody2D

export (int) var speed = 200
var timer
var velocity = Vector2()

var life = 4

var run = 0
var left = 0
var right = 1
var roll= 0
var atack = 0

onready var tween = $Tween
var hurtbox
var rest

signal make_damage

func _ready():
	timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)
	timer.set_wait_time(0.2)

	hurtbox = Timer.new()
	hurtbox.connect("timeout",self,"_on_hurtbox_timeout") 
	add_child(hurtbox)
	hurtbox.set_wait_time(0.3)



func get_input():
	velocity = Vector2()
	
	if Input.is_action_just_pressed("ui_accept") and roll == 0 and atack == 0:
		_Roll()
	
	elif Input.is_action_just_pressed("z"):
		if atack == 0:
			atack()
			if right == 1:
				velocity.x = 1
			if left == 1:
				velocity.x = -1
	
	elif Input.is_action_pressed("ui_right") and roll == 0 and atack == 0:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.play("Run")
		velocity.x += 1
		left = 0
		right = 1
		run = 1
		
	elif Input.is_action_pressed("ui_left") and roll == 0 and atack == 0:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.play("Run")
		velocity.x -= 1
		left = 1
		right = 0
		run = 1
	
	elif Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
		
	elif roll == 0 and atack == 0:
		$AnimatedSprite.play("idle")


		
func _Roll():
	timer.start() #to start
	$AnimatedSprite.play("Roll")
	roll = 1
	self.layers = 0

func _physics_process(delta):
	$ProgressBar.value = life
	get_input()

	if roll == 1:
		if right == 1:
			velocity.x = 100 * delta
		if left == 1:
			velocity.x = -100 * delta
	
	velocity = velocity * speed
	velocity = move_and_slide(velocity)


func _on_timer_timeout():
	timer.stop()
	roll = 0
	self.layers = 1


func take_damage(damage):
	tween.interpolate_property($AnimatedSprite,"modulate:a",1,0,0.3)
	tween.start()
	yield(tween, "tween_completed")
	tween.interpolate_property($AnimatedSprite,"modulate:a",0,1,0.1)
	tween.start()
	life -= damage
	print(life)

func atack():
	hurtbox.start()
	$AnimatedSprite.play("Ata")
	atack = 1
	if $AnimatedSprite.flip_h == false:
		$Ataque1.collision_mask = 2
	if $AnimatedSprite.flip_h == true:
		$Ataque2.collision_mask = 2
		print("pega")
		
func _on_hurtbox_timeout():
	atack = 0
	hurtbox.stop()
	$Ataque1.collision_mask = 0
	$Ataque2.collision_mask = 0
	

func _on_Area2D_body_entered(body):
	if body.is_in_group('Ghost'):
		emit_signal("make_damage",body)

func _on_Area2D2_body_entered(body):
	if body.is_in_group('Ghost'):
		emit_signal("make_damage",body)
		print(body)


func _on_Ghost_Archer_take_damage():
	pass # Replace with function body.
