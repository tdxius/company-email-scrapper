module Scrapers
  class Bizi
    class << self
      def scrape(row)
        davcna = row[0].value.to_i

        index_page_url = index_page_url(davcna)
        index_a = find_element(index_page_url, 'table tbody tr:nth-child(1) a')
        return scrape_failed(row, davcna) if index_a.nil?

        show_page_url = index_a.attribute('href')
        mail_a = find_element(show_page_url, '.main .i-email a')
        return scrape_failed(row, davcna) if mail_a.nil?

        email = extract_email(mail_a)

        scrape_success(row, davcna, email, show_page_url)
      end

      private

      def index_page_url(davcna)
        "https://www.bizi.si/iskanje?q=#{davcna}"
      end

      def ip_blocked?(response)
        response.include? 'smo vam za določen čas onemogočili dostop'
      end

      def find_element(url, css)
        response = HTTParty.get(url)
        if ip_blocked?(response)
          raise StandardError.new('IP has been blocked.')
        end

        document = Nokogiri::HTML(response.body)
        document.at_css(css)
      end

      def extract_email(a)
        href = a.attribute('href').to_s
        href.sub('mailto:', '')
      end

      def mark_as_processed(row)
        row[8].change_contents(1)
      end

      def update_row(row, email, url)
        row[6].change_contents(email)
        row[7].change_contents(url)
      end

      def scrape_failed(row, davcna)
        mark_as_processed(row)
        puts "#{row[0].row}: Davcna #{davcna} not found.".red
      end

      def scrape_success(row, davcna, email, url)
        update_row(row, email, url)
        mark_as_processed(row)
        puts "#{row[0].row}: #{davcna} = #{email}".green
      end
    end
  end
end
