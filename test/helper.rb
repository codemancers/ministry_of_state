require 'rubygems'
require 'bundler'
require 'debugger'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ministry_of_state'

ActiveRecord::Base.configurations = {
  'db1' => {
    :adapter  => 'sqlite3',
    :encoding => 'utf8',
    :database => ':memory:',
  }
}

ActiveRecord::Base.establish_connection('db1')

def migrate_blog!
  Blog.connection.drop_table('blogs') if Blog.connection.table_exists?(:blogs)
  Blog.connection.create_table :blogs do |t|
    t.column :text, :text
    t.column :status, :string
    t.timestamps
  end
end

def migrate_user!
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
end

def migrate_article!
  Article.connection.drop_table('articles') if Article.connection.table_exists?(:articles)
  Article.connection.create_table :articles do |a|
    a.string :state
    a.string :title
    a.text :content
  end
end

def migrate_post!
  Post.connection.drop_table('posts') if Post.connection.table_exists?(:posts)
  Post.connection.create_table :posts do |p|
    p.string :status
    p.string :title
    p.text :content
    p.boolean :public
    p.timestamps
  end
end

def migrate_cargo!
  Cargo.connection.drop_table('cargos') if Cargo.connection.table_exists?(:cargos)
  Cargo.connection.create_table :cargos do |c|
    c.string :payment
    c.string :shippment
  end
end
