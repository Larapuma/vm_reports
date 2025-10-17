require 'csv'

# Загрузка всех необходимых файлов
require_relative 'models/vm'
require_relative 'models/price'
require_relative 'models/volume'

require_relative 'loaders/loader'
require_relative 'loaders/vm_loader'
require_relative 'loaders/price_loader'
require_relative 'loaders/volume_loader'
require_relative 'loaders/vm_info_loader'

require_relative 'calculators/other_hdd_price_calculator'
require_relative 'calculators/vm_price_calculator'

require_relative 'reports/base_report'
require_relative 'reports/most_expensive_vm_report'
require_relative 'reports/cheapest_vm_report'
require_relative 'reports/most_volume_vm_report'
require_relative 'reports/most_volume_count_vm_report'
require_relative 'reports/largest_othet_capacity_vm_report'

require_relative 'presenter/report_presenter'



# ТЕСТЫ
vm_info_loader = VMInfoLoader.new("data/vms.csv", "data/volumes.csv", "data/prices.csv")

reports = [
  MostExpensiveVMReport.new(vm_info_loader, 3),
  CheapestVMReport.new(vm_info_loader, 3),
  MostVolumeVMReport.new(vm_info_loader, 3, "cpu"),
  MostVolumeVMReport.new(vm_info_loader, 3, "ram"), 
  MostVolumeVMReport.new(vm_info_loader, 3, "sas"),
  MostVolumeVMReport.new(vm_info_loader, 3, "ssd"),
  MostVolumeCountVMReport.new(vm_info_loader, 3),
  MostVolumeCountVMReport.new(vm_info_loader, 3, "sas"),
  LargestOtherCapacityVMReport.new(vm_info_loader, 3),
  LargestOtherCapacityVMReport.new(vm_info_loader, 3, "ssd")
]

# Запуск всех отчетов
reports.each do |report|
  ReportPresenter.print(report)
end
