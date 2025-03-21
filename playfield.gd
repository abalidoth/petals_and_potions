extends Node2D

var rng = RandomNumberGenerator.new()

var mutation_chance = 0.2
var PlantClass = preload("plant.tscn")

var all_tiles : Array[Vector3i]

var total_genes: Vector3
var total_mult: float
var which_potion: int
var potion_base: float
var potion_total : float
var score : float = 0
var week = 0

var directions : Array[Vector3i] = [
	Vector3i(0,-1,1),
	Vector3i(1,-1,0),
	Vector3i(-1,1,0),
	Vector3i(-1,0,1),
	Vector3i(1,0,-1),
	Vector3i(0,1,-1)
]

var plants: Dictionary[Vector3i, Plant]

var selected_plants: Array[Vector3i]

signal brew_started(first_gene:Vector3, second_gene:Vector3)

func generate_field() -> void:
	for x in range(-4,5):
		for y in range(-4,5):
			if abs(x+y)<=4:
				all_tiles.append(Vector3i(x,y,-x-y))

func tile_to_world(tile:Vector3i) -> Vector2:
	return $TileMapLayer.map_to_local(Vector2i(tile.x, tile.y)) + $TileMapLayer.position
	

func make_new_plant(tile:Vector3i, genes: Vector3) -> void:
	var new_plant = PlantClass.instantiate()
	plants[tile] = new_plant
	$Plants.add_child(new_plant)
	new_plant.genes = genes
	new_plant.set_gene_expression()
	new_plant.position = tile_to_world(tile)
	new_plant.tile = tile
	new_plant.plant_clicked.connect(_on_plant_clicked)

func _ready() -> void:
	generate_field()
	for tile in all_tiles:
		var new_genes = Vector3(
			rng.randf_range(-1,1),
			rng.randf_range(-1,1),
			rng.randf_range(-1,1)
		)
		make_new_plant(tile, new_genes)
		if rng.randf()<0.5:
			plants[tile].grow_up()
	brew_disable()
	%WeekLabel.text = "1\n/20"
		
func _on_plant_clicked(tile:Vector3i) -> void:
	if tile in selected_plants:
		plants[tile].deselect()
		selected_plants.erase(tile)
	elif len(selected_plants)<2:
		selected_plants.append(tile)
		plants[tile].select()
		
	if len(selected_plants)==2:
		brew_enable()
	else:
		brew_disable()
	
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
		if len(selected_plants)==2:
			_on_brew_button_pressed()
	elif event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_on_pass_time_button_pressed()


func brew_enable() -> void:
	%BrewButton.disabled = false
	%BrewTip.visible = true
	total_genes = plants[selected_plants[0]].genes + plants[selected_plants[1]].genes
	
	if total_genes.x>0:
		%FireProgress.value = total_genes.x / 2 * 100
		%FireProgressLabel.text = ("%d"%(total_genes.x*100))+"%"
		%IceProgress.value = 0
		%IceProgressLabel.text = ""
	else:
		%IceProgress.value = -total_genes.x / 2 * 100
		%IceProgressLabel.text = ("%d"%(-total_genes.x*100))+"%"
		%FireProgress.value = 0
		%FireProgressLabel.text = ""
	
	if total_genes.y>0:
		%NatureProgress.value = total_genes.y / 2 * 100
		%NatureProgressLabel.text = ("%d"%(total_genes.y*100))+"%"
		%MagicProgress.value = 0
		%MagicProgressLabel.text = ""
	else:
		%MagicProgress.value = -total_genes.y / 2 * 100
		%MagicProgressLabel.text = ("%d"%(-total_genes.y*100))+"%"
		%NatureProgress.value = 0
		%NatureProgressLabel.text = ""
	
	if total_genes.z>0:
		%WaterProgress.value = total_genes.z / 2 * 100
		%WaterProgressLabel.text = ("%d"%(total_genes.z*100))+"%"
		%EarthProgress.value = 0
		%EarthProgressLabel.text = ""
	else:
		%EarthProgress.value = -total_genes.z / 2 * 100
		%EarthProgressLabel.text = ("%d"%(-total_genes.z*100))+"%"
		%WaterProgress.value = 0
		%WaterProgressLabel.text = ""
		
	total_mult = abs(total_genes.x) * abs(total_genes.y) * abs(total_genes.z)
	%Multiplier.text = ("%d"%(total_mult*100))+"%"
	
	which_potion =0
	if total_genes.x < 0:
		which_potion += 4
	if total_genes.y < 0:
		which_potion += 2
	if total_genes.z < 0:
		which_potion += 1
	
	potion_base = %MarketBoard.current_prices[which_potion]
	%BasePrice.text = "%.2f"%potion_base
	potion_total = total_mult * potion_base
	%Total.text = "%.2f"%potion_total
	
	
	
func brew_disable() -> void:
	%BrewButton.disabled=true
	%BrewTip.visible = false
	
	
func brew_potion() -> void:
	score += potion_total
	%CurrentScore.text = "%.2f"%score
	
	var plant_a : Vector3i = selected_plants[0]
	var plant_b : Vector3i = selected_plants[1]
	brew_started.emit(plants[plant_a].genes, plants[plant_b].genes)
	plants[plant_a].queue_free()
	plants[plant_b].queue_free()
	plants.erase(plant_a)
	plants.erase(plant_b)
	selected_plants = []
	
func _on_brew_button_pressed():
	brew_potion()
	brew_disable()


func _on_pass_time_button_pressed():
	pass_time() # Replace with function body.


func pass_time():
	week += 1
	%WeekLabel.text = str(week) + "\n/20"
	$MarketBoard.update_prices()
	for tile in all_tiles:
		if tile not in plants:
			var neighbors = []
			var new_genes: Vector3 = Vector3.ZERO
			for dir in directions:
				if tile+dir in plants and not plants[tile+dir].baby:
					neighbors.append(tile+dir)
			if neighbors:
				for i in range(3):
					if rng.randf() < mutation_chance:
						new_genes[i] = rng.randf_range(-1,1)
					else:
						new_genes[i] = plants[neighbors[rng.randi_range(0,len(neighbors)-1)]].genes[i]
				make_new_plant(tile, new_genes)
				plants[tile].new_baby = true
	for tile in all_tiles:
		if tile in plants and plants[tile].baby:
			if plants[tile].new_baby:
				plants[tile].new_baby = false
			else:
				plants[tile].grow_up()
						
				
					

func unhover_potions() ->void:
	for plant in plants:
		plants[plant].stop_highlight()

func _on_market_board_potion_hovered(fire_ice, nature_magic, water_earth):
	for plant in plants:
		var this_plant = plants[plant]
		if (
			(this_plant.genes.x < 0)==fire_ice and
			(this_plant.genes.y < 0)==nature_magic and
			(this_plant.genes.z < 0)==water_earth and
			not this_plant.baby
		):
			this_plant.start_highlight()
			


func _on_market_board_potion_unhovered(fire_ice, nature_magic, water_earth):
	for plant in plants:
		var this_plant = plants[plant]
		if (
			(this_plant.genes.x < 0)==fire_ice and
			(this_plant.genes.y < 0)==nature_magic and
			(this_plant.genes.z < 0)==water_earth and
			not this_plant.baby
		):
			this_plant.stop_highlight()
