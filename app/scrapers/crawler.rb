require 'mechanize'

class Crawler

    def initialize()
        @agent = Mechanize.new
        @agent.user_agent = "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:47.0) Gecko/20100101 Firefox/47.0"
    end

    def get_page(url)
        begin 
          retries ||= 0
          return @agent.get(url)
        rescue => e
          puts "error.. retrying after a min"
          sleep 3
          if retries <= 1
            retries += 1
            retry
          end
        end
    end

    def get_attribute(node, attr)
        node[attr] unless node[attr].nil?
    end

    def get_products(doc, tag)
        doc.search(tag)
    end

    def get_content(tag, doc, options = {})
        content = doc.search(tag).first
        unless content.nil?
            content = content[options[:attrib]] if options[:attrib]
            content = yield(content) if block_given?
        end
        content
    end

    def get_content_proc(tag, doc, &block)
        content = doc.search(tag).first
        binding.pry
        unless content.nil?
            # content = content[options[:attrib]] if options[:attrib]
            content = yield(content) 
        end
        content
    end

    def get_tag_content(tag, doc, options = {})
        unless doc.search(tag).first.nil?
            if options[:method] && options[:attrib]
            doc.search(tag).first.text[options[:attrib]].strip()
            elsif options[:method]
            doc.search(tag).first.text.strip()
            elsif options[:attrib]
            doc.search(tag).first[options[:attrib]]
            else
            doc.search(tag).first
            end
        end
    end


end