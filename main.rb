require 'csv'

# Загрузка всех необходимых файлов
require './models/vm.rb'
require './models/price.rb'
require './models/volume.rb'

require './loaders/loader.rb'
require './loaders/vm_loader.rb'
require './loaders/price_loader.rb'
require './loaders/volume_loader.rb'
require './loaders/vm_info_loader.rb'

require './calculators/other_hdd_price_calculator.rb'
require './calculators/vm_price_calculator.rb'

require './reports/base_report.rb'
require './reports/most_expensive_vm_report.rb'
require './reports/cheapest_vm_report.rb'
require './reports/most_volume_vm_report.rb'
require './reports/most_volume_count_vm_report.rb'
require './reports/largest_othet_capacity_vm_report.rb'

require './presenter/report_presenter.rb'

require './router/report_router.rb'







vm_info_loader = VMInfoLoader.new("data/vms.csv", "data/volumes.csv", "data/prices.csv")
router = ReportRouter.new(vm_info_loader)



report_type = if ARGV[0] && !ARGV[0].empty?
                ARGV[0]  
              else
                ENV["DEFAULT_REPORT"] 
              end

limit = if ARGV[1] && !ARGV[1].empty?
          ARGV[1]  
        else
          ENV["DEFAULT_LIMIT"]
        end


router.generate_report(report_type,limit)


#ТЕСТЫ
# reports = [
#   MostExpensiveVMReport.new(vm_info_loader, 3),
#   CheapestVMReport.new(vm_info_loader, 3),
#   MostVolumeVMReport.new(vm_info_loader, 3, "cpu"),
#   MostVolumeVMReport.new(vm_info_loader, 3, "ram"), 
#   MostVolumeVMReport.new(vm_info_loader, 3, "sas"),
#   MostVolumeVMReport.new(vm_info_loader, 3, "ssd"),
#   MostVolumeCountVMReport.new(vm_info_loader, 3),
#   MostVolumeCountVMReport.new(vm_info_loader, 3, "sas"),
#   LargestOtherCapacityVMReport.new(vm_info_loader, 3,"sas"),
#   LargestOtherCapacityVMReport.new(vm_info_loader, 3, "ssd")
# ]

# # Запуск всех отчетов
# reports.each do |report|
#   ReportPresenter.print(report)
# end


