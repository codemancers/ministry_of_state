require File.dirname(__FILE__) + '/helper'

class MinimalPost < ActiveRecord::Base
  self.table_name = 'posts'
  include MinistryOfState
  
  ministry_of_state('status') do
    add_initial_state 'pending'
    add_state :published

    add_event(:publish, :after => :make_public) do
      transitions(:from => :pending, :to => :published)
    end
  end

  def make_public
    self.public = true
    raise "some error"
  end

  def publish_and_make_public!
    self.class.transaction do
      self.publish!
    end
  end
end

class TestWrappedTransaction < ActiveSupport::TestCase

  setup do
    migrate_post! MinimalPost
    @post = MinimalPost.create(:title => "Hello world", content: "test test", status: :pending)
  end

  context "after callback hook" do
    should "be executed" do
      @post.expects(:make_public).once
      @post.publish_and_make_public!
    end

    should "rollback on error because it is wrapped in a transaction" do
      @post.publish_and_make_public!
      @post.reload
      assert @post.pending?
    end
  end
end
