# The Nature of Code
# <http:#www.shiffman.net/teaching/nature>
# Spring 2011
# Updated to use the updated library
# translated to ruby-processing 2 March 2014 by Martin Prout
# Box2DProcessing example

load_libraries :box2d_processing, :particle_system


# module PS is a wrapper for java packages, and Boundary and Particle classes
include PS     

attr_reader :box2d, :boundaries, :systems

def setup
  size(400,300)
  smooth  
  # Initialize box2d physics and create the world
  @box2d = PS::Box2DProcessing.new(self)
  box2d.create_world  
  # We are setting a custom gravity
  box2d.set_gravity(0, -20)  
  # Create Arrays	
  @systems = []
  @boundaries = []  
  # Add a bunch of fixed boundaries
  boundaries << Boundary.new(box2d, 50, 100, 300, 5, -0.3)
  boundaries << Boundary.new(box2d, 250, 175, 300, 5, 0.5)  
end

def draw
  background(255)  
  # We must always step through time!
  box2d.step  
  # Run all the particle systems
  if systems.size > 0
    systems.each do |system|
      system.run 
      system.add_particles(box2d, rand(0..2)) 
    end
  end  
  # Display all the boundaries
  boundaries.each do |wall|
    wall.display
  end
end


def mouse_pressed
  # Add a new Particle System whenever the mouse is clicked
  systems << ParticleSystem.new(box2d, 0, mouse_x, mouse_y)
end





