require File.join(File.expand_path(File.dirname(__FILE__)), 'test_helper.rb')

class TestSanitize < Test::Unit::TestCase
  include RbbCode::HTMLAssertions
  
  def test_sanitize_custom_config
    # Identical to RbbCode::DEFAULT_SANITIZE_CONFIG except without <strong>
    config = {
      :elements => %w[a blockquote br code del em img li p pre ul],
      :attributes => {
        'a'   => %w[href],
        'img' => %w[alt src]
      },
  
      :protocols => {
        'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]}
      }
    }
    assert_converts_to(
      '<p><em>Italic</em> but not bold.</p>',
      '[i]Italic[/i] but not [b]bold.[/b]',
      {:sanitize_config => config}
    )
  end
  
  def test_sanitize_turned_off
    assert_converts_to(
      '<p><em>Italic</em> and a <span>custom span.</span></p>',
      '[i]Italic[/i] and a <span>custom span.</span>',
      {:sanitize => false}
    )
  end
end