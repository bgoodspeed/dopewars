
class AlwaysDownMonsterKeyHolder < KeyHolder
  
  def initialize(key=GameSettings::DOWNKEY)
    super()
    add_key(key)
  end

  def first
    @keys.first
  end

  def switch(oldkey, newkey)
    delete_key(oldkey)
    add_key(newkey)
  end
end
