# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'rubygame'
class MissingResourceError < Exception

end
module FontLoader
  @@DEPTH = 24
  include Rubygame
 
  def font_path
    File.join(File.dirname(__FILE__), '..', 'resources', 'fonts')
  end
  def load_font(name)
    filename = File.join(font_path, name)
    raise MissingResourceError unless File.exists?(filename)

    TTF.setup
    TTF.new filename, @@DEPTH
  end
end
