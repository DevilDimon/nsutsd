class ConcurrentArray
  def initialize(array = [])
    @array = array
  end

  # private
  def each_concurrent(thread_count)
    threads = []
    new_thread_count = thread_count.clamp(0, @array.size)
    return if new_thread_count.zero?

    partition_size = @array.size / new_thread_count

    (0...new_thread_count).each do |thread_number|
      threads << Thread.new do
        if thread_number < thread_count - 1
          partition = @array[(thread_number * partition_size)...((thread_number + 1) * partition_size)]
        else
          partition = @array[(thread_number * partition_size)..]
        end
        next if partition.empty?

        yield partition
      end
    end

    threads.each(&:join)
  end
end