# Proxy Pac Rb

[![Build Status](https://travis-ci.org/fedux-org/proxy_pac_rb.png?branch=master)](https://travis-ci.org/fedux-org/proxy_pac_rb)
[![Code Climate](https://codeclimate.com/github/fedux-org/proxy_pac_rb.png)](https://codeclimate.com/github/fedux-org/proxy_pac_rb)
[![Coverage Status](https://coveralls.io/repos/fedux-org/proxy_pac_rb/badge.png?branch=master)](https://coveralls.io/r/fedux-org/proxy_pac_rb?branch=master)
[![Gem Version](https://badge.fury.io/rb/proxy_pac_rb.png)](http://badge.fury.io/rb/proxy_pac_rb)
[![Downloads](http://img.shields.io/gem/dt/proxy_pac_rb.svg?style=flat)](http://rubygems.org/gems/proxy_pac_rb)


`proxy_pac_rb` is a gem to compress, lint and parse [proxy auto-config](http://en.wikipedia.org/wiki/Proxy_auto-config
) files. It comes with a cli program, some rack middlewares and can be used from within ruby scripts as well
. `proxy_pac_rb` uses a JavaScript runtime to evaulate a proxy auto-config file the same way a browser does to determine what proxy (if any at all) should a program use to connect to a server. You must install on of the supported JavaScript runtimes: [miniracer](https://github.com/rubyjs/mini_racer), [therubyracer](https://rubygems.org/gems/therubyracer) or [therubyrhino](https://rubygems.org/gems/therubyrhino/).

Big thanks to [sstephenson](https://github.com/sstephenson)'s [execjs](https://github.com/sstephenson/execjs) for the
runtime wrapper code and to
[samuelkadolph](https://github.com/samuelkadolph/ruby-pac)'s
[ruby-pac](https://github.com/samuelkadolph/ruby-pac) for the foundation of this gem.

## Installing

Add this line to your application's Gemfile:

    gem 'proxy_pac_rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install proxy_pac_rb


## Requirements

After installing the `proxy_pac_rb` gem you must install a JavaScript runtime. Compatible runtimes include:

* [therubyracer](https://rubygems.org/gems/therubyracer) Google V8 embedded within Ruby
* [therubyrhino](https://rubygems.org/gems/therubyrhino/) Mozilla Rhino embedded within JRuby
* [miniracer](https://github.com/rubyjs/mini_racer) Minimal, modern embedded V8 for Ruby

## Usage

### Command Line

#### Find proxy for url

*Arguments*

* `-p|--proxy-pac FILE`: Path to proxy pac file
* `-t|--time YYYY-MM-DD HH:MM:SS`: Time to use in proxy.pac
* `-c|--client-ip x.x.x.x`: Client-IP to use in proxy.pac
* `-h|--help`: Show help

*Use*

```bash
# Download via curl and parse pac
curl -L -o sample.pac https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac
pprb find proxy -c 127.0.0.1 -t "2014-03-09 12:00:00" -p sample.pac -u https://github.com

# Or download via pprb directly and parse pac #2
pprb find proxy -c 127.0.0.1 -t "2014-03-09 12:00:00" -p https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac -u https://github.com

# Or download this example if you are behind a coporate proxy via pprb directly and parse pac #3
pprb find proxy -c 127.0.0.1 -t "2014-03-09 12:00:00" -p https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac -u https://github.com --use-proxy

# =>                url: result
# => https://github.com: DIRECT
```

#### Compress proxy.pac-file

You can compress a proxy.pac with `pprb` to reduce the amount of data
transferred to download the proxy.pac.

```bash
# Download pac
curl -L -o sample.pac https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac

# Compress pac
pprb compress proxy_pac -p sample.pac
```

#### Lint proxy.pac-file

You can lint a proxy.pac with `pprb` to check a proxy.pac before deploying it.

```bash
# Download pac
curl -L -o sample.pac https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac

# Lint pac
pprb lint proxy_pac -p sample.pac
```

#### Init new proxy.pac

You can use the following command to start a new proxy.pac:

*Plain*

```bash
pprb init proxy_pac
```

*Add rspec*

To test your proxy.pac you can use `rspec`.

```bash
pprb init proxy_pac --test rspec
```

*Add middleman*

To build your proxy.pac you can use `middleman`.

```bash
pprb init proxy_pac --build middleman
```

### "rack"-middleware

The middleware which comes with `proxy_pac_rb` is compliant with the
`rack`-specification - tested via
[`rack/lint`](https://github.com/rack/rack/blob/master/lib/rack/lint.rb) and
should work with every `rack`-compliant-server.

#### Prerequisites

Make sure the content is served with `"Content-Type":
'application/x-ns-proxy-autoconfig'`. Otherwise the content is ignored by both
middlewares.

#### Warning

The linter-`rack`-middleware needs to be activated before ANY other
middleman-extension, `rack`-middleware or whatever framework you are using
can instantiate the `V8`-runtime! Only the first time the
`V8`-javascript-engine - aka `therubyracer` - is instantiated, it is possible to
create a binding to ruby code. Every other `V8`-object created later re-uses
this binding.

You might an error like this if you ignore this warning!

```bash
error  build/proxy.pac
Unexpected token: name (is) (line: 1, col: 10, pos: 10)

Error
    at new JS_Parse_Error (<eval>:2359:10623)
    at js_error (<eval>:2359:10842)
    at croak (<eval>:2359:19086)
    at token_error (<eval>:2359:19223)
    at unexpected (<eval>:2359:19311)
    at semicolon (<eval>:2359:19784)
    at simple_statement (<eval>:2359:22580)
    at <eval>:2359:20553
    at <eval>:2359:19957
    at <eval>:2359:31968
There were errors during this build
```


#### Linter Middleware

```ruby
require 'proxy_pac_rb/rack/proxy_pac_linter'
use ProxyPacRb::Rack::ProxyPacLinter
```

#### Compressor Middleware

```ruby
require 'proxy_pac_rb/rack/proxy_pac_compressor'
use ProxyPacRb::Rack::ProxyPacCompressor
```

If you need to change some settings, please pass it a `options`-parameter.
Please see the (`uglifier`)[https://github.com/lautis/uglifier] for more
information about this.

```ruby
require 'proxy_pac_rb/rack/proxy_pac_compressor'
use ProxyPacRb::Rack::ProxyPacCompressor.new(options: {})
```

#### Using "rack"-middleware with "middleman"

If you want to use the `rack`-middleware with `middleman` look at the following
code snippet captured from the `middleman`-configuration file `config.rb`:

* `config.rb`:

  ```ruby
  # IMPORTANT: Needs to come first before compressor
    require 'proxy_pac_rb/rack/proxy_pac_linter'
    use ProxyPacRb::Rack::ProxyPacLinter
  
    require 'proxy_pac_rb/rack/proxy_pac_compressor'
    use ProxyPacRb::Rack::ProxyPacCompressor
  
  # The middleware works on content served with 
  # "Content-Type" 'application/x-ns-proxy-autoconfig'
    page "*.pac", content_type: 'application/x-ns-proxy-autoconfig', layout: false
  
  # This provides an uncompressed copy of the proxy.pac to make it
  # possible for your support to review it by hand
  Dir.glob(File.join(source_dir, '**', '*.pac*')).each do |f|
    # Path should be relative to source dir
    relative_path = Pathname.new(f).relative_path_from(Pathname.new(source_dir))
    relative_path = relative_path.to_s.gsub(/(?<path>.*\.pac)\..*/, '\k<path>')

    # "text/plain" prevents the middlewares to handle it
    proxy(format('%s.raw', relative_path), relative_path, content_type: 'text/plain', layout: false)
  end
  ```

### Ruby

*Load from website*

```ruby
require 'proxy_pac_rb'

file = ProxyPacRb::Parser.new.parse('https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac')
file.find('https://github.com')        # => "DIRECT"
```

*Load from filesystem*

```bash
curl -L -o sample.pac https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample.pac
```

```ruby
require 'proxy_pac_rb'

file = ProxyPacRb::Parser.new.parse("sample.pac")
file.find('https://github.com')        # => "DIRECT"
```

*Use string*

```ruby
require 'proxy_pac_rb'

file = ProxyPacRb::Parser.new.parse <<-JS
  function FindProxyForURL(url, host) {
    return "DIRECT";
  }
JS

file.find('http://localhost') # => "DIRECT"
```

*Use Client IP*

```ruby
require 'proxy_pac_rb'

environment = ProxyPacRb::Environment.new(client_ip: '127.0.0.1')
file = ProxyPacRb::Parser.new(environment).parse('https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample2.pac')
file.find('https://github.com')        # => "PROXY localhost:8080"

environment = ProxyPacRb::Environment.new(client_ip: '127.0.0.2')
file = ProxyPacRb::Parser.new(environment).parse('https://github.com/fedux-org/proxy_pac_rb/raw/master/files/sample2.pac')
file.find('https://github.com')        # => "DIRECT"
```

*Use Date Time*

```ruby
require 'proxy_pac_rb'

string = <<~EOS
function FindProxyForURL(url, host) {
  if (dateRange("JUL", "SEP")) {
    return "PROXY localhost:8080";                                                                                                          
  } else {
    return "DIRECT";
  }
}
EOS

environment = ProxyPacRb::Environment.new(time: Time.parse('2014-07-06 12:00'))
file = ProxyPacRb::Parser.new(environment).parse(string)
file.find('http://localhost') # => 'PROXY localhost:8080'

environment = ProxyPacRb::Environment.new(time: Time.parse('2014-03-08 6:00'))
file = ProxyPacRb::Parser.new(environment).parse(string)
file.find('http://localhost') # => 'DIRECT'
```

## Available JavaScript Functions

* isPlainHostName(host)
* dnsDomainIs(host, domain)
* localHostOrDomainIs(host, hostdom)
* isResolvable(host)
* isInNet(host, pattern, mask)
* dnsResolve(host)
* myIpAddress()
* dnsDomainLevels(host)
* shExpMatch(str, shexp)
* weekdayRange(wd1, wd2, gmt)
* dateRange(*args)
* timeRange(*args)
* alert(msg) (output on stderr by default)

## RSpec-integration

`proxy_pac_rb` comes with helpers and matchers for `rspec`. To make those
helpers and matchers available in your project, add this code snippet in your
project:

```
require 'proxy_pac_rb/rspec'
```

### Helpers

* `proxy_pac`:

    This helper makes a proxy.pac available. It requires a source for your
    proxy.pac given in `subject { }` - e.g. a file, a string, or a url. It
    represents a [`ProxyPacFile`](lib/proxy_pac_rb/proxy_pac_file.rb).

* `time`:

    The `time`-helper makes `1970-01-01 00:00:00` as time available. Overwrite
    this helper at will with another time string or a time-object - e.g
    `let(:time) { Time.now }`.

* `client_ip`:

    The `client_ip`-helper makes `127.0.0.1` available. Overwrite it with a
    different ip-address as string or an object which returns an ip-address on
    `#to_s`.

* `root_path`:

    The `root_path`-helper is meant for overriding. It is used to find your
    "proxy.pac"-files. By default its value is `Dir.getwd` which is set by
    `rspec`.

### Configuration

You can either configure `ProxyPacRb` either via a global `ProxyPacRb.configure`-block:

```ruby
ProxyPacRb.configure do |config|
  config.use_proxy = true
end
```

or via `RSpec`-metadata:

```ruby
RSpec.describe 'proxy.pac', type: :proxy_pac, use_proxy: true do
end
```

### Examples

To make it easier for you to start, you find some examples below.

**Type for specs**

It is important that you flag your specs with `type: :proxy_pac`. Otherwise the
helpers are not included and not available in your examples.

```ruby
RSpec.describe 'proxy.pac', type: :proxy_pac do
```

**Supported sources**

*String*

```ruby
RSpec.describe 'String', type: :proxy_pac do
  subject do
    <<~EOS.chomp
      function FindProxyForURL(url, host) {
        return "DIRECT";
      }
    EOS
  end
end
```

*Local File*

```ruby
RSpec.describe 'proxy.pac', type: :proxy_pac do
  subject { 'proxy.pac' }
end
```

*URL*

```ruby
RSpec.describe 'http://server/proxy.pac', type: :proxy_pac do
  subject { 'http://server/proxy.pac' }
end
```

**Matchers**

*Readable*

To check if a proxy.pac could be read from filesystem or downloaded via HTTP,
check `be_readable`.

```ruby
require 'proxy_pac_rb/rspec'

RSpec.describe 'proxy.pac', type: :proxy_pac do
  context 'when proxy pac exist' do
    context 'when is file' do
      subject { 'proxy.pac' }
      it { expect(proxy_pac).to be_readable }
    end

    context 'when is url' do
      subject { 'http://www.example.com/proxy.pac' }
      it { expect(proxy_pac).to be_readable }
    end
  end
end
```

*Equal*

If you want to check if a proxy.pac is the same you can use the
`be_the_same_proxy_pac_file`-matcher.

```ruby
require 'proxy_pac_rb/rspec'

RSpec.describe 'proxy.pac', type: :proxy_pac do
  subject do
    <<~EOS.chomp
      function FindProxyForURL(url, host) {
        return "DIRECT";
      }
    EOS
  end
  context 'Check equality of proxy pac' do
    context 'when proxy.pac is eq' do
      it { expect(proxy_pac).to be_the_same_proxy_pac_file 'proxy.pac' }
    end

    context 'when proxy.pac is not eq' do
      it { expect(proxy_pac).not_to be_the_same_proxy_pac_file 'proxy.pac' }
    end
  end
end
```

This is quite handy to compare a local proxy.pac with a remote one - e.g. a
deployed one.

```ruby
require 'proxy_pac_rb/rspec'

RSpec.describe 'proxy.pac', type: :proxy_pac do
  let(:local_proxy_pac) { ProxyPacRb::ProxyPacFile.new(source: file) }

  before(:each) do
    ProxyPacRb::ProxyPacLoader.new.load(local_proxy_pac)
    ProxyPacRb::ProxyPacCompressor.new.compress(local_proxy_pac) if local_proxy_pac.readable?
  end

  context 'when no proxy.pac is given' do
    subject { 'http://server.example.com/proxy.pac' }
    let(:file) { 'source/proxy.pac' }

    it { expect(proxy_pac).to be_the_same_proxy_pac_file(local_proxy_pac) }
  end
end
```

*Valid*

You want to check if your proxy.pac is valid. This will find `reference errors`
(e.g. unknown variables) and `syntax errors`.

```ruby
require 'proxy_pac_rb/rspec'

RSpec.describe 'proxy.pac', type: :proxy_pac do
  subject do
    <<~EOS.chomp
      function FindProxyForURL(url, host) {
        return "DIRECT";
      }
    EOS
  end
  context 'Check validity of proxy pac' do
    context 'when proxy.pac is valid' do
      it { expect(proxy_pac).to be_valid }
    end

    context 'when proxy.pac is not valid' do
      subject do
        <<~EOS.chomp
          function FindProxyForURL(url, host) {
            return adsf;
          }
        EOS
      end
      it { expect(proxy_pac).not_to be_valid }
    end
  end
end
```

*Parse proxy.pac*

To make some logic checks use the `be_downloaded_via`-matcher. This will parse
the proxy.pac and returns the proxy to be used for a given url.

```ruby
require 'proxy_pac_rb/rspec'
RSpec.describe 'proxy.pac', type: :proxy_pac do
  subject do
    <<~EOS.chomp
      function FindProxyForURL(url, host) {
        if (dnsDomainIs(host, 'www1.example.com'')) {
          return "PROXY proxy1.example.com:8080";
        } else {
          return "PROXY proxy2.example.net:8080";
        }
      }
    EOS
  end
  context 'Parse Proxy Pac' do
    context 'when url is forwarded via' do
      let(:url) { 'http://www1.example.com' }
      it { expect(url).to be_downloaded_via 'PROXY proxy.example.com:8080' }
    end

    context 'when url is not forwarded via' do
      let(:url) { 'http://www2.example.com' }
      it { expect(url).not_to be_downloaded_via 'PROXY proxy.example.com:8080' }
    end
  end
end
```

## Developers

After checking out the repo, run `script/bootstrap` to install dependencies.
Then, run `script/console` for an interactive prompt that will allow you to
experiment. To run tests execute `script/test`.

To install this gem onto your local machine, run `bundle exec rake gem:install`. To
release a new version, update the version number in `version.rb`, and then run
`bundle exec rake gem:release` to create a git tag for the version, push git
commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).

### Contributing

If you want to contribute: fork, branch & pull request and please see
[CONTRIBUTING.md](CONTRIBUTING.md).

### Running Tests

```
bundle install
rake test:rspec
rake test:rubyracer
rake test:rubyrhino
```

If you want to open an issue. Please send a PR with a test describing the bug.

