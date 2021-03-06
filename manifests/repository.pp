class dell_openmanage::repository {

  $dell_repo_packages = ['dell-omsa-repository-2-5','yum-dellsysid']

  if ( $osfamily == 'RedHat') and ( $bios_vendor == 'Dell Inc.') {
    exec {'dell-openmanage-RedHat-repo':
      command   => '/usr/bin/wget -cv -o /root/DellOpenManage.log -O - http://linux.dell.com/repo/hardware/latest/bootstrap.cgi | /bin/bash',
      cwd       => '/root', 
      creates   => '/root/DellOpenManageRepo.log',
      logoutput => true,
      unless    => '/bin/rpm -qa |grep dell-omsa-repository-2-5 2>/dev/null',
    }

    package { $dell_repo_packages: 
      ensure   => latest,
      provider => 'yum',
      require => Exec['dell-openmanage-RedHat-repo'],
    }
  }
 

  if ( $lsbdistid == 'Ubuntu') and ( $bios_vendor == 'Dell Inc.') {
    exec {'dell-openmanage-Ubuntu-repo':
      command   => '/bin/echo "deb http://linux.dell.com/repo/community/ubuntu precise openmanage" | /usr/bin/tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list',
      cwd       => '/root',
      creates   => '/etc/apt/sources.list.d/linux.dell.com.sources.list',
      logoutput => true,
    }
  }

    if ($lsbdistid == 'Debian') and ( $bios_vendor == 'Dell Inc.' ){
      exec {'dell-openmanage-Debian-repo':
        command   => "echo 'deb http://linux.dell.com/repo/community/ubuntu precise openmanage/730' | sudo tee -a /etc/apt/sources.list.d/linux.dell.com.sources.list",
        cwd       => '/root',
        creates   => '/etc/apt/sources.list.d/linux.dell.com.sources.list',
        logoutput => true,
      }
    }


  if $osfamily == 'Debian' {
    exec {'download-dell-gpg-key':
      command   => '/usr/bin/gpg --keyserver pool.sks-keyservers.net --recv-key 1285491434D8786F',
      cwd       => '/root',
      creates   => '/etc/apt/sources.list.d/linux.dell.com.sources.list',
      logoutput => true,
      require   => Exec["dell-openmanage-${lsbdistid}-repo"],
    }
    exec {'import-dell-gpg-key':
      command   => '/usr/bin/gpg -a --export 1285491434D8786F|apt-key add -',
      cwd       => '/root',
      user      => 'root',
      creates   => '/etc/apt/sources.list.d/linux.dell.com.sources.list',
      logoutput => true,
      require   => Exec['download-dell-gpg-key'],
    }
  }

  notify {"BIOS VENDOR: ${bios_vendor} MANUFACTURER:${manufacturer}":}

}
