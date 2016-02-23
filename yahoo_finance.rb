require 'open-uri'
require 'nokogiri'
module ReadWebpage

	YAHOO_FINANCE_ENDPOINT = "http://finance.yahoo.com/q?s="

	# reads webpage http://finance.yahoo.com/q?s= 
	# @params - entity firm name 
	# @returns - hash containing page data
	def ReadWebpage.read_yahoo_finance( entity )
		begin 
			if entity.nil? or entity.eql?""
				return {:error => 'entity value missing'}
			end

			webpage_data = {}
			quote_summ = {}
			after_hrs  = {}
			tab_data   = {}

			web_page_url = ReadWebpage::YAHOO_FINANCE_ENDPOINT+entity

			doc = Nokogiri::HTML( open( web_page_url ) )

				quote_summary =  doc.xpath("//*[@id=\"yfi_rt_quote_summary\"]/div[2]/div[1]")		

					quote_summ["quote"] = quote_summary.css(".time_rtq_ticker").text.strip

					quote_summ["value"] = quote_summary.css(".time_rtq_content").text.strip

					quote_summ["time"] = quote_summary.css(".time_rtq").text.strip

				after_hours = doc.xpath("//*[@id=\"yfi_rt_quote_summary\"]/div[2]/div[2]")

					after_hrs["quote"] = after_hours.css(".yfs_rtq_quote").text.strip

					after_hrs["value"] = after_hours.css(".down_r").text.strip

					after_hrs["time"] = after_hours.css(".time_rtq").text.strip

				doc.css("#table1 tr").collect do | row |
					if !row.at("th").nil? and !row.at("td").nil?
						tab_data[ row.at("th").text ] = row.at("td").text.strip 
					end
				end 

				doc.css("#table2 tr").collect do | row |
					if !row.at("th").nil? and !row.at("td").nil?
						tab_data[ row.at("th").text ] = row.at("td").text.strip 
					end
				end 

				webpage_data["quote_summary"] = quote_summ
				webpage_data["after_hours"]   = after_hrs
				webpage_data["tab_data"]      = tab_data
				
				return webpage_data

		rescue Exception => exc 
			puts exc.message
			puts exc.backtrace
		end
	end

end

json_data = ReadWebpage.read_yahoo_finance("IBM")
puts json_data
