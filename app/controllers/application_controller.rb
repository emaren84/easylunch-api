class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  def load_messenger_code(params)
    CodeTable.find_messenger(params[:messenger]).id
  end

  def render_200(json)
    render json: json, status: 200
  end

  def render_201(json)
    render json: json, status: 201
  end

  def render_error_401
    render json: { error: 'cannot verify user or meetup information' },
           status: 401
  end

  def authorize_params
    if !params_authorizable?
      render_error_401
    else
      return true
    end
  end
end
