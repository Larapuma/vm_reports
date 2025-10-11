require 'csv'

class VM
  attr_accessor :id, :cpu, :ram, :hdd_type, :hdd_capacity

  def initialize(id, cpu, ram, hdd_type, hdd_capacity)
    @id = id
    @cpu = cpu
    @ram = ram
    @hdd_type = hdd_type
    @hdd_capacity = hdd_capacity
  end
end
  

class Price
  attr_accessor :type, :price

  def initialize(type, price)
    @type = type
    @price = price
  end
end


class Volume
  attr_accessor :vm_id, :hdd_type, :hdd_capacity

  def initialize(vm_id, hdd_type, hdd_capacity)
    @vm_id = vm_id
    @hdd_type = hdd_type
    @hdd_capacity = hdd_capacity
  end
end


class Loader
  def initialize(path)
    @data = []
    load_data(path) 
  end

  def data
    @data
  end

  private
  def load_data(path) 
  end
end


class VMLoader < Loader  
  def find_by_id(id)
    @data.find {|vm| vm.id == id}
  end

  private
  def load_data(path)
    begin
      CSV.foreach(path) do |row|
        @data << VM.new(*row)
      end
    rescue Errno::ENOENT => e
      puts "Файл не найден: #{e.message}"
      @data = []
    rescue CSV::MalformedCSVError => e
      puts "Неправильный формат CSV: #{e.message}"
      @data = []
    end
  end
end
    

class PriceLoader < Loader  
  def find_by_type(type)
    @data.find {|price| price.type == type}
  end

  private 
  def load_data(path)
    CSV.foreach(path) do |row|
      @data << Price.new(*row)
    end
  rescue Errno::ENOENT => e
    puts "Файл не найден: #{e.message}"
    @data = []
  rescue CSV::MalformedCSVError => e
    puts "Неправильный формат CSV: #{e.message}"
    @data = []
  end
end


class VolumeLoader < Loader
  def find_by_vm_id(id)
    @data.find_all {|volume| volume.vm_id == id}
  end

  private 
  def load_data(path)
    CSV.foreach(path) do |row|
      @data << Volume.new(*row)
    end
  rescue Errno::ENOENT => e
    puts "Файл не найден: #{e.message}"
    @data = []
  rescue CSV::MalformedCSVError => e
    puts "Неправильный формат CSV: #{e.message}"
    @data = []
  end
end


class OtherHDDPriceCalculator
  def initialize(volume_loader, price_loader)
    @volume_loader = volume_loader
    @price_loader = price_loader
  end
  
  def calculate_other_HDD_cost(vm_id)
    total = 0
    volumes = @volume_loader.find_by_vm_id(vm_id)
    volumes.each do |v|
      price_obj = @price_loader.find_by_type(v.hdd_type)
      total += v.hdd_capacity.to_i * price_obj.price.to_f
    end
    total
  end 
end


class VMPriceCalculator
  def initialize(vms_path, volume_path, price_path)
    @vms = VMLoader.new(vms_path)
    @volumes = VolumeLoader.new(volume_path)
    @prices = PriceLoader.new(price_path)
    @other_hdd_price_calc = OtherHDDPriceCalculator.new(@volumes, @prices)
  end

  def calculate_vm_cost(vm_id)
    vm = @vms.find_by_id(vm_id)
    return "ВМ не найдена" unless vm 
    
    cpu_price_obj = @prices.find_by_type("cpu")
    ram_price_obj = @prices.find_by_type("ram")
    hdd_price_obj = @prices.find_by_type(vm.hdd_type)

    total = convert_to_rub((cpu_price_obj.price.to_f * vm.cpu.to_i) + 
            (ram_price_obj.price.to_f * vm.ram.to_i) +
            (hdd_price_obj.price.to_f * vm.hdd_capacity.to_i) +
            @other_hdd_price_calc.calculate_other_HDD_cost(vm_id))
    total
  end
  private 
  def convert_to_rub(total)
    total/100
  end
end


class VMInfoLoader
  def initialize(vms_path, volume_path, price_path)
    @vm_loader = VMLoader.new(vms_path)
    @calculator = VMPriceCalculator.new(vms_path, volume_path, price_path)
    @volumes = VolumeLoader.new(volume_path)
  end

  def generate_vm_info_list
    @vm_loader.data.map do |vm|
      vm_volumes = @volumes.find_by_vm_id(vm.id)
      {
        
        vm_id: vm.id,
        cpu: vm.cpu,
        ram: vm.ram,
        hdd_capacity: vm.hdd_capacity,
        hdd_type: vm.hdd_type,
        other_hdd: format_other_hhd(vm_volumes),
        total_price: @calculator.calculate_vm_cost(vm.id)
      }
    end
  end

  private 
  def format_other_hhd(volumes)
    volumes.map do |v|{
      type: v.hdd_type,
      hdd_capacity: v.hdd_capacity
    }
  end
end
end


class BaseVMReport
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


class MostExpensiveVMReport < BaseVMReport

  def generate
    
    vm_data.sort_by{
      |vm| -vm[:total_price]
    }.take(@limit)
  end

  def get_report_name
    "#{@limit} Самых дорогих ВМ"
  end
end

class CheapestVMReport < BaseVMReport
  
  def generate
   vm_data.sort_by{|vm| vm[:total_price]}.take(@limit)

  end

  def get_report_name
    "#{@limit} Самых дешёвых ВМ"
  end
end


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


class LargestOtherCapacityVMReport < BaseVMReport
  
  def initialize(vm_info_loader, limit = 5, hdd_type = nil)
    super(vm_info_loader, limit)
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
end


class ReportPresenter
  def self.print(report)
    result = report.generate
    return if result.nil? || result.empty?
    puts "\n#{report.get_report_name}"
    puts "=" * 60
    
    result.each_with_index do |vm, index|
      puts "#{index + 1}. Виртуальная машина: #{vm[:vm_id]}"
      puts "   Основные характеристики:"
      puts "   - Процессор: #{vm[:cpu]} ядер"
      puts "   - Оперативная память: #{vm[:ram]} GB"
      puts "   - Основной диск: #{vm[:hdd_capacity]} GB (#{vm[:hdd_type]})"
      
      # Дополнительные диски
      if vm[:other_hdd] && !vm[:other_hdd].empty?
        puts "   Дополнительные диски:"
        vm[:other_hdd].each do |hdd|
          puts "   - #{hdd[:hdd_capacity]} GB (#{hdd[:type]})"
        end
        puts "   Всего дополнительных дисков: #{vm[:other_hdd].size}"
      else
        puts "   Дополнительные диски: отсутствуют"
      end
      
      # Специфичные метрики для разных отчетов
      if vm[:other_volumes_count]
        puts "   Количество доп. дисков: #{vm[:other_volumes_count]}"
      end
      
      if vm[:other_volumes_sum]
        puts "   Объем доп. дисков: #{vm[:other_volumes_sum]} GB"
      end
      
      if vm[:total_capacity]
        puts "   Общий объем: #{vm[:total_capacity]} GB"
      end
      
      puts "   Общая стоимость: #{vm[:total_price].round(2)} руб."
      puts "-" * 40
    end
  end
end


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
