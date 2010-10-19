
class CISBPEntry < ISBPEntry
  attr_reader :filename
  def initialize(conf, actionable)
    super(conf.slice(1,2), actionable)
    @filename = conf[0]
  end

end
