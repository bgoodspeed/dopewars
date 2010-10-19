
class InteractionPolicy
  def self.immediate_return
    InteractionPolicy.new(true,true,true,true)
  end
  def self.process_all
    InteractionPolicy.new(false, false, false, false)
  end

  attr_reader :dialog, :current, :facing, :npcs
  alias_method :return_after_dialog,:dialog
  alias_method :return_after_current, :current
  alias_method :return_after_facing, :facing
  alias_method :return_after_npcs, :npcs
  def initialize(dialog, current, facing, npcs)
    @dialog, @current, @facing, @npcs = dialog, current, facing, npcs
  end

end

