
class TalkingNPC < Monster
  def is_blocking?
    true
  end

  def initialize(player, universe, text, filename, posn, inv=nil, attrib=nil, ai=nil)
    super(player, universe,filename, posn, inv, attrib, ai)
    @text = text
  end

  def interact(game, universe, player)
    puts "display dialog '#{@text}' from #{self}"
    universe.dialog_layer.active = true
    universe.dialog_layer.text = @text
  end

  include JsonHelper
  def json_params
    [ @text, @filename, @animated_sprite_helper.px, @animated_sprite_helper.py, @npc_x, @npc_y, @inventory, @character_attribution, @ai]
  end
end


