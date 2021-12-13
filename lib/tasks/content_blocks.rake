# lib/tasks/content_blocks.rake
# load content blocks for About, Terms of Use, and Deposit Agreement pages
namespace :cuirator do
  namespace :content_blocks do
    desc "Load content for About, Terms of Use, and Deposit Agreement pages"
    task load: :environment do
      ContentBlock.about_page = default_about_text
      ContentBlock.terms_page = default_terms_text
      ContentBlock.agreement_page = default_agreement_text
    end

    def default_about_text
      ERB.new(
        IO.read(
          Rails.root.join('app', 'views', 'hyrax', 'content_blocks', 'templates', 'about.html.erb')
        )
      ).result
    end

    def default_terms_text
      ERB.new(
        IO.read(
          Rails.root.join('app', 'views', 'hyrax', 'content_blocks', 'templates', 'terms.html.erb')
        )
      ).result
    end

    def default_agreement_text
      ERB.new(
        IO.read(
          Rails.root.join('app', 'views', 'hyrax', 'content_blocks', 'templates', 'agreement.html.erb')
        )
      ).result
    end
  end
end
