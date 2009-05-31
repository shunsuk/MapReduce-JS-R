class MapReducer
  REQUIRED_CLIENT_COUNT = 0

  def data(index)
    raise NotImplementedError
  end

  def complete(result)
    raise NotImplementedError
  end
end
