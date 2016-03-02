module Vk
  module Ruby
    class EnumCompiler
      include BaseCompiler

      attr_reader :enum

      def initialize(spec, enum, io = StringIO.new, ident = 0)
        super(spec, io, ident)
        @enum = enum
        nil
      end

      def compile

        values = enum[:values]
        length = values.map(&:first).map(&:length).max + 1

        writeln '{'
        with_indent { enum[:values].each { |name, value| writeln "#{build_value(name, value, length)}," } }
        writeln '}.freeze'
        nil
      end
    end
  end
end