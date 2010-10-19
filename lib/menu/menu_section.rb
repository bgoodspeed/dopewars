class MenuSection

  attr_reader :text, :content
  def initialize(text, content)
    @text = text
    @content = content
  end
  def content_at(i)
    @content[i]
  end
  def text_contents
    @content.collect {|ma| ma.text}
  end
end