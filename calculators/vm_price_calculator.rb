class VMPriceCalculator
  def initialize(vms_path, volume_path, price_path)
    @vms = VMLoader.new(vms_path)
    @volumes = VolumeLoader.new(volume_path)
    @prices = PriceLoader.new(price_path)
    @other_hdd_price_calc = OtherHDDPriceCalculator.new(@volumes, @prices)
  end

  def calculate_vm_cost(vm_id)
    vm = @vms.find_by_id(vm_id)
    return "ВМ не найдена" unless vm 
    
    cpu_price_obj = @prices.find_by_type("cpu")
    ram_price_obj = @prices.find_by_type("ram")
    hdd_price_obj = @prices.find_by_type(vm.hdd_type)

    total = convert_to_rub((cpu_price_obj.price.to_f * vm.cpu.to_i) + 
            (ram_price_obj.price.to_f * vm.ram.to_i) +
            (hdd_price_obj.price.to_f * vm.hdd_capacity.to_i) +
            @other_hdd_price_calc.calculate_other_HDD_cost(vm_id))
    total
  end
  private 
  def convert_to_rub(total)
    total/100
  end
end
