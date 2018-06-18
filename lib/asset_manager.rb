class AssetManager
  IMAGES = {
    0 => "assets/cars/CAR.png",  # Car specs 0..99
    1 => "assets/cars/CAR_body.png",

    2 => "assets/cars/sport.png",
    3 => "assets/cars/sport_body.png",

    100 => "", # Tile images 100.999

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

  def self.sound_from_id(id)
    if found = SOUNDS[id]
      return found
    else
      false
    end
  end
end