module Vk
  module Ruby
    class StructCompiler
      include BaseCompiler

      attr_reader :struct

      def initialize(struct, io = StringIO.new, ident = 0)
        super(io, ident)
        @struct = struct
        nil
      end

      def compile
        writeln '{'
        with_indent { struct.members.each { |name, type| writeln "#{build_member(name, type)}," } }
        writeln '}.freeze'
        nil
      end
    end
  end
end