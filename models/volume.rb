class Volume
  attr_accessor :vm_id, :hdd_type, :hdd_capacity

  def initialize(vm_id, hdd_type, hdd_capacity)
    @vm_id = vm_id
    @hdd_type = hdd_type
    @hdd_capacity = hdd_capacity
  end
end
