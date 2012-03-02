class StaticController < ApplicationController
  before_filter :require_user, only: [:secret]
end
