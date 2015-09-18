module Supply
  class Setup
    attr_accessor :api

    def initialize
      self.api = Client.new(path_to_key: Supply.config[:key], 
                                 issuer: Supply.config[:issuer])
    end

    def perform_download
      api.begin_edit(package_name: Supply.config[:package_name])

      all = api.listings.each do |listing|
        store_metadata(listing)
      end

      Helper.log.info "Successfully stored metadata in '#{metadata_path}'".green
    end

    def store_metadata(listing)
      containing = File.join(metadata_path, listing.language)
      FileUtils.mkdir_p(containing)

      %w|title short_description full_description video|.each do |key|
        path = File.join(containing, "#{key}.txt")
        Helper.log.info "Writing to #{path}..."
        File.write(path, listing.send(key))
      end
    end

    private

    def metadata_path
      @metadata_path ||= Supply.config[:metadata_path]
      @metadata_path ||= "fastlane/metadata/android" if Helper.fastlane_enabled?
      @metadata_path ||= "metadata" unless Helper.fastlane_enabled?
    end
  end
end