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
