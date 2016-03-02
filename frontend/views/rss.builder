xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title "Princeton Ridge Homeowners Association"
    xml.description "News in your neighborhood."
    xml.link "http://www.princetonridge.com"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link "http://www.princetonridge.com/news/#{post.id}"
        xml.description post.content
        xml.pubDate #{post.uploaddate}
      end
    end
  end
end