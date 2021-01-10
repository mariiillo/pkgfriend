#frozen_string_literal: true

class PackageDecorator < Draper::Decorator
  delegate_all

  def version_numbers
    versions.pluck(:number).join
  end
end
