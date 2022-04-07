# EtaShare API

API to share account information between peers

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- GET `api/v1/accounts`: returns all accounts IDs
- GET `api/v1/accounts/[ID]`: returns details about a single account (ID -> String)
- POST `api/v1/accounts/{new_account}`: Creates a new account with given information
