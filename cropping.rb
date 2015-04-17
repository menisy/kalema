require 'tesseract'
require 'RMagick'

include Magick

image_path = "#{Rails.root}/public/text.png"

e = Tesseract::Engine.new {|e|
  e.language  = :eng
  e.blacklist = '|'
}

boxes = []
e.each_word_for(image_path) do |word|
 boxes << word.bounding_box
end

image = Image.read(image_path).first

boxes.each_with_index do |box, i|
  b = image.crop(box.x, box.y, box.width, box.height);
  b.write("#{Rails.root}/public/word#{i}.png")
end