require_relative 'volume_loader'
require_relative 'price_loader'
require_relative 'vm_loader'

class VMInfoLoader
  def initialize(vms_path, volume_path, price_path)
    @vm_loader = VMLoader.new(vms_path)
    @calculator = VMPriceCalculator.new(vms_path, volume_path, price_path)
    @volumes = VolumeLoader.new(volume_path)
  end

  def generate_vm_info_list
    @vm_loader.data.map do |vm|
      vm_volumes = @volumes.find_by_vm_id(vm.id)
      {
        
        vm_id: vm.id,
        cpu: vm.cpu,
        ram: vm.ram,
        hdd_capacity: vm.hdd_capacity,
        hdd_type: vm.hdd_type,
        other_hdd: format_other_hhd(vm_volumes),
        total_price: @calculator.calculate_vm_cost(vm.id)
      }
    end
  end

  private 
  def format_other_hhd(volumes)
    volumes.map do |v|{
      type: v.hdd_type,
      hdd_capacity: v.hdd_capacity
    }
  end
end
end
