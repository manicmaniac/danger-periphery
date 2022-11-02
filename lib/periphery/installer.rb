# frozen_string_literal: true

require 'fileutils'
require 'net/http'
require 'open-uri'
require 'zip'

module Periphery
  # Downloads Periphery binary executable and install it to the specified path.
  class Installer
    def initialize(version_spec)
      @version_spec = version_spec
    end

    def install(dest_path, force: false)
      URI.parse(download_url).open do |src|
        entry = Zip::File.open_buffer(src).get_entry('periphery')
        entry.restore_permissions = true
        FileUtils.rm_f(dest_path) if force
        entry.extract(dest_path)
      end
    end

    def version
      @version ||= @version_spec == :latest ? fetch_latest_version : @version_spec
    end

    private

    def download_url
      "https://github.com/peripheryapp/periphery/releases/download/#{version}/periphery-v#{version}.zip"
    end

    def fetch_latest_version
      Net::HTTP.start('github.com', port: 443, use_ssl: true) do |http|
        response = http.head('/peripheryapp/periphery/releases/latest')
        URI.parse(response['location']).path.split('/').last
      end
    end
  end
end
