class Decoration < GameObject
  attr_accessor :type
  def setup
    @type = options[:type] || "solid"
  end
end