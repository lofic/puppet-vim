# vim - Vi IMproved, a programmers text editor

class vim(
    $packages,
    $vimpkg = 'vim-enhanced',
    $deb_cfg_file = 'only_for_debian',
    $build_tools = false,
    ) {

    if $vim::build_tools {
        include vim::build_minimal
    }

    if $facts['os']['family'] == 'Debian' {
        package { $vim::packages : ensure => installed, }

        exec { 'Fix vim mouse cut and paste on Debian':
            path    => [ '/bin', '/usr/bin' ],
            command => "sed -i 's/set mouse=a/set mouse-=a/g' ${deb_cfg_file}",
            onlyif  => "test -f ${deb_cfg_file} && grep -q 'set mouse=a' ${deb_cfg_file}",
        }
    }

    if ($facts['os']['family'] == 'RedHat') {
        include yum

        # Avoid conflicts between Ghettoforge and standard distribution
        # packages.
        if ($facts['os']['release']['major'] == '7')
        and has_key($facts,'vimver') {
            if $facts['vimver'] =~ /[0-9\.]+/ {
                if versioncmp($facts['vimver'], '8') < 0 { $latest = true }
            }
        }

        $pkgensure = $latest ? {
            true    => 'latest',
            default => 'present',
        }

        package { 'vim-minimal': ensure => $pkgensure }

        package { $vim::packages :
          ensure  => $pkgensure,
          require => [ Class['yum'], Package[ 'vim-minimal' ] ],
        }
    }

    $vimrc_local = @(EOT)
    if has('mouse')
        set mouse=r
    endif
    | EOT

    file { '/etc/vim':
        ensure => directory,
        mode   => '0755',
        owner  => 'root',
        group  => 'root',
    }

    file { '/etc/vim/vimrc.local':
        ensure  => present,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => $vimrc_local,
    }

    file { '/etc/vimrc' :
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        source  => 'puppet:///modules/vim/vimrc',
        require => Package[ $vimpkg ],
    }

}

