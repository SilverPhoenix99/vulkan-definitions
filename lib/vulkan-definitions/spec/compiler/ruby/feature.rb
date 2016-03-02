module Vk
  module Ruby
    class FeatureCompiler
      include BaseCompiler

      attr_reader :spec
      attr_reader :feature

      def initialize(spec, feature, io = StringIO.new, ident = 0)
        super(spec, io, ident)
        @feature = feature
        nil
      end

      def name
        feature.name
      end

      def version
        feature.version
      end

      def requires
        feature.requires
      end

      def compile
        writeln "module #{name}"

        with_indent do
          writeln 'extend ::Vk::ExtensionModule'

          if version
            writeln
            writeln "@version = '#{version}'.freeze"
          end

          compile_constants
          compile_types
          compile_enums
          compile_structs
          compile_commands
        end

        writeln 'end'
        nil
      end

      private
        def compile_constants
          constants = requires.enums.map do |name|
            constant = spec.constants[name]
            [name, convert_value(constant)] if constant
          end.tap(&:compact!)
          compile_hash(constants, :constants)
          nil
        end

        def compile_types
          types = mapped_types.reject { |_, type| type == :enum || type.is_a?(Struct) }
            .map { |name, type| [name, convert_type(name, type)] }
          compile_hash types, :types
          nil
        end

        def compile_enums
          enums = mapped_types.select { |_, type| type == :enum }
            .map { |name, type| [name, convert_type(name, type)] }
          compile_hash enums, :enums
          nil
        end

        def compile_structs
          structs = mapped_types.select { |_, type| type.is_a?(Struct) }
            .map { |name, type| [name, convert_type(name, type)] }
          compile_hash structs, :structs, adjust: false
          nil
        end

        def compile_commands
          commands = requires.commands.map do |name|
            ret, params = spec.commands[name]
            params = [ret] + params
            params = params.map { |type| convert_type(nil, type) }.join(', ')
            [name, "[ #{params} ].freeze"]
          end

          compile_hash(commands, :commands)
          nil
        end

        def mapped_types
          @mapped_types ||= requires.types.map do |name|
            type = spec.types[name]
            [name, type] if type
          end.tap(&:compact!)
        end
    end
  end
end