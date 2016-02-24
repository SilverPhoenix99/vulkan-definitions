require 'fileutils'

module Vk
  module Ruby
    class SpecCompiler
      def self.compile(spec, path)
        new(spec, path).compile
      end

      attr_reader :spec
      attr_reader :path

      def initialize(spec, path)
        @spec, @path = spec, path
        nil
      end

      def compile
        compile_extensions 'Feature'
        compile_extensions 'Extension'
        nil
      end

      private
        def compile_extensions(type)
          compiler_class = ::Vk::Ruby.const_get("#{type}Compiler")
          type = "#{type.downcase}s"
          extensions = spec.instance_variable_get("@#{type}")
          path = File.expand_path(type, self.path)

          FileUtils.rm_rf path
          FileUtils.mkdir_p path
          extensions.each do |extension|
            compiler_class.new(spec, extension).tap do |compiler|
              compiler.compile
              File.write File.expand_path("#{extension.name}.rb", path), compiler.io.string
            end
          end

          nil
        end
    end
  end
end