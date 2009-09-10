require 'date'

require_dependency 'time_entry'

module TimeLimitTimeEntryPatch
  def self.included(base)
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)

    # Same as typing in the class 
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      validates_presence_of :comments

      validates_each :hours do |record, attr, value|
        if not value.nil? and record.new_record?
          if User.current.time_limit_begin
            time_limit = (Time.now - User.current.time_limit_begin.to_time) / 3600 -
              User.current.time_limit_hours
            record.errors.add attr, 'too much' if value > time_limit
          else
            record.errors.add attr, 'invalid'
          end
        end
      end
      
      validates_each :issue_id do |record, attr, value|
        if record.new_record?
          if record.issue.status.is_closed
            journal = Journal.find(
              :first,
              :joins => [:details],
              :conditions => {
                :journalized_type => 'Issue',
                :journalized_id => value,
                :journal_details => {
                  :property => 'attr',
                  :prop_key => 'status_id'
                }
              },
              :order => 'created_on desc'
            )
            if journal
              record.errors.add attr, 'closed' if Date.parse(journal.created_on.to_s) != Date.today
            end
          end
        end
      end
      
      before_validation_on_create do |record|
        record.spent_on = Date.today
      end
      
      after_create do |record|
        User.current.time_limit_hours += record.hours
        User.current.save
      end
    end
  end
  
  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
end
