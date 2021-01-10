# frozen_string_literal: true

class PackagesController < ApplicationController
  def index
    @packages = Package.all
  end
end
