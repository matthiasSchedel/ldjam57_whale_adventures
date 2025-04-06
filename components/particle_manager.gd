extends Node2D

class_name ParticleManager

# Particle configurations as constants
const EATING_PARTICLES = {
	"amount": 8,
	"lifetime": 0.5,
	"explosiveness": 0.8,
	"direction": Vector2.UP,
	"velocity_min": 50,
	"velocity_max": 100,
	"scale_min": 2,
	"scale_max": 4,
	"color": Color(1, 1, 0.5, 0.8)
}

const GROWTH_PARTICLES = {
	"amount": 16,
	"lifetime": 1.0,
	"explosiveness": 1.0,
	"direction": Vector2.UP,
	"velocity_min": 100,
	"velocity_max": 200,
	"scale_min": 4,
	"scale_max": 8,
	"color": Color(1, 0.8, 0.2, 0.8),
	"emission_shape": CPUParticles2D.EMISSION_SHAPE_SPHERE,
	"emission_radius": 50
}

func spawn_particles(config: Dictionary, spawn_position: Vector2) -> void:
	var particles = CPUParticles2D.new()
	particles.position = spawn_position
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = config.get("explosiveness", 1.0)
	particles.amount = config.get("amount", 8)
	particles.lifetime = config.get("lifetime", 0.5)
	particles.direction = config.get("direction", Vector2.UP)
	particles.gravity = Vector2.ZERO
	particles.initial_velocity_min = config.get("velocity_min", 50)
	particles.initial_velocity_max = config.get("velocity_max", 100)
	particles.scale_amount_min = config.get("scale_min", 2)
	particles.scale_amount_max = config.get("scale_max", 4)
	particles.color = config.get("color", Color.WHITE)
	
	if config.has("emission_shape"):
		particles.emission_shape = config.get("emission_shape")
		particles.emission_sphere_radius = config.get("emission_radius", 10)
	
	add_child(particles)
	
	# Remove particles after they're done
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	particles.queue_free()

func spawn_eat_particles(spawn_position: Vector2) -> void:
	spawn_particles(EATING_PARTICLES, spawn_position)

func spawn_grow_particles(spawn_position: Vector2) -> void:
	spawn_particles(GROWTH_PARTICLES, spawn_position)