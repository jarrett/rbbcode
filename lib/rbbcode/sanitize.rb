class RbbCode
  DEFAULT_SANITIZE_CONFIG = {
    :elements => %w[a blockquote br code del em img li p pre strong ul span],
    :attributes => {
      'a'   => %w[href],
      'img' => %w[alt src],
      'span' => %w[style]
    },

    :protocols => {
      'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]}
    }
  }
  
  COLOR_PROCESSOR = lambda do |env|
    node = env[:node]
    node_name = env[:node_name]
    
    return if env[:is_whitelisted] || !node.element?
    return unless node_name == 'span'
    
    return unless node['style'] =~ /^color:.+?;$/
    
    Sanitize.clean_node!(node, {
    :elements => %w[span],

    :attributes => {
      'span'  => %w[style]
      }
    })
  
    {:node_whitelist => [node]}
  end
end