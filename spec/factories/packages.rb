# frozen_string_literal: true

FactoryBot.define do
  factory :package do
    name { "A3" }
    depends { "R (>= 2.15.0), xtable, pbapply" }
    suggests { "randomForest, e1071" }
    license { "GPL (>= 2)" }
    md5_sum { "027ebdd8affce8f0effaecfcd5f5ade2" }
    needs_compilation { "no" }
  end
end
