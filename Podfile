# Uncomment this line to define a global platform for your project
 platform :ios, '9.0'
# Uncomment this line if you're using Swift
 use_frameworks!

target 'iOrder' do

pod "SwiftString"
pod 'Google/SignIn'
pod 'Alamofire', '~> 3.4'
pod 'SegueManager'
pod 'SwiftyJSON', :git => 'https://github.com/SwiftyJSON/SwiftyJSON.git'
pod 'AlamofireImage', '~> 2.0'
pod 'ReachabilitySwift', :git => 'https://github.com/ashleymills/Reachability.swift'
pod 'Kingfisher', '~> 2.4'
pod 'ASHorizontalScrollView', '~> 1.2'
pod "AKPickerView-Swift"
pod 'Cosmos', '~> 1.2'
pod 'BRYXBanner'
pod 'Money'
#pod 'Format'
#pod 'NVActivityIndicatorView'
#pod 'Stripe'
#pod 'Braintree'
#pod 'UIColor_Hex_Swift'
#pod 'Localize-Swift', '~> 1.1'
#pod 'ALCameraViewController'
#pod "TextFieldEffects"
#pod 'AlamoImage'
#pod 'TNImageSliderViewController'
#pod "PubNub"
#pod 'SlideMenuControllerSwift'
#pod "QRCode"
#pod 'SwiftQRCode'
#pod "SMSwipeableTabView"
#pod 'GradientView'
#pod 'RAMAnimatedTabBarController'


end

target 'iOrderTests' do

end

target 'iOrderUITests' do

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
end
