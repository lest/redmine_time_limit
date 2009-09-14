module Redmine
  module MenuManager
    module MenuController
      module TimeLimitApplicationControllerPatch
        def MenuController.included(base)
          base.extend(Redmine::MenuManager::MenuController::ClassMethods)
          base.send(:include, ClassMethods)
        end
        
        module ClassMethods
          def self.included(base)
            base.class_eval do
              before_filter :time_limit
            end
          end
          def time_limit
            if User.current.logged?
              require 'date'
              now = Time.now
              today = Date.today
              update = false
              local = true
              if not request.remote_ip.match(Setting.plugin_redmine_time_limit['remote_ip_match'])
                update = true
                local = false
              end
              if update or User.current.time_limit_begin == nil
                update = true
              end
              if update or Date.parse(User.current.time_limit_begin.to_s) != today
                update = true
              end
              if update or User.current.time_limit_hours == 99
                update = true
              end
              if update
                User.current.time_limit_begin = now
                if local
                  User.current.time_limit_hours = 0
                else
                  User.current.time_limit_hours = 99
                end
                User.current.save
                
                timers = Timer.find(:all, :conditions => ['user_id = ? AND start < ?', User.current.id, Date.today])
                timers.each {|t| t.delete}
              end
            end
          end
        end
      end
    end
  end
end
