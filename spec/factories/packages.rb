# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    name { "A3" }
    depends { "R (>= 2.15.0), xtable, pbapply" }
    md5_sum { "027ebdd8affce8f0effaecfcd5f5ade2" }
    maintainer { "Scott Fortmann-Roe <scottfr@berkeley.edu>" }
  end
end
