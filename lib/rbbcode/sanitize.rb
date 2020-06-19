class RbbCode
  DEFAULT_SANITIZE_CONFIG = {
    :elements => %w[a blockquote br code del em img li p pre strong ul u],
    :attributes => {
      'a'   => %w[href target],
      'img' => %w[alt src]
    },

    :protocols => {
      'a' => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]}
    }
  }
end