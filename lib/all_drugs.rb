# To change this template, choose Tools | Templates
# and open the template in the editor.
require 'drug'

class AllDrugs

  @@DRUG_DB = {
      :acid => Drug.new("Acid", 800),
      :weed => Drug.new("Weed", 250),
      :hash => Drug.new("Hash", 330),
      :pcp => Drug.new("PCP", 500),
      :heroin => Drug.new("Heroin", 1600),
      :cocaine => Drug.new("Cocaine", 2000),
      :crack => Drug.new("Crack", 1100),
      :opium => Drug.new("Opium", 1400),
      :vicodin => Drug.new("Vicodin", 700),
      :human_adrenal_gland => RareDrug.new("Human Adrenal Gland", 3500),
      :adderall => Drug.new("Adderall", 200),
      :crystal_meth => Drug.new("Crystal Meth", 1500),
      :bathtub_brandy => RareDrug.new("Bathtub Brandy", 100),
      :peyote => Drug.new("Peyote", 600),
      :ecstacy => Drug.new("Ecstacy", 900)
    
  }

  def self.drugs
    @@DRUG_DB.values
  end

  def self.rare_drugs
    self.drugs.select {|drug| drug.rare?}
  end
  def self.common_drugs
    self.drugs.select {|drug| !drug.rare?}
  end
  def self.for_name(name)
    @@DRUG_DB[name]
  end

  def self.with(required_drug_names, target_size)

    drug_list = required_drug_names.collect { |name| self.for_name(name) }
    remaining_drugs = self.drugs - drug_list
    need_to_take = target_size - drug_list.size

    return drug_list if drug_list.size >= target_size
    raise "Not enough drugs to meet request" if need_to_take > remaining_drugs.size
    
    drug_list + remaining_drugs.slice(0, need_to_take)
  end
end
