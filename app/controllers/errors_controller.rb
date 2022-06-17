class ErrorsController < ApplicationController
  
  def not_found
    render formats: :html, status: 404
  end

end
