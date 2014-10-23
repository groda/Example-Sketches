# bezier bez_patch By Marius Watz:
# http://www.openprocessing.org/sketch/57709
# Normal calculation added by Andres Colubri
# Direct port of sample code by Paul Bourke.
# Original code: http://paulbourke.net/geometry/bezier/
#
# hit "spacebar" to generate a new shape and save current
# translated for ruby-processing by Martin Prout January 2013
#

load_library :vecmath

NI=4
NJ=5
RESI=NI*10
RESJ=NJ*10

attr_accessor :outp, :inp, :normp, :auto_normals, :arcball, :bez_patch

def setup
  size(1024, 768, P3D)
  ArcBall.init(self, width/2.0, height/2.0)
  @auto_normals = false
  build_geometry
  @bez_patch = build_shape
end

def draw
  background(255)
  smooth(8)
  lights
  define_lights
  scale(0.9)
  no_stroke
  shape(bez_patch)
end

#######
# use bez patch geometry to
# create a vbo object (PShape)
#######

def build_shape
  no_stroke
  bez = create_shape
  bez.begin_shape(QUAD_STRIP)
  bez.fill(192, 192, 192)
  bez.ambient(20, 20, 20)
  bez.specular(30)
  (0 ... RESI - 1).each do |i|
    (0 ... RESJ).each do |j|
      if (!auto_normals)
        bez.normal(*normp[i][j])
      end
      bez.vertex(*outp[i][j])
      bez.vertex(*outp[i+1][j])
    end
  end
  bez.end_shape
  return bez
end

##########
# build geometry
# for bez patch
##########

def build_geometry
  @outp = []
  @normp = []
  @inp = Array.new(NI){|i| Array.new(NJ){|j| Vec3D.new(i, j, rand(-3.0..3))}}
  uitang = Vec3D.new
  ujtang = Vec3D.new

  (0 ... RESI).each do |i|
    mui = i.fdiv(RESI - 1)
    row = []
    row_n = []
    (0 ... RESJ).each do |j|
      muj = j.fdiv(RESJ - 1)
      vect = Vec3D.new
      uitang.x, uitang.y, uitang.z = 0, 0, 0
      ujtang.x, ujtang.y, ujtang.z = 0, 0, 0
      (0 ... NI).each do |ki|
        bi = bezier_blend(ki, mui, NI)
        dbi = d_bezier_blend(ki, mui, NI)
        (0 ... NJ).each do |kj|
          bj = bezier_blend(kj, muj, NJ)
          dbj = d_bezier_blend(kj, muj, NJ)

          vect += inp[ki][kj] * bi * bj

          uitang += inp[ki][kj] * dbi * bj

          ujtang += inp[ki][kj] * bi * dbj
        end
      end
      vect += Vec3D.new(-NI / 2, -NJ / 2, 0)
      vect *= 100
      row << vect.to_a
      uitang.normalize!
      ujtang.normalize!
      row_n << uitang.cross(ujtang).to_a
    end
    @outp << row
    @normp << row_n
  end
end

def bezier_blend( k, mu,  n)
  blend = 1.0
  nn = n
  kn = k
  nkn = n - k

  while (nn >= 1)
    blend *= nn
    nn -= 1
    if (kn > 1)
      blend = blend.fdiv(kn)
      kn -= 1
    end
    if (nkn > 1)
      blend = blend.fdiv(nkn)
      nkn -= 1
    end
  end
  blend *= mu**k.to_f if (k > 0)
  blend *= (1 - mu)**(n - k).to_f if (n - k > 0)
  return(blend)
end

def d_bezier_blend( k, mu,  n)
  dblendf = 1.0

  nn = n
  kn = k
  nkn = n - k

  while (nn >= 1)
    dblendf *= nn
    nn -= 1
    if (kn > 1)
      dblendf  = dblendf.fdiv(kn)
      kn -= 1
    end
    if (nkn > 1)
      dblendf  = dblendf.fdiv(nkn)
      nkn -= 1
    end
  end

  fk = 1
  dk = 0
  fnk = 1
  dnk = 0
  if (k > 0)
    fk = mu**k.to_f
    dk = k * (mu**(k - 1).to_f)
  end
  if (n - k > 0)
    fnk = (1 - mu)**(n - k).to_f
    dnk = (k - n) * (1 - mu)**(n - k - 1).to_f
  end
  dblendf *= (dk * fnk + fk * dnk)

  return(dblendf)
end

def define_lights
  ambient_light(40, 40, 40)
  point_light(30, 30, 30, 0, 0, 0)
  directional_light(60, 60, 60, 1, 0, 0)
  spot_light(30, 30, 30, 0, 40, 200, 0, -0.5, 0.5, PI / 2, 2)
end


