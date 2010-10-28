class MenuSection

  attr_reader :text, :content

  def has_subsections?
    true
  end

  def size
    @content.size
  end
  def initialize(text, content)
    @text = text
    @content = content
  end


  def content_at(i)
    @content.section_by_index(i)
  end
  def text_contents
    @content.collect {|ma| ma.text}
  end

  def draw(menu_layer_config, game, text_rendering_helper, layer, screen)
    @content.draw(menu_layer_config, game, text_rendering_helper, layer, screen)
  end

  alias_method :name, :text
  alias_method :section_by_index, :content_at


end