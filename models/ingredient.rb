class Ingredient 
  include DataMapper::Resource

  property :id,           Serial
  property :name,         String
#  property :description,  Text
#  property :dependancies, Text
  property :markdown,      String

  property :created_at,   DateTime
  property :updated_at,   DateTime

  belongs_to :category
end
