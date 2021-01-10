# frozen_string_literal: true

require 'tempfile'
require 'rubygems/package'
require 'fileutils'
require 'open-uri'

module Packages
  class Update
    include Dry::Transaction

    LIMIT = 25
    DOWNLOAD_PATH = 'vendor/download'
    WANTED_ATTRIBUTES = %w[Package Version Depends MD5sum]
    PACKAGES_URL = 'https://cran.r-project.org/src/contrib/PACKAGES'

    map :scrape_webpage
    map :parse_data
    map :add_additional_fields
    map :download_packages
    map :extract_data_from_tar_files
    map :persist_package_info
    map :delete_downloaded_packages

    def scrape_webpage
      data = open(PACKAGES_URL).read
      data.split("\n\n").first(LIMIT)
    end

    def parse_data(input)
      input.map do |data|
        data.split("\n").each_with_object({}) do |raw_attr, result|
          key, value = raw_attr.split(': ')
          result[key] = value
          result.slice!(*WANTED_ATTRIBUTES)
        end
      end
    end

    def add_additional_fields(input)
      input.map do |pkg_data|
        pkg_data.merge!(
          "DownloadUrl" => 'https://cran.r-project.org/src/contrib/' \
            "#{pkg_data['Package']}_#{pkg_data['Version']}.tar.gz",
          "FilePath" => "#{DOWNLOAD_PATH}/#{pkg_data['Package']}_" \
            "#{pkg_data['Version']}.tar.gz"
        )
      end
    end

    def download_packages(input)
      FileUtils.mkdir(DOWNLOAD_PATH)
      input.each do |package|
        File.open(package["FilePath"], "wb") do |file|
          file.write open(package["DownloadUrl"]).read
        end
      end
    end

    def extract_data_from_tar_files(input)
      input.map do |package|
        Gem::Package::TarReader.new(Zlib::GzipReader.open(File.open(package["FilePath"], 'rb'))) do |file|
          file.seek("#{package["Package"]}/DESCRIPTION") do |description|
            key, value = description.read.split("\n").find do |attr|
              attr.include?('Maintainer')
            end.split(': ')
            package[key] = value
          end
        end
      end
      input
    end

    def persist_package_info(input)
      input.each do |package_hash|
        package = Package.first_or_create(
          name: package_hash["Package"],
          depends: package_hash["Depends"],
          md5_sum: package_hash["MD5sum"],
          maintainer: package_hash["Maintainer"],
        )
        unless package.versions.map(&:number).include?(package_hash["Version"])
          package.versions.create(number: package_hash["Version"])
        end
      end
    end

    def delete_downloaded_packages
      FileUtils.rm_rf(DOWNLOAD_PATH)
    end
  end
end
