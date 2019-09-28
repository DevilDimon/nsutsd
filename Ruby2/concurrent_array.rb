class ConcurrentArray
  def initialize(array = [])
    @array = array
  end

  def to_s
    @array.to_s
  end

  def map_concurrent(thread_count)
    new_array = each_concurrent(thread_count) do |partition|
      partition.map { |elem| yield elem }
    end

    ConcurrentArray.new(new_array.flatten)
  end

  def select_concurrent(thread_count)
    new_array = each_concurrent(thread_count) do |partition|
      partition.select { |elem| yield elem }
    end

    ConcurrentArray.new(new_array.flatten)
  end

  def any_concurrent?(thread_count)
    is_any = false
    each_concurrent(thread_count) do |partition|
      next if is_any

      partition.each do |elem|
        next if is_any

        is_any = true if yield elem
      end
    end

    is_any
  end

  def all_concurrent?(thread_count)
    !any_concurrent?(thread_count) { |elem| !yield elem }
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

        next yield partition
      end
    end

    results = []
    threads.each do |thread|
      results << thread.value
    end

    results
  end
end