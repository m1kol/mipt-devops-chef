# Chef. Настройка и простейшее использование.

## Предварительные ресурсы
Для проведения данного демо, а именно запуска виртуальных машин, понадобится утилита `Vagrant` и `VirtualBox`. Также необходимо установить host-модули `VirtualBox` для используемого в системе ядра, а также плагин `vagrant-hostmanager`

```bash
vagrant plugin install vagrant-hostmanager
```

## Настройка сервера
Для настройки сервера сначала зайдём на него.
```bash
vagrant ssh server
```

Переходим в папку `/tmp` и скачиваем необходимый и подходящий для нашей системы файл для установки, затем устанавливаем.
```bash
cd /tmp
wget https://packages.chef.io/files/stable/chef-server/14.1.0/ubuntu/16.04/chef-server-core_14.1.0-1_amd64.deb
sudo dpkg -i chef-server-core_14.1.0-1_amd64.deb
cd ~
```

Обновляем конфигурацию сервера и стартуем сервисы.
```bash
sudo chef-server-ctl reconfigure
```

Добавляем организацию и пользователя. Создадим также папку, куда положим сгенерированные ключи.
```bash
mkdir .chef
sudo chef-server-ctl user-create chef_admin Chef Admin admin@example.com 'admin1234' --filename ./.chef/chef_admin.pem
sudo chef-server-ctl org-create chef_org 'Chef Example Org' --association_user chef_admin --filename ./.chef/chef_org-validator.pem
```

Добавляем настройку сервера в `/etc/opscode/chef-server.rb`:
```
server_name = "10.211.55.201"
api_fqdn server_name
nginx['url'] = "https://#{server_name}"
nginx['server_name'] = server_name
lb['fqdn'] = server_name
bookshelf['vip'] = server_name
```

## Настройка рабочей машины
Для настройки рабочей машины заходим на неё.
```bash
vagrant ssh workstation
```

Устанавливаем Руби.
```bash
sudo apt install ruby
```

Переходим в папку `/tmp` и скачиваем необходимый и подходящий для нашей системы файл для установки, затем устанавливаем.
```bash
cd /tmp
wget https://packages.chef.io/files/stable/chef-workstation/21.2.303/ubuntu/16.04/chef-workstation_21.2.303-1_amd64.deb
sudo dpkg -i chef-workstation_21.2.303-1_amd64.deb
cd ~
```

Сгенерируем Chef-репозиторий.
```bash
chef generate repo chef-repo
cd chef-repo
```

Копируем сгенерированные на сервере ключи во внутреннюю папку репозитория `.chef`
```bash
mkdir .chef && cd .chef
scp vagrant@10.211.55.201:/home/vagrant/.chef/chef_admin.pem .
scp vagrant@10.211.55.201:/home/vagrant/.chef/chef_org-validator.pem .
```

В этой же папке создаём файл `config.rb` со следующим содержанием:
```
current_dir = File.dirname(__FILE__)
log_level               :info
log_location            STDOUT
node_name               'chef_workstation'
client_key              "#{current_dir}/chef_admin.pem"
validation_client_name  'chef_workstation'
validation_key          "#{current_dir}/chef_org-validator.pem"
chef_server_url         'https://chef-server/organizations/chef_org'
cache_type              'BasicFile'
cache_options( :path => "#{ENV['HOME']}/.chef/checksums" )
cookbook_path           ["#{current_dir}/../cookbooks"]
```

Возвращаемся обратно в папку репозитрория, скачиваем SSL-сертификат с сервера и проверяем подключение.
```bash
cd ..
knife ssl fetch
knife ssl check
```

## Добавление и настройка узла
Регистрация узла происходит с рабочей машины. Добавляем узел следующей командой:
```bash
knife bootstrap 10.211.55.202 -U vagrant --sudo
```

Загружаем созданный во время генерации `cookbook` на сервер и добавляем его в `run-list` созданного узла.
```bash
cd cookbooks
knife cookbook upload example
knife node run_list add chef-client 'example'
```

Заходим на сам узел и проверяем работу.
```bash
vagrant ssh node
sudo chef-client
```

Сгенирируем ещё один `cookbook`
```bash
cd cookbooks
chef generate cookbook sample
```

и создадим `recipe` со следующим содержанием
```
file "#{ENV['HOME']}/test.txt" do
    content "Test file content!"
end
```

Также загрузим его на сервер и назначим в список выполнения узла.
```bash
cd ~/chef-repo/cookbooks
knife upload cookbook sample
knife node run_list add chef-client 'sample'
```

Затем снова проверим работу на нашем узле.
