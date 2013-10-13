class MainController < ApplicationController
  def index
    @tables = ActiveRecord::Base.connection.execute("SELECT 'mysnu' as category, * from mysnus UNION SELECT 'computer' as category, * from computers ORDER BY date DESC")
  end
end
