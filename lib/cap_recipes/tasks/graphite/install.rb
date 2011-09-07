Capistrano::Configuration.instance(true).load do

  namespace :graphite do
    set :graphite_servername, "localhost"
    set :graphite_from_source, true
    set :graphite_compiled_dir, "/usr/local/src"
    set :graphite_local_data_dir, "/mnt/storage/whisper"
    set :graphite_apache_config, File.join(File.dirname(__FILE__),'graphite.conf')
    set :graphite_carbon_conf, File.join(File.dirname(__FILE__),'carbon.conf') 
    set :graphite_storage_schema, File.join(File.dirname(__FILE__),'storage-schemas.conf') 
    set :pixman_src, "http://cairographics.org/releases/pixman-0.20.2.tar.gz"
    set(:pixman_ver) { pixman_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set :py2cairo_src, "http://cairographics.org/releases/py2cairo-1.8.10.tar.gz"
    set(:py2cairo_ver) { py2cairo_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set :whisper_src, "http://launchpad.net/graphite/1.0/0.9.8/+download/whisper-0.9.8.tar.gz"
    set(:whisper_ver) { whisper_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set :carbon_src, "http://launchpad.net/graphite/1.0/0.9.8/+download/carbon-0.9.8.tar.gz"
    set(:carbon_ver) { carbon_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    set :graphite_src, "http://launchpad.net/graphite/1.0/0.9.8/+download/graphite-web-0.9.8.tar.gz"
    set(:graphite_ver) { graphite_src.match(/\/([^\/]*)\.tar\.gz$/)[1] }
    
    desc "Install All"
    task :install, :roles => :graphite do
      graphite.install_apt
      graphite.install_python_tools
      graphite.install_pixman
      graphite.install_cairo
      graphite.install_whisper
      graphite.install_carbon
      graphite.install_graphite_web
      graphite.install_graphite_apache
    end
      
    desc "Install what we can from apt"
    task :install_apt, :roles => :graphite do
      run "sudo apt-get update"
      utilities.apt_install %w[build-essential wget python-setuptools python-memcache python-sqlite apache2 libapache2-mod-python pkg-config python2.6 python-cairo-dev python2.6-dev libcairo2-dev]
    end
    
    desc "Install Python Tools"
    task :install_python_tools, :roles => :graphite do
      sudo "easy_install-2.6 django"
      sudo "easy_install-2.6 txamqp"
    end  
      
    desc "Install Pixman"
    task :install_pixman, :roles => :graphite do
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{pixman_src} && #{sudo} tar --no-same-owner -xzf #{pixman_ver}.tar.gz"
      run "cd /usr/local/src/#{pixman_ver} && #{sudo} ./configure && #{sudo} make && #{sudo} make install"
    end
      
    desc "Install Cairo"
    task :install_cairo, :roles => :graphite do
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{py2cairo_src} && #{sudo} tar --no-same-owner -xzf #{py2cairo_ver}.tar.gz"
      run "cd /usr/local/src/#{py2cairo_ver.tr('2','')} && #{sudo} ./configure --prefix=/usr && #{sudo} make && #{sudo} make install"
      sudo %Q{ sh -c "echo '/usr/local/lib' > /etc/ld.so.conf.d/pycairo.conf" }
      sudo "ldconfig"
    end  
    
    desc "Install Whisper"
    task :install_whisper, :roles => :graphite do
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{whisper_src} && #{sudo} tar --no-same-owner -xzf #{whisper_ver}.tar.gz"
      run "cd /usr/local/src/#{whisper_ver} && #{sudo} python setup.py install"
    end
    
    desc "Install Carbon"
    task :install_carbon, :roles => :graphite do
      run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{carbon_src} && #{sudo} tar --no-same-owner -xzf #{carbon_ver}.tar.gz"
      run "cd /usr/local/src/#{carbon_ver} && #{sudo} python setup.py install"
      utilities.sudo_upload_template graphite_carbon_conf, "/opt/graphite/conf/carbon.conf", :mode => "644", :owner => 'root:root'
      utilities.sudo_upload_template graphite_storage_schemas, "/opt/graphite/conf/storage-schemas.conf", :mode => "644", :owner => 'root:root'
    end
    
    desc "Install Graphite"
    task :install_graphite_web, :roles => :graphite do
       run "cd /usr/local/src && #{sudo} wget --tries=2 -c --progress=bar:force #{graphite_src} && #{sudo} tar --no-same-owner -xzf #{graphite_ver}.tar.gz"
       run "cd /usr/local/src/#{graphite_ver} && #{sudo} python setup.py install"
       run "cd /opt/graphite/webapp/graphite && #{sudo} python manage.py syncdb --noinput"
       sudo "chown -R www-data:www-data /opt/graphite/storage/"
       
    end
    
    desc "Copy over Graphite Apache Config, restart Apache and Start Carbon Cache Server"
    task :install_graphite_apache, :roles => :graphite do
      utilities.sudo_upload_template graphite_apache_config, "/etc/apache2/sites-available/graphite", :mode => "644", :owner => 'root:root'
      sudo "a2ensite graphite"
      sudo "apache2ctl restart"
      run "cd /opt/graphite/bin && #{sudo} python carbon-cache.py start"
    end
    
  end

end