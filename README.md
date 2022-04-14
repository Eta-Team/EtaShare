# EtaShare API

API to share account information between peers

## Routes

All routes return JSON

- GET `/`: Root route shows if Web API is running
- GET `api/v1/links/[link_id]/files/[file_id]`: Get a file
- GET `api/v1/links/[link_id]/files`: Get list of files for link
- POST `api/v1/links/[ID]/files/`: Upload file for a link
- GET `api/v1/links/[ID]`: Get information about a link
- GET `api/v1/links/`: Get lsit of all links
- POST `api/v1/links/`: Create new link
