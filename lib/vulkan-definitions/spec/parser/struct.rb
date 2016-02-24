module Vk
  class Struct
    using OgaExtensions

    attr_reader :name
    attr_reader :members

    def initialize(elem)
      @name = elem[:name]
      @members = {}
      elem.xpath('member').each { |x| @members[x.at_xpath('name').text] = parse_command_type(x) }
      nil
    end

    private
      def parse_command_type(elem)
        type = elem.at_xpath('type')
        type.text + type.next.text.strip
      end

  end
end