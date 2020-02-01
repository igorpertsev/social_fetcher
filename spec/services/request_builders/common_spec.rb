RSpec.shared_examples 'common request builder tests' do |_|
  describe '#build' do
    subject { described_class.build }

    it 'returns Typhoeus request with valid url' do
      expect(subject.url).to eq(described_class.url)
    end

    it 'returns Typhoeus request with valid method' do
      expect(subject.options[:method]).to eq(:get)
    end

    it 'returns Typhoeus request with valid headers' do
      expect(subject.options[:headers][:Accept]).to eq('application/json')
    end
  end
end

