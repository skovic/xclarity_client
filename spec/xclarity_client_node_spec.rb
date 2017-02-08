require 'spec_helper'

describe XClarityClient do
  before :all do
    WebMock.allow_net_connect! # -- This line should be uncommented if you're using external mock test

    conf = XClarityClient::Configuration.new(
      username:   ENV['LXCA_USERNAME'],
      password:   ENV['LXCA_PASSWORD'],
      host:       ENV['LXCA_HOST'],
      auth_type:  ENV['LXCA_AUTH_TYPE'],
      verify_ssl: ENV['LXCA_VERIFY_SSL']
    )

    @client = XClarityClient::Client.new(conf)

    @includeAttributes = %w(accessState activationKeys)
    @excludeAttributes = %w(accessState activationKeys)
  end

  before :each do
    @uuidArray = @client.discover_nodes.map { |node| node.uuid  }
  end

  it 'has a version number' do
    expect(XClarityClient::VERSION).not_to be nil
  end

  describe 'GET /nodes' do

    it 'should respond with an array' do
      expect(@client.discover_nodes.class).to eq(Array)
    end

  end

  describe 'GET /nodes/UUID' do
    context 'with include attributes' do
      it 'required attributes should not be nil' do
        response = @client.fetch_nodes(@uuidArray, @includeAttributes,nil)
        response.map do |node|
          @includeAttributes.map do |attribute|
            expect(node.send(attribute)).not_to be_nil
          end
        end
      end
    end

    context 'with excludeAttributes' do
      it 'excluded attributes should to be nil' do
        response = @client.fetch_nodes(@uuidArray, nil, @excludeAttributes)
        response.map do |node|
          @excludeAttributes.map do |attribute|
            expect(node.send(attribute)).to be_nil
          end
        end
      end
    end
  end

  describe 'GET /nodes/UUID,UUID,...,UUID' do

    context 'with includeAttributes' do
      it 'required attributes shoud not be nil ' do
        response = @client.fetch_nodes(@uuidArray, @includeAttributes,nil)
        response.map do |node|
          @includeAttributes.map do |attribute|
            expect(node.send(attribute)).not_to be_nil
          end
        end
      end
    end

    context 'with excludeAttributes' do
      it 'excluded attributes shoud to be nil' do
        response = @client.fetch_nodes(@uuidArray, nil, @excludeAttributes)
        response.map do |node|
          @excludeAttributes.map do |attribute|
            expect(node.send(attribute)).to be_nil
          end
        end
      end
    end
  end

  describe 'GET /nodes' do

    context 'with includeAttributes' do
      it 'required attributes should not be nil' do
        response = @client.fetch_nodes(nil,@includeAttributes,nil)
        response.first do |node|
          @includeAttributes.map do |attribute|
            expect(node.send(attribute)).not_to be_nil
          end
        end
      end
    end

    context 'with excludeAttributes' do
      it 'excluded attributes should be nil' do
        response = @client.fetch_nodes(nil,nil,@excludeAttributes)
        response.map do |node|
          @excludeAttributes.map do |attribute|
            expect(node.send(attribute)).to be_nil
          end
        end
      end
    end
  end

  describe 'Get /node' do
    it 'should power down system' do
      response = @client.set_node_power_state(@uuidArray[0])
      expect(response.status).to eq(200)

      puts response.headers.location
    end
  end

  describe 'PUT /nodes/UUID' do
    context 'with a leds object' do
      context 'with state == "On" and name == "Identify"' do
        it 'turns on the location led' do
          @client.turn_on_loc_led(@uuidArray[0])
          uri = "http://example.com/nodes/#{@uuidArray[0]}"
          request_body = { 'body' => { 'leds' => [{ 'name'  => 'Identify',
                                                    'state' => 'On' }] } }
          expect(a_request(:put, uri).with(request_body)).to have_been_made
        end
      end

      context 'with state == "Off" and name == "Identify"' do
        it 'turns off the location led' do
          @client.turn_off_loc_led(@uuidArray[0])
          uri = "http://example.com/nodes/#{@uuidArray[0]}"
          request_body = { 'body' => { 'leds' => [{ 'name'  => 'Identify',
                                                    'state' => 'Off' }] } }
          expect(a_request(:put, uri).with(request_body)).to have_been_made
        end
      end

      context 'with state == "Blinking" and name == "Identify"' do
        it 'turns on the blinking location led' do
          @client.turn_on_loc_led(@uuidArray[0], true)
          uri = "http://example.com/nodes/#{@uuidArray[0]}"
          request_body = { 'body' => { 'leds' => [{ 'name'  => 'Identify',
                                                    'state' => 'Blinking' }] } }
          expect(a_request(:put, uri).with(request_body)).to have_been_made
        end
      end
    end
  end
end
