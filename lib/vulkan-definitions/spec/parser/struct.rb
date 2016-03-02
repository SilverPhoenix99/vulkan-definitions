module Vk
  class Struct
    using OgaExtensions

    attr_reader :name
    attr_reader :category # :struct or :union
    attr_reader :members

    def initialize(elem)
      @name = elem[:name]
      @category = elem[:category]
      @members = {}
      elem.xpath('member').each { |x| parse_member(x) }
      nil
    end

    private
      def parse_member(elem)
        # TODO: parse indexer
        # e.g.: <member><type>float</type> <name>float32</name>[4]</member>
        name = elem.at_xpath('name')
        @members[name.text] = parse_command_type(elem)
      end

      def parse_command_type(elem)
        type = elem.at_xpath('type')
        type.text + type.next.text.strip
      end

  end
end