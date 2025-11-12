# frozen_string_literal: true

module Admin
  class AdminController < ApplicationController
    before_action :require_admin!

    layout 'admin'
  end
end
