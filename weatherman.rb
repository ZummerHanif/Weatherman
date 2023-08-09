class Weatherman
  def initialize(year, folder_name)
    @year = year
    @folder_name = folder_name


  end

  def split
    year,month=ARGV[1].split('/')
    month_names = %w[Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec]
    month_abbr = month_names[month.to_i - 1]

    [year,month_abbr]

  end

  def run
    case ARGV[0]
    when "-e"
      analyze_entire_year

    when "-a"



    year,month_abbr=split
    file_name = "#{@folder_name}/#{@folder_name}_#{year}_#{month_abbr}.txt"

    # Checking if the specified file exists
    unless File.exist?(file_name)
    puts "Error: No file found for the specified year and month in the specified folder."
    exit
    end
    max_temp,min_temp,most_humid_value=analyze_average_monthly_data(file_name)
     puts "Highest average temperature: #{max_temp}°C "
     puts "Lowest Average temperature: #{min_temp}°C  "
     puts "Highest Average  humidity : #{most_humid_value}% "


    when "-c"
      year,month_abbr=split
      file_name = "#{@folder_name}/#{@folder_name}_#{year}_#{month_abbr}.txt"

      # Checking if the specified file exists
      unless File.exist?(file_name)
        puts "Error: No file found for the specified year and month in the specified folder."
        exit
      end

      draw_bar_charts(file_name)
    else
      puts "Invalid command. Usage: ruby weatherman.rb (-e <year> <folder_path> | -a <year/month> <folder_path> | -c <year/month> <folder_path>)"
      exit
    end
  end

  def analyze_entire_year
    matching_files = Dir.glob("#{@folder_name}/*_#{@year}_*.txt")

    if matching_files.empty?
      puts "Error: No files found for the specified year in the specified folder."
      exit
    end

    max_temps = []
    max_dates = []
    min_temps = []
    min_dates = []
    humidities = []
    humid_dates = []

    matching_files.each do |file_path|
      max_temp, max_date, min_temp, min_date, humidity, humid_date = analyze_weather_data(file_path, @year)
      max_temps << max_temp
      max_dates << max_date
      min_temps << min_temp
      min_dates << min_date
      humidities << humidity
      humid_dates << humid_date
    end

    max_temp_of_all = max_temps.max
    max_temp_date = max_dates[max_temps.index(max_temp_of_all)]
    min_temp_of_all = min_temps.min
    min_temp_date = min_dates[min_temps.index(min_temp_of_all)]
    max_humidity = humidities.max
    max_humidity_date = humid_dates[humidities.index(max_humidity)]

    puts "Highest: #{max_temp_of_all}°C on #{max_temp_date}"
    puts "Lowest: #{min_temp_of_all}°C on #{min_temp_date}"
    puts "Humid: #{max_humidity}% on #{max_humidity_date}"
  end

  def analyze_weather_data(file_path, target_year)
    highest_temperature_value = -Float::INFINITY
  highest_temperature_date = ''
  lowest_temperature_value = Float::INFINITY
  lowest_temperature_date = ''
  most_humid_value = 0
  most_humid_date = ''

  File.open(file_path, "r") do |file|
    header = file.readline
    file.each_line do |line|
      fields = line.chomp.split(',')
      date = fields[0]
      file_year = date.split('-')[0] # Extract the year from the date
      next unless file_year == target_year # Skip if not the specified year

      max_temp = fields[1].to_i
      min_temp = fields[3].to_i
      humidity = fields[7].to_i

      if max_temp > highest_temperature_value
        highest_temperature_value = max_temp
        highest_temperature_date = date
      end

      if min_temp < lowest_temperature_value
        lowest_temperature_value = min_temp
        lowest_temperature_date = date
      end

      if humidity > most_humid_value
        most_humid_value = humidity
        most_humid_date = date
      end
    end
  end

  [highest_temperature_value, highest_temperature_date, lowest_temperature_value, lowest_temperature_date, most_humid_value, most_humid_date]
end



  def analyze_average_monthly_data(file_path)


    target_year, target_month = ARGV[1].split('/')



    highest_average_temperature_value = -Float::INFINITY
    lowest_average_temperature_value = Float::INFINITY
    average_max_humidity = 0

    File.open(file_path, "r") do |file|
      header = file.readline
      file.each_line do |line|
        fields = line.chomp.split(',')
        date = fields[0]
        file_year = date.split('-')[0] # Extract the year from the date
        file_month = date.split('-')[1]
        next unless file_year == target_year && file_month== target_month # Skip if not the specified year

        avg_temp = if fields[2].empty?
          (fields[1].to_i + fields[3].to_i) / 2
        else
          fields[2].to_i
        end
        avg_humidity = fields[8].to_i


        if  avg_temp  > highest_average_temperature_value
          highest_average_temperature_value = avg_temp

        end

        if avg_temp < lowest_average_temperature_value
          lowest_average_temperature_value = avg_temp


        end

        if avg_humidity > average_max_humidity
          average_max_humidity = avg_humidity

        end
      end
    end

    [highest_average_temperature_value,lowest_average_temperature_value,average_max_humidity]
  end

  end

  def draw_bar_charts(file_name)

    target_year, target_month = ARGV[1].split('/')

    File.open(file_name, "r") do |file|
      header = file.readline
      counter=1

      file.each_line do |line|
        fields = line.chomp.split(',')
        date = fields[0]
        file_year = date.split('-')[0] # Extract the year from the date
        file_month = date.split('-')[1]
        next unless file_year == target_year && file_month== target_month # Skip if not the specified year

        highest_temp = fields[1].to_i
        lowest_temp =fields[3].to_i


        green_color = "\e[32m"
        red_color = "\e[31m"
        reset_color = "\e[0m"

       puts "#{counter}"  "#{green_color} #{'+' * highest_temp}#{red_color}#{'+' * lowest_temp.abs}#{reset_color}#{highest_temp}°C _ #{lowest_temp}°C"
       counter+=1

      end
      reset_color = "\e[0m"
     puts "#{reset_color}"
    end
  end




year = ARGV[1]
folder_name = ARGV[2]

analyzer = Weatherman.new(year, folder_name)
analyzer.run
