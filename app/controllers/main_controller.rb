class MainController < ApplicationController
  def index
    @tables = ActiveRecord::Base.connection.execute("SELECT 'mysnu' as category, * from mysnus UNION SELECT 'computer' as category, * from computers UNION SELECT 'engineer' as category, * from engineers ORDER BY date DESC, node DESC limit 50")
  end
end
