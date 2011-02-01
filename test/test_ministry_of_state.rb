require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/blog'
require File.dirname(__FILE__) + '/user'

ActiveRecord::Base.configurations = {
  'db1' => {
    :adapter  => 'mysql2',
    :username => 'root',
    :encoding => 'utf8',
    :database => 'ministry_of_state_test',
  }
}

ActiveRecord::Base.establish_connection('db1')

class TestMinistryOfState < ActiveSupport::TestCase

  setup do
    Blog.connection.drop_table('blogs') if Blog.connection.table_exists?(:blogs)
    Blog.connection.create_table :blogs do |t|
      t.column :text, :text
      t.column :status, :string
      t.timestamps
    end
    User.connection.drop_table('users') if User.connection.table_exists?(:users)
    User.connection.create_table :users do |u|
      u.string :status
      u.string :firstname
      u.string :lastname
      u.string :gender
      u.datetime :login_at
      u.string :login
    end
  end

  context "User should be able to define state" do
    setup do
      @blog = Blog.create(:text => "Hello world")
    end
    should "have initial state set" do
      assert @blog.pending?
    end
    should "be able to change state" do
      assert_nil @blog.foo
      assert @blog.approve!
      assert @blog.foo
      assert @blog.reload.approved?
    end
  end

  context "Error while creating records" do
    setup do
      @blog = Blog.create()
    end
    should "have error object" do
      assert !@blog.errors.blank?
      assert !@blog.errors[:text].blank?
    end
  end

  context "With conditional validations" do
    setup do
      @user = User.create(:firstname => "Hemant", :lastname => "kumar")
    end
    should "create valid record" do
      assert @user.valid?
      assert @user.pending?
    end
    should "not kick if for pending users" do
      assert @user.activate!
      assert @user.errors.blank?
    end

    should "kick for active users" do
      @user.activate!
      assert !@user.pending_payment!
      assert !@user.errors.blank?
    end
  end

end
