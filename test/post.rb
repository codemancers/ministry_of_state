class Post < ActiveRecord::Base
  include MinistryOfState
  attr_accessor :public, :private
  attr_accessor :published_flag, :archived_flag

  ministry_of_state('status') do
    add_initial_state 'pending'
    add_state :published, :after => :make_public
    add_state :archived, :enter => :make_private



    add_event(:publish, :before => :about_to_publish) do
      transitions(:from => :pending, :to => :published)
    end

    add_event(:archive, :after => lambda { |x| x.archived_flag = true }) do
      transitions(:from => [:pending,:published], :to => :archived)
    end
  end

  def about_to_publish
    @published_flag = true
  end

  def make_public
    @public = true
  end

  def make_private
    @private = true
  end
end
