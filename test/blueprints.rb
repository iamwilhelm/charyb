require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  datasource_url { "http://" + Faker::Internet.domain_name }
  title { Faker::Lorem.sentence }
  description { Faker::Lorem.paragraph }
end

Source::TextHtml.blueprint do
  url { Sham.datasource_url }
  title { Sham.title }
  description { Sham.description }

  type { "TextHtml" }
  content_type { "text/html" }
end

Source::TextCsv.blueprint do
  url { Sham.datasource_url }
  title { Sham.title }
  description { Sham.description }

  type { "TextCsv" }
  content_type { "text/html" }
end

Source::TextPlain.blueprint do
  url { Sham.datasource_url }
  title { Sham.title }
  description { Sham.description }

  type { "TextPlain" }
  content_type { "text/plain" }
end
