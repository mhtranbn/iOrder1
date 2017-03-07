export GEM_HOME=~/.gems
export PATH=$PATH:~/.gems/bin
sudo gem install -n /usr/local/bin cocoapods
pod init
open -a Xcode Podfile
pod install
