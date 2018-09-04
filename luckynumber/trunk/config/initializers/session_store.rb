# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_luckynumber_session',
  :secret      => '00ec7c11f07c2c4c3aed03a07b581cd121d53108bc7d8ebfbd6f851633093e90ac57586c94154c3d09ab50ed8af444816758f33662facb88141885b7bdb644cc'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
