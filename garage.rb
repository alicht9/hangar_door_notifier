#!/usr/bin/ruby
#
# Copyright (c) Adam Licht alicht@gmail.com  2013
# All rights resereved
#
#

require 'pi_piper'
require 'mail'
require 'yaml'
require 'time'
include PiPiper



class Garage
	def initialize config
		@config_file=config
		raise "You have to give me a config yml" unless @config_file
		@config = YAML.load(File.read(@config_file))
		$to = @config['TO']
		mail_options = { :address => "smtp.gmail.com",
				 :port    => 587,
				 :domain  => 'localhost',
				 :user_name => @config['USER'],
				 :password  => @config['PASSWORD'],
				 :authentication => 'plain',
				 :enable_starttls_auto => true }

		Mail.defaults do
		  puts "Setting up E-Mail service"
		  delivery_method :smtp, mail_options
		end
	end

	def setup_radio pin, led
		  watch ({:pin => pin, :trigger => :rising}) do
		    
		    time = Time.now.localtime
		    puts "Pin #{pin} Changed from #{last_value} to #{value} at #{time}"
		      led.off
			puts "Sending Emails"
			$to.each do |email|
			  Mail.deliver do
			    to email
			    from 'Your_Garage_Door'
			    subject 'Hangar door'
			    body "Hangar door activated via radio. At #{time}"
			  end
			end
			sleep 5
			led.on
		  end
	end	

	def setup_internal pin, led
	 
		  watch ({:pin => pin, :trigger => :rising}) do
		    
		    time = Time.now.localtime
		    puts "Pin #{pin} Changed from #{last_value} to #{value} at #{time}"
		      led.off
			puts "Sending Emails"
			email = $to[0]
			  Mail.deliver do
			    to email
			    from 'Your_Garage_Door'
			    subject 'Hangar door'
			    body "Hangar door activated via INSIDE switch at #{time}."
			  end
			sleep 5
			led.on
		  end
	 end

	def run
		pins = {:led => 24, :radio => 18, :internal =>15}
		pins.each do |key, value|
		  puts "#{key} is on pin #{value}"
		end

		led = PiPiper::Pin.new(:pin => pins[:led].to_i, :direction => :out)
		led.on
		setup_radio pins[:radio], led
		setup_internal pins[:internal], led
		puts 'watching input'
		PiPiper.wait
  	 end
		  

end

g = Garage.new ARGV[0]
g.run
