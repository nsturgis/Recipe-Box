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

def all_recipes
  query = 'SELECT recipes.name, recipes.id FROM recipes ORDER BY recipes.name ASC'

  recipes = db_connection do |conn|
    conn.exec(query)
  end

  recipes
end

def recipe(id)
  query = "SELECT recipes.name, recipes.description AS description, recipes.instructions AS instructions, ingredients.name AS ingredients FROM recipes
  JOIN ingredients ON ingredients.recipe_id = recipes.id WHERE recipes.id = $1"

  recipe = db_connection do |conn|
    conn.exec_params(query, [id])
  end

  recipe
end

get '/recipes' do
  @recipes = all_recipes

  erb :index
end

get '/recipes/:id' do
  @recipe = recipe(params[:id])

  erb :show
end
