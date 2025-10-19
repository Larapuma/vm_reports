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
