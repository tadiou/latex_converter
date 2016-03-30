require 'sinatra'
require "sinatra/reloader" if development?

class App < Sinatra::Base
  get '/' do
    erb :index
  end

  post '/' do
    # $$  \frac{1}{\displaystyle 1+    \frac{1}{\displaystyle 2+    \frac{1}{\displaystyle 3+x}}} +  \frac{1}{1+\frac{1}{2+\frac{1}{3+x}}} $$
    @string_render = Mathematical.new.render(params[:latex_string])
    erb :index
  end

  post '/convert.json' do
    renderer = Mathematical.new
    rendered = renderer.render(params[:latex_string])
    if rendered[:exception]
      {:exception => rendered[:exception], :tex => rendered[:data]}.to_json
    else
      {:svg => rendered[:data].gsub(/\n/, '')}.to_json
    end
  end
end