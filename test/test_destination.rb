require 'minitest/autorun'
require 'destination'
require 'fileutils'
require 'slim'

class TestDestination < MiniTest::Unit::TestCase
  def setup
    root        = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    @sample_dir = File.join(root, 'test', 'samples')
  end

  def test_parents
    level1 = Destination.new('level1', 1)
    level2 = Destination.new('level2', 2, level1)
    level3 = Destination.new('level3', 3, level2)
    assert_equal 1, level2.parents.size
    assert_equal 2, level3.parents.size
    assert 2 == level3.parent.id, 'parents are in the correct order'
  end

  def test_create_from_xml
    sample_file = File.join(@sample_dir, 'destination.xml')
    destination = Destination.create_from_xml(File.read(sample_file))

    assert_kind_of Destination, destination

    assert_equal 'Danialville',       destination.name
    assert_equal '1',                 destination.id
    assert_equal 'test history',      destination.history
    assert_equal 'test weather',      destination.weather
    assert_equal 'test introduction', destination.introduction

    assert_equal "test transport line 1\ntest transport line 2", destination.transport
  end

  def test_write_template
    template    = Slim::Template.new(File.join(@sample_dir, 'template.slim'))
    destination = Destination.new('test_write_template', 1)
    output_dir  = File.join('/', 'tmp', 'test_write_template' + $$.to_s)
    output_file = File.join(output_dir, destination.to_param + ".html")
    destination.write_template(output_dir, template)

    assert File.exists?(output_file)

    output = File.read(output_file)
    assert_equal "<div>#{destination.name}</div>", output.strip

    FileUtils.rm output_file
    FileUtils.rmdir output_dir
  end
end
