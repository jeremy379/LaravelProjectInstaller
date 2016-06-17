# LaravelProjectInstaller

#Purpose

The purpose of this little shell script is to install and update laravel project from a repository (git or mercurial are supported).

Composer, git and mercurial will be installed by the script if missing.

#Installation

Retrieve the archive ans launch `./make install` in the directory where you want to install you Laravel project.

`wget https://github.com/jeremy379/LaravelProjectInstaller/archive/master.zip`

`unzip master.zip`

`mv LaravelProjectInstaller-master/make . `

`chmod +x make`

`rm -rf LaravelProjectInstaller`

`rm master.zip`

#Usage

`./make install` Install a new project and ask you some question for the installation. The config data are stored in a .make_config file in the same directory

`./make update` Do the update of the project from the repository


