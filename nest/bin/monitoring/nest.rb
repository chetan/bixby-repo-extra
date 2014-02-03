#!/usr/bin/env ruby

use_bundle "system/monitoring"

require "nest_thermostat"

module Bixby
  module Home

    class Nest < Monitoring::Base

      def monitor

        begin
          nest = NestThermostat::Nest.new(:email => @options["email"], :password => @options["password"])
          status = nest.status
        rescue Exception => ex
          return error(ex)
        end

        add_metric({
          :current_temperature => nest.current_temperature,
          :target_temperature  => get_target_temp(nest, status),
          :current_humidity    => nest.humidity,
          :heat                => status["shared"].values.first["hvac_heater_state"],
          :away                => nest.away,
          :status              => status["track"].values.first["online"]
        })

      end


      private

      def get_target_temp(nest, status)
        if !nest.away then
          return nest.temperature
        end

        device = status["device"].values.first
        if device["away_temperature_high_enabled"] then
          return c2f(device["away_temperature_high"])
        elsif device["away_temperature_low_enabled"] then
          return c2f(device["away_temperature_low"])
        else
          return nest.temperature
        end
      end

      def c2f(degrees)
        degrees.to_f * 9.0 / 5 + 32
      end

    end

  end
end

Bixby::Home::Nest.new.run if $0 == __FILE__
