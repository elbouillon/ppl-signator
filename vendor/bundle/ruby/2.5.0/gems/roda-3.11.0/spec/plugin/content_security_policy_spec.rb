require_relative "../spec_helper"

describe "content_security_policy plugin" do 
  it "does not add header if no options are set" do
    app(:content_security_policy){'a'}
    header('Content-Security-Policy', "/a").must_be_nil
  end

  it "sets Content-Security-Policy header" do
    app(:bare) do
      plugin :content_security_policy do |csp|
        csp.default_src :self
        csp.img_src :self, 'example.com'
        csp.style_src [:sha256, 'abc']
      end

      route do |r|
        r.get 'ro' do
          content_security_policy.report_only
          ''
        end

        r.get 'nro' do
          content_security_policy.report_only
          content_security_policy.report_only(false)
          content_security_policy.report_only?.inspect
        end

        r.get 'get' do
          content_security_policy.get_default_src.inspect
        end

        r.get 'add' do
          content_security_policy.add_default_src('foo.com', 'bar.com')
          ''
        end

        r.get 'empty' do
          content_security_policy.add_default_src
          ''
        end

        r.get 'set' do
          content_security_policy.default_src('foo.com', 'bar.com')
          ''
        end

        r.get 'bool' do
          content_security_policy.block_all_mixed_content
          content_security_policy.upgrade_insecure_requests(false)
          content_security_policy.block_all_mixed_content?.inspect
        end

        r.get 'block' do
          content_security_policy do |csp|
            csp.block_all_mixed_content
            csp.add_default_src('foo.com', 'bar.com')
            csp.img_src :none
            csp.style_src
            csp.report_only
          end
          ''
        end

        r.get 'clear' do
          content_security_policy do |csp|
            csp.clear
            csp.add_default_src('foo.com', 'bar.com')
          end
          ''
        end

        'a'
      end
    end

    v = "default-src 'self'; img-src 'self' example.com; style-src 'sha256-abc'; "

    header('Content-Security-Policy', "/a").must_equal v

    header('Content-Security-Policy', "/nro").must_equal v
    header('Content-Security-Policy-Report-Only', "/nro").must_be_nil
    body("/nro").must_equal 'false'

    header('Content-Security-Policy-Report-Only', "/ro").must_equal v
    header('Content-Security-Policy', "/ro").must_be_nil

    body('/get').must_equal '[:self]'

    header('Content-Security-Policy', "/add").must_equal "default-src 'self' foo.com bar.com; img-src 'self' example.com; style-src 'sha256-abc'; "

    header('Content-Security-Policy', "/empty").must_equal "default-src 'self'; img-src 'self' example.com; style-src 'sha256-abc'; "

    header('Content-Security-Policy', "/set").must_equal "default-src foo.com bar.com; img-src 'self' example.com; style-src 'sha256-abc'; "

    body('/bool').must_equal 'true'
    header('Content-Security-Policy', "/bool").must_equal "default-src 'self'; img-src 'self' example.com; style-src 'sha256-abc'; block-all-mixed-content; "

    header('Content-Security-Policy-Report-Only', "/block").must_equal "default-src 'self' foo.com bar.com; img-src 'none'; block-all-mixed-content; "

    header('Content-Security-Policy', "/clear").must_equal "default-src foo.com bar.com; "
  end

  it "raises error for unsupported CSP values" do
    app{}
    proc{app.plugin(:content_security_policy){|csp| csp.default_src Object.new}}.must_raise Roda::RodaError
    proc{app.plugin(:content_security_policy){|csp| csp.default_src []}}.must_raise Roda::RodaError
    proc{app.plugin(:content_security_policy){|csp| csp.default_src [:a]}}.must_raise Roda::RodaError
    proc{app.plugin(:content_security_policy){|csp| csp.default_src [:a, :b, :c]}}.must_raise Roda::RodaError
  end

  it "supports all documented settings" do
    app(:content_security_policy) do |r|
      content_security_policy.send(r.path[1..-1], :self)
    end

    '
    base_uri
    child_src
    connect_src
    default_src
    font_src
    form_action
    frame_ancestors
    frame_src
    img_src
    manifest_src
    media_src
    object_src
    plugin_types
    report_uri
    require_sri_for
    sandbox
    script_src
    style_src
    worker_src
    '.split.each do |setting|
      header('Content-Security-Policy', "/#{setting}").must_equal "#{setting.gsub('_', '-')} 'self'; "
    end
  end

  it "does not override existing heading" do
    app(:content_security_policy) do |r|
      content_security_policy.default_src :self
      response['Content-Security-Policy'] = "default_src 'none';"
      ''
    end
    header('Content-Security-Policy').must_equal "default_src 'none';"
  end

  it "works with error_handler" do
    app(:bare) do
      plugin(:error_handler){|_| ''}
      plugin :content_security_policy do |csp|
        csp.default_src :self
        csp.img_src :self, 'example.com'
        csp.style_src [:sha256, 'abc']
      end

      route do |r|
        r.get 'a' do
          content_security_policy.default_src 'foo.com'
          raise
        end

        raise
      end
    end

    header('Content-Security-Policy').must_equal "default-src 'self'; img-src 'self' example.com; style-src 'sha256-abc'; "

    # Don't include updates before the error
    header('Content-Security-Policy', '/a').must_equal "default-src 'self'; img-src 'self' example.com; style-src 'sha256-abc'; "
  end
end
