module LazyRecords

  class PredicateToSql
    def initialize
      @pred_map = {
          equals: '=',
          equal_to: '=',
          greater_than: '>',
          less_than: '<',
          like: 'like'
      }
    end

    def custom(pred_map)
      @pred_map = @pred_map.merge(pred_map)
    end

    def convert(predicate)
      predicate.predicates.map do |pred|
        operation = option(@pred_map[pred.value.name]).get_or_throw(NoSuchElementException, "Operation not supported: #{pred.value.name}")
        column = pred.key.to_s
        value = pred.value.value
        "#{column} #{operation} '#{value}'"
      end.to_a.join(' and ')
    end

  end

end