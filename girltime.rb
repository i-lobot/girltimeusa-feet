require 'rubygems'
require 'open-uri'
require 'image_suckr'

class GirlTime

  def initialize
    @suckr = ImageSuckr::GoogleSuckr.new
  end

  def generate
    
    word = %w(
      sexy
      beautiful
      woman
      female
      her
      fetish
      hot
      tiny
    ).sample

    @suckr.get_image_file({"q" => "#{word} feet", "start" => rand(0..2).to_s})
  end
end
