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
