#!/usr/bin/env ruby

use_bundle "system/monitoring"

require "dht-sensor-ffi"

module Bixby
  module Home

    class DhtSensor < Monitoring::Base

      def monitor

        pin  = @options["pin"] || 4
        type = @options["sensor_type"] || 22

        begin
          reading = ::DhtSensor.read(pin, type)
        rescue Exception => ex
          return error(ex)
        end

        add_metric({
          :temperature => reading.temp_f,
          :humidity    => reading.humidity
        })

      end

    end

  end
end

Bixby::Home::DhtSensor.new.run if $0 == __FILE__
