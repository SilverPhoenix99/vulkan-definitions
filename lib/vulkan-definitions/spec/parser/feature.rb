module Vk
  class Feature
    using OgaExtensions

    attr_reader :api
    attr_reader :name
    attr_reader :version
    attr_reader :require
    # attr_reader :remove

    def initialize(elem)
      @api, @name, @version = elem[:api], elem[:name], elem[:number]
      @require = parse_group(:require, elem)
      # @remove  = parse_group(:remove, elem)
      nil
    end

    private
      def parse_group(type, elem)
        Group.new(type).tap do |group|
          elem.xpath("#{type}/type").each { |x| group.types << x[:name] }
          elem.xpath("#{type}/enum").each { |x| group.enums << x[:name] }
          elem.xpath("#{type}/command").each { |x| group.commands << x[:name] }
        end
      end
  end
end