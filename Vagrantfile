# This Vagrantfile was created by docker-osx-dev. It is used to create a 
# productive development environment with Docker, Vagrant, and Rsync on OS X.
# See https://github.com/brikis98/docker-osx-dev for more info.
# See also https://raw.githubusercontent.com/brikis98/docker-osx-dev/master/setup.sh
# See also https://raw.githubusercontent.com/brikis98/docker-osx-dev/master/docker-osx-dev

DOCKER_COMPOSE_FILE = "docker-compose.yml"
DOCKER_COMPOSE_VOLUMES_KEY = "volumes"
DOCKER_COMPOSE_VOLUMES_SEPARATOR = ":"

VAGRANTFILE_API_VERSION = "2"
VAGRANT_ROOT = File.dirname(__FILE__)
VAGRANT_FOLDER_NAME = File.basename(VAGRANT_ROOT)
DEFAULT_FOLDERS_TO_SYNC = [{:src => VAGRANT_ROOT, :dest => VAGRANT_ROOT}]  

# Set default provider
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

# Parse .gitignore style files and return the entries within
def parse_ignore_file(file)
  if File.exist?(file)
    IO.read(file)
      .split("\n")
      .reject{|line| line.empty? || line.start_with?("#")}
  else
    []
  end
end

# Determine the folders to sync to the VM based on the volumes specified in the
# docker-compose file. If this project isn't using docker-compose, sync the
# current directory.
def folders_to_sync
  docker_compose_file = File.join(VAGRANT_ROOT, DOCKER_COMPOSE_FILE)
  if File.exist?(docker_compose_file)
    require 'yaml'
    docker_compose_config = YAML::load_file(docker_compose_file)
    volumes = docker_compose_config.values.map { |container| container.fetch(DOCKER_COMPOSE_VOLUMES_KEY, []) }.flatten
    local_volumes = volumes.select { |volume| volume.include?(DOCKER_COMPOSE_VOLUMES_SEPARATOR) }
    local_volumes.map do |volume| 
      src, _ = volume.split(DOCKER_COMPOSE_VOLUMES_SEPARATOR)
      absolute_src = File.expand_path(src)
      # Note: destination needs to be same as source. This way, /foo on the host
      # machine (OS X) ends up at /foo on the VM. This is because the volumes
      # entries in docker-compose.yml and the volumes specified in the -v flag
      # to docker are looking for folders on the VM.
      {:src => absolute_src, :dest => absolute_src}
    end
  else
    DEFAULT_FOLDERS_TO_SYNC
  end
end

Vagrant.require_version ">= 1.6.3"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "boot2docker"

  config.vm.box = "blinkreaction/boot2docker"
  config.vm.box_version = "1.6.0"
  config.vm.box_check_update = false

  # When syncing, exclude any files in .gitignore or .dockerignore
  excludes = (parse_ignore_file(".gitignore") + parse_ignore_file(".dockerignore")).uniq

  # Sync folders using rsync. The --omit-dir-times flag makes sure folder
  # timestamps aren't updated just because a file changed within them. The
  # --inplace and --whole-file flags tells rsync to overwrite the file in place 
  # in one step rather than creating a temp file or updating one small piece at
  # a time. Both of these reduce unnecessary restarts and recompiles in file 
  # watch mechanisms.
  folders_to_sync.each do |folder|
    config.vm.synced_folder folder[:src], folder[:dest],
      type: "rsync",
      rsync__exclude: excludes,
      rsync__args: ["--verbose", "--archive", "--delete", "-z", "--chmod=ugo=rwX", "--omit-dir-times", "--inplace", "--whole-file"]
  end

  # Decreate this number for faster syncing on small projects; increase it for
  # better performance on large projects. For more info, see 
  # https://github.com/smerrill/vagrant-gatling-rsync
  config.gatling.latency = 0.5

  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |v|
    v.gui = false
    #BRIAN EDIT - want to share VM instances
    v.name = "boot2docker"
    #v.name = VAGRANT_FOLDER_NAME + "_boot2docker"
    #BRIAN EDIT
    v.cpus = 2
    #v.cpus = 1
    #v.memory = 2048
    #BRIAN EDIT
    v.memory = 8192

    # Necessary to ensure "sending build to context" runs quickly
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]    
    v.customize ["modifyvm", :id, "--nictype1", "virtio"]
  end

  #BRIAN EDIT
  config.vm.network "forwarded_port", host: 4502, guest: 4502
  config.vm.network "forwarded_port", host: 4503, guest: 4503

  #BRIAN EDIT
  config.vm.post_up_message = "Your Linux VM running Docker containers is now active."

  # Allow Mac OS X docker client to connect to Docker without TLS auth.
  # https://github.com/deis/deis/issues/2230#issuecomment-72701992
  config.vm.provision :shell do |s|
    s.inline = <<-EOT
      echo 'DOCKER_TLS=no' >> /var/lib/boot2docker/profile
      /etc/init.d/docker restart
    EOT
  end
end