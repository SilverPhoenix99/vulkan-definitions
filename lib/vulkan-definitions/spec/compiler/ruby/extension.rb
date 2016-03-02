module Vk
  module Ruby
    class ExtensionCompiler < FeatureCompiler

      attr_reader :spec
      alias_method :extension, :feature

      def initialize(spec, extension, io = StringIO.new, indent = 0)
        super(spec, extension, io, indent)
        nil
      end

      def version
        nil
      end

      private
        def compile_constants
          constants = requires.enums.map do |name, constant|
            next if constant[:extends]
            value = constant[:value]
            next [name, convert_value(value)] if value

            value = constant[:extends]

            [name, convert_value(constant)] if constant
          end.tap(&:compact!)
          compile_hash(constants, :constants)
          nil
        end
    end
  end
end
