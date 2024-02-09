# frozen_string_literal: true

class User
  include ActiveModel::Model

  ATTRIBUTES = %w[
    country
    country_code
    email
    email_verified
    id
    name
    nickname
    picture
    postcode
    profile
    roles
  ].freeze

  attr_accessor(*ATTRIBUTES)

  def attributes
    ATTRIBUTES.index_with { |_k| nil }
  end

  def role?(role:)
    return false if roles.nil?

    roles.to_s.split(',').map(&:strip).include? role.to_s
  end

  def school_owner?
    role?(role: 'school-owner')
  end

  def school_teacher?
    role?(role: 'school-teacher')
  end

  def school_student?
    role?(role: 'school-student')
  end

  def ==(other)
    id == other.id
  end

  def self.where(id:)
    from_userinfo(ids: id)
  end

  def self.from_userinfo(ids:)
    user_ids = Array(ids)

    UserinfoApiClient.fetch_by_ids(user_ids).map do |info|
      info = info.stringify_keys
      args = info.slice(*ATTRIBUTES)

      new(args)
    end
  end

  def self.from_omniauth(token:)
    return nil if token.blank?

    auth = HydraPublicApiClient.fetch_oauth_user(token:)
    return nil unless auth

    auth = auth.stringify_keys
    args = auth.slice(*ATTRIBUTES)
    args['id'] = auth['sub']

    new(args)
  end
end
