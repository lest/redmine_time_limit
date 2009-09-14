class TimersController < ApplicationController
  unloadable
  layout 'base'

  def start
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      timer = @issue.timers.find(:first, :conditions => {:user_id => User.current.id})
      
      if @issue.timer_start_allowed?
        timers = Timer.find(:all, :conditions => ['user_id = ? AND issue_id != ?', User.current.id, @issue.id])
        timers.each do |t|
          t.do_pause
        end

        timer = Timer.new(:issue_id => @issue.id, :user_id => User.current.id) if timer.nil?
        timer.do_start
      end

      render :layout => false
    else
      render :nothing => true
    end
  end
  
  def pause
    if params[:issue_id]
      @issue = Issue.find(params[:issue_id])
      timer = @issue.timers.find(:first, :conditions => {:user_id => User.current.id})
      
      if timer
        timer.do_pause
      end

      render :layout => false
    else
      render :nothing => true
    end
  end
end
