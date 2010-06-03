require 'fileutils'
require 'yaml'

BackupFolder = ARGV[0]
config = YAML.load_file( File.join(BackupFolder, 'hosts.yml' ) )

raise "Backup dir does not exist" unless File.exists? BackupFolder

config["hosts"].each do |key, host|
  puts host.inspect
  host["backup_paths"].each do |path|
    local_path = File.join(BackupFolder, host["hostname"], path.split("/")[0..-2])
    FileUtils.makedirs( local_path ) unless File.exists?( local_path )

    %x{scp -rCpq #{host["username"]}@#{host["hostname"]}:#{path} #{local_path}}
  end
end

unless File.exists?( ( git_dir = File.join(BackupFolder, ".git") ) )
  %x{cd #{BackupFolder} && git init}
end

%x{cd #{BackupFolder} && git add * && git commit -m 'Snapshot: #{Time.now}'}
