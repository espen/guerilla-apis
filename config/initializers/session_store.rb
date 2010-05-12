# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_trafikanten_session',
  :secret => '150d444fc183ff59def59dffd4b8621e5647aea89171dd760c4c373bffeed1b7dcd4d9ea90c11305802196ddd3e555b7e261131c513f080a8af8e861870d1821'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
