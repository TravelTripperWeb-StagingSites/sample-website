require 'xkeys'

Jekyll::Hooks.register :site, :post_write do |site|
  SitemapGenerator.new(site).generate
end

class SitemapGenerator
  attr_reader :site

  def initialize(site)
    @site = site
  end

  def generate
    pages = site.pages
    default_lang = site.config['default_lang']

    # generate only once
    return unless default_lang == site.active_lang

    sitemap = {}.extend(XKeys::Hash)

    sitemap['__CONFIG__', 'default_locale'] = default_lang
    sitemap['__CONFIG__', 'page_gen'] = site.config['page_gen']

    pages.each do |page|
      url = page.url
      url += 'index.html' if url.end_with?('/')

      url = '__ROOT__' + url

      path = url.split('/')
      label = path.last
      path = path[0..-2] + ['__PAGES__']

      sitemap[*path] ||= []
      sitemap[*path] << { label: page.data['label'] || label, locales: localized_urls(site, page), data_source: (page.is_a?(Jekyll::DataPage) && page.data_source) || nil }
    end

    sitemap['__REGIONS__'] = site.data['regions']

    save sitemap
  end

  def localized_urls(site, page)
    {}.tap do |result|
      site.config['languages'].each do |locale|
        url = if page.data['permalink_localized'] && page.data['permalink_localized'][locale]
                page.data['permalink_localized'][locale]
              else
                page.url
              end
        url = "/#{locale}" + url unless locale == site.config['default_lang']

        result[locale] = url
      end
    end
  end

  private
    def save(sitemap)
      File.open('sitemap.json', 'w') do |f|
        f.write(sitemap.to_json)
      end
    end
end
