require 'redmine'

require 'dispatcher'
require 'time_limit_tag_helper_patch'
require 'time_limit_time_entry_patch'
require 'time_limit_application_controller_patch'

Dispatcher.to_prepare do
  TimeEntry.send(:include, TimeLimitTimeEntryPatch)
  Redmine::MenuManager::MenuController.send(:include, Redmine::MenuManager::MenuController::TimeLimitApplicationControllerPatch)
end

Redmine::Plugin.register :redmine_time_limit do
  name 'Redmine Time Limit plugin'
  author 'Just Lest'
  description ''
  version '0.0.1'
  
  settings :default => {'remote_ip_match' => '127.0.0.1'}, :partial => 'settings/time_limit_settings'
end
