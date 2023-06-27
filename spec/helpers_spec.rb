require_relative '../views/helpers'

describe 'Helper' do
  it '#dates' do
    expect(Helpers.dates(1)).to be_a(Hash)
    expect(Helpers.dates.size).to eq(16)
  end
end
