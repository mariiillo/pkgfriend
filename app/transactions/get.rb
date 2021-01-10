# frozen_string_literal: true

require 'dry/transaction'
require 'ostruct'
require 'httparty'
require 'tempfile'
require 'rubygems/package'
require 'fileutils'

module Packagefriend
  module Packages
    class Get
      include Dry::Transaction

      # map :collect_packages
      # map :format
      map :present

      def collect_packages(_input)
        packages_repository.all
      end

      def format(input)
        input.map(&:as_json)
      end

      def present(input)
        presenter.present(input)
      end

      private

      def packages_repository
        PackagesRepository.new(ROM.env)
      end

      def presenter
        ConsolePrinter.new
      end
    end
  end
end

require 'terminal-table'

class ConsolePrinter
  HEADERS = %w[Package Version Depends Suggests License MD5sum NeedsCompilation Maintainer].freeze

  def present(_data)
    data = [
      ["A3", "1.0.0", "R (>= 2.15.0), xtable, pbapply", "randomForest, e1071", "GPL (>= 2)", "027ebdd8affce8f0effaecfcd5f5ade2", "no", "https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz", "vendor/download/A3_1.0.0.tar.gz", "Scott Fortmann-Roe <scottfr@berkeley.edu>"],
      ["aaSEA", "1.1.0", "R(>= 3.4.0)", "DT(>= 0.4), networkD3(>= 0.4), shiny(>= 1.0.5),", nil, nil, "knitr, rmarkdown", "GPL-3", "0f9aaefc1f1cf18b6167f85dab3180d8", "no", "Raja Sekhara Reddy D.M <raja.duvvuru@gmail.com>"],
    ]

    puts Terminal::Table.new(
      headings: HEADERS,
      rows: data
    )
  end
end
