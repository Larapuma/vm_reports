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
