require 'roxml'
require 'pry'

class Wortru
	
	class Category
		include ROXML
		xml_reader :domain, from: :attr
		xml_reader :nicename, from: :attr
		xml_reader :name, from: :content

		def category?
			domain == 'category'
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
    xml_reader :pub_date, from: 'pubDate'
    xml_reader :status, from: 'wp:status'
    xml_reader :content, from: 'content:encoded', cdata: true
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

    def meta_post_shop_reference
    	post_meta = post_metas.find{|pm| pm.meta_key == 'post_shop_reference'}
    	post_meta.meta_value if post_meta
    end

    def meta_post_shop_type
    	post_meta = post_metas.find{|pm| pm.meta_key == 'post_shop_type7'}
    	post_meta.meta_value if post_meta
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
      end
    end
  end


end