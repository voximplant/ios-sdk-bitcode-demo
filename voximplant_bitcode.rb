class Voximplant
  require 'fileutils'
  require 'colorize'
  require 'net/http'
  require 'uri'
  require 'zip'
  require 'progressbar'

  $voximplant_verified = false

  private

  def self.create_directories(pods_path)
    sdk_path = "#{pods_path}/VoxImplantSDK"
    webrtc_path = "#{pods_path}/VoxImplantWebRTC"

    unless FileTest.exists?(sdk_path)
      puts "Creating #{sdk_path} directory...".yellow
      FileUtils.mkdir_p(sdk_path)
    end

    unless FileTest.exists?(webrtc_path)
      puts "Creating #{webrtc_path} directory...".yellow
      FileUtils.mkdir_p(webrtc_path)
    end
  end

  private

  def self.download(title, url, out)
    url_base = url.split('/')[2]
    url_path = '/' + url.split('/')[3..-1].join('/')
    counter = 0

    Net::HTTP.start(url_base) do |http|
      response = http.request_head(URI.escape(url_path))
      unless response.code == 200
        raise "Failed to download #{title}!".red
      end
      pbar = ProgressBar.create(:title => title, :total => response['content-length'].to_i)
      File.open(out, 'w') {|f|
        http.get(URI.escape(url_path)) do |str|
          f.write str
          counter += str.length
          pbar.progress = counter
        end
      }
      pbar.finish
    end
  end

  private

  def self.extract_zip(file, destination)
    if FileTest.exist?(destination)
      FileUtils.rm_rf(destination)
    end
    FileUtils.mkdir_p(destination)

    Zip::File.open(file) do |zip_file|
      zip_file.each do |f|
        fpath = File.join(destination, f.name)
        zip_file.extract(f, fpath) unless File.exist?(fpath)
      end
    end
  end

  private

  def self.check_sdk_version(pods_path, sdk_version)
    sdk_path = "#{pods_path}/VoxImplantSDK"

    begin
      spec = Pod::Specification.from_file("#{sdk_path}/VoxImplantSDK.podspec")
      unless spec.version.to_s == sdk_version.to_s
        puts "Version mismatch: found #{spec.version}, required #{sdk_version}".red
        raise "Version mismatch"
      end

      webrtc = spec.dependencies.find {|dep| dep.name == "VoxImplantWebRTC"}
      webrtc_version = Pod::Requirement.parse(webrtc.requirement)[1]

      puts "Voximplant iOS SDK v#{sdk_version} ... OK".green
      return webrtc_version
    rescue
      puts "Downloading Voximplant iOS SDK v#{sdk_version}".yellow

      url = "https://s3.eu-central-1.amazonaws.com/voximplant-releases/ios-sdk/#{sdk_version}/VoxImplant_bitcode.zip"
      zip = "#{pods_path}/VoxImplantSDK.zip"
      download "Voximpant iOS SDK", url, zip

      puts "Unpacking".yellow
      extract_zip zip, sdk_path

      return check_sdk_version pods_path, sdk_version
    end
  end

  private

  def self.check_webrtc_version(pods_path, webrtc_version)
    webrtc_path = "#{pods_path}/VoxImplantWebRTC"

    begin
      spec = Pod::Specification.from_file("#{webrtc_path}/VoxImplantWebRTC.podspec")
      if spec.version != webrtc_version
        puts "Version mismatch: found #{spec.version}, required #{webrtc_version}".red
        raise "Version mismatch"
      end
    rescue
      puts "Downloading VoximplantWebRTC v#{webrtc_version}".yellow

      url = "https://s3.eu-central-1.amazonaws.com/voximplant-releases/ios-webrtc/#{webrtc_version}/VoxImplantWebRTC_bitcode.zip"
      zip = "#{pods_path}/VoxImplantWebRTC.zip"
      download "Voximpant WebRTC", url, zip

      puts "Unpacking".yellow
      extract_zip zip, webrtc_path
    end
    puts "Voximplant WebRTC  v#{webrtc_version} ... OK".green
  end

  def self.prepare_voximplant_pods(sdk_version)
    unless $voximplant_verified
      puts "Verifying Voximplant Pods"
      pods_path = "./Pods"

      create_directories pods_path
      webrtc_version = check_sdk_version pods_path, sdk_version
      check_webrtc_version pods_path, webrtc_version

      $voximplant_verified = true
    end
  end
end