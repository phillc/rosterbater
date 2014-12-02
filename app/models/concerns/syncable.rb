module Syncable
  def currently_syncing?
    return false if !sync_started_at
    refresh_time = 1.minute

    if sync_started_at > refresh_time.ago
      !sync_finished_at? || sync_finished_at < sync_started_at
    else
      false
    end
  end
end

