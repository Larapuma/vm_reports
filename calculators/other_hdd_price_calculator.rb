class OtherHDDPriceCalculator
  def initialize(volume_loader, price_loader)
    @volume_loader = volume_loader
    @price_loader = price_loader
  end
  
  def calculate_other_HDD_cost(vm_id)
    total = 0
    volumes = @volume_loader.find_by_vm_id(vm_id)
    volumes.each do |v|
      price_obj = @price_loader.find_by_type(v.hdd_type)
      total += v.hdd_capacity.to_i * price_obj.price.to_f
    end
    total
  end 
end
