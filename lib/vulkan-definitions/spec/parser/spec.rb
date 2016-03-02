require 'facets/string/snakecase'
require 'oga'

module OgaExtensions
  refine Oga::XML::Element do
    def [](attr)
      a = attribute(attr)
      a && a.value
    end
  end
end

module Vk
  class Spec
    using OgaExtensions

    attr_reader :version
    attr_reader :types
    attr_reader :callbacks
    attr_reader :constants
    attr_reader :enums
    attr_reader :commands
    attr_reader :features
    attr_reader :extensions

    def initialize(path)
      @types = {}
      @callbacks = {}
      @constants = {}
      @enums = {}
      @commands = {}
      doc = Oga.parse_xml(File.read(path))
      parse doc
      nil
    end

    private
      def parse(doc)
        parse_version doc
        parse_enums doc
        parse_basic_types doc
        parse_handle_types doc
        parse_enum_types doc
        parse_struct_types doc
        parse_callbacks doc
        parse_commands doc
        parse_features doc
        parse_extensions doc
        nil
      end

      def parse_version(doc)
        version = doc.at_xpath('//types/type[name="VK_API_VERSION"]/text()[last()]').text
        @version = /\((\d+),\s*(\d+),\s*(\d+)\)/.match(version).captures
      end

      def parse_enums(doc)
        doc.xpath('//enums').each do |x|
          if x[:type]
            parse_enum x
          else
            x.xpath('enum').each { |e| @constants[e[:name]] = e[:value] }
          end
        end
        nil
      end

      def parse_enum(elem)
        prefix = elem[:expand]
        if prefix
          prefix += '_' unless prefix.end_with?('_')
        else
          names = elem.xpath('enum/@name').map(&:value)

          if names.length == 1
            names << elem[:name].snakecase.upcase
          end

          len = names.map(&:length).min
          len = names.map! { |n| n[0...len] }
                    .map { |n| n.each_char.to_a }
                    .transpose.map!(&:uniq).map!(&:length).index { |l| l > 1 }
          prefix = names[0][0...len]
        end

        @enums[elem[:name]] = { type: elem[:type].to_sym, prefix: prefix, values: values = {} }

        elem.xpath('enum')
            .map { |e| [ e[:name][prefix.length..-1], e[:bitpos], e[:value] ] }
            .each { |name, bitpos, value| values[name] = bitpos ? '0x%08x' % (1 << bitpos.to_i) : value }

        nil
      end

      def parse_basic_types(doc)
        doc.xpath('//types/type[@category="basetype" or @category="bitmask"]').each do |x|
          @types[x.at_xpath('name').text] = x.at_xpath('type').text
        end
        nil
      end

      # :non_dispatchable_handle is a special case
      #   on 64 bit architectures, it's a pointer
      #   on 32 bit architectures, it's a uint64_t
      def parse_handle_types(doc)
        doc.xpath('//types/type[@category="handle" and type="VK_DEFINE_HANDLE"]/name/text()').each do |x|
          @types[x.text] = :pointer
        end

        doc.xpath('//types/type[@category="handle" and type="VK_DEFINE_NON_DISPATCHABLE_HANDLE"]/name/text()').each do |x|
          @types[x.text] = :non_dispatchable_handle
        end
        nil
      end

      def parse_enum_types(doc)
        doc.xpath('//types/type[@category="enum"]').each { |x| @types[x[:name]] = :enum }
        nil
      end

      def parse_struct_types(doc)
        doc.xpath('//types/type[@category="struct" or @category="union"]').each { |x| @types[x[:name]] = Struct.new(x) }
        nil
      end

      def parse_callbacks(doc)
        doc.xpath('//types/type[@category="funcpointer"]').each do |x|
          ret = x.children.first.text.match(/typedef\s+([^\(\s]+)\s*\(.*/)[1]
          params = x.xpath('type').map { |t| [t.text, *t.next.text.gsub('const', '').split][0..-2].join }
          @callbacks[x.at_xpath('name').text] = [ret, params]
        end
        nil
      end

      def parse_commands(doc)
        doc.xpath('//commands/command').each do |x|
          proto = x.at_xpath('proto')
          name = proto.at_xpath('name').text
          ret = parse_command_type(proto)
          params = x.xpath('param').map { |x| parse_command_type(x) }
          @commands[name] = [ret, params]
        end
        nil
      end

      def parse_command_type(elem)
        type = elem.at_xpath('type')
        type.text + type.next.text.strip
      end

      def parse_features(doc)
        @features = doc.xpath('//feature').map { |x| Feature.new(x) }
        nil
      end

      def parse_extensions(doc)
        @extensions = doc.xpath('//extensions/extension[not(@supported="disabled")]').map { |x| Extension.new(x) }
        nil
      end
  end
end