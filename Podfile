platform :ios, '8.0'
use_frameworks!
inhibit_all_warnings!

def voximplant
  sdk_version = '2.20.0'

  require_relative 'voximplant_bitcode'
  Voximplant::prepare_voximplant_pods sdk_version

  pod 'VoxImplantSDK', :path => "./Pods/VoxImplantSDK"
  pod 'VoxImplantWebRTC', :path => "./Pods/VoxImplantWebRTC"
end

target 'Example ObjC' do
  voximplant
end

target 'Example Swift' do
  voximplant
end
