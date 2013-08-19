# Travel destination/taxonomy xml processor

## Usage

```ruby
  country = Destination.new('Australia', 109736)
  city    = Destination.new('Melbourne', 183626, country)
  city.history = 'Lorem ipsum....'
  city.write_template 'public/cities'
```

```
  bundle install --path gems
  bundle exec ./bin/create_pages.rb doc/taxonomy.xml doc/destinations.xml public/
```

## Testing

If you have rake installed system wide, simply `rake test`. Otherwise `bundle install --path gems && bundle exec rake test`.

## Notes

   * An XML stream listener was used rather than reading into memory for the
     destinations file due to expected large amount of data. The decision to
     read the taxonomy file into memory was on the assumption this file would be
     relatively small. The alternative is to process the taxonomy file again for
     each destination encountered, which is a performance hit. The trade of is
     performance for load, a decision I would need the full data set to make.
   * REXML was used purely as it comes stock with ruby. For long term, I would
     investigate other SAX parsers such as Nokogiri to determine if they are
     faster when dealing with the larger data set.
   * Slim was used as the templating for no real reason other than I was
     interested to have a look at it, since I've used ERB and HAML mostly until
     now, I saw this as an opportunity to try it out.

## Author

Danial Pearce <git AT tigris DOT id DOT au>
