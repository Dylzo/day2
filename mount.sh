#!/bin/sh
set -e
echo "`date +"[%H:%M:%S | %d.%m.%y]"` Starting script"

if [[ "$EUID" = 0 ]]; then
    echo "Вы авторизованы как root пользователь"

    #Находим диск, который не использует разделы sd*(цифра) - в моём случае sdb
    ls /dev/sd*

    #Помечаем диск для использования LVM
    pvcreate /dev/sdb

    #Создаем группу том(а/ов)
    vgcreate vg01 /dev/sdb

    #Создаем логический раздел группы vg01 - в моём случае используем все свободное пространство
    lvcreate -l 100%FREE vg01

    #Необходимо проверить/узнать LV Path
    lvdisplay

    #Создаем файловую систему ext4
    mkfs.ext4 /dev/vg01/lvol0

    #Для монтирования необходимо создать дирректорию
    mkdir /mnt/storage

    #Монтируем диск в созданную дирректорию
    mount /dev/vg01/lvol0 /mnt/storage

    #Вносим в автозагрузку LVM диск
    echo "/dev/vg01/lvol0 /mnt/storage ext4 errors=remount-ro 0 1" >> /etc/fstab

    #Проверяем настройку fstab, смонтировав раздел
    mount -a

    #Проверяем, что диск примонтирован
    df -hT
   
   echo "Done"
else
   echo "Необходимо авторизоваться под root пользователем"
fi
