
class KeyHolder
  def initialize
    @keys = []
    @ttl_map = {}
    @ttl_calls = 0 #TODO delete this, just a curiousity
  end

  extend Forwardable
  def_delegators :@keys, :include?, :empty?, :size

  def delete_key(key)
    @keys -= [key]
  end
  def add_key(key)
    @keys += [key]
  end

  def clear_keys
    @keys.clear
  end

  def set_timed_keypress(key, ttl)
    @ttl_map[key] = ttl
    add_key(key)
  end

  def update_timed_keys(dt)
    @ttl_map.each {|k,v|
      newv = v - 1
      if newv == 0
        delete_key(k)
        @ttl_map.delete(k)
      else
        @ttl_map[k] = newv
      end
    }
  end

end