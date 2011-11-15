desc "Delete files older than 5 days"
task :delete_old_files => :environment do
  assets = Asset.where("uploaded_file_updated_at < ?", 5.day.ago)
  assets.each do |asset|
    asset.destroy
  end
end