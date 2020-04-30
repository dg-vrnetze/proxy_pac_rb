# frozen_string_literal: true
module ProxyPacRb
  # Mini Racer Runtime
  # little adaptation from execjs gem.
  # All credits go to execjs gem author
  class MiniRacerRuntime < Runtime
    # Context
    class Context < Runtime::Context
      def initialize(_runtime, source = '', _environment = nil)
        source = encode(source)

        self.context = ::MiniRacer::Context.new
        translate { context.eval(source) }
      end

      def include(environment)
        environment.available_methods.each do |name|
          context.attach(name.to_s, environment.method(name))
        end
      end

      def exec(source, options = {})
        source = encode(source)

        # rubocop:disable Security/Eval, Style/EvalWithLocation
        eval "(function(){#{source}})()", options if /\S/ =~ source
        # rubocop:enable Security/Eval, Style/EvalWithLocation
      end

      def eval(source, _options = {})
        source = encode(source)

        return nil unless /\S/ =~ source

        translate { context.eval("(#{source})") }
      end

      def call(properties, *args)
        translate { context.eval("#{properties}.apply(this, #{::JSON.generate(args)})") }
      end

      private

      def strip_functions!(value)
        if Array === value
          value.map! do |v|
            if MiniRacer::JavaScriptFunction === value
              nil
            else
              strip_functions!(v)
            end
          end
        elsif Hash === value
          value.each do |k, v|
            if MiniRacer::JavaScriptFunction === v
              value.delete k
            else
              value[k] = strip_functions!(v)
            end
          end
          value
        elsif MiniRacer::JavaScriptFunction === value
          nil
        else
          value
        end
      end

      def translate
        strip_functions! yield
      rescue MiniRacer::RuntimeError => e
        ex = ProgramError.new e.message
        if backtrace = e.backtrace # rubocop:disable Lint/AssignmentInCondition
          backtrace = backtrace.map do |line|
            if line =~ /JavaScript at/
              line.sub('JavaScript at ', '')
                  .sub('<anonymous>', '(proxypac)')
                  .strip
            else
              line
            end
          end
          ex.set_backtrace backtrace
        end
        raise ex
      rescue MiniRacer::ParseError => e
        ex = RuntimeError.new e.message
        ex.set_backtrace(['(proxypac):1'] + e.backtrace)
        raise ex
      end
    end

    def name
      'mini_racer (V8)'
    end

    def available?
      require 'mini_racer'
      true
    rescue LoadError
      false
    end
  end
end
