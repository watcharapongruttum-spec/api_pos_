class ApplicationController < ActionController::API
  before_action :authenticate_request

  private

  def authenticate_request
    auth_header =
      request.headers['Authorization'] ||
      request.headers['HTTP_AUTHORIZATION']

    Rails.logger.debug "AUTH HEADER RAW: #{auth_header.inspect}"

    if auth_header.blank?
      return render json: { error: 'Unauthorized' }, status: :unauthorized
    end

    token = auth_header.split(' ').last

    decoded = JWT.decode(
      token,
      Rails.application.secret_key_base,
      true,
      algorithm: 'HS256'
    )[0]

    @current_user = User.find(decoded['user_id'])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
    Rails.logger.warn "AUTH ERROR: #{e.class} - #{e.message}"
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end
end
