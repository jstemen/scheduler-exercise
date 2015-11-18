# Complete the function below.

class Event
  attr_accessor :start_minute, :end_minute, :id

  def initialize(id, priority, start_str, end_str)
    @id = id
    @priority = priority.to_i
    @start_minute = convert_time_str_to_minute start_str
    @end_minute = convert_time_str_to_minute end_str
  end

  def <=> (other) #1 if self>other; 0 if self==other; -1 if self<other
    -1 * (self.sorting_key <=> other.sorting_key)
  end


  def sorting_key
    "#{@priority.to_s.rjust(3, '0')}#{(24*60-@start_minute).to_s.rjust(4, '0')}"
  end

  def duration
    @end_minute - @start_minute
  end

  private
  def convert_time_str_to_minute(time_str)
    padded_str = time_str.rjust(4, '0')
    time_minutes = padded_str[-2..-1].to_i
    time_minutes += padded_str[0..1].to_i * 60
    time_minutes
  end

end

class Point
  attr_accessor :start_minute, :utilization

  def initialize(start_pt, utilization)
    if utilization < 0
      raise "utilization can not be negitive"
    end
    @start_minute = start_pt
    @utilization = utilization
  end

  def increment_utilization(simu_event_cap)

    if utilization + 1 <= simu_event_cap
      @utilization = @utilization + 1
      successful = true
    else
      successful = false
    end
    successful
  end
end

class Scheduler
  def initialize(event_capacity)
    @events = []
    @timeline = [Point.new(-1, 0), Point.new(60*24 + 1, 0)]
    @simu_event_cap = event_capacity
  end

  def schedule_event(incoming_event)
    successful = true
    i = 0
    during_event = false
    puts " ================ Incoming event is  #{incoming_event.inspect} =================== "
    puts "Timeline is #{@timeline.inspect}"
    starting_pos = nil
    while i < @timeline.size - 1 && successful
      puts "i is #{i}"
      present = @timeline[i]
      future = @timeline[i+1]
      if !during_event
        puts "Event is not active"
        # found the start of the event?
        if present.start_minute == incoming_event.start_minute
          puts "We are aligned with begining of event"
          during_event = true
          starting_pos = i
          # are we straddling the starting pt?
        elsif present.start_minute < incoming_event.start_minute && incoming_event.start_minute < future.start_minute
          puts "We are stradding the beging of the event"
          # use exising utilization for new point, shift future to the left to make room for new pt
          @timeline.insert(i+1, Point.new(incoming_event.start_minute, present.utilization))
          #@events << incoming_event
        end
      end

      if during_event
        #If we are in the during_event state, we must increment the utilization of every point we land on
        break unless successful = present.increment_utilization(@simu_event_cap)

        puts "Event is currently active"
        # are we straddling the end of the event?  ( must be done before interior segment)
        if present.start_minute < incoming_event.end_minute && incoming_event.end_minute < future.start_minute
          puts "We are stradding the end of the event."
          @timeline.insert(i+1, Point.new(incoming_event.end_minute, present.utilization - 1))
          @events << incoming_event
          future = @timeline[i+1]
        end
        if future.start_minute == incoming_event.end_minute
          puts "We are aligned with end of event."
          during_event = false
          break
        end

        #interior segment?
        if incoming_event.start_minute < present.start_minute && future.start_minute <= incoming_event.start_minute
          break unless successful = present.increment_utilization(@simu_event_cap)
        end
      end


      puts "Timeline is #{@timeline.inspect}.  i was #{i}"
      i +=1
    end

    if !successful
      puts "Woops, look like this event can't fit, let's undo our mettling to restore the timeline to our previous state"
      puts "Messed up timeline is: #{@timeline.inspect}"
      j = starting_pos
      while j <= i
        past_pt = @timeline[j]
        past_pt.utilization = past_pt.utilization - 1
        j +=1
      end
    end

    if successful
      puts "Successfully inserted: #{incoming_event.inspect}."
    else
      puts "Failed to insert: #{incoming_event.inspect}"
    end
    puts "We now have #{@events.size} events scheduled"

    #@events << incoming_event if successful
    successful
  end
end

def schedule(num_rooms_availible, events)
  scheduler = Scheduler.new(num_rooms_availible)

  events.sort!
  booked_event_ids = []
  events.each { |potential_event|
    successful = scheduler.schedule_event potential_event
    if successful
      booked_event_ids << potential_event.id
    end
  }
  booked_event_ids
end


require "minitest/autorun"

class PointTests < Minitest::Test
=begin

  def test_that_original_problem_is_solved_correctly
    events = [Event.new('1', '100', '0', '100'), Event.new('2', '95', '230', '330'), Event.new('3', '90', '300', '500'), Event.new('4', '50', '200', '400')]
    assert_equal(['1', '2'], schedule(1, events))
  end

  def test_that_original_problem_works_with_more_capacity
    events = [Event.new('1', '100', '0', '100'), Event.new('2', '95', '230', '330'), Event.new('3', '90', '300', '500'), Event.new('4', '50', '200', '400')]
    assert_equal(['1', '2', '3'], schedule(2, events))
  end

  def test_case_one
    events = [Event.new('1', '100', '1300', '1400'),
              Event.new('2', '100', '1345', '1445'),
              Event.new('3', '100', '1330', '1350'),
              Event.new('4', '75', '1500', '1700'),
              Event.new('5', '90', '1300', '1400')]
    assert_equal(['1', '3', '2', '4'], schedule(3, events))
  end
=end
  def test_case_eleven
    events = [Event.new('1', '19', '100', '200'),
              Event.new('2', '90', '130', '300'),
              Event.new('3', '100', '230', '400')]
    assert_equal(['3', '1'], schedule(1, events))
  end
end

