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

# Проверяем SSH-доступ
echo ""
echo "=== Проверка SSH-доступа ==="
ssh -o ConnectTimeout=5 ubuntu@$YANDEX_IP "echo '✅ Yandex VM доступна'" || {
  echo "❌ Не удалось подключиться к Yandex VM"
  exit 1
}

ssh -o ConnectTimeout=5 ubuntu@$SELECTEL_IP "echo '✅ Selectel VM доступна'" || {
  echo "❌ Не удалось подключиться к Selectel VM"
  exit 1
}

# Получаем публичный ключ с Yandex ВМ (используем ed25519)
echo ""
echo "=== Получение публичного ключа с Yandex VM ==="
ssh ubuntu@$YANDEX_IP "cat ~/.ssh/authorized_keys" > /tmp/yandex_key.pub || {
  echo "❌ Не удалось получить ключ с Yandex VM"
  exit 1
}

# Добавляем ключ на Selectel ВМ
echo "=== Добавление SSH-ключа на Selectel VM ==="
cat /tmp/yandex_key.pub | ssh ubuntu@$SELECTEL_IP "cat >> ~/.ssh/authorized_keys" || {
  echo "❌ Не удалось добавить ключ на Selectel VM"
  exit 1
}

echo "✅ SSH-ключ добавлен на Selectel VM"

# Проверяем туннель
echo ""
echo "=== Проверка SSH-туннеля ==="
ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE "hostname && echo '✅ Туннель работает!'" || {
  echo "❌ Не удалось подключиться через туннель"
  echo "Попробуйте вручную:"
  echo "  ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE"
  exit 1
}

echo ""
echo "=== 🎉 SSH-туннель успешно настроен! ==="
echo ""
echo "Для подключения к Selectel через Yandex используйте:"
echo "  ssh -J ubuntu@$YANDEX_IP ubuntu@$SELECTEL_PRIVATE"
echo ""
echo "Для проброса порта (например, 8080) используйте:"
echo "  ssh -L 8080:$SELECTEL_PRIVATE:8080 ubuntu@$YANDEX_IP"