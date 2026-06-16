#!/bin/bash
# Установка SSH-туннеля между Yandex Cloud и Selectel

set -e

echo "=== Настройка SSH-туннеля между Yandex Cloud и Selectel ==="

# Получаем IP-адреса из outputs
cd ../yandex
YANDEX_IP=$(terraform output -raw vm_public_ip)
YANDEX_PRIVATE=$(terraform output -raw vm_private_ip)

cd ../selectel
SELECTEL_IP=$(terraform output -raw vm_public_ip)
SELECTEL_PRIVATE=$(terraform output -raw vm_private_ip)

echo "Yandex VM public IP: $YANDEX_IP"
echo "Yandex VM private IP: $YANDEX_PRIVATE"
echo "Selectel VM public IP: $SELECTEL_IP"
echo "Selectel VM private IP: $SELECTEL_PRIVATE"

# Проверяем доступность
echo ""
echo "=== Проверка доступности ==="
ping -c 2 $YANDEX_IP || echo "Yandex VM не отвечает на ping (может быть блокировка ICMP)"
ping -c 2 $SELECTEL_IP || echo "Selectel VM не отвечает на ping (может быть блокировка ICMP)"

# Добавляем публичный ключ Yandex ВМ на Selectel ВМ
echo ""
echo "=== Добавление SSH-ключа Yandex на Selectel ==="
ssh ubuntu@$SELECTEL_IP "echo '$(cat ~/.ssh/id_rsa.pub)' >> ~/.ssh/authorized_keys" || {
  echo "Не удалось добавить ключ. Попробуйте вручную:"
  echo "  cat ~/.ssh/id_rsa.pub | ssh ubuntu@$SELECTEL_IP 'cat >> ~/.ssh/authorized_keys'"
  exit 1
}

# Проверяем SSH-туннель
echo ""
echo "=== Проверка SSH-туннеля ==="
echo "Подключение с Yandex (через публичный IP) к Selectel (через приватный IP):"
ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE "hostname && echo 'Туннель работает!'" || {
  echo "Не удалось подключиться через туннель. Проверьте:"
  echo "1. SSH-ключи на обеих ВМ"
  echo "2. Security Groups (Yandex) и правила фаервола (Selectel)"
  echo "3. Попробуйте вручную: ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE"
  exit 1
}

echo ""
echo "=== SSH-туннель успешно настроен! ==="
echo ""
echo "Для подключения к Selectel через Yandex используйте:"
echo "  ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE"
echo ""
echo "Для проброса порта (например, 8080) используйте:"
echo "  ssh -L 8080:$SELECTEL_PRIVATE:8080 ubuntu@$YANDEX_IP"