extends GutTest

class MockSystem extends System:
	var processed_entities = []
	func _init():
		required_components = [Velocity]
	func process(entity, delta):
		processed_entities.append(entity)

func test_system_processes_entities_with_required_components():
	var system = MockSystem.new()
	var entity_with_component = Entity.new()
	var Velocity = preload("res://game/components/velocity.gd")
	var velocity_component = Velocity.new()
	entity_with_component.add_component(velocity_component)
	var entity_without_component = Entity.new()
	var entities = [entity_with_component, entity_without_component]
	system.process_entities(entities, 0.1)
	assert_eq(system.processed_entities.size(), 2, "System should process entities fed into it.")
	assert_eq(system.processed_entities, entities, "System should process the correct entity.")