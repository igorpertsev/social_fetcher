class SocialNetworksController < ApplicationController
  def fetch
    response = ::Requesters::Common.call
    render json: response, status: response[:errors].present? ? 206 : 200
  end
end
