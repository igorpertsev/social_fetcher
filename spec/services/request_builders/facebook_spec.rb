RSpec.describe ::RequestBuilders::Facebook do
  include_examples 'common request builder tests'

  describe '#url' do
    it 'returns valid url' do
      expect(described_class.url).to eq('https://takehome.io/facebook')
    end
  end
end
