require 'rexml/document'
require 'rexml/streamlistener'
require 'destination'

# This listener will simply capture all XML content of a node named destination,
# then at the end of that node, it will hand the content over to the model. This
# is done as a stream listener so that we don't hold the entire destinations XML
# in memory for the duration of the process.
class DestinationListener
  include REXML::StreamListener

  def initialize taxonomy, output_folder
    @taxonomy      = taxonomy
    @output_folder = output_folder
    @recording     = false
    @tree          = []
  end

  def tag_start name, attrs
    @recording = true if name == 'destination'
    if @recording
      element = REXML::Element.new(name)
      element.add_attributes(attrs)
      @tree.last.add_element(element) if @tree.length > 0
      @tree << element
    end
  end

  def text content
    @tree.last.add_text(REXML::Text.new(content)) if @recording
  end

  def cdata content
    @tree.last.add_text(REXML::CData.new(content)) if @recording
  end

  def tag_end name
    element = @tree.pop if @recording
    if name == 'destination'
      @recording  = false
      @tree       = []
      destination = Destination.create_from_xml element
      destination.parent = @taxonomy.find_parent(destination)
      destination.write_template(@output_folder)
    end
  end
end