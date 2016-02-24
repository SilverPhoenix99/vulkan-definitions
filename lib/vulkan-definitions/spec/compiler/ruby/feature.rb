module Vk
  module Ruby
    class FeatureCompiler
      include BaseCompiler

      attr_reader :spec
      attr_reader :feature

      def initialize(spec, feature, io = StringIO.new, ident = 0)
        super(io, ident)
        @spec, @feature = spec, feature
        nil
      end

      def compile
        writeln "module #{feature.name}"

        with_indent do
          writeln 'extend ::Vk::ExtensionModule'
          writeln
          writeln "@version = '#{feature.version}'.freeze"
          compile_constants
          compile_types
          # compile_enums
          # compile_commands
        end

        writeln 'end'
        nil
      end

      private
        def compile_constants
          constants = feature.require.enums.map do |name|
            constant = spec.constants[name]
            build_value(name, constant) if constant
          end.tap(&:compact!)

          compile_collection(constants, :constants)

          nil
        end

        def compile_types
          types = feature.require.types.map do |name|
            type = spec.types[name]
            build_member(name, type) if type
          end.tap(&:compact!)

          compile_collection(types, :types) unless types.empty?
          nil
        end

        def compile_collection(collection, type)
          writeln
          writeln "@#{type} = {"
          with_indent { collection.each { |item| writeln "#{item}," } }
          writeln '}.freeze'
        end
    end
  end
end