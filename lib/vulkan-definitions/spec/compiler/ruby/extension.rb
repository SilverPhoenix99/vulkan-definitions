module Vk
  module Ruby
    class ExtensionCompiler
      include BaseCompiler

      attr_reader :spec
      attr_reader :extension

      def initialize(spec, extension, io = StringIO.new, indent = 0)
        super(io, indent)
        @spec, @extension = spec, extension
      end

      def compile
        writeln "module #{extension.name}"

        with_indent do
          writeln 'extend ::Vk::ExtensionModule'
        end

        writeln 'end'
        nil
      end

    end
  end
end
