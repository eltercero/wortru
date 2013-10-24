class Wortru
  
  class Author
    include ROXML
    xml_reader :author_login, from: 'wp:author_login'
    xml_reader :author_email, from: 'wp:author_email'
    xml_reader :author_display_name, from: 'wp:author_display_name', cdata: true
    xml_reader :author_first_name, from: 'wp:author_first_name', cdata: true
    xml_reader :author_last_name, from: 'wp:author_last_name', cdata: true
    
    def name
      author_display_name.presence || author_login.presence
    end
    
  end

  class Category
    include ROXML
    xml_reader :domain, from: :attr
    xml_reader :nicename, from: :attr
    xml_reader :name, from: :content

    def category?
      domain == 'category'
    end

    def tag?
      domain == 'post_tag'  
    end
  end

  class PostMeta
    include ROXML
    xml_reader :meta_key, from: 'wp:meta_key'
    xml_reader :meta_value, from: 'wp:meta_value', cdata: true
  end

  class Item
    include ROXML

    xml_reader :title, from: 'title'
    xml_reader :creator, from: 'dc:creator'
    xml_reader :nicetitle, from: 'wp:post_name'
    xml_reader :pub_date, from: 'pubDate'
    xml_reader :status, from: 'wp:status'
    xml_reader :content, from: 'content:encoded', cdata: true
    xml_reader :excerpt, from: 'excerpt:encoded', cdata: true
    xml_reader :post_type, from: 'wp:post_type'
    xml_reader :post_date, from: 'wp:post_date'
    xml_reader :categories, from: 'category', as: [Category]
    xml_reader :post_metas, from: 'wp:postmeta', as: [PostMeta]

    def published?
      status == 'publish'
    end

    def post?
      post_type == 'post'
    end

    def true_categories
      categories.select(&:category?)
    end

    def tags
      categories.select(&:tag?)
    end    

    %w(post_shop_reference post_shop_type post_image post_desc).each do |name|
      send :define_method, "meta_#{name}" do
        post_meta = post_metas.find{|pm| pm.meta_key == name}
        post_meta.meta_value if post_meta      
      end
    end

    def summary
      meta_post_desc.presence || excerpt.presence
    end

  end

  def initialize(file_path)
    raise 'No se ha introducido ninguna ruta de archivo' unless file_path

    f = File.open(file_path)
    @reader = Nokogiri::XML::Reader(f)
  end

  def each(&block)
    @reader.each do |node|
      if @reader.node_type == 1 && @reader.name == 'item'
        str = @reader.outer_xml
        yield Item.from_xml(str)
      elsif @reader.node_type == 1 && @reader.name == 'wp:author'
        str = @reader.outer_xml
        yield Author.from_xml(str)
      end
    end
  end

end