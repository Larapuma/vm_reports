require 'terminal-table'
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
require './reports/largest_other_capacity_vm_report.rb'

require './presenter/report_presenter.rb'
require './manager/report_manager.rb'


vm_info_loader = VMInfoLoader.new("data/vms.csv", "data/volumes.csv", "data/prices.csv")
manager = ReportManager.new(vm_info_loader)


report_name = ARGV[0]
limit = ARGV[1].to_i
manager.show_report(report_name,limit)
