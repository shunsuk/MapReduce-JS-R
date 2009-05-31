class WordCount < MapReducer
  REQUIRED_CLIENT_COUNT = 5

  def data(index)
    key = "fruits#{index}"
    value = nil

    File.open("#{RAILS_ROOT}/lib/fruits.txt", 'r') { |f|
      i = 0
      while l = f.gets
        if i == index
          value = l.chomp
          break
        end
        i += 1
      end
    }

    {key => value}
  end

  def complete(result)
    {"result" => result}
  end
end
