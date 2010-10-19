
class KeyHolder
  def initialize
    @keys = []
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
end