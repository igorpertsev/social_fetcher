RSpec.describe ::Requesters::Common do
  subject { described_class.new }

  let(:facebook_response) { Typhoeus::Response.new(code: 200, body: { facebook: ['test facebook'] }.to_json) }
  let(:instagram_response) { Typhoeus::Response.new(code: 200, body: { instagram: ['test instagram'] }.to_json) }
  let(:twitter_response) { Typhoeus::Response.new(code: 200, body: { twitter: ['test twitter'] }.to_json) }

  before do
    Typhoeus.stub('https://takehome.io/facebook').and_return(facebook_response)
    Typhoeus.stub('https://takehome.io/instagram').and_return(instagram_response)
    Typhoeus.stub('https://takehome.io/twitter').and_return(twitter_response)
  end

  describe '#call' do
    it 'returns data for facebook' do
      expect(subject.call['facebook']).to eq(JSON.parse(facebook_response.body))
    end

    it 'returns data for twitter' do
      expect(subject.call['twitter']).to eq(JSON.parse(twitter_response.body))
    end

    it 'returns data for instagram' do
      expect(subject.call['instagram']).to eq(JSON.parse(instagram_response.body))
    end

    context 'facebook response contains error' do
      let(:facebook_response) { Typhoeus::Response.new(code: 500, body: 'ERROR') }

      it 'returns empty data for facebook' do
        expect(subject.call['facebook']).to be_empty
      end

      it 'returns received error in erros block for facebook' do
        expect(subject.call[:errors]['facebook']).to eq(facebook_response.body)
      end
    end

    context 'twitter response contains error' do
      let(:twitter_response) { Typhoeus::Response.new(code: 500, body: 'ERROR') }

      it 'returns empty data for twitter' do
        expect(subject.call['twitter']).to be_empty
      end

      it 'returns received error in erros block for twitter' do
        expect(subject.call[:errors]['twitter']).to eq(twitter_response.body)
      end
    end

    context 'instagram response contains error' do
      let(:instagram_response) { Typhoeus::Response.new(code: 500, body: 'ERROR') }

      it 'returns empty data for instagram' do
        expect(subject.call['instagram']).to be_empty
      end

      it 'returns received error in erros block for instagram' do
        expect(subject.call[:errors]['instagram']).to eq(instagram_response.body)
      end
    end
  end

  describe '#build_request_for' do
    it "calls build for Facebook" do
      expect(::RequestBuilders::Facebook).to receive(:build)
      subject.send(:build_request_for, 'facebook')
    end

    it "calls build for Instagram" do
      expect(::RequestBuilders::Instagram).to receive(:build)
      subject.send(:build_request_for, 'instagram')
    end

    it "calls build for Twitter" do
      expect(::RequestBuilders::Twitter).to receive(:build)
      subject.send(:build_request_for, 'twitter')
    end

    it 'returns nil for other values' do
      expect(subject.send(:build_request_for, 'test')).to be_nil
    end
  end

  describe '#build_requests' do
    let(:facebook_request) { Typhoeus::Request.new('https://takehome.io/facebook', method: :get, headers: { Accept: "application/json" }) }
    let(:instagram_request) { Typhoeus::Request.new('https://takehome.io/instagram', method: :get, headers: { Accept: "application/json" }) }
    let(:twitter_request) { Typhoeus::Request.new('https://takehome.io/twitter', method: :get, headers: { Accept: "application/json" }) }
    let(:hydra) { double }

    before do
      allow(subject).to receive(:hydra).and_return(hydra)
      allow(hydra).to receive(:queue)

      allow(subject).to receive(:build_request_for).with('facebook').and_return(facebook_request)
      allow(subject).to receive(:build_request_for).with('instagram').and_return(instagram_request)
      allow(subject).to receive(:build_request_for).with('twitter').and_return(twitter_request)
    end

    it "builds request for social networks" do
      expect(subject).to receive(:build_request_for).with('facebook').and_return(facebook_request)
      expect(subject).to receive(:build_request_for).with('instagram').and_return(instagram_request)
      expect(subject).to receive(:build_request_for).with('twitter').and_return(twitter_request)

      subject.send(:build_requests)
    end

    it "adds callback to request for social networks" do
      expect(subject).to receive(:add_callback).with('facebook', facebook_request)
      expect(subject).to receive(:add_callback).with('instagram', instagram_request)
      expect(subject).to receive(:add_callback).with('twitter', twitter_request)

      subject.send(:build_requests)
    end

    it "adds requests for social networks to hydra queue" do
      expect(hydra).to receive(:queue).with(facebook_request)
      expect(hydra).to receive(:queue).with(instagram_request)
      expect(hydra).to receive(:queue).with(twitter_request)

      subject.send(:build_requests)
    end
  end

  describe '#callback' do
    context 'successful response' do
      let(:response) { Typhoeus::Response.new(code: 200, body: [ response: 'test facebook' ].to_json) }

      it 'adds response body to responses list' do
        subject.send(:build_defaults)
        subject.send(:callback, 'facebook', response)

        expect(subject.responses['facebook']).to eq(JSON.parse(response.body))
      end
    end

    context 'response with error' do
      let(:response) { Typhoeus::Response.new(code: 500, body: 'Error') }

      it 'adds response body to errors list for social network and set empty response in list' do
        subject.send(:build_defaults)
        subject.send(:callback, 'facebook', response)

        expect(subject.responses['facebook']).to be_empty
        expect(subject.responses[:errors]['facebook']).to eq(response.body)
      end
    end
  end
end
