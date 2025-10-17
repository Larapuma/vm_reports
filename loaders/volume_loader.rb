require 'csv'
require_relative 'loader'
require_relative '../models/volume'

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
