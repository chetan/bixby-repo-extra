#!/usr/bin/env ruby

use_bundle "system/monitoring"

require "nest_thermostat"

module Bixby
  module Home

    class Nest < Monitoring::Base

      def monitor

        begin
          nest = NestThermostat::Nest.new(:email => @options["email"], :password => @options["password"])
        rescue Exception => ex
          return error(ex)
        end

        add_metric({
          :current_temperature => nest.current_temperature,
          :target_temperature  => nest.temperature,
          :current_humidity    => nest.humidity,
          :away                => nest.away,
          :status              => nest.status["track"].values.first["online"]
        })

      end

    end

  end
end

Bixby::Home::Nest.new.run if $0 == __FILE__
