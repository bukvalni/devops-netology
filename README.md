# Домашнее задание к занятию «Введение в Terraform»

Приложите скриншот вывода команды terraform --version:
![screen](/img//terraform%20version.jpg)

## Задание 1
1. Перейдите в каталог src. Скачайте все необходимые зависимости, использованные в проекте.
Изучите файл .gitignore. В каком terraform-файле, согласно этому .gitignore, допустимо сохранить личную, секретную информацию?(логины,пароли,ключи,токены итд)\
Ответ: personal.auto.tfvars

2. Выполните код проекта. Найдите в state-файле секретное содержимое созданного ресурса random_password, пришлите в качестве ответа конкретный ключ и его значение.\
Ответ: "result": "Pa2afoU3yDGQbmZq"

3. Раскомментируйте блок кода, примерно расположенный на строчках 29–42 файла main.tf. Выполните команду terraform validate. Объясните, в чём заключаются намеренно допущенные ошибки. Исправьте их.\
Ответ:
#### Ошибка:
```Bash
Error: Missing name for resource
│
│   on main.tf line 23, in resource "docker_image":
│   23: resource "docker_image" {\
│
│ All resource blocks must have 2 labels (type, name).
```
Объяснение:
Блок resource "docker_image" не имеет второго обязательного ярлыка (имени ресурса в terraform). Написано просто resource "docker_image" {, а должно быть resource "docker_image" "имя_ресурса" {. Из-за этого terraform не понимает, как к этому образу обращаться в коде
#### Ошибка:
```Bash
Error: Invalid resource name
│
│   on main.tf line 28, in resource "docker_container" "1nginx":
│   28: resource "docker_container" "1nginx" {
│
│ A name must start with a letter or underscore and may contain only letters, digits, underscores, and dashes.
```
Объяснение:
Имя ресурса контейнера указано как "1nginx". В terraform имена ресурсов строго не могут начинаться с цифры они должны начинаться только с буквы или знака подчёркивания
4. Выполните код. В качестве ответа приложите: исправленный фрагмент кода и вывод команды docker ps.
Ответ:
Исправленный код:
```bash
resource "docker_image" "nginx" {
  name = "nginx:latest"
  keep_locally = true
}
resource "docker_container" "nginx_container" {
  image = docker_image.nginx.image_id
  name  = "example_${random_password.random_string.result}"
  ports {
    internal = 80
    external = 9080
  }
}
```
![screen](/img/validate.jpg)
![screen](/img/docker_ps.jpg)

5. Замените имя docker-контейнера в блоке кода на hello_world. Не перепутайте имя контейнера и имя образа. Мы всё ещё продолжаем использовать name = "nginx:latest". Выполните команду terraform apply -auto-approve. Объясните своими словами, в чём может быть опасность применения ключа -auto-approve. Догадайтесь или нагуглите зачем может пригодиться данный ключ? В качестве ответа дополнительно приложите вывод команды docker ps.\
Ответ:\
Этот флаг полностью отключает интерактивное подтверждение от пользователя. Обычно terraform показывает план и ждёт, команду yes. С этим флагом утилита применяет изменения мгновенно. Если случайно удалить в коде важную базу данных, terraform уничтожит их без единого предупреждения\
Этот флаг незаменим для автоматизации в CI/CD пайплайнах (например, GitHub Actions, GitLab CI, Jenkins). Когда код разворачивается автоматически роботом на сервере, там физически некому сидеть перед консолью и нажимать yes
![screen](/img/hello_world.jpg)

6. Уничтожьте созданные ресурсы с помощью terraform. Убедитесь, что все ресурсы удалены. Приложите содержимое файла terraform.tfstate.\
Ответ:
![screen](/img/destroy.jpg)
7. Объясните, почему при этом не был удалён docker-образ nginx:latest. Ответ ОБЯЗАТЕЛЬНО НАЙДИТЕ В ПРЕДОСТАВЛЕННОМ КОДЕ, а затем ОБЯЗАТЕЛЬНО ПОДКРЕПИТЕ строчкой из документации terraform провайдера docker. (ищите в классификаторе resource docker_image)\
Ответ:\
В самом начале твоего файла main.tf в блоке ресурса docker_image прописан специальный аргумент.
```Bash
keep_locally = true
```
Если установлено значение true, Docker-образ не будет удалён при операции destroy. Если установлено false, образ будет удалён из локального хранилища Docker при уничтожении

[Документация Docker Image - keep_locally](https://library.tf/providers/kreuzwerker/docker/latest/docs/resources/image#:~:text=keep_locally%20(Boolean))
