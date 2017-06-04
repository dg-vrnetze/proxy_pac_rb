# encoding: utf-8
# frozen_string_literal: true
module ProxyPacRb
  # Compress javascript files
  class ProxyPacCompressor
    private

    attr_reader :options

    public

    def initialize(options: {})
      opts = {
        output: {
          # ascii_only: true,        # Escape non-ASCII characters
          # comments: :copyright,    # Preserve comments (:all, :jsdoc, :copyright, :none, Regexp (see below))
          # inline_script: false,    # Escape occurrences of </script in strings
          # quote_keys: false,       # Quote keys in object literals
          # max_line_len: 32 * 1024, # Maximum line length in minified code
          max_line_len: 1024, # Maximum line length in minified code
          # bracketize: true,       # Bracketize if, for, do, while or with statements, even if their body is a single statement
          # semicolons: true,        # Separate statements with semicolons
          # preserve_line: false,    # Preserve line numbers in outputs
          # beautify: false,         # Beautify output
          beautify: true, # Beautify output
          # indent_level: 4,         # Indent level in spaces
          # indent_start: 0,         # Starting indent level
          # space_colon: false,      # Insert space before colons (only with beautifier)
          # width: 80,               # Specify line width when beautifier is used (only with beautifier)
          # preamble: nil            # Preamble for the generated JS file. Can be used to insert any code or comment.
        },
        mangle: false,
        compress: {
          # sequences: false,      # Allow statements to be joined by commas
          # properties: true,     # Rewrite property access using the dot notation
          # dead_code: true,      # Remove unreachable code
          # drop_debugger: true,  # Remove debugger; statements
          # unsafe: false,        # Apply "unsafe" transformations
          # conditionals: true,   # Optimize for if-s and conditional expressions
          # comparisons: true,    # Apply binary node optimizations for comparisons
          # evaluate: true,       # Attempt to evaluate constant expressions
          # booleans: true,       # Various optimizations to boolean contexts
          # loops: true,          # Optimize loops when condition can be statically determined
          # unused: true,         # Drop unreferenced functions and variables
          # hoist_funs: true,     # Hoist function declarations
          # hoist_vars: false,    # Hoist var declarations
          # if_return: true,      # Optimizations for if/return and if/continue
          # join_vars: true,      # Join consecutive var statements
          join_vars: false, # Join consecutive var statements
          # cascade: true,        # Cascade sequences
          # negate_iife: true,    # Negate immediately invoked function expressions to avoid extra parens
          # pure_getters: false,  # Assume that object property access does not have any side-effects
          # pure_funcs: nil,      # List of functions without side-effects. Can safely discard function calls when the result value is not used
          # drop_console: false,  # Drop calls to console.* functions
          # angular: false,       # Process @ngInject annotations
          keep_fargs: true # Preserve unused function arguments
          # keep_fnames: true     # Preserve function names
        }
      }.deep_merge options

      @options = opts
    end

    def compress(proxy_pac)
      proxy_pac.content = Uglifier.new(options).compile(proxy_pac.content)
    end
  end
end
