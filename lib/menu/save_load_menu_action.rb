
class SaveLoadMenuAction < MenuAction

  def has_subsections?
    false
  end

  def save_slot(idx)
    "save-slot-#{idx}.json"
  end
end
