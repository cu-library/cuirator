  # Configure Capybara and web drivers

  # Use Silent to suppress webserver output -- see Capybara README 
  Capybara.server = :puma, { Silent: true }

  # Set save path for screenshots
  Capybara.save_path = Rails.root.join('tmp', 'capybara')

  # WebDriver options
  options = Selenium::WebDriver::Chrome::Options.new

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.register_driver :headless_chrome do |app|
    options.add_argument('--headless')
    options.add_argument('--disable-gpu')
    options.add_argument('--window-size=1280,4800')

    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.javascript_driver = :headless_chrome

  # Increase default max wait time
  Capybara.default_max_wait_time = 240
  
  # Set webdriver log level
  # Webdrivers.logger.level = :DEBUG

