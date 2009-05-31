$mutex ||= Mutex.new
$threads ||= []

$map_result ||= {}
$reduce_result ||= {}

class MapReduceController < ApplicationController
  skip_before_filter :verify_authenticity_token

  def index
  end

  def master
  end

  def prepare
    model = eval(params[:model].classify)

    if $threads.size >= model::REQUIRED_CLIENT_COUNT
      render :text => "over", :layout => false
      return
    end

    data = nil

    $mutex.synchronize {
      data = model.new.data($threads.size)

      $threads << Thread.current
    }
    Thread.stop

    render :text => data.to_json, :layout => false
  end

  def start
    $mutex.synchronize {
      $threads.each do |t|
        t.run if t.status == 'sleep'
      end
      $threads.clear
    }

    render :text => "start", :layout => false
  end

  def shuffle
    model = eval(params[:model].classify)

    map = eval(params[:map])

    $mutex.synchronize {
      map.each_pair do |key, value|
        if $map_result[key]
          $map_result[key] =  $map_result[key] + "," + value
        else
          $map_result[key] = value 
        end
      end

      $threads << Thread.current
    }
    Thread.stop unless $threads.size == model::REQUIRED_CLIENT_COUNT

    $mutex.synchronize {
      if $threads.size == model::REQUIRED_CLIENT_COUNT
        $threads.each do |t|
          t.run if t.status == 'sleep'
        end
        $threads.clear
      end
    }

    key = nil
    value = nil

    $mutex.synchronize {
      key_value = $map_result.shift
      key = key_value[0]
      value = key_value[1]
    }

    ret = {key => value}

    render :text => ret.to_json, :layout => false
  end

  def complete
    model = eval(params[:model].classify)

    reduce = eval(params[:reduce])

    $mutex.synchronize {
      $reduce_result = $reduce_result.merge(reduce)

      $threads << Thread.current
    }
    Thread.stop unless $threads.size == model::REQUIRED_CLIENT_COUNT

    $mutex.synchronize {
      if $threads.size == model::REQUIRED_CLIENT_COUNT
        $threads.each do |t|
          t.run if t.status == 'sleep'
        end
        $threads.clear
      end
    }

    result = nil

    $mutex.synchronize {
      result = model.new.complete($reduce_result)
    }

    render :text => result.to_json, :layout => false
  end

  def client_size
    model = eval(params[:model].classify)

    current = $threads.size
    required = model::REQUIRED_CLIENT_COUNT

    render :text => "current: #{current} / required: #{required}", :layout => false
  end

  def reset
    $threads = []
    $mutex = Mutex.new
    $map_result = {}
    $reduce_result = {}

    render :text => "reset", :layout => false
  end
end
