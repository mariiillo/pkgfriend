require 'rails_helper'

RSpec.describe Version, type: :model do
  describe "attributes" do
    it { is_expected.to have_db_column(:number) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:package) }
  end
end
