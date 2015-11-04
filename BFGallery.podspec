Pod::Spec.new do |s|
 
  s.name         = "BFGallery"
  s.version      = "0.1.1"
  s.summary      = "Objective C Gallery."
  s.description  = <<-DESC
    Objective C Gallery.
  DESC
  s.requires_arc = true
  s.subspec 'json' do |sp|
    sp.source_files = 'BFGallery/JSON/*.{h,m}'
    sp.requires_arc = false
  end
 
  s.homepage     = "https://github.com/darioalessandro/BlackFireGallery"
  s.license      = { :type => "Apache2", :file => "License.txt" }
  s.author       = { "Dario Lencina" => "darioalessandrolencina@gmail.com" }
  s.social_media_url   = "https://twitter.com/darioalessandro"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/darioalessandro/BlackFireGallery.git", :tag => s.version }
  s.source_files  = "BFGallery/BFGalleryLib/*"

 
end
