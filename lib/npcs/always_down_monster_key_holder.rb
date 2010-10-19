
class AlwaysDownMonsterKeyHolder < KeyHolder
  @@DOWNKEY = :always_down
  def initialize(key=@@DOWNKEY)
    super()
    add_key(key)
  end

  def switch(oldkey, newkey)
    delete_key(oldkey)
    add_key(newkey)
  end
end
