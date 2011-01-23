require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/blog'


ActiveRecord::Base.configurations = {
  'db1' => {
  :adapter  => 'mysql2',
  :username => 'root',
  :encoding => 'utf8',
  :database => 'ministry_of_state_test',
}}

ActiveRecord::Base.establish_connection('db1')


class TestMinistryOfState < ActiveSupport::TestCase

  setup do
    MinistryOfState::Blog.connection.drop_table('blogs') if MinistryOfState::Blog.connection.table_exists?(:blogs)
      MinistryOfState::Blog.connection.create_table :blogs do |t|
        t.column :text, :text
        t.column :status, :string
        t.timestamps
      end
  end

  should "probably rename this file and start testing for real" do
    
  end

  
end
