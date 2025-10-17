class BaseVMReport
  VALID_TYPES = ['cpu', 'ram', 'sas', 'ssd', 'sata'].freeze


  def initialize(vm_info_loader, limit = 5)
    @vm_info_loader = vm_info_loader
    @limit = limit
  end
  
  def generate
     
  end
  
  def get_report_name
    "Базовый"
  end
  

  private
  def vm_data
    @vm_data = @vm_info_loader.generate_vm_info_list
  end
end
