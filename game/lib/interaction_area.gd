class_name InteractionArea
extends Area3D

## The parent entity of the interaction area
@export var parent: Entity
## The static queries that the interaction area will use to check if an entity can interact with it
@export var can_interact_query: Array[StaticQuery]

func get_can_interact_query() -> QueryBuilder:
    var query: QueryBuilder = ECS.world.query
    # Combine all static queries
    for static_query in can_interact_query:
        query.combine(static_query.query())
    return query

func _ready():
    # Connect the area_entered signal to the parent entity
    body_shape_entered.connect(_on_area_entered)
    body_shape_exited.connect(_on_area_exited)
    

func _on_area_entered(_body_id: RID, body, _body_shape: int, _area_shape: int) -> void:
    if body is Entity:
        if not parent.has_component(C_Interactable):
            return
        # Check if the body matches the query
        if not get_can_interact_query().matches([body]).is_empty():
            body.add_relationship(Relationship.new(C_CanInteractWith.new(), parent))

func _on_area_exited(_body_id: RID, body, _body_shape: int, _area_shape: int) -> void:
    if parent and body and body is Entity:
        # Check if the body matches the query
        if not  get_can_interact_query().matches([body]).is_empty():
            body.remove_relationship(Relationship.new(C_CanInteractWith.new(), parent))