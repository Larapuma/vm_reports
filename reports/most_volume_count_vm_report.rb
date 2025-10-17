class MostVolumeCountVMReport < BaseVMReport
    
  def initialize(vm_info_loader, limit = 5, hdd_type = nil)
    super(vm_info_loader, limit)
    @hdd_type = hdd_type
  end
  
  def generate
    vm_data
      .map do |vm|  # перебираем КАЖДУЮ VM
        # Для каждой VM считаем количество дополнительных дисков
        other_count = if @hdd_type
          vm[:other_hdd].count { |hdd| hdd[:type] == @hdd_type }
        else
          vm[:other_hdd].size
        end
        
        # Добавляем поле с количеством к данным VM
        vm.merge(other_volumes_count: other_count)
      end
      .sort_by { |vm| -vm[:other_volumes_count] }  # сортируем по убыванию количества
      .take(@limit)  # берем первые n
  end
  def get_report_name
    @hdd_type ? "#{@limit} ВМ с наибольшим количеством дополнительных дисков типа #{@hdd_type}": "#{@limit} ВМ с наибольшим количеством дополнительных дисков"
  end
end
