require_relative 'pagevars'
require_relative 'notifications'

class ViewData
   @page_style = "bootstrap_v3"
   @page_name = "Default"
   @css_urls = Array.new
   @data_hash = Hash.new
   @notif = ""
   @js_urls = Array.new
   ##
   # Default initializer for ViewData object.
   def initialize(page_style, page_name, page_notify)
       @page_style = page_style
       @page_name = page_name
       @css_urls = Array.new
       @js_urls = Array.new
       @data_hash = Hash.new
       @notif = page_notify
   end
   ##
   # Gets the corresponding UID for current build.
   def get_travis_build_id()
      return Pagevars.set_vars("CIbuild")
   end
   ##
   # Gets all global notifications.
   def get_notifications()
      notifs = Notifications.get_all()
      notifs.push(@notif)
      return notifs
   end
   ##
   # Retrieves list of CSS files needed by curent site style.
   def get_css_urls()
      urls = @css_urls
      if(@page_style.eql? 'bootstrap_v3')
         urls.push('http://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/css/bootstrap.min.css')
         urls.push('//cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/css/toastr.min.css')
      elsif(@page_style.eql? 'metro_v3')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-responsive.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-schemes.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-rtl.min.css')
         urls.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/css/metro-icons.min.css')
      end
      return urls
   end
   ##
   # Adds a CSS file link to the referenced ViewData object.
   def add_css_url(url)
      @css_urls.push(url)
   end
   ##
   # Adds a JavaScript file link to the referenced ViewData object.
   def add_js_url(url)
      @js_urls.push(url)
   end
   ##
   # Retrieves list of JavaScript files required by
   # current site style and functionality.
   def get_js_urls()
      js_urls_temp = @js_urls
      # js_urls_temp.push('http://getbootstrap.com/assets/js/ie10-viewport-bug-workaround.js')
      if(@page_style.eql? 'bootstrap_v3')
         js_urls_temp.push('https://maxcdn.bootstrapcdn.com/bootstrap/3.3.5/js/bootstrap.min.js')
         js_urls_temp.push('https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/js/toastr.min.js')
      elsif(@page_style.eql? 'metro_v3')
         js_urls_temp.push('https://cdn.rawgit.com/olton/Metro-UI-CSS/master/build/js/metro.min.js')
         js_urls_temp.push('/src/js/metro/notif.js')
      end
      return js_urls_temp.reverse
   end
   ##
   # Gets the current page name.
   def get_page_name()
      return @page_name
   end
   ##
   # Adds a variable to the referenced ViewData object
   # hash table.
   def set_var(name, value)
      @data_hash[name] = value
   end
   ##
   # Get a variable from the referenced ViewData object
   # hash table.
   def get_var(name)
      return @data_hash[name]
   end
   ##
   # Gets the currently selected style of the ViewData object.
   def get_style_name()
      if(@page_style == 'bootstrap_v3')
         return 'bootstrap'
      elsif(@page_style == 'metro_v3')
         return 'metro'
      end
   end
end
