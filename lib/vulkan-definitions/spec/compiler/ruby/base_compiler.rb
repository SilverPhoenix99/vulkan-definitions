module Vk
  module Ruby
    module BaseCompiler

      MASK_CONST  = /^\(~((?:0x)?\d+)(U(?:LL)?)\)$/
      FLOAT_CONST = /^\d+(?:\.\d+)?f$/

      attr_accessor :spec
      attr_accessor :io
      attr_accessor :indent

      def initialize(spec, io = StringIO.new, indent = 0)
        @spec, @io, @indent = spec, io, indent
        nil
      end

      protected
        def writeln(str = nil)
          return @io.puts unless str
          str.each_line do |line|
            @io.write(' ' * @indent)
            @io.puts line.chomp
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

        def compile_array(ary, type, print_empty: false)
          return if !print_empty && ary.empty?

          writeln
          writeln "@#{type} = {"
          with_indent { ary.each { |item| writeln "#{item}," } }
          writeln '}.freeze'
        end

        def compile_hash(hsh, type, print_empty: false, adjust: true)
          return if !print_empty && hsh.empty?

          length = adjust ? hsh.map(&:first).map(&:length).max + 1 : nil

          ary = hsh.map do |key, value|
            key = "#{key}:"
            key = key.ljust(length) if length
            "#{key} #{value}"
          end

          compile_array ary, type, print_empty: print_empty
        end

        def build_value(name, value, length = nil)
          name = "#{name}:"
          name = name.ljust(length) if length
          "#{name} #{convert_value(value)}"
        end

        def convert_type(name, type)
          case type
            when Struct
              StructCompiler.new(spec, type).tap(&:compile).io.string.chomp

            when :enum
              EnumCompiler.new(spec, spec.enums[name]).tap(&:compile).io.string.chomp

            when 'char*'
              ':string'

            when /\*$/ # end_with?('*')
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
            size = $2 == 'ULL' ? Fiddle::SIZEOF_LONG_LONG : Fiddle::SIZEOF_LONG
            mask = (1 << 8*size)-1 & ~$1.to_i
            return '0x%x' % mask
          end

          value
        end
    end
  end
end