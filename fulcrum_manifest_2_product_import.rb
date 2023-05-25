# frozen_string_literal: true

#get path to input file (or pipe) from ARGV.shift

require 'csv'
require 'isbn'


header = [
"Product ID",
"Project ID",
"Description",
"Format",
"Publication Date",
"Ingestion Date",
"Status",
"Secondary ID",
"Edition",
"Page Count",
"Season",
"Out of Print",
"Price",
"MFG Cost",
"Misc 1",
"Misc 2 ",
"Misc 3",
"Misc 4"
]



CSV.open('data/4_products_heb.csv', 'w') do |output|
  output << header
  CSV.foreach(ARGV.shift, headers: true) do |input|
    next unless(input['Published?'].match(/TRUE/i))
    next if(input['Tombstone?'])
    
    isbns_formats = []
    isbns_formats = input['ISBN(s)'].split('; ') if input['ISBN(s)']

    #Get hebid and add it to the list of ISBNs
    hebids = [] #Yes some titles have multiple  
    ids= input['Identifier(s)'].split('; ')
    ids.each { |i|
      if i.match(/^heb_id: ?heb((\d\d\d\d\d)\.\d\d\d\d\.\d\d\d)/)
        hebids.push("HEB#{$1}")
      end
    }
    products = hebids + isbns_formats
    projectID = hebids.first
    products.each {|i|
      row = CSV::Row.new(header,[])
      
      #Figure out if this product ID is an HEBID or an ISBN
      productID = ''

      if i.match(/^heb/)
        row['Product ID'] = i
        row['Format'] = 'Ebook'
      else
        i.match(/^(\d+)/) { row['Product ID'] = $1}
        format = ''
        i.match(/\((.*?)\)/) { format = $1 }
        case format
        when /ebook/i
          row['Format'] = 'Ebook'
        when /paper/i
          row['Format'] = 'Paperback'
        when /hard/i
          row['Format'] = 'Hardcover'
        end

      end

      row['Project ID'] = projectID
      row['Description'] = input['Title']
      row['Publication Date'] = input['Pub Year']
      row['Ingestion Date'] = input['Date Uploaded']
      row['Status'] = 'Available'
      row['Edition'] = input['Edition Name']

      output << row
    }
  end
end
