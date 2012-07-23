require 'bundler'
Bundler.require

DataMapper.setup(:default, 'sqlite::memory:')
require_all 'models'
DataMapper.finalize
# match the database to the models
DataMapper.auto_upgrade!
# truncate any existing data


configure do
  set :environment, :development
  DataMapper::Model.raise_on_save_failure = true 
end

# seed database
Dir["views/ingredient-list/*"].each do |file|
  category_name = file.split("/")[2]
  print "#{category_name}\n"
  if category_name == "template.md" then 
    next
  end
  category = Category.create(:name => category_name)
  Dir["#{file}/*"].each do |item|
    item.slice! ".md"
    item.slice! "views/"
    name = item.split("/")[2]
    print "#{name}\n"
    Ingredient.create(:name => name, :markdown => item, :category => category)
  #File.open(file).each do |line|
  #  desc = line.split(" : ")
  #  if !desc[0].nil?
  #    print "#{desc[0]} : #{desc[1]}\n"
  #    Ingredient.create(:name => desc[0], :description => desc[1], :category => category)
  #    print "Added to db"
  #  end
  end
end


get '/' do
  erb :index, :layout => :page
end

#require_all 'helpers'
#require_all 'routes'
