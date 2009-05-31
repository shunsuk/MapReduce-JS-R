# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_map_reduce_session',
  :secret      => 'c384a4cb554cc6e7848caf39e8b51ce6b451e95cc64d0d4d5e82de48f8c9ff7fcd1146145463dfee3d2bdfcaeb3b3a28c494cccd0ac8ac278b52f12d674f2d6c'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
