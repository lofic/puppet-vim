Facter.add( 'vimver' ) do
    confine :osfamily => 'RedHat'
    setcode do
        orienv = ENV['LANG']
        ENV['LANG'] = 'C'
        ver = nil
        begin
            vcver = Facter::Util::Resolution.exec("rpm -q --queryformat '%{VERSION}' vim-common").split('.').first
            if vcver =~ /[0-9\.]+/
                ver = vcver
            else
                vmver = Facter::Util::Resolution.exec("rpm -q --queryformat '%{VERSION}' vim-minimal").split('.').first
                if vmver =~ /[0-9\.]+/
                    ver =  vmver
                end
            end
        rescue
            nil
        ensure
            ENV['LANG'] = orienv
        end
        ver
    end
end

