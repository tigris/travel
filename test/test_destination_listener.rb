require 'minitest/autorun'
require 'destination_listener'
require 'taxonomy'
require 'fileutils'

class TestDestinationListener < MiniTest::Unit::TestCase
  def setup
    root        = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    @sample_dir = File.join(root, 'test', 'samples')
  end

  def test_parse_destination_stream
    output_dir = File.join('/', 'tmp', 'test_parse_destination_stream' + $$.to_s)
    FileUtils.rm_r(output_dir) if File.exists?(output_dir)
    taxonomy   = Taxonomy.new []
    xml_file   = File.join(@sample_dir, 'destinations.xml')
    listener   = DestinationListener.new(taxonomy, output_dir)
    REXML::Document.parse_stream(File.new(xml_file), listener)
    assert File.exists?(File.join(output_dir, '1-test1.html')), 'first destination file exists'
    assert File.exists?(File.join(output_dir, '2-test2.html')), 'second destination file exists'
    FileUtils.rm_r output_dir
  end
end
