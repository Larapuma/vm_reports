class ReportPresenter
  def self.print(report)
    result = report.generate
    if result.nil? || result.empty?
      puts "\n#{report.get_report_name}"
      puts "Нет данных для отображения"
      return
    end
    
    table = Terminal::Table.new do |t|
      t.title = report.get_report_name #заголовок таблицы 
      t.headings = ['VM ID', 'CPU', 'RAM', 'Main HDD', 'HDD Type', 'Additional Volumes', 'Total Price']# названия столбцов
      t.rows = result.map do |vm|
        [
          vm[:vm_id],
          vm[:cpu],
          "#{vm[:ram]} GB",
          "#{vm[:hdd_capacity]} GB",
          vm[:hdd_type],
          format_volumes(vm[:other_hdd]),
          "#{vm[:total_price]/100} руб. #{(vm[:total_price]%100)} коп."
        ]# преобразование данных из каждой вмки в формат для таблицы
      end
    end
    
    puts table
  end
  
  private
  
  def self.format_volumes(other_hdd)
    return "нет" if other_hdd.nil? || other_hdd.empty?
    
    volumes_by_type = other_hdd.group_by { |hdd| hdd[:type] }
    volumes_by_type.map { |type, hdds| 
      total = hdds.sum { |hdd| hdd[:hdd_capacity].to_i }
      "#{type}: #{total}GB"
    }.join(", ")
  end
end