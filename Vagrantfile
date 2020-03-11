Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-16.04"
  config.vm.provider "vmware_desktop" do |vw|
    vw.vmx["memsize"] = 2048
    vw.vmx["numvcpus"] = 2
  end

  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
    vb.linked_clone = true
  end

  config.vm.provision :shell, privileged: true, path: "scripts/common.sh"
  config.vm.define :master do |master|
    master.vm.hostname = "master"
    master.vm.network :private_network, ip: "10.0.1.10"
    master.vm.provision :shell, privileged: false, path: "scripts/master.sh"
  end

  %w{worker1 worker2}.each_with_index do |name, i|
    config.vm.define name do |worker|
      worker.vm.hostname = name
      worker.vm.network :private_network, ip: "10.0.1.#{i + 11}"
      worker.vm.provision :shell, privileged: false, path: "scripts/worker.sh"
    end
  end
end
