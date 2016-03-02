module Vk
  module Ruby
    class StructCompiler
      include BaseCompiler

      attr_reader :struct

      def initialize(spec, struct, io = StringIO.new, ident = 0)
        super(spec, io, ident)
        @struct = struct
        nil
      end

      def compile

        length = struct.members.map(&:first).map(&:length).max + 1

        writeln '{'
        with_indent { struct.members.each { |name, type| writeln "#{build_member(name, type, length)}," } }
        writeln '}.freeze'
        nil
      end

      private
        def build_member(name, type, length)
          name = "#{name}:".ljust(length)
          "#{name} #{convert_type(name, type)}"
        end
    end
  end
end