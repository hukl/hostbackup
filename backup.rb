require 'fileutils'
require 'yaml'

config = YAML.load_file( 'hosts.yml' )

BackupFolder = File.join( %w(/ Volumes Data Backups hostbackup) )


config["hosts"].each do |key, host|
  puts host.inspect
  host["backup_paths"].each do |path|
    local_path = File.join(BackupFolder, host["hostname"], path.split("/")[0..-2])
    FileUtils.makedirs( local_path ) unless File.exists?( local_path )

    %x{scp -rCq #{host["username"]}@#{host["hostname"]}:#{path} #{local_path}}
  end
end

%x{cd #{BackupFolder} && git add * && git commit -m 'Snapshot: #{Time.now}'}
