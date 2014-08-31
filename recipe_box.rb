require 'pry'
require 'sinatra'
require 'sinatra/reloader'
require 'pg'

def db_connection
begin
  connection = PG.connect(dbname: 'recipes')

  yield(connection)

ensure
  connection.close
end
end

get '/recipes' do
  query = 'SELECT recipes.name, recipes.id FROM recipes ORDER BY recipes.name ASC'
  db_connection do |conn|
    @recipes = conn.exec(query)
  end
  erb :index
end

get '/recipes/:id' do
  id = params[:id]
  query = "SELECT recipes.name, recipes.description AS description, recipes.instructions AS instructions, ingredients.name AS ingredients FROM recipes
  JOIN ingredients ON ingredients.recipe_id = recipes.id WHERE recipes.id = #{id}"
  db_connection do |conn|
    @recipe = conn.exec(query)
  end
  erb :show
end
