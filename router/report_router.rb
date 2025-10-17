require './presenter/report_presenter.rb'

class ReportRouter
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
      'largest_other_capacity' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit) },
      'largest_other_capacity_ssd' => ->(limit) { LargestOtherCapacityVMReport.new(@vm_info_loader, limit, 'ssd') }
    }
  end

  def generate_report(report_name, limit)
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

    if report_name.nil?
      raise ArgumentError, "Вы не указали тип отчёта. Доступные отчёты: #{available_reports.join(', ')}"
    elsif report_name == "all"
      generate_all_reports(limit)
    elsif available_reports.include?(report_name)
      ReportPresenter.print(@reports_registry[report_name].call(limit))
    else
      raise ArgumentError, "Неверно указан вид отчёта: #{report_name}. Доступные отчёты: #{available_reports.join(', ')}"
    end
  end
    
  def available_reports
    @reports_registry.keys
  end

  private

  def generate_all_reports(limit)
    @reports_registry.each_value do |report_factory|
      ReportPresenter.print(report_factory.call(limit))
    end
  end

  def is_digit?(num)
    num.to_s.match?(/\A\d+\z/)
  end
end