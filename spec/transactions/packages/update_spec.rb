require "rails_helper"

RSpec.describe Packages::Update do
  describe "steps" do

    before do
      response = File.read("spec/fixtures/package_list.txt")
      stub_request(:get, "https://cran.r-project.org/src/contrib/PACKAGES").
        with(
          headers: {
         'Accept'=>'*/*',
         'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
         'User-Agent'=>'Ruby'
          }).
        to_return(status: 200, body: response, headers: {})
    end

    describe "scrape_webpage" do
      it "reads a list of packages from internet" do
        described_class.new.scrape_webpage

        expect(a_request(:get, "https://cran.r-project.org/src/contrib/PACKAGES")).to have_been_made
      end

      it "returns info of only the 25 packages" do
        result = described_class.new.scrape_webpage

        expect(result).to be_a Array
        expect(result.count).to eq 25
      end
    end

    describe "parse_data" do
      it "returns a parsed info of packages" do
        input = [
          "Package: A3\nVersion: 1.0.0\nDepends: R (>= 2.15.0), xtable, pbapply\nSuggests: randomForest, e1071\nLicense: GPL (>= 2)\nMD5sum: 027ebdd8affce8f0effaecfcd5f5ade2\nNeedsCompilation: no",
          "Package: aaSEA\nVersion: 1.1.0\nDepends: R(>= 3.4.0)\nImports: DT(>= 0.4), networkD3(>= 0.4), shiny(>= 1.0.5),\n        shinydashboard(>= 0.7.0), magrittr(>= 1.5), Bios2cor(>= 2.0),\n        seqinr(>= 3.4-5), plotly(>= 4.7.1), Hmisc(>= 4.1-1)\nSuggests: knitr, rmarkdown\nLicense: GPL-3\nMD5sum: 0f9aaefc1f1cf18b6167f85dab3180d8\nNeedsCompilation: no"
        ]
        result = described_class.new.parse_data(input)

        expect(result).to eq(
        [{
          "Package"=>"A3",
          "Version"=>"1.0.0",
          "Depends"=>"R (>= 2.15.0), xtable, pbapply",
          "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
          },
          {
          "Package"=>"aaSEA",
          "Version"=>"1.1.0",
          "Depends"=>"R(>= 3.4.0)",
          "MD5sum"=>"0f9aaefc1f1cf18b6167f85dab3180d8",
        }]
      )
      end
    end

    describe "add_additional_fields" do
      it "sets some useful fields to each package hash" do
        input = [{
          "Package"=>"A3",
          "Version"=>"1.0.0",
          "Depends"=>"R (>= 2.15.0), xtable, pbapply",
          "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
          },
          {
          "Package"=>"aaSEA",
          "Version"=>"1.1.0",
          "Depends"=>"R(>= 3.4.0)",
          "MD5sum"=>"0f9aaefc1f1cf18b6167f85dab3180d8",
        }]

        result = described_class.new.add_additional_fields(input)

        expect(result).to eq(
          [{
            "Depends"=>"R (>= 2.15.0), xtable, pbapply",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
            "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
            "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
            "Package"=>"A3",
            "Version"=>"1.0.0"
          },
          {
            "Depends"=>"R(>= 3.4.0)",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/aaSEA_1.1.0.tar.gz",
            "FilePath"=>"vendor/download/aaSEA_1.1.0.tar.gz",
            "MD5sum"=>"0f9aaefc1f1cf18b6167f85dab3180d8",
            "Package"=>"aaSEA",
            "Version"=>"1.1.0"
            }
          ]
        )
      end
    end

    describe "download_packages" do
      before do
        stub_request(:get, "https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz").
          to_return(status: 200, body: "", headers: {})
        stub_request(:get, "https://cran.r-project.org/src/contrib/aaSEA_1.1.0.tar.gz").
          to_return(status: 200, body: "", headers: {})
      end

      it "creates a download folder" do
        input = [
          {
            "Depends"=>"R (>= 2.15.0), xtable, pbapply",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
            "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
            "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
            "Package"=>"A3",
            "Version"=>"1.0.0"
          },
          {
            "Depends"=>"R(>= 3.4.0)",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/aaSEA_1.1.0.tar.gz",
            "FilePath"=>"vendor/download/aaSEA_1.1.0.tar.gz",
            "MD5sum"=>"0f9aaefc1f1cf18b6167f85dab3180d8",
            "Package"=>"aaSEA",
            "Version"=>"1.1.0"
          }
        ]

        described_class.new.download_packages(input)
        expect(Dir.exist?('vendor/download')).to eq true

        FileUtils.rm_rf('vendor/download')
      end

      it "download each package" do
        input = [
          {
            "Depends"=>"R (>= 2.15.0), xtable, pbapply",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
            "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
            "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
            "Package"=>"A3",
            "Version"=>"1.0.0"
          },
          {
            "Depends"=>"R(>= 3.4.0)",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/aaSEA_1.1.0.tar.gz",
            "FilePath"=>"vendor/download/aaSEA_1.1.0.tar.gz",
            "MD5sum"=>"0f9aaefc1f1cf18b6167f85dab3180d8",
            "Package"=>"aaSEA",
            "Version"=>"1.1.0"
          }
        ]

        result = described_class.new.download_packages(input)

        expect(a_request(:get, "https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz")).to have_been_made
        expect(a_request(:get, "https://cran.r-project.org/src/contrib/aaSEA_1.1.0.tar.gz")).to have_been_made

        FileUtils.rm_rf('vendor/download')
      end
    end

    describe "extract_data_from_tar_files" do
      it "reads extract the package and reads DESCRIPTION file (add Maintainer attr)" do
        FileUtils.mkdir("vendor/download/")
        FileUtils.cp("spec/fixtures/A3_1.0.0.tar.gz", "vendor/download/")
        input = [
          {
            "Depends"=>"R (>= 2.15.0), xtable, pbapply",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
            "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
            "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
            "Package"=>"A3",
            "Version"=>"1.0.0"
          }
        ]

        result = described_class.new.extract_data_from_tar_files(input)

        expect(result).to eq(
          [
            {
              "Depends"=>"R (>= 2.15.0), xtable, pbapply",
              "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
              "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
              "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
              "Package"=>"A3",
              "Version"=>"1.0.0",
              "Maintainer"=>"Scott Fortmann-Roe <scottfr@berkeley.edu>"
            }
          ]
        )

        FileUtils.rm_rf('vendor/download')
      end
    end

    describe "persist_package_info" do
      it "stores the packages in the db" do
        input = [
          {
            "Depends"=>"R (>= 2.15.0), xtable, pbapply",
            "DownloadUrl"=>"https://cran.r-project.org/src/contrib/A3_1.0.0.tar.gz",
            "FilePath"=>"vendor/download/A3_1.0.0.tar.gz",
            "MD5sum"=>"027ebdd8affce8f0effaecfcd5f5ade2",
            "Package"=>"A3",
            "Version"=>"1.0.0",
            "Maintainer"=>"Scott Fortmann-Roe <scottfr@berkeley.edu>"
          }
        ]

        transaction = -> { described_class.new.persist_package_info(input) }

        expect(transaction).to change { Package.count }.by(1)
        package = Package.first
        expect(package.name).to eq "A3"
        expect(package.depends).to eq "R (>= 2.15.0), xtable, pbapply"
        expect(package.md5_sum).to eq "027ebdd8affce8f0effaecfcd5f5ade2"
        expect(package.maintainer).to eq "Scott Fortmann-Roe <scottfr@berkeley.edu>"
        expect(package.versions.count).to eq 1
        expect(package.versions.first.number).to eq "1.0.0"
      end
    end

    describe "delete_downloaded_packages" do
      it "deletes the download directory used in the process" do
        FileUtils.mkdir("vendor/download/")

        described_class.new.delete_downloaded_packages

        expect(Dir.exist?('vendor/download')).to eq false
      end
    end
  end
end
