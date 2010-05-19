class Hash

  # Return all combinations of a hash.
  #
  # Example:
  #   {
  #     :a => [1, 2]
  #     :b => [1, 2]
  #   }.combinations #=> [{:a=>1, :b=>1}, {:a=>1, :b=>2}, {:a=>2, :b=>1}, {:a=>2, :b=>2}]
  #
  def combinations
    return [{}] if empty?

    copy = dup
    values = copy.delete(key = keys.first)

    result = []
    copy.combinations.each do |tail|
      values.each do |value|
        result << tail.merge(key=>value)
      end
    end

    result
  end

end
