# Начало работы с интеграциями PostgreSQL в Aspire

## Обзор

[PostgreSQL](https://www.postgresql.org/) — это мощная, открытая объектно-реляционная система баз данных с многолетней активной разработкой, которая заслужила сильную репутацию благодаря надежности, функциональности и производительности. Интеграция Aspire PostgreSQL предоставляет способ подключения к существующим базам данных PostgreSQL или создания новых экземпляров из [контейнерного образа docker.io/library/postgres](https://hub.docker.com/_/postgres).

В этом руководстве вы увидите, как установить и использовать интеграции Aspire PostgreSQL в простой конфигурации. Если у вас уже есть эти знания, см. [PostgreSQL Hosting integration](../postgres-host/) для полных справочных деталей.

> **Примечание:** Чтобы следовать этому руководству, вы должны создать решение Aspire для работы. Чтобы узнать, как это сделать, см. [Build your first Aspire app](https://aspire.dev/get-started/first-app/).

## Настройка интеграции хостинга

Чтобы начать, установите интеграцию Aspire PostgreSQL Hosting в проект Aspire AppHost. Эта интеграция позволяет создавать и управлять экземплярами баз данных PostgreSQL из ваших проектов хостинга Aspire.

### Установка пакета

#### Использование Aspire CLI

```bash
aspire add postgresql
```

Aspire CLI интерактивен, обязательно выберите соответствующий результат поиска при запросе:

```
Select an integration to add:
> postgresql (Aspire.Hosting.PostgreSQL)
> Other results listed as selectable options...
```

> **Примечание:** Если есть только один результат, CLI выбирает его автоматически. Вам все равно нужно будет подтвердить версию.

#### Альтернативные способы установки

- **apphost.cs (C# file-based app):** Добавьте пакет через PackageReference
- **PackageReference (*.csproj):** Добавьте `<PackageReference Include="Aspire.Hosting.PostgreSQL" />` в файл проекта

### Создание ресурсов PostgreSQL в AppHost

В проекте AppHost создайте экземпляры ресурсов сервера и базы данных PostgreSQL, затем передайте базу данных в потребляющие клиентские проекты:

```csharp
var builder = DistributedApplication.CreateBuilder(args);

var postgres = builder.AddPostgres("postgres");
var postgresdb = postgres.AddDatabase("postgresdb");

var exampleProject = builder.AddProject<Projects.ExampleProject>("apiservice")
    .WaitFor(postgresdb)
    .WithReference(postgresdb);
```

> **Совет:** Это самая простая реализация ресурсов PostgreSQL в AppHost. Есть много дополнительных опций, которые вы можете выбрать для решения ваших требований. Для полных деталей см. [PostgreSQL Hosting integration](../postgres-host/).

## Использование интеграции в клиентских проектах

Теперь, когда интеграция хостинга готова, следующий шаг — установить и настроить клиентскую интеграцию в любых проектах, которым нужно ее использовать.

### Настройка клиентских проектов

В каждом из этих потребляющих клиентских проектов установите клиентскую интеграцию Aspire PostgreSQL:

#### Установка пакета

```bash
dotnet add package Aspire.Npgsql
```

#### Настройка в Program.cs

В файле `Program.cs` вашего клиентского проекта вызовите метод расширения `AddNpgsqlDataSource` на любом `IHostApplicationBuilder`, чтобы зарегистрировать `NpgsqlDataSource` для использования через контейнер внедрения зависимостей. Метод принимает параметр имени подключения:

```csharp
builder.AddNpgsqlDataSource(connectionName: "postgresdb");
```

> **Совет:** Параметр `connectionName` должен соответствовать имени, используемому при добавлении ресурса сервера PostgreSQL в проекте AppHost. Для получения дополнительной информации см. [Set up hosting integration](#настройка-интеграции-хостинга).

### Использование внедренных свойств PostgreSQL

В AppHost, когда вы использовали метод `WithReference` для передачи ресурса сервера или базы данных PostgreSQL в потребляющий клиентский проект, Aspire внедряет несколько свойств конфигурации, которые вы можете использовать в потребляющем проекте.

Aspire предоставляет каждое свойство как переменную окружения с именем `[RESOURCE]_[PROPERTY]`. Например, свойство `Uri` ресурса с именем `postgresdb` становится `POSTGRESDB_URI`.

#### Получение свойств конфигурации

Используйте метод `GetValue()` для получения этих переменных окружения в потребляющих проектах:

```csharp
string hostname = builder.Configuration.GetValue<string>("POSTGRESDB_HOST");
string databaseport = builder.Configuration.GetValue<string>("POSTGRESDB_PORT");
string jdbcconnectionstring = builder.Configuration.GetValue<string>("POSTGRESDB_JDBCCONNECTIONSTRING");
string databasename = builder.Configuration.GetValue<string>("POSTGRESDB_DATABASE");
```

> **Совет:** Полный набор свойств, которые внедряет Aspire, зависит от того, передали ли вы ресурс сервера или базы данных PostgreSQL. Для получения дополнительной информации см. [Properties of the PostgreSQL resources](../postgres-client/#properties-of-the-postgresql-resources).

### Использование ресурсов PostgreSQL в клиентском коде

Теперь, когда вы добавили `NpgsqlDataSource` в builder в потребляющем проекте, вы можете использовать ресурс PostgreSQL для получения и хранения данных. Получите экземпляр `NpgsqlDataSource` с помощью внедрения зависимостей. Например, чтобы получить объект источника данных из примера сервиса, определите его как параметр конструктора и убедитесь, что класс `ExampleService` зарегистрирован в контейнере внедрения зависимостей:

```csharp
public class ExampleService(NpgsqlDataSource dataSource)
{
    // Use dataSource to query the database...
}
```

Получив источник данных, вы можете работать с базой данных PostgreSQL, как в любом другом приложении C#.

## Следующие шаги

Теперь, когда у вас есть приложение Aspire с интеграциями PostgreSQL, работающее и запущенное, вы можете использовать следующие справочные документы, чтобы узнать, как настроить и взаимодействовать с ресурсами PostgreSQL:

### Понимание интеграции хостинга PostgreSQL

[Understand the PostgreSQL hosting integration](../postgres-host/) — узнайте, как настроить персистентность, ресурсы pgAdmin и многое другое.

### Понимание клиентской интеграции PostgreSQL

[Understand the PostgreSQL client integration](../postgres-client/) — узнайте, как настроить ключевые клиенты, проверки работоспособности клиентской интеграции и многое другое.

### Понимание расширений сообщества PostgreSQL

[Understand the PostgreSQL community extensions](../postgresql-extensions/) — узнайте, как добавить пользовательский интерфейс управления DbGate и многое другое.

## Ссылки

- [Официальная документация Aspire PostgreSQL](https://aspire.dev/integrations/databases/postgres/postgres-get-started/)
- [PostgreSQL Official Website](https://www.postgresql.org/)
- [Docker PostgreSQL Image](https://hub.docker.com/_/postgres)


