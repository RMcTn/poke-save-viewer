json.extract! gen1_entry, :id, :playerName, :saveFile, :created_at, :updated_at
json.url gen1_entry_url(gen1_entry, format: :json)
json.saveFile url_for(gen1_entry.saveFile)
