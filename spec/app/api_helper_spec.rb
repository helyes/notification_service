require 'spec_helper'

describe ApiHelper do
  it 'returns unknowns if exception raised' do
    entity_name = ApiHelper.entity_name(nil)
    expect(entity_name).to eq 'unknowns'
  end

  it 'returns entity name' do
    grape_endpoint = double
    allow(grape_endpoint).to receive(:namespace) { 'notification' }
    env = {}
    env[Grape::Env::API_ENDPOINT] = grape_endpoint
    entity_name = ApiHelper.entity_name(env)
    expect(entity_name).to eq 'notification'
  end

  it 'returns entity name if namespace starts with /' do
    grape_endpoint = double
    allow(grape_endpoint).to receive(:namespace) { '/notification' }
    env = {}
    env[Grape::Env::API_ENDPOINT] = grape_endpoint
    entity_name = ApiHelper.entity_name(env)
    expect(entity_name).to eq 'notification'
  end
end
