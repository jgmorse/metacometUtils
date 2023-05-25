# frozen_string_literal: true

#get path to input file (or pipe) from ARGV.shift

require 'csv'

def parse_identifiers(ids_str, row)
  ids=ids_str.split('; ')
  ids.each { |i|
    if i.match(/^heb_id: ?heb((\d\d\d\d\d)\.\d\d\d\d\.\d\d\d)/)
      row['projectid']="HEB#{$1}"
      return
    end
  }
end

header = [
  "projectid",
  "business unit",
  "projectname",
  "projectdisplayname",
  "Frequency",
  "paymentwindow",
  "firststatementend",
  "Net Price Must Exceed MFG Cost",
  "paymentthreshold",
  "overstockgraceperiod",
  "overstockyears",
  "pubcode",
  "active",
  "Series",
  "Series Code",
  "Review Period",
  "Needs Review",
  "Creator",
  "Co-creator",
  "Contract Date",
  "Notes"
]

CSV.open('data/3_projects_heb.csv', 'w') do |output|
  output << header
  CSV.foreach(ARGV.shift, headers: true) do |input|
    next unless(input['Published?'].match(/TRUE/i))
    next if(input['Tombstone?'])
    row = CSV::Row.new(header,[])
    parse_identifiers(input['Identifier(s)'], row)
    row['projectname'] = input['Title']
    row['projectdisplayname'] = input['Title']
    row['Frequency'] = 'Semiannual'
    row['active'] = 'T'
    row['Series'] = input['Series']
    last, first = nil
    if input['Creator(s)']
     input['Creator(s)'].gsub!(/\(.+?\)/,'')
     input['Creator(s)'].gsub!(/;.*?$/,'')
     input['Creator(s)'].to_s.match(/^(.+?),/) {last = $1}
     input['Creator(s)'].to_s.match(/^.+?,(.+?)$/) {first = $1}
     row['Creator'] = "#{last}, #{first}"
    end
    if input['Additional Creator(s)']
      input['Additional Creator(s)'].gsub!(/\(.+?\)/,'')
      input['Additional Creator(s)'].gsub!(/;.*?$/,'')
      input['Additional Creator(s)'].to_s.match(/^(.+?),/) {last = $1}
      input['Additional Creator(s)'].to_s.match(/^.+?,(.+?)$/) {first = $1}
      row['Co-creator'] = "#{last}, #{first}"
    elsif input['Contributor(s)']
      input['Contributor(s)'].gsub!(/\(.+?\)/,'')
      input['Contributor(s)'].gsub!(/;.*?$/,'')
      input['Contributor(s)'].to_s.match(/^(.+?),/) {last = $1}
      input['Contributor(s)'].to_s.match(/^.+?,(.+?)$/) {first = $1}
      row['Co-creator'] = "#{last}, #{first}"
    end
    output << row
  end
end
