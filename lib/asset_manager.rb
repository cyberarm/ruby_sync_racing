class AssetManager
  IMAGES = {
    0 => "assets/cars/CAR.png",  # Car specs 0..99
    1 => "assets/cars/CAR_body.png",

    2 => "assets/cars/sport.png",
    3 => "assets/cars/sport_body.png",

    100 => "assets/tracks/general/road/asphalt.png", # Tile images 100.999
    101 => "assets/tracks/general/road/asphalt_left.png",
    102 => "assets/tracks/general/road/asphalt_left_bottom.png",
    103 => "assets/tracks/general/road/asphalt_left_bottom_corner.png",
    104 => "assets/tracks/general/road/asphalt_bottom_45.png",
    105 => "assets/tracks/general/road/asphalt_bottom_45_corner.png",
    106 => "assets/tracks/general/road/asphalt_bottom_45_grass.png",
    107 => "assets/tracks/general/road/asphalt_bottom_45_sand.png",
    108 => "assets/tracks/general/road/asphalt_bottom_45_sandstone.png",
    109 => "assets/tracks/general/road/asphalt_bottom_45_water.png",
    110 => "assets/tracks/general/road/asphalt_bottom_45_clay.png",

    115 => "assets/tracks/general/road/clay.png",
    120 => "assets/tracks/general/road/clay_water.png",
    121 => "assets/tracks/general/road/clay_sand.png",
    122 => "assets/tracks/general/road/clay_sandstone.png",
    123 => "assets/tracks/general/road/clay_grass.png",
    124 => "assets/tracks/general/road/clay_transparent.png",

    116 => "assets/tracks/general/road/sandstone.png",
    125 => "assets/tracks/general/road/sandstone_water.png",
    126 => "assets/tracks/general/road/sandstone_sand.png",
    127 => "assets/tracks/general/road/sandstone_clay.png",
    128 => "assets/tracks/general/road/sandstone_grass.png",
    129 => "assets/tracks/general/road/sandstone_transparent.png",

    117 => "assets/tracks/general/road/grass.png",
    130 => "assets/tracks/general/road/grass_water.png",
    131 => "assets/tracks/general/road/grass_sand.png",
    132 => "assets/tracks/general/road/grass_clay.png",
    133 => "assets/tracks/general/road/grass_sandstone.png",
    134 => "assets/tracks/general/road/grass_transparent.png",

    118 => "assets/tracks/general/road/water.png",
    140 => "assets/tracks/general/road/water_transparent.png",

    119 => "assets/tracks/general/road/sand.png",
    135 => "assets/tracks/general/road/sand_water.png",
    136 => "assets/tracks/general/road/sand_grass.png",
    137 => "assets/tracks/general/road/sand_clay.png",
    138 => "assets/tracks/general/road/sand_sandstone.png",
    139 => "assets/tracks/general/road/sand_transparent.png",

    141 => "assets/tracks/general/road/finish_line.png",

    1000 => "" # Decoration images 1000..infinity
  }

  SOUNDS = {
    0 => "", # MUSIC 0..99
    100 => "assets/sound/brakes.ogg" # SOUND EFFECTS
  }

  def self.image_from_id(id)
    if found = IMAGES[id]
      return found
    else
      p id
      false
    end
  end

  def self.id_from_image(image_path)
    found = false
    IMAGES.each do |key, value|
      if (image_path == value)
        found = key
        break
      end
    end
    if found
      return found
    else
      false
    end
  end

  def self.sound_from_id(id)
    if found = SOUNDS[id]
      return found
    else
      false
    end
  end
end