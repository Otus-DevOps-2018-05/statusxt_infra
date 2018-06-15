# statusxt_infra
statusxt Infra repository

Homework 04.


1. Задание с 35 слайда.

Способ подключения к someinternalhost в одну команду:
ssh -i ~/.ssh/appuser2 -A appuser@35.206.144.111 ssh 10.132.0.3

Вариант решения для подключения из консоли при помощи команды вида ssh
someinternalhost из локальной консоли рабочего устройства:

	touch ~/.ssh/config
	nano ~/.ssh/config
	
	Host someinternalhost
		HostName 10.132.0.3
		User appuser
		ProxyCommand ssh -W %h:%p -i ~/.ssh/appuser appuser@35.206.144.111
ssh someinternalhost

2. Файлы.

setupvpn.sh - установка VPN сервера

cloudbastion.ovpn - конфиг для подключения клиента

3. Конфигурация.

bastion_IP = 35.206.144.111

someinternalhost_IP = 10.132.0.3
