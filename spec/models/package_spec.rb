require 'rails_helper'

RSpec.describe Package, type: :model do

  describe "attributes" do
    it { is_expected.to have_db_column(:name) }
    it { is_expected.to have_db_column(:depends) }
    it { is_expected.to have_db_column(:suggests) }
    it { is_expected.to have_db_column(:license) }
    it { is_expected.to have_db_column(:md5_sum) }
    it { is_expected.to have_db_column(:needs_compilation) }
  end
end
