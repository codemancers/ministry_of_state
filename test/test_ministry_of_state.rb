require File.dirname(__FILE__) + '/helper'
require File.dirname(__FILE__) + '/blog'
require File.dirname(__FILE__) + '/user'
require File.dirname(__FILE__) + '/article'
require File.dirname(__FILE__) + '/student'
require File.dirname(__FILE__) + '/post'
require File.dirname(__FILE__) + '/cargo'

ActiveRecord::Base.configurations = {
  'db1' => {
    :adapter  => 'sqlite3',
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
      u.string :type
    end

    Article.connection.drop_table('articles') if Article.connection.table_exists?(:articles)
    Article.connection.create_table :articles do |a|
      a.string :state
      a.string :title
      a.text :content
    end

    Post.connection.drop_table('posts') if Post.connection.table_exists?(:posts)
    Post.connection.create_table :posts do |p|
      p.string :status
      p.string :title
      p.text :content
      p.timestamps
    end

    Cargo.connection.drop_table('cargos') if Cargo.connection.table_exists?(:cargos)
    Cargo.connection.create_table :cargos do |c|
      c.string :payment
      c.string :shippment
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

    should "throw error for non-existant to state" do
      assert_raise(MinistryOfState::TransitionNotAllowed) do
        @user.foobar!
      end
    end
  end

  context "For non-existant state columns" do
    should "throw error if state column is invalid" do
      assert_raise(MinistryOfState::InvalidStateColumn) do
        @article = Article.create
      end
    end
  end

  context "Not specifying from and to " do
    should "throw error" do
      assert_raise(MinistryOfState::TransitionNotAllowed) do
        class Foo < ActiveRecord::Base
          include MinistryOfState
          ministry_of_state('status') do
            add_initial_state :pending
            add_state :active
            add_event(:activate) do
              transitions(:to => :active)
            end
          end
        end
      end
    end
  end

  context "Not specifying initial state" do
    should "throw error" do
      assert_raise(MinistryOfState::NoInitialState) do
        class Note < ActiveRecord::Base
          include MinistryOfState
          ministry_of_state('status') do
          end
        end
      end
    end
  end

  context "calling enter and exit callbacks for normal events" do
    setup do
      @post = Post.create(:title => "Hello", :content => "Good world")
    end
    should "call proper callbacks" do
      assert @post.pending?
      assert_nil @post.public

      assert @post.publish!
      assert @post.published?
      assert_equal :published, @post.current_state('status')
      assert @post.public

      assert_nil @post.private
      assert @post.archive!
      assert @post.archived?
      assert @post.private
    end
  end

  context "for STI classes child" do
    setup do
      @student = Student.create(:firstname => "Hemant", :lastname => "kumar")
    end

    should "inherit all the parent states and events" do
      assert @student.pending?

      assert @student.activate!
      assert @student.active?

      @student.gender = 'male'
      @student.save
      assert @student.pending_payment!
      assert @student.pending_payment?
    end

    should "be able to override events" do
      @student.gender = 'male'
      @student.save
      assert @student.make_foo!
      assert @student.foo?

      assert @student.activate!
      assert @student.active?
    end

  end

  context "for cargo with multiple stages" do
    setup do
      @cargo = Cargo.create
    end

    should "able to be delivered to destination" do
      assert @cargo.unpaid?
      assert @cargo.pay!
      assert @cargo.paid?

      assert @cargo.unshipped?
      assert @cargo.bill_paid!
      assert @cargo.shipped?
      assert @cargo.cargo_delivered!
      assert @cargo.delivered?
    end
  end

  context "honour default states set by user" do
    should "able to honour default state" do
      @cargo = Cargo.new
      @cargo.payment = 'paid'
      @cargo.save
      assert @cargo.paid?
    end
  end
end
