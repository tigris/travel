#!/usr/bin/env ruby

file   = __FILE__
file   = File.readlink(file) while File.symlink?(file) # Avoid putting same end path in load_path twice via symlinks
libdir = File.expand_path(File.join(File.dirname(file), '..', 'lib'))
$LOAD_PATH.unshift(libdir) unless $LOAD_PATH.include?(libdir)

require 'destination_listener'
require 'fileutils'
require 'rexml/document'
require 'taxonomy'

def validate_usage! taxonomy_file, destinations_file, output_folder
  if taxonomy_file.nil?
    $stderr.puts 'You need to provide a taxonomy file.'
    exit 1
  elsif !File.exists?(taxonomy_file)
    $stderr.puts 'The taxonomy file you provided does not exist.'
    exit 1
  end

  if destinations_file.nil?
    $stderr.puts 'You need to provide a destinations file.'
    exit 1
  elsif !File.exists?(destinations_file)
    $stderr.puts 'The taxonomy file you provided does not exist.'
    exit 1
  end

  if output_folder.nil?
    $stderr.puts 'You need to provide an output directory.'
    exit 1
  elsif File.exists?(output_folder)
    if File.file?(output_folder)
      $stderr.puts 'Output directory can not be a file.'
      exit 1
    end
  else
    FileUtils.mkdir_p(output_folder)
  end
end

def parse_taxonomy file
  nil
end

taxonomy_file     = ARGV[0]
destinations_file = ARGV[1]
output_folder     = ARGV[2]

validate_usage!(taxonomy_file, destinations_file, output_folder)
taxonomy = Taxonomy.create_from_xml File.read(taxonomy_file) # Potential issue point if full taxonomy file is large
listener = DestinationListener.new(taxonomy, output_folder)
REXML::Document.parse_stream(File.new(destinations_file), listener)