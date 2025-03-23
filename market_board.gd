extends Control

var current_prices: Array[float]
var next_prices: Array[float]
var rng = RandomNumberGenerator.new()

signal potion_hovered(fire_ice:bool, nature_magic:bool, water_earth:bool)
signal potion_unhovered(fire_ice:bool, nature_magic:bool, water_earth:bool)


func generate_price_list() -> Array[float]:
	var out: Array[float] = []
	for i in range(8):
		out.append(rng.randf_range(0,10))
	return out
		

func set_prices() -> void:
	for i in range(8):
		var price_node = get_node("%Price"+str(i+1))
		var change_node = get_node("%Change"+str(i+1))
		price_node.text = "%.2f"%current_prices[i]
		if next_prices[i]>current_prices[i]:
			change_node.text = "up"
			change_node.modulate = Color(0,1,0)
		else:
			change_node.text = "down"
			change_node.modulate = Color(1,0,0)
			

func update_prices():
	current_prices = next_prices
	next_prices = generate_price_list()
	set_prices()

func _ready():
	current_prices = generate_price_list()
	next_prices = generate_price_list()
	set_prices()


func _on_potion_1_mouse_entered():
	potion_hovered.emit(false, false, false)


func _on_potion_2_mouse_entered():
	potion_hovered.emit(false, false, true)


func _on_potion_3_mouse_entered():
	potion_hovered.emit(false, true, false)


func _on_potion_4_mouse_entered():
	potion_hovered.emit(false, true, true)


func _on_potion_5_mouse_entered():
	potion_hovered.emit(true, false, false)


func _on_potion_6_mouse_entered():
	potion_hovered.emit(true, false, true)


func _on_potion_7_mouse_entered():
	potion_hovered.emit(true, true, false)


func _on_potion_8_mouse_entered():
	potion_hovered.emit(true, true, true)


func _on_potion_1_mouse_exited():
	potion_unhovered.emit(false, false, false)


func _on_potion_2_mouse_exited():
	potion_unhovered.emit(false, false, true)


func _on_potion_3_mouse_exited():
	potion_unhovered.emit(false, true, false)


func _on_potion_4_mouse_exited():
	potion_unhovered.emit(false, true, true)


func _on_potion_5_mouse_exited():
	potion_unhovered.emit(true, false, false)


func _on_potion_6_mouse_exited():
	potion_unhovered.emit(true, false, true)


func _on_potion_7_mouse_exited():
	potion_unhovered.emit(true, true, false)


func _on_potion_8_mouse_exited():
	potion_unhovered.emit(true, true, true)
