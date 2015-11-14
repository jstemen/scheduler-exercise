# Complete the function below.

class Event
    attr_accessor :start_minute, :end_minute, :id
    def initialize(id,priority,start_str, end_str)
        @id = id
        @priority = priority.to_i
        @start_minute = convert_time_str_to_minute start_str
        @end_minute = convert_time_str_to_minute end_str
    end
    def <=> (other) #1 if self>other; 0 if self==other; -1 if self<other
        -1 * (self.sorting_key <=> other.sorting_key)
    end
    
    
    
    def sorting_key
        "#{@priority.to_s.rjust(3,'0')}#{(24*60-@start_minute).to_s.rjust(4,'0')}"
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

class Room
    def initialize
        @events = []
        #@simu_event_cap = event_capacity
    end
    def <=> (other) #1 if self>other; 0 if self==other; -1 if self<other
        -1 * (self.percent_booked <=> other.percent_booked)
    end
    def percent_booked
        minutes= 0
        @events.each{ |event|
            minutes += event.duration
        }
        minutes.to_f / 24*60
    end
    def schedule_event(incomming_event)
        #conflicts = 0
        successful = true
        @events.each{|existing_event|
            if incomming_event.start_minute < existing_event.start_minute
                if incomming_event.end_minute > existing_event.start_minute  
                    successful = false
                end
            elsif incomming_event.start_minute == existing_event.start_minute
                successful = false
            else # after existing event
                    if existing_event.end_minute > incomming_event.start_minute
                        successful = false
                    end
            end
            break if successful == false
        }
        #if conflicts >= @simu_event_cap
        #    successful = false
        #else
        #    @events << incomming_event
        #    successful = true
        #end
        @events << incomming_event if successful
        successful
    end
end

def  schedule() 
    num_rooms_availible = gets.chomp.to_i
    rooms =(1..num_rooms_availible).collect{ Room.new}
    num_meetings = gets.chomp.to_i
    events = (1..num_meetings).collect{
        (meeting_id, start_time, end_time, priority, title) = gets.chomp.split(', ')
        Event.new meeting_id, priority, start_time, end_time
    }
    events.sort!
    booked_event_ids = []
    events.each{|potential_event|
        rooms.sort!.each{|room|
            successful = room.schedule_event potential_event
            if successful
                booked_event_ids << potential_event.id
                break
            end
        }    
    }
    booked_event_ids
end
