class MostVolumeVMReport < BaseVMReport
  def initialize(vm_info_loader, limit = 5, type)
    super(vm_info_loader, limit)
    @type = type
  end

  def generate
    if ['cpu','ram'].include?(@type)
      # Для CPU и RAM - просто сортируем по убыванию значения
      vm_data.sort_by { |vm| -vm[@type.to_sym].to_i }.take(@limit)
    else
      # Для типов дисков - считаем общий объем (основной + дополнительные)
      vm_data
        .select { |vm| vm[:hdd_type] == @type }  # только VM с основным диском этого типа
        .map do |vm|
          total_capacity = vm[:hdd_capacity].to_i + other_hdd_capacity(vm, @type)
          vm.merge(total_capacity: total_capacity)
        end
        .sort_by { |vm| -vm[:total_capacity] }
        .take(@limit)
    end
  end

  def get_report_name
    "#{@limit} Самых объемных ВМ по параметру #{@type}"
  end

  private
  def other_hdd_capacity(vm, hdd_type)
    vm[:other_hdd].select { |hdd| hdd[:type] == hdd_type }
                  .sum { |hdd| hdd[:hdd_capacity].to_i }
  end
end
