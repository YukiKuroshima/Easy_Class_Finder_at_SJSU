require "mechanize"
require "colorize"

UNIVERSITY_NAME = "San Jose State University"

# Go to google.com and search RMP
a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}

agent = Mechanize.new
page = agent.get("http://info.sjsu.edu/web-dbgen/soc-spring-courses/all-departments.html")
# elements = page.search('title')
elements = page.search('.content_wrapper a')

i = 0
elements.each do |link|

  i+=1
  if i > 3
    break
  end

  #Output class Depertment Name
  puts link.text

  #Go to each depertment class list page
  next_page = page.link_with(:text => link.text).click

  #Seach for only class title Eq CS 49J
  next_page_elements = next_page.search('.content_wrapper a')

  #Create hash to check and count the duplicates
  duplicate = {}
  #Itelate through each classes in a depertment

  j = 0
  next_page_elements.each do |one_class|

    #i+=1
    #if i >3
      #break
    #end

    class_name = one_class.text

    #go to each classes page and get prof name.
    each_class_page = next_page.link_with(:text => one_class.text).click

    #get a table
    each_class_page_elements = each_class_page.search('//*[@id="content"]/div[3]/table')

    #get all professor name ONLY ONE ELEMENT
    each_class_page_elements_prof_name = each_class_page_elements.search('tr[16]/td[3]')

    puts "  #{class_name}: #{each_class_page_elements_prof_name.text}".colorize(:green)

    professor_name = each_class_page_elements_prof_name.text

    a.get('http://google.com/') do |page|
    search_result = page.form_with(:name => 'f') do |search|
      #searching one professor's RMP
      search.q = "#{professor_name} #{UNIVERSITY_NAME} rate my professor"
    end.submit

    # get URLs
    urls = search_result.search(".r")

    #False means not found
    is_prof_found = false
    professor_page_url = ""
    urls.each do |url|
      last_first_name = professor_name[2..-1]
      #last_first_name << " ,"
      #last_first_name << professor_name[0]


      if (url.text.include?(last_first_name) && !url.text.include?("Add A Review"))
        professor_page_url = url
        is_prof_found = true
        break
      end
    end


    if(!is_prof_found)
      puts "ERROR: Sorry #{professor_name} was not in google search result.".colorize(:red)
    else

      # Get professor's RMP Content into professor_page
      professor_page = search_result.link_with(:text => professor_page_url.text).click

      #p professor_page.title
  
      prof_info = professor_page.search(".grade")


      prof_quality = prof_info[0].text.to_f

      prof_difficulity = prof_info[2].text.to_f
      print "   #{professor_name}  at #{UNIVERSITY_NAME} has "
      print "#{prof_quality}".colorize(:blue)
      print " points and "
      print "#{prof_difficulity}".colorize(:blue)
      puts " difficulity"
      puts "    URL: #{professor_page.uri.to_s}".colorize(:light_green)
    end

      # each_class_page_elements.each do |instractor|
      #   puts instractor
      # end
      #Itelate each class
      #next_page_elements.each do |one_class|

      #end

      #puts "  #{class_name} is taught by #{}"

      #if has_key is TRUE, increse class count 1
      #Not nil means the key exits
      if(duplicate[class_name] != nil)
        duplicate[one_class.text]+=1
      #if FALSE, create new key
      else
        duplicate[class_name] = 1
      end
    end

    

  end

  #Output hash
  duplicate.each do |key, value|
#    puts " #{key} has #{value} courses"
  end

  # puts " #{next_page.search('.content_wrapper a').text} "
end

