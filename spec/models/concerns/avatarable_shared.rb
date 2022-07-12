require 'rails_helper'

shared_examples_for 'avatarable' do
  let(:avatarable) { create(described_class.to_s.underscore) }

  it { is_expected.to have_one_attached(:avatar) }

  it 'add avatar_url method' do
    expect(avatarable.respond_to?(:avatar_url)).to eq true
  end

  context 'when avatarable has an email attribute' do
    it 'enques job when email is changed on avatarable create' do
      avatarable = build(described_class.to_s.underscore, account: create(:account))
      if avatarable.respond_to?(:email)
        avatarable.email = 'test@test.com'
        expect(Avatar::AvatarFromGravatarJob).to receive(:set).with(wait: 30.seconds).and_call_original
      end
      avatarable.save!
      expect(Avatar::AvatarFromGravatarJob).to have_been_enqueued.with(avatarable, avatarable.email) if avatarable.respond_to?(:email)
    end

    it 'enques job when email is changes on avatarable update' do
      if avatarable.respond_to?(:email)
        avatarable.email = 'xyc@test.com'
        expect(Avatar::AvatarFromGravatarJob).to receive(:set).with(wait: 30.seconds).and_call_original
      end
      avatarable.save!
      expect(Avatar::AvatarFromGravatarJob).to have_been_enqueued.with(avatarable, avatarable.email) if avatarable.respond_to?(:email)
    end

    it 'will not enqueu when email is not changed on avatarable update' do
      avatarable = build(described_class.to_s.underscore, account: create(:account))
      avatarable.email = nil if avatarable.respond_to?(:email)
      avatarable.save!
      expect(Avatar::AvatarFromGravatarJob).not_to have_been_enqueued.with(avatarable, avatarable.email)
    end
  end
end
