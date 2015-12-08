module Jekyll
  module PermalinkGenerator
    def permalink_url(path_or_page, data_dir = nil, locale = nil)
      site = Jekyll.sites.first
      page = path_or_page.is_a?(Jekyll::Page) ? path_or_page : detect_page(site, path_or_page, data_dir)

      page.url(locale || site.active_lang)
    end

    def detect_page(site, path, data_dir)
      token = [data_dir, path].compact.join('/')
      token = '/' + token unless token.start_with?('/')

      page = site.pages.detect do |p|
        page_url = Jekyll::URL.new({ template: p.template, placeholders: p.url_placeholders, permalink: nil }).to_s

        if token.end_with?('/') && p.index? && page_url == token
          true
        elsif !token.end_with?('/')
          pathname = Pathname.new(page_url)
          dir = pathname.dirname.to_s
          base = pathname.basename('.*').to_s

          token_pathname = Pathname.new(token)
          token_dir = token_pathname.dirname.to_s
          token_base = token_pathname.basename('.*').to_s

          token == "#{dir}/#{base}" || "#{token_dir}/#{token_base}" == "#{dir}/#{base}"
        end
      end

      raise "permalink for '#{token}' not found" if page.nil?

      page
    end
  end
end

Liquid::Template.register_filter(Jekyll::PermalinkGenerator)
