#!/bin/bash
# Настраивает и проверяет SSH-туннель между облачными ВМ.
# Скрипт завершится при первой ошибке, чтобы не продолжать с неверным состоянием.

set -e

echo "=== Настройка SSH-туннеля между Yandex Cloud, Selectel и Cloud.ru ==="

cd ../yandex
# Читаем IP-адреса из Terraform outputs для каждого облака.
YANDEX_IP=$(terraform output -raw vm_public_ip)
YANDEX_PRIVATE=$(terraform output -raw vm_private_ip)

cd ../selectel
SELECTEL_IP=$(terraform output -raw vm_public_ip)
SELECTEL_PRIVATE=$(terraform output -raw vm_private_ip)

cd ../cloudru
CLOUDRU_IP=$(terraform output -raw vm_public_ip)
CLOUDRU_PRIVATE=$(terraform output -raw vm_private_ip)

echo "Yandex VM public IP: $YANDEX_IP"
echo "Yandex VM private IP: $YANDEX_PRIVATE"
echo "Selectel VM public IP: $SELECTEL_IP"
echo "Selectel VM private IP: $SELECTEL_PRIVATE"
echo "Cloud.ru VM public IP: $CLOUDRU_IP"
echo "Cloud.ru VM private IP: $CLOUDRU_PRIVATE"

echo ""
echo "=== Проверка SSH-доступа ==="
ssh -o ConnectTimeout=5 ubuntu@$YANDEX_IP "echo '✅ Yandex VM доступна'" || {
# Проверяем, что ВМ доступна по SSH перед настройкой туннеля.
  echo "❌ Не удалось подключиться к Yandex VM"
  exit 1
}

ssh -o ConnectTimeout=5 root@$SELECTEL_IP "echo '✅ Selectel VM доступна'" || {
# Проверяем, что ВМ доступна по SSH перед настройкой туннеля.
  echo "❌ Не удалось подключиться к Selectel VM"
  exit 1
}

ssh -o ConnectTimeout=5 ubuntu@$CLOUDRU_IP "echo '✅ Cloud.ru VM доступна'" || {
# Проверяем, что ВМ доступна по SSH перед настройкой туннеля.
  echo "❌ Не удалось подключиться к Cloud.ru VM"
  exit 1
}

echo ""
echo "=== Получение публичного ключа с Yandex VM ==="
ssh ubuntu@$YANDEX_IP "cat ~/.ssh/authorized_keys" > /tmp/yandex_key.pub || {
# Берём публичный ключ с Yandex VM как с промежуточного узла.
  echo "❌ Не удалось получить ключ с Yandex VM"
  exit 1
}

echo "=== Добавление SSH-ключа на Selectel VM ==="
cat /tmp/yandex_key.pub | ssh root@$SELECTEL_IP "cat >> ~/.ssh/authorized_keys" || {
# Добавляем ключ на целевую ВМ, чтобы работал переход через jump host.
  echo "❌ Не удалось добавить ключ на Selectel VM"
  exit 1
}
echo "✅ SSH-ключ добавлен на Selectel VM"

echo "=== Добавление SSH-ключа на Cloud.ru VM ==="
cat /tmp/yandex_key.pub | ssh ubuntu@$CLOUDRU_IP "cat >> ~/.ssh/authorized_keys" || {
# Добавляем ключ на целевую ВМ, чтобы работал переход через jump host.
  echo "❌ Не удалось добавить ключ на Cloud.ru VM"
  exit 1
}
echo "✅ SSH-ключ добавлен на Cloud.ru VM"

echo ""
echo "=== Проверка SSH-туннеля: Yandex → Selectel ==="
ssh -J ubuntu@$YANDEX_IP root@$SELECTEL_IP "hostname && echo '✅ Туннель Yandex→Selectel работает!'" || {
# Проверяем подключение через Yandex VM как jump host.
  echo "❌ Не удалось подключиться через туннель Yandex→Selectel"
  exit 1
}

echo ""
echo "=== Проверка SSH-туннеля: Yandex → Cloud.ru ==="
ssh -J ubuntu@$YANDEX_IP ubuntu@$CLOUDRU_IP "hostname && echo '✅ Туннель Yandex→Cloud.ru работает!'" || {
# Проверяем подключение через Yandex VM как jump host.
  echo "❌ Не удалось подключиться через туннель Yandex→Cloud.ru"
  exit 1
}

echo ""
echo "=== 🎉 SSH-туннели успешно настроены! ==="
echo ""
echo "Для подключения к Selectel через Yandex используйте:"
echo "  ssh -J ubuntu@$YANDEX_IP root@$SELECTEL_IP"
echo ""
echo "Для подключения к Cloud.ru через Yandex используйте:"
echo "  ssh -J ubuntu@$YANDEX_IP ubuntu@$CLOUDRU_IP"
echo ""
echo "Для проброса порта (например, 8080) на Selectel:"
echo "  ssh -L 8080:$SELECTEL_IP:8080 ubuntu@$YANDEX_IP"
echo ""
echo "Для проброса порта (например, 8080) на Cloud.ru:"
echo "  ssh -L 8080:$CLOUDRU_IP:8080 ubuntu@$YANDEX_IP"
