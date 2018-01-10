require 'mechanize'
require 'anemone'
require 'csv'

    # For Buffet 			--> restaurants?buffet=1
    # For Deserts & Bakes 	--> restaurants?desserts-bakes=1

	# endpoint url break-down --> 
	# base_url https://www.zomato.com/city/search_param

	curr_timestamp = Time.now.strftime('%Y%m%d%H%M%S')

	$csv_file_path = 'zomato_'+curr_timestamp+'.csv'

	endpoint_url  = "https://www.zomato.com"

	cities = ['mumbai']

    category_params = ['delivery','breakfast','lunch','dinner','drinks-and-nightlife','cafés','chinese','north-indian']

    pagination_string = "page"

    page_index = 194

    page_index_max = 5000

	$agent = Mechanize.new

	$agent.redirect_ok = false

	# method to read zomato web page data of the url https://www.zomato.com/city/search_param 
	# and write to csv.
	def web_page_to_csv()
	
		begin 

			web_page = $agent.get($web_page_url)
			puts "Page status -"+web_page.code.to_s
			puts "Webpage url -"+$web_page_url
			
			if web_page and web_page.code[/30[12]/]
				return {:stop => true}
			end
			if web_page and web_page.code[/200/]
				CSV.open($csv_file_path,'a+') do | csv_ip_row | 

					web_page.search('.resBB10').each do | row | 
	    
					    zomato_link       = row.css('.result-title').attr('href') 					# zomato link 
					    resto_name        = row.css('.result-title').text 							# resto name
					    resto_address     = row.css('.search-result-address').text 					# resto address
					    rating_votes_temp = row.css('.search_result_rating') 						# resto rating
					    resto_rating 	  = rating_votes_temp.css('.tooltip').text 				 	# rating
					    resto_votes 	  = rating_votes_temp.css('.rating-rank').text 			 	# votes
					    cusine_type_temp  = row.css('.search-page-text') 	 						# cusine type
					    cusines           = cusine_type_temp.css('.res-cuisine').text 
					    cusine_type 	  = cusine_type_temp.css('.res-snippet-small-establishment').text 

						csv_ip_row << [zomato_link,
										resto_name,
										resto_address,
										resto_rating,
										resto_votes,
										cusines,
										cusine_type]

	     			end 
				end
				return {:stop => false}
			end
		rescue Exception => exc 
			puts "Exception at ScrapePage --> web_page_to_csv --> "+exc.message
			raise 'error processing/reading web_page_to_csv'			
		end
	end

    cities.each do | city |
    	category_params.each do | category_param | 
    		begin

    			while page_index < page_index_max
	    			
		    			$web_page_url = endpoint_url+"/"+city+"/"+category_param+"?"+pagination_string+"="+page_index.to_s
						continue = web_page_to_csv()				  
			    		page_index    = page_index + 1
			    		if continue[:stop]
			    			page_index = 1
			    			break
			    		end

    			end 
    		rescue Exception => exc 
    			puts exc.message
    			next
    		end
    	end
    end


