
class RepeatingPathFollower

  def initialize(path, ticks_per_char)
    @path = path
    @ticks_per_path_unit = ticks_per_char
    @ticks_seen = 0
    @path_idx = 0

  end

  def update(keys)
    @ticks_seen += 1
    if @ticks_seen >= @ticks_per_path_unit
      @ticks_seen = 0
      new_idx = (@path_idx + 1) % @path.length
      keys.switch(keysym_at(@path_idx),keysym_at(new_idx))
      @path_idx = new_idx
    end
  end




  def keysym_at(idx)
    char_syms[@path.slice(idx,1)]
  end

  def char_syms
    m = {}
    m["L"] = :left
    m["U"] = :up
    m["R"] = :right
    m["D"] = :down
    m
  end

  include JsonHelper
  def json_params
    [@path, @ticks_per_path_unit]
  end



end
