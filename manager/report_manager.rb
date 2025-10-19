class ReportManager
  def initialize(vm_info_loader)
    @vm_info_loader = vm_info_loader

    @reports_registry = {
      'most_expensive' => ->(limit) { MostExpensiveVMReport.new(@vm_info_loader, limit) },
      'cheapest' => ->(limit) { CheapestVMReport.new(@vm_info_loader, limit) },
      'most_volume_cpu' => ->(limit) { MostVolumeVMReport.new(@vm_info_loader, limit, 'cpu') },
      'most_volume_ram' => ->(limit) { MostVolumeVMReport.new(@vm_info_loader, limit, 'ram') },
      'most_volume_sas' => ->(limit) { MostVolumeVMReport.new(@vm_info_loader, limit, 'sas') },
      'most_volume_ssd' => ->(limit) { MostVolumeVMReport.new(@vm_info_loader, limit, 'ssd') },
      'most_volume_count' => ->(limit) { MostVolumeCountVMReport.new(@vm_info_loader, limit) },
      'most_volume_count_sas' => ->(limit) { MostVolumeCountVMReport.new(@vm_info_loader, limit, 'sas') },
      'most_volume_count_ssd' => ->(limit) { MostVolumeCountVMReport.new(@vm_info_loader, limit, 'ssd') },
      'most_volume_count_sata' => ->(limit) { MostVolumeCountVMReport.new(@vm_info_loader, limit, 'sata') },
      'largest_other_capacity' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit) },
      'largest_other_capacity_sas' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit, 'sas') },
      'largest_other_capacity_ssd' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit, 'ssd') },
      'largest_other_capacity_sata' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit, 'sata') }

    }
  end

  def show_report(report_name, limit)
    if report_name.nil?
      raise ArgumentError, "Вы не указали тип отчёта. Доступные отчёты: #{available_reports.join(', ')}"
    elsif report_name == "all"
      show_all_reports(limit)
    elsif available_reports.include?(report_name)
      ReportPresenter.print(@reports_registry[report_name].call(limit))
    else
      raise ArgumentError, "Неверно указан вид отчёта: #{report_name}. Доступные отчёты: #{available_reports.join(', ')}"
    end

    if limit.nil?
      limit = 5
    elsif !is_digit?(limit)
      raise ArgumentError, "Неверно указано значение числа отчётов. Число отчётов должно быть целым положительным числом."
    else
      limit = limit.to_i
      if limit <= 0
        raise ArgumentError, "Неверно указано число отчётов. Число отчётов должно быть целым положительным числом."
      end
    end

    
  end
    


  private

  def show_all_reports(limit)
    @reports_registry.each_value do |report_factory|
      ReportPresenter.print(report_factory.call(limit))
    end
  end

  def is_digit?(num)
    num.to_s.match?(/\A\d+\z/)
  end

  def available_reports
    @reports_registry.keys
  end
end
