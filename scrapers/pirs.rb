module Scrapers
  class Pirs
    class << self
      def scrape(row)
        davcna = row[0].value.to_i

        options = Selenium::WebDriver::Chrome::Options.new
        options.add_argument('--ignore-certificate-errors')
        options.add_argument('--disable-popup-blocking')
        options.add_argument('--disable-translate')
        options.add_argument('--headless')
        options.add_argument('--no-sandbox')
        options.add_argument('--disable-dev-shm-usage')
        driver = Selenium::WebDriver.for :chrome, options: options
        driver.navigate.to("https://pirs.si/#/")

        driver.find_element(name: 'searchKey').send_keys(davcna)
        driver.find_element(:css, '#searchButton .btn.btn-primary').click

        wait = Selenium::WebDriver::Wait.new(timeout: 20) # seconds
        wait.until do
          el = driver.find_element(:css, '.title.hand')
          el if el.enabled? && el.displayed?
        end

        sleep(2)

        driver.find_element(:css, '.title.hand').click

        wait = Selenium::WebDriver::Wait.new(timeout: 10) # seconds
        wait.until { driver.find_element(:css, '.nav.nav-tabs.justify-content-start') }

        element = driver.find_element(:css, '[column="email"] a')
        return if element.nil?

        scrape_success(row, davcna, element.text, driver.current_url)

        driver.quit
      rescue StandardError => e
        puts e.message
        puts e.class
        if e.kind_of?(Selenium::WebDriver::Error::UnknownError)
          return scrape(row)
        end

        scrape_failed(row, davcna)
        driver.quit

      end

      private

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
