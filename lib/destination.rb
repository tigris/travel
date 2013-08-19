require 'rexml/document'
require 'fileutils'
require 'slim'

class Destination
  attr_accessor :id,  :name, :parent, :history, :transport, :weather, :introduction
  private       :id=, :name=

  DEFAULT_TEMPLATE = Slim::Template.new('views/destination.slim', pretty: false, format: :xhtml, streaming: true)

  def initialize name, id, parent = nil
    self.name   = name
    self.id     = id
    self.parent = parent
  end

  def to_param
    "#{id}-#{name.gsub(/\W+/, '-').downcase}"
  end

  def write_template directory, template = nil
    FileUtils.mkdir_p(directory)
    template ||= DEFAULT_TEMPLATE
    File.open(File.join(directory, to_param + '.html'), 'w') do |f|
      f.puts template.render('foo', destination: self)
    end
  end

  def parents
    current = self
    parents = []
    while parent = current.parent
      current = parent
      parents << parent
    end
    parents.reverse
  end

  class << self
    def create_from_xml xml
      xml = REXML::Document.new(xml.to_s) unless xml.is_a?(REXML::Document)
      xml = REXML::XPath.first(xml, '/destination')

      destination = self.new(xml.attributes['title'], xml.attributes['atlas_id'])

      %w(history transport weather introduction).each do |section|
        destination.send("#{section}=", self.send("#{section}_from_xml", xml))
      end

      destination
    end

    def history_from_xml xml
      data = REXML::XPath.first(xml, '//history//overview')
      data.nil? ? nil : data.texts.join('').strip
    end

    def transport_from_xml xml
      transport = REXML::XPath.match(xml, '//transport//overview')
      transport.nil? ? nil : transport.map{|node| node.texts.join('').strip }.join("\n")
    end

    def weather_from_xml xml
      if weather = REXML::XPath.first(xml, '//weather//overview')
        weather.texts.join('').strip
      elsif weather = REXML::XPath.match(xml, '//weather//climate')
        weather.map{|node| node.texts.join('').strip }.join("\n")
      else
        nil
      end
    end

    def introduction_from_xml xml
      data = REXML::XPath.first(xml, '//introduction//overview')
      data.nil? ? nil : data.texts.join('').strip
    end

    def default_template
      # Set pretty: true for nice indented output, but is documented to be slightly slower.
      Slim::Template.new('views/destination.slim', pretty: false, format: :xhtml, streaming: true)
    end
  end
end