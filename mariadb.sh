CMD mysqld_safe --datadir='/db' & \
	service apache2 start; \
	/usr/sbin/sshd -D
