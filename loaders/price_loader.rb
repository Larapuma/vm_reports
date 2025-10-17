require 'csv'
require_relative 'loader'
require_relative '../models/price'

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
