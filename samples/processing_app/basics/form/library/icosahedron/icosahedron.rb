# Example of replacing Processing::Proxy with extend Forwardable
# And using Vec3D :to_vertex function
class Icosahedron
  extend Forwardable   # replacing Processing::Proxy mixin
  def_delegators(:@app, :vertex, :begin_shape, :end_shape)
  attr_reader :r, :app, :renderer

  def initialize(app, radius)
    @r = radius
    @app = app
    @renderer = AppRender.new(app)
  end

  ##
  # Draw an icosahedron defined by a radius r.
  #
  def draw
    # Calculate vertex data for an icosahedron inscribed by a sphere radius 'r'.
    # Use 4 Golden Ratio rectangles as the basis.
    phi = (1.0 + Math.sqrt(5.0)) / 2.0
    h = r / Math.sqrt(1.0 + phi * phi)
    v =
    [
      Vec3D.new(0, -h, h * phi), Vec3D.new(0, -h, -h * phi),
      Vec3D.new(0, h, -h * phi), Vec3D.new(0, h, h * phi),
      Vec3D.new(h, -h * phi, 0), Vec3D.new(h, h * phi, 0),
      Vec3D.new(-h, h * phi, 0), Vec3D.new(-h, -h * phi, 0),
      Vec3D.new(-h * phi, 0, h), Vec3D.new(-h * phi, 0, -h),
      Vec3D.new(h * phi, 0, -h), Vec3D.new(h * phi, 0, h)
    ]

    begin_shape(Java::ProcessingCore::PConstants::TRIANGLES)
    draw_triangle(v[0], v[7], v[4])
    draw_triangle(v[0], v[4], v[11])
    draw_triangle(v[0], v[11], v[3])
    draw_triangle(v[0], v[3], v[8])
    draw_triangle(v[0], v[8], v[7])
    draw_triangle(v[1], v[4], v[7])
    draw_triangle(v[1], v[10], v[4])
    draw_triangle(v[10], v[11], v[4])
    draw_triangle(v[11], v[5], v[10])
    draw_triangle(v[5], v[3], v[11])
    draw_triangle(v[3], v[6], v[5])
    draw_triangle(v[6], v[8], v[3])
    draw_triangle(v[8], v[9], v[6])
    draw_triangle(v[9], v[7], v[8])
    draw_triangle(v[7], v[1], v[9])
    draw_triangle(v[2], v[1], v[9])
    draw_triangle(v[2], v[10], v[1])
    draw_triangle(v[2], v[5], v[10])
    draw_triangle(v[2], v[6], v[5])
    draw_triangle(v[2], v[9], v[6])
    end_shape
  end

  def draw_triangle(p1, p2, p3)
    p1.to_vertex(renderer)
    p2.to_vertex(renderer)
    p3.to_vertex(renderer)
  end
end
