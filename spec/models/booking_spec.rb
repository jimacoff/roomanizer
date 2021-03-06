require 'rails_helper'

RSpec.describe Booking do
  it { is_expected.to validate_presence_of(:start_at) }
  it { is_expected.to validate_presence_of(:end_at) }
  it { is_expected.to belong_to(:bookable) }
  it { is_expected.to belong_to(:organisator) }

  it 'is expected to start before end' do
    now = Time.now
    booking = Booking.new start_at: now, end_at: now - 12.hours
    expect(booking.valid?).to be false
    expect(booking.errors.full_messages).to include 'End at must be after 2015-06-15 14:33:52'
  end

  describe 'availability' do
    before do
      @room = create :room, bookings:[ Booking.new(start_at: Time.now + 1.hour, end_at: Time.now + 3.hour) ]
      @workspace = create :workspace, room: @room, bookings:[ Booking.new(start_at: Time.now + 10.hour, end_at: Time.now + 13.hour) ]
    end

    it 'raises an error if there is a start from another booking in between' do
      valid_booking = Booking.new(bookable: @room, start_at: Time.now - 2.hours, end_at: Time.now - 1.hours)
      expect(valid_booking).to be_valid

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 30.minutes, end_at: Time.now + 2.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 9.hours, end_at: Time.now + 12.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 16 Jun 00:33')

      invalid_booking = Booking.new(bookable: @workspace, start_at: Time.now + 30.minutes, end_at: Time.now + 2.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')

    end

    it 'raises an error if there is an end from another booking in between' do
      valid_booking = Booking.new(bookable: @room, start_at: Time.now - 2.hours, end_at: Time.now - 1.hours)
      expect(valid_booking).to be_valid

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 2.hours, end_at: Time.now + 4.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 11.hours, end_at: Time.now + 14.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 16 Jun 03:33')

      invalid_booking = Booking.new(bookable: @workspace, start_at: Time.now + 2.hours, end_at: Time.now + 4.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')
    end

    it 'raises an error if there is another booking in between' do
      valid_booking = Booking.new(bookable: @room, start_at: Time.now - 2.hours, end_at: Time.now - 1.hours)
      expect(valid_booking).to be_valid

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 30.minutes, end_at: Time.now + 4.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 10.hours, end_at: Time.now + 14.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 16 Jun 00:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 16 Jun 03:33')

      invalid_booking = Booking.new(bookable: @workspace, start_at: Time.now + 30.minutes, end_at: Time.now + 4.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')
    end

    it 'raises an error if it is between another booking' do
      valid_booking = Booking.new(bookable: @room, start_at: Time.now - 2.hours, end_at: Time.now - 1.hours)
      expect(valid_booking).to be_valid

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 1.hour + 30.minutes, end_at: Time.now + 2.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')

      invalid_booking = Booking.new(bookable: @room, start_at: Time.now + 11.hours, end_at: Time.now + 12.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 16 Jun 00:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 16 Jun 03:33')

      invalid_booking = Booking.new(bookable: @workspace, start_at: Time.now + 1.hour + 30.minutes, end_at: Time.now + 2.hours)
      expect(invalid_booking).not_to be_valid
      expect(invalid_booking.errors.full_messages).to include('Start at reserved from 15 Jun 15:33')
      expect(invalid_booking.errors.full_messages).to include('End at reserved until 15 Jun 17:33')
    end
  end
end
