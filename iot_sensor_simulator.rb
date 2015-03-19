require 'cuba'
require 'slim'
require 'cuba/render'

require 'mqtt'

module Sender

  def self.setup app
    app.settings[:mqtt_client] = MQTT::Client.new(
      ENV['XIVELY_URL'] || 'test.mosquitto.org')
  end

  def publish topic, payload
    client = settings[:mqtt_client]
    client.connect unless client.connected?
    client.publish topic, payload
  end

end

Cuba.use Rack::Static, urls: %w[/js /css /img], root: 'public'
Cuba.plugin Cuba::Render
Cuba.settings[:render][:template_engine] = 'slim'

Cuba.plugin Sender

Cuba.define do
  on get, root do
    render 'index'
  end

  on post do
    on 'publish/:topic/:payload' do |topic, payload|
      publish topic, payload
      res.write 'ok'
    end
  end
end
