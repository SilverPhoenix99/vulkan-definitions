module Vk
  module Ruby
    module BaseCompiler

      MASK_CONST  = /^\(~((?:0x)?\d+)(U(?:LL)?)\)$/
      FLOAT_CONST = /^\d+(?:\.\d+)?f$/

      attr_accessor :io
      attr_accessor :indent

      def initialize(io = StringIO.new, indent = 0)
        @io, @indent = io, indent
        nil
      end

      protected
        def writeln(str = nil)
          return @io.puts unless str
          str.each_line do |line|
            @io.write(' ' * @indent)
            @io.puts line
          end
          nil
        end

        def with_indent(increment = 2)
          return unless block_given?
          @indent += increment
          yield
          @indent -= increment
          nil
        end

        def build_member(name, type)
          "#{name}: #{convert_type(type)}"
        end

        def build_value(name, value)
          "#{name}: #{convert_value(value)}"
        end

        def convert_type(type)
          case type
            when Struct
              StructCompiler.new(type).tap(&:compile).io.string.chomp

            when 'char*'
              ':string'

            when 'void*'
              ':pointer'

            else
              ":#{type}"
          end
        end

        def convert_value(value)
          return "'#{value[1..-2]}'.freeze" if value.start_with?('"')

          return value[0..-2] if value =~ FLOAT_CONST

          if value =~ MASK_CONST
            require 'fiddle' unless defined? Fiddle
            size  = $2 == 'ULL' ? Fiddle::SIZEOF_LONG_LONG : Fiddle::SIZEOF_LONG
            mask = (1 << 8*size)-1 & ~$1.to_i
            return '0x%x' % mask
          end

          value
        end
    end
  end
end