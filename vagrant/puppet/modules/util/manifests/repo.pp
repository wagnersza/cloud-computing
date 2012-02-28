# Define: util::repo
#
# Util repo Define
#
# Author: Wagner Souza (wagnersza@gmail.com)
#
class util::repo {

	file { 'puppetlabs.repo':
		path => '/etc/yum.repos.d/puppetlabs.repo',
		ensure => present,
		content => template("util/puppetlabs.repo.erb"),
		owner => 'root',
	}
	file { 'rpmforge.repo':
		path => '/etc/yum.repos.d/rpmforge.repo',
		ensure => present,
		content => template("util/rpmforge.repo.erb"),
		owner => 'root',
	}
	file { 'epel.repo':
		path => '/etc/yum.repos.d/epel.repo',
		ensure => present,
		content => template("util/epel.repo.erb"),
		owner => 'root',
	}
	file { 'CentOS-Base.repo':
		path => '/etc/yum.repos.d/CentOS-Base.repo',
		ensure => present,
		content => template("util/CentOS-Base.repo.erb"),
		owner => 'root',
	}
	file { 'CentOS-Debuginfo.repo':
		path => '/etc/yum.repos.d/CentOS-Debuginfo.repo',
		ensure => absent,
	}
	file { 'CentOS-Media.repo':
		path => '/etc/yum.repos.d/CentOS-Media.repo',
		ensure => absent,
	}
	file { 'CentOS-Vault.repo':
		path => '/etc/yum.repos.d/CentOS-Vault.repo',
		ensure => absent,
	}
	
}