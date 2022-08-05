Pod::Spec.new do |s|
    s.name             = 'TokenTextView'
    s.version          = ENV['TAG_VERSION'] || '1.0.0' # falls back to 1.0.0
    s.summary          = "A UITextView class for editing & managing tokenized text."
    s.homepage         = 'https://github.com/open-turo/token-text-view'
    s.license          = { :type => 'MIT', :file => 'LICENSE.md' }
    s.author           = { 'Turo iOS' => 'eng-ios@turo.com' }
    s.source           = { :git => 'https://github.com/open-turo/token-text-view.git', :tag => s.version.to_s }
    s.platform         = :ios, "14.0"
    s.ios.deployment_target = '14.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/TokenTextView/**/*.{swift}'
  end
