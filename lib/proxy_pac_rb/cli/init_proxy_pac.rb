# frozen_string_literal: true
module ProxyPacRb
  module Cli
    # Find proxy for url
    class InitProxyPac < Thor::Group
      include Shared
      include Thor::Actions

      class_option :proxy_pac, type: :string, desc: 'Proxy.pac-file', aliases: '-p', default: 'proxy.pac'
      class_option :test, enum: ['rspec'], desc: 'Test-framework - supported: rspec', aliases: '-t'
      class_option :build, enum: ['middleman'], desc: 'Builder-framework - supported: middleman', aliases: '-b'

      def pre_init
        enable_debug_mode

        @destination_directory = Dir.getwd
      end

      def add_sources
        source_paths << File.expand_path('../../../../templates', __FILE__)
      end

      def create_default_files
        directory 'default/', './'
      end

      def create_test_framework_files
        return unless options[:test] == 'rspec'

        directory 'test_framework/rspec/', 'spec'

        append_file 'Gemfile', <<~EOS
        group :development, :test do
          gem 'aruba', require: false

          gem 'pry'
          gem 'pry-byebug'
          gem 'pry-stack_explorer'
          gem 'pry-doc'

          gem 'rspec', '~>3.0'
          gem 'fuubar'
        end
        EOS

        append_file 'Rakefile', <<~EOS
        desc 'Run tests'
        task test: 'test:local'

        namespace :test do
          desc 'Run all tests'
          task :all do
            sh 'bundle exec rspec'
          end

          desc 'Run local tests'
          task :local do
            sh 'bundle exec rspec --tag ~remote'
          end

          desc 'Run remote tests'
          task :remote do
            sh 'bundle exec rspec --tag remote'
          end
        end
        EOS
      end

      def create_build_files
        return unless options[:build] == 'middleman'

        directory 'build/middleman', './'

        append_file 'Gemfile', <<~EOS
        gem 'middleman', '~>3.3.10'
        gem 'therubyracer'
        EOS

        append_file 'Rakefile', <<~EOS
        desc 'Build site'
        task :build do
          sh 'bundle exec middleman build --verbose'
        end

        desc 'Serve site'
        task :serve do
          sh 'bundle exec middleman server --verbose'
        end
        EOS

        @destination_directory = File.join(@destination_directory, 'source')
      end

      def create_proxy_pac
        template 'new_proxy_pac.pac.erb', File.join(@destination_directory, options[:proxy_pac])
      end
    end
  end
end
