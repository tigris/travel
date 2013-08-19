require 'minitest/autorun'
require 'taxonomy'

class TestTaxonomy < MiniTest::Unit::TestCase
  def setup
    root        = File.expand_path(File.join(File.dirname(__FILE__), '..'))
    @sample_dir = File.join(root, 'test', 'samples')
  end

  def test_create_from_xml
    sample_file = File.join(@sample_dir, 'taxonomy.xml')
    taxonomy    = Taxonomy.create_from_xml(File.read(sample_file))
    assert_kind_of Taxonomy, taxonomy
    assert_equal 'level1', taxonomy.destinations.first.name
    assert_equal 3, taxonomy.destinations.size
    assert_equal 2, taxonomy.destinations.last.parents.size
  end
end
