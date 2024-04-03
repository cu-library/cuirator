class ErrorsController < ApplicationController
  
  def not_found
    render formats: :html, status: 404
  end

  def internal_server_error
    render formats: :html, status: 500 
  end

end
