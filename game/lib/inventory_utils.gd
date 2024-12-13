class_name InventoryUtils

## Uses an item from the player's inventory.
## This is the main way we interact with items in the player's inventory.
## Calls the run_action method on the item's [Action].
## Parameters:
##   - item: The item [Entity] to use.
##   - player: The player [Entity] using the [C_Item] from the `item`.
static func use_inventory_item(item: Entity, player: Entity):
	var action = get_item_action(item)
	Loggie.debug('Using Item', item)
	if action:
		# We execute the action with no entities, as the action should be able to find the entities it needs.
		action.run_action([], {'item': item, 'player': player, 'from': 'InventoryUtils.use_inventory_item'})
	
	remove_inventory_item(item)

## Adds an item to the player's inventory.
## Parameters:
##   - c_item: The item component to add.
##   - quantity: The quantity of the item to add.
## Returns:
##   - The new item entity added to the inventory.
static func add_inventory_c_item(c_item: C_Item, quantity: int = 1):
	var new_item = Item.new()
	new_item.add_components([c_item, C_InInventory.new(), C_Quantity.new(quantity)])
	ECS.world.add_entity(new_item)
	GameState.inventory_item_added.emit(new_item)
	Loggie.debug('Added item to inventory: ', new_item.name, ' Quantity: ', quantity)
	return new_item

## Gets the quantity of the specified item.
## Parameters:
##   - item: The item entity.
## Returns:
##   - The quantity of the item.
static func get_item_quantity(item: Entity) -> int:
	if not item:
		return 0
	var c_qty = item.get_component(C_Quantity) as C_Quantity
	return c_qty.value if c_qty else 1

## Gets the action associated with the item.
## Parameters:
##   - item: The item entity.
## Returns:
##   - The action associated with the item.
static func get_item_action(item: Entity) -> Action:
	var c_item_weapon = get_item_or_weapon(item)
	if c_item_weapon:
		return c_item_weapon.action
	assert(false, 'Item does not have an action')
	return

## Gets the item or weapon component from the entity.
## Parameters:
##   - item: The item entity.
## Returns:
##   - The item or weapon component.
static func get_item_or_weapon(item:Entity):
	var c_item = item.get_component(C_Item) as C_Item
	var c_weapon = item.get_component(C_Weapon) as C_Weapon
	if c_item:
		return c_item
	if c_weapon:
		return c_weapon
	return

## Removes a specified quantity of an item from the player's inventory.
## Parameters:
##   - item: The item entity to remove.
##   - remove_quantity: The quantity to remove.
static func remove_inventory_item(item: Entity, remove_quantity = 1):	
	var c_item_weapon = get_item_or_weapon(item)
	var c_qty = item.get_component(C_Quantity) as C_Quantity
	var quantity = c_qty.value if c_qty else 1
	if c_item_weapon:
		if quantity >= remove_quantity:
			quantity -= remove_quantity
		if quantity == 0:
			item.add_component(C_IsPendingDelete.new())
			# TODO: Swap this to a different item?
			GameState.player.remove_component(C_HasActiveItem)

		Loggie.debug('Removing Item', c_item_weapon)
	else:
		Loggie.debug('Item does not have a C_Item component')

## Cycles to the next item in the player's inventory.
static func cycle_inventory_item():
	consolidate_inventory()
	var items =  Queries.in_inventory_of_entity(GameState.player).combine(Queries.is_item()).combine(Queries.shows_in_quickbar()).execute()
	# Find the active item and set the next item as the active item
	for item in items:
		if item.has_component(C_IsActiveItem):
			var next_index = (items.find(item) + 1) % items.size()
			GameState.active_item = items[next_index]
			return
		else:
			GameState.active_item = items[0]


## Cycles to the next weapon in the player's inventory.
static func cycle_inventory_weapon():
	consolidate_inventory()
	var weapons =  Queries.in_inventory_of_entity(GameState.player).combine(Queries.is_weapon()).combine(Queries.shows_in_quickbar()).execute()
	# Find the active weapon and set the next weapon as the active weapon
	for weapon in weapons:
		if weapon.has_component(C_IsActiveWeapon):
			var next_index = (weapons.find(weapon) + 1) % weapons.size()
			GameState.active_weapon = weapons[next_index]
			return
		else:
			GameState.active_weapon = weapons[0]

## Consolidates the player's inventory.
## This will consolidate all items that have the same item component.
## This is useful for when the player picks up multiple items of the same type.
static func consolidate_inventory():
	var inventory_entities = Queries.in_inventory_of_entity(GameState.player).execute()
	var item_quantities = {}
	var entities_to_remove = []

	# Sum quantities for each unique c_item
	for entity in inventory_entities:
		var c_item = get_item_or_weapon(entity)
		if c_item:
			var quantity = get_item_quantity(entity)
			if c_item in item_quantities:
				# Add quantity to existing entry
				item_quantities[c_item]["quantity"] += quantity
				entities_to_remove.append(entity)  # Mark duplicate entity for removal
			else:
				# Create new entry for unique item
				item_quantities[c_item] = {"entity": entity, "quantity": quantity}

	# Remove duplicate entities
	for entity in entities_to_remove:
		ECS.world.remove_entity(entity)

	# Update quantities of remaining entities
	for item_data in item_quantities.values():
		var entity = item_data["entity"]
		var qty = item_data["quantity"]
		entity.add_component(C_Quantity.new(qty))


