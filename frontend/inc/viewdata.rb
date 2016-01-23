require_relative 'pagevars'
require_relative 'notifications'

class ViewData
   @page_style = "bootstrap_v3"
   @page_name = "Default"
   @css_urls = Array.new
   @data_hash = Hash.new
   def initialize(page_style, page_name)
       @page_style = page_style
       @page_name = page_name
       @css_urls = Array.new
       @data_hash = Hash.new
   end
   def get_travis_build_id()
      return Pagevars.set_vars("CIbuild")
   end
   def get_notifications()
      return Notifications.get_all()
   end
   def get_css_urls()
      urls = @css_urls
      if(@page_style == 'bootstrap_v3')
         urls.push('http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css')
         urls.push('//cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/css/toastr.min.css')
      elsif(@page_style == 'metro_v3')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-responsive.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-schemes.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-rtl.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-icons.min.css')
      end
      return urls.reverse
   end
   def add_css_url(url)
      @css_urls.push(url)
   end
   def get_js_urls()
      js_urls = Array.new
      js_urls.push('https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js')
      js_urls.push('http://ajax.googleapis.com/ajax/libs/angularjs/1.3.14/angular.min.js')
      js_urls.push('http://getbootstrap.com/assets/js/ie10-viewport-bug-workaround.js')
      if(@page_style == 'bootstrap_v3')
         js_urls.push('http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js')
         js_urls.push('//cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/js/toastr.min.js')
      elsif(@page_style == 'metro_v3')
         js_urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/js/metro.min.js')
         js_urls.push('/src/js/metro/notif.js')
      end
      return js_urls.reverse
   end
   def get_page_name()
      return @page_name
   end
   def set_var(name, value)
      @data_hash[name] = value
   end
   def get_var(name)
      return @data_hash[name]
   end
   def get_style_name()
      if(@page_style == 'bootstrap_v3')
         return 'bootstrap'
      elsif(@page_style == 'metro_v3')
         return 'metro'
      end
   end
end