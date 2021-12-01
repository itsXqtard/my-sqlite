require_relative './expression.rb'

class Expression_Array < Array
  include Enumerable
  def initialize(data_array)
    @collection = data_array
  end

  def combine_with_delimiter
    return Expression.new(@collection.join("+"))
  end
end