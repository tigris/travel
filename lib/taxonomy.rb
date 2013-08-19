require 'rexml/document'
require 'destination'

class Taxonomy
  attr_reader :destinations

  def initialize destinations
    @destinations = destinations
  end

  def find_parent destination
    found = @destinations.find{|d| d.id == destination.id }
    found.nil? ? nil : found.parent
  end

  class << self
    def create_from_xml xml
      xml = REXML::Document.new(xml.to_s) unless xml.is_a?(REXML::Document)
      xml = REXML::XPath.first(xml, '/taxonomies/taxonomy')
      destinations = []
      REXML::XPath.match(xml, './node').each do |node|
        destinations += parse_node(node)
      end
      self.new(destinations)
    end

    def parse_node node, parent = nil
      name = REXML::XPath.first(node, './node_name') || REXML::XPath.first(node, './taxonomy_name')
      name = name.text if name.respond_to?(:text)
      id   = node.attributes['atlas_node_id']
      destination  = Destination.new(name, id, parent)
      destinations = [destination]
      REXML::XPath.match(node, './node').each do |sub_node|
        destinations += parse_node(sub_node, destination)
      end
      destinations
    end
  end
end