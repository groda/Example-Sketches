# Ported from http://processing.org/learning/topics/multipleparticlesystems.html

# Click the mouse to generate a burst of particles at mouse location.

# Each burst is one instance of a particle system with Particles and
# CrazyParticles (a subclass of Particle).
require 'forwardable'
load_library :vecmath

module Runnable
  def run
    reject! { |item| item.dead? }
    each    { |item| item.run   }
  end
end

class ParticleSystem
  include Enumerable, Runnable
  extend Forwardable
  def_delegators(:@particles, :reject!, :<<, :each, :empty?)
  def_delegator(:@particles, :empty?, :dead?)

  def initialize(number, origin)
    @particles = []
    @origin = origin
    kind = rand < 0.5 ? Sketch::Particle : Sketch::CrazyParticle
    number.times { self << kind.new(origin) }
  end
end

attr_reader :particle_systems

def setup
  size 640, 580
  color_mode(RGB, 255, 255, 255, 100)
  ellipse_mode(CENTER)
  @particle_systems = ParticleSystem.new(rand(5..26), Vec2D.new(width / 2, height / 2))
end

def draw
  background 0
  particle_systems.run
end

def mouse_pressed
  origin = rand(5..26)
  vector = Vec2D.new(mouse_x, mouse_y)
  particle_systems << ParticleSystem.new(origin, vector)
end


class Particle
  attr_reader :acceleration, :velocity

  def initialize(origin)
    @origin = origin
    @velocity = Vec2D.new(rand(-1.0..1), rand(-2.0..0))
    @acceleration = Vec2D.new(0, 0.05)
    @radius = 10
    @lifespan = 100
  end

  def run
    update
    grow
    render
    render_velocity_vector
  end

  def update
    @velocity += acceleration
    @origin += velocity
  end

  def grow
    @lifespan -= 1
  end

  def dead?
    @lifespan <= 0
  end

  def render
    stroke(255, @lifespan)
    fill(100, @lifespan)
    ellipse(@origin.x, @origin.y, @radius, @radius)
  end

  def render_velocity_vector
    scale = 10
    arrow_size = 4
    push_matrix
    translate(@origin.x, @origin.y)
    rotate(velocity.heading)
    length = velocity.mag * scale
    line 0, 0, length, 0
    line length, 0, length - arrow_size, arrow_size / 2
    line length, 0, length - arrow_size, -arrow_size / 2
    pop_matrix
  end
end

class CrazyParticle < Particle
  def initialize(origin)
    super
    @theta = 0
  end

  def run
    update
    grow
    render
    render_rotation_line
  end

  def update
    super
    @theta += velocity.x * velocity.mag / 10
  end

  def grow
    @lifespan -= 0.8
  end

  def render_rotation_line
    push_matrix
    translate(@origin.x, @origin.y)
    rotate(@theta)
    stroke(255, @lifespan)
    line(0, 0, 25, 0)
    pop_matrix
  end
end
