module LazyRecords

  def keyword(name, encrypt=false)
    Keyword.new(name, encrypt)
  end

  class Keyword

    attr_reader :name, :encrypt

    def initialize(name, encrypt=false)
      @name = name
      @encrypt = encrypt
    end
  end

end