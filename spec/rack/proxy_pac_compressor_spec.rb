# frozen_string_literal: true
require 'spec_helper'
require 'proxy_pac_rb/rack/proxy_pac_compressor'
require 'rack/lint'

RSpec.describe ProxyPacRb::Rack::ProxyPacCompressor, type: :rack_test do
  let(:compressed_content) { %(function FindProxyForURL(url, host) {\n    return \"DIRECT\";\n}) }

  before(:each) { get '/' }
  subject(:body) { last_response.body }

  context 'when valid proxy pac is given' do
    let(:app) do
      a = Class.new(Sinatra::Base) do
        before do
          content_type 'application/x-ns-proxy-autoconfig'
        end

        get '/' do
          <<~EOS.chomp
          // comment
          function FindProxyForURL(url, host) {
            return "DIRECT";
          }
          EOS
        end
      end

      a.use Rack::Lint
      a.use ProxyPacRb::Rack::ProxyPacCompressor
      a.use Rack::Lint

      a.new
    end

    it { expect(body).to eq compressed_content }
  end

  context 'when invalid proxy pac is given' do
    let(:compressed_content) { %{Unexpected token: string (!$ )} }

    let(:app) do
      a = Class.new(Sinatra::Base) do
        before do
          content_type 'application/x-ns-proxy-autoconfig'
        end

        get '/' do
          <<~EOS.chomp
          function FindProxyForURL(url, host) {
            return $"!$ "DIRECT";
          }
          EOS
        end
      end

      a.use Rack::Lint
      a.use ProxyPacRb::Rack::ProxyPacCompressor
      a.use Rack::Lint

      a.new
    end

    it { expect(body).to include compressed_content }
  end
end
