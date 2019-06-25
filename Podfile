# Uncomment the next line to define a global platform for your project
platform :ios, '9.1'

target 'TestDome' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  # use_frameworks!

  # Pods for ZHChatBar
    pod 'AFNetworking','~>3.1.0'
    post_install do |installer|
        installer.pods_project.targets.each do |target|
            target.build_configurations.each do |config|
                config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] ='9.1'
            end
        end
    end
    
end

