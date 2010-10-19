
class ISBPEntry
  attr_reader :offsets, :actionable
  def initialize(offsets, actionable)
    @offsets = offsets

    @actionable = actionable
  end

end
