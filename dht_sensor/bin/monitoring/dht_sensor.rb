#!/usr/bin/env ruby

use_bundle "system/monitoring"

require "dht-sensor-ffi"

module Bixby
  module Home

    class DhtSensor < Monitoring::Base

      def monitor

        pin  = @options["pin"] || 4
        type = @options["sensor_type"] || 22

        # fork a subprocess and change uid to 0 (root) so we can read from /dev/mem
        rd, wr = IO.pipe
        pid = fork do
          rd.close
          Process.uid = 0
          Process.euid = 0
          begin
            reading = ::DhtSensor.read(pin, type)
            hash = {"temperature" => reading.temp_f, "humidity" => reading.humidity}
          rescue Exception => ex
            hash = {"error" => ex.message + "\n" + ex.backtrace.join("\n")}
          end
          wr.write(MultiJson.dump(hash))
          wr.close
        end
        wr.close
        ret = rd.read
        Process.wait(pid)

        if ret.nil? or ret.empty? then
          return error("failed to read from sensor")
        end

        json = MultiJson.load(ret)
        if json["error"] then
          return error(json["error"])
        end

        add_metric({
          :temperature => json["temperature"],
          :humidity    => json["humidity"]
        })

      end

    end

  end
end

Bixby::Home::DhtSensor.new.run if $0 == __FILE__
