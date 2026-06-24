Создание 3 виртуальных машин при помощи Terraform: 1 на Yandex.Cloud, 1 на Selectel, 1 на Cloud.ru. Между машинами прокладывается ssh-тунель. 

НАХОДИТСЯ В РАЗРАБОТКЕ!!! 

При работе с Cloud.ru необходимо установить провайдер, выполнив следующие команды:

Создайте папку для версии 2.0.0
mkdir -p ~/.terraform.d/plugins/cloud.ru/cloudru/cloud/2.0.0/linux_amd64

Скачайте провайдер версии 2.0.0 (важно: точная версия!)
curl -L -o ~/.terraform.d/plugins/cloud.ru/cloudru/cloud/2.0.0/linux_amd64/terraform-provider-cloud \
  https://github.com/CLOUDdotRu/evo-terraform/releases/download/2.0.0/terraform-provider-cloud_2.0.0_linux_amd64

Сделайте файл исполняемым
chmod +x ~/.terraform.d/plugins/cloud.ru/cloudru/cloud/2.0.0/linux_amd64/terraform-provider-cloud

Проверьте, что файл скачался
ls -la ~/.terraform.d/plugins/cloud.ru/cloudru/cloud/2.0.0/linux_amd64/

cat > ~/.terraformrc << 'EOF'
provider_installation {
  dev_overrides {
    "cloud.ru/cloudru/cloud" = "/home/user2/.terraform.d/plugins/cloud.ru/cloudru/cloud/2.0.0/linux_amd64"
  }
  direct {}
}
EOF

Проверьте содержимое
cat ~/.terraformrc
