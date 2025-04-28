class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :when_parameter_missing

  private

  def when_parameter_missing(exception)
    render json: {
      status: 400,
      error: "Bad Request",
      message: "Required parameter missing: #{exception.param || 'unknown'}"
    }, status: :bad_request
  end
end
