# -*- mode: ruby -*-
# vi: set ft=ruby :

# May need to change `cfg.vm.box = ""` is your vagrant box has a different name

Vagrant.configure("2") do |config|
    config.vm.define "win2012r2" do |cfg|
        cfg.vm.define "win2012r2"
        cfg.vm.box = "windows2012r2"
        cfg.vm.hostname = "Win2012r2"
        cfg.vm.communicator = "winrm"

        # use the plaintext WinRM transport and force it to use basic authentication.
        # NB this is needed because the default negotiate transport stops working
        #    after the domain controller is installed.
        #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
        cfg.winrm.transport = :plaintext
        cfg.winrm.basic_auth_only = true


        cfg.vm.guest = :windows
        cfg.windows.halt_timeout = 15

        cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
        cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
        cfg.vm.network :forwarded_port, guest: 445, host: 445, id: "smb", auto_correct: true
        cfg.vm.network :private_network, ip: "192.168.32.2", gateway: "192.168.32.1"

        cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip 192.168.32.2"
        #cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
        cfg.vm.provision "reload"
        cfg.vm.provision "shell", path: "scripts/setupAD.ps1", privileged: true, args: "-ip 192.168.32.2"
        cfg.vm.provision "reload"
    end

    config.vm.define "windows10" do |cfg|
        cfg.vm.define "windows10"
        cfg.vm.box = "windows10"
        cfg.vm.hostname = "windows10"
        cfg.vm.communicator = "winrm"

        cfg.winrm.username = "vagrant"
        cfg.winrm.password = "vagrant"

        cfg.vm.guest = :windows
        cfg.windows.halt_timeout = 15

        cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
        cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
        cfg.vm.network :private_network, ip: "192.168.32.4", gateway: "192.168.38.1", dns: "192.168.32.2"

        cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip 192.168.32.4"
        #cfg.vm.provision "shell", path: "s/provision.ps1", privileged: true
        cfg.vm.provision "reload"
        cfg.vm.provision "shell", path: "scripts/join-domain.ps1", privileged: false
        cfg.vm.provision "reload"

    end

    config.vm.define "windows7x86" do |cfg|
        cfg.vm.define "windows7x86"
        cfg.vm.box = "windows7x86"
        cfg.vm.hostname = "windows7x86"
        cfg.vm.communicator = "winrm"

        cfg.winrm.username = "vagrant"
        cfg.winrm.password = "vagrant"

        cfg.vm.guest = :windows
        cfg.windows.halt_timeout = 15

        cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
        cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
        cfg.vm.network :private_network, ip: "192.168.32.6", gateway: "192.168.38.1", dns: "192.168.32.2"

        cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: true, args: "-ip 192.168.32.6"
        cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: true
        cfg.vm.provision "reload"
        cfg.vm.provision "shell", path: "scripts/join-domain.ps1", privileged: false
        cfg.vm.provision "reload"

    end
end
