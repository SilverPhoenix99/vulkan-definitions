module Vk
  class Extension
    using OgaExtensions

    attr_reader :name
    attr_reader :number
    attr_reader :apis
    attr_reader :require
    # attr_reader :remove

    def initialize(elem)
      @name, @number = elem[:name], elem[:number].to_i
      @apis = elem[:supported].split(/\|/)
      @require = parse_group(:require, elem)
      # @remove  = parse_group(:remove, elem)
      nil
    end

    private
      def parse_group(type, elem)
        Group.new(type, enums: {}).tap do |group|
          elem.xpath("#{type}/type").each { |x| group.types << x[:name] }
          elem.xpath("#{type}/command").each { |x| group.commands << x[:name] }

          elem.xpath("#{type}/enum").each do |x|
            value = x[:value]
            group.enums[x[:name]] = if value
                                      { value: value }
                                    else
                                      { extends: x[:extends], offset: x[:offset], dir: x[:dir] }
                                    end
          end

        end
      end
  end
end