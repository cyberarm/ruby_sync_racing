class AssetManager
  IMAGES = {
    0 => "assets/cars/CAR.png",  # Car specs 0..99
    1 => "assets/cars/CAR_body.png",

    2 => "assets/cars/sport.png",
    3 => "assets/cars/sport_body.png",

    100 => "assets/tracks/general/road/asphalt.png", # Tile images 100.999
    101 => "assets/tracks/general/road/asphalt_left.png",
    102 => "assets/tracks/general/road/asphalt_left_bottom.png",

    115 => "assets/tracks/general/road/clay.png",
    116 => "assets/tracks/general/road/sandstone.png",
    117 => "assets/tracks/general/road/grass.png",
    118 => "assets/tracks/general/road/water.png",

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