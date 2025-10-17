class LargestOtherCapacityVMReport < BaseVMReport
  VALID_HDD = ['sas', 'ssd', 'sata'].freeze

  def initialize(vm_info_loader, limit = 5, hdd_type = nil)
    super(vm_info_loader, limit)
    validate_type! hdd_type
    @hdd_type = hdd_type
  end

  def get_report_name
    @hdd_type ? "#{@limit} ВМ с наибольшим объемом дополнительных дисков типа #{@hdd_type}": "#{@limit} ВМ с наибольшим объемом дополнительных дисков типа"
  end

  def generate
    vm_data
      .map do |vm|  # перебираем КАЖДУЮ VM
        # Для каждой VM считаем количество дополнительных дисков
        other_sum = if @hdd_type
          vm[:other_hdd].select { |hdd| hdd[:type] == @hdd_type }.sum { |hdd| hdd[:hdd_capacity].to_i }
        else
          vm[:other_hdd].sum{|hdd| hdd[:hdd_capacity].to_i}
        end
        
        # Добавляем поле с количеством к данным VM
        vm.merge(other_volumes_sum: other_sum)
      end
      .sort_by { |vm| -vm[:other_volumes_sum] }  # сортируем по убыванию количества
      .take(@limit)  # берем первые n
  end

  private
  def validate_type! type
    return if type.nil?
    unless VALID_HDD.include?(type)
      raise ArgumentError, "Неверно указан параметр: #{type}. Доступные параметры: #{VALID_HDD.join(', ')}"
    end
  end

end
