require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/blog'


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
  end

  context "User should be able to define state" do
    setup do
      @blog = Blog.create(:text => "Hello world")
    end
    should "have initial state set" do
      assert @blog.pending?
    end
    should "be able to change state" do
      assert @blog.approve!
      p @blog.reload
      assert @blog.reload.approved?
    end
  end
end
