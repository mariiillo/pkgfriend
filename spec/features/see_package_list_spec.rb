# frozen_string_literal: true

require "rails_helper"

RSpec.feature "Packages" do
  scenario "all the packages are listed" do
    package = FactoryBot.create(:package)
    FactoryBot.create(:version, package: package)
    visit packages_path

    expect(page).to have_content package.name
    expect(page).to have_content package.depends
    expect(page).to have_content package.md5_sum
    expect(page).to have_content package.maintainer
    expect(page).to have_content "1.0.0"
  end
end
