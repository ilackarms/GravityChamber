class Timer

  $running_threads = []

  def self.call_once block, delay_s
    thr = Thread.new {
      sleep(delay_s)
      block.call
    }
    $running_threads << thr
    # thr.join
  end

  def self.call_repeating block, delay_s, no_times
    thr = Thread.new {
      sleep(delay_s)
      block.call
      if no_times > 0
        Timer.call_repeating(block, delay_s, no_times - 1)
      end
    }
    $running_threads << thr
    # thr.join
  end

  def self.kill_all_threads
    until $running_threads.empty?
      $running_threads.each do
        |thr|
        thr.terminate
        $running_threads.delete(thr)
      end
    end
  end

end