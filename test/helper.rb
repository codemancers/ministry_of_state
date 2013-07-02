require 'rubygems'
require 'bundler'

require 'etc'
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
  'sqlite' => {
    :adapter  => 'sqlite3',
    :encoding => 'utf8',
    :database => ':memory:',
  },
  'postgres' => {
    adapter: 'postgresql',
    encoding: 'unicode',
    database: 'mos_development',
    pool: '5',
    username: Etc.getpwuid(Process.uid).name,
    password: '',
    min_messages: 'warning'
  }
}

# ActiveRecord::Base.establish_connection('sqlite')

conn = ActiveRecord::Base.configurations['postgres']
ActiveRecord::Base.establish_connection conn.merge(database: "postgres")
ActiveRecord::Base.connection.recreate_database conn[:database]
ActiveRecord::Base.establish_connection('postgres')

def migrate_blog!(klass = Blog)
  klass.connection.create_table :blogs, force: true do |t|
    t.column :text, :text
    t.column :status, :string
    t.timestamps
  end
end

def migrate_user!(klass = User)
  klass.connection.create_table :users, force: true do |u|
    u.string :status
    u.string :firstname
    u.string :lastname
    u.string :gender
    u.datetime :login_at
    u.string :login
    u.string :type
  end
end

def migrate_article!(klass = Article)
  klass.connection.create_table :articles, force: :true do |a|
    a.string :state
    a.string :title
    a.text :content
    end
end

def migrate_post!(klass = Post)
  klass.connection.create_table :posts, force: true do |p|
    p.string :status
    p.string :title
    p.text :content
    p.boolean :public
    p.timestamps
  end
end

def migrate_cargo!(klass = Cargo)
  klass.connection.create_table :cargos, force: true do |c|
    c.string :payment
    c.string :shippment
  end
end
