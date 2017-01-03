# Docker Compose

> Docker Compose 是 Docker 官方编排（Orchestration）项目之一，负责快速在集群中部署分布式应用。

Docker Compose的前身是Fig项目，Fig是基于Docker的用于快速搭建开发环境的工具之一，2015年Docker公司收购了Fig团队并将其加入了Docker tools工具集并改名为`docker-compose`。`docker-compose`通过一个配置文件来管理多个Docker容器，非常适合组合使用多个容器进行开发的场景和构建基于Docker的复杂应用。

## 编配概念

编配（Orchestration）是指通过统一的配置文件同时管理多个容器的运行行为。当你刚开始学习Docker的时候，你只需要操作一个容器，通过命令行或者脚本就可以很方便的完成对此容器的控制和管理。紧接着你学习了容器网络，并清楚的知道把所有进程都放入同一个容器中并不合适，然后不知不觉你就发现自己已经建立了多容器的基础架构，并且通过多个启动及配置命令行或脚本其配置和管理多个容器。你初期尝试可能不会感到复杂，毕竟在一组容器中工作和协调还是比较容易构建的，但是当使用两组或者更多组容器的时候，你就会觉得很麻烦，脚本越来越多，条目越来越复杂。手动连接容器、管理卷和网络，很快容器之间的关系就从点到线，然后又从线到面，然后乱作一团。这时你就会感慨应该有更好更实用的工具来做这件事。做这件事的就是编配工具！

## Docker Compose 介绍

Docker Compose 项目是 Docker 官方的开源项目，负责实现对 Docker 容器集群的快速编配。其代码由Python编写，目前在 [https://github.com/docker/compose](https://github.com/docker/compose) 上开源，大家可以通过Github follow 此项目，也可以直接通过Github来下载使用，在我编写此文档时Docker Compose的release是1.9.0。

Docker 定义 docker-compose 应用是 “定义和运行多个 Docker 容器的应用（Defining and running multi-container Docker applications）”，其前身是开源项目 Fig，使用格式是YAML，文件扩展名为yml，目前仍然兼容 Fig 格式的模板文件。

通过前面课程的学习，我们可以使用一个 Dockerfile 配置文件，定义一个单独的应用容器。可是在日常工作中，我们经常会碰到需要多个容器相互配合来完成某项任务的情况。例如要实现一个 LAMP或LAMP的Web 项目，除了Apache或Nginx的 Web 服务容器本身，还需要再加上后端的Mysql数据库服务容器，甚至还包括LVS或Haproxy负载均衡容器等。

Docker Compose 正是为了满足这样的需求而创建的。它允许用户通过一个单独的 `docker-compose.yml` 配置文件（YAML 格式）来定义一组相关联的应用容器为一个项目（project）。

Docker Compose 中有两个重要的概念：

- **服务（service）**：一个应用的容器，实际上可以包括若干运行相同镜像的容器实例，作为负载均衡的基础。
- **项目（project）**：由一组关联的应用容器组成的一个完整业务单元，在 `docker-compose.yml` 文件中定义。

Compose 的默认管理对象是**项目（project）**，通过子命令对**项目（project）**中的一组容器进行便捷地生命周期管理。

Compose 项目由 Python 编写，实现上调用了 Docker 服务提供的 API 来对容器进行管理。因此，只要所操作的平台支持 Docker API，就可以在其上利用 Compose 来进行编排管理。目前Docker API支持Linux 、Windows和MacOS系统，我们可以通过Python 的PIP方式安装，也可以通过下载应用的方式安装。需要注意的是，在Windows和MacOS系统中安装Docker Compose时，Docker官方建议使用`Docker ToolBox` 方式安装。 

## 安装Docker Compose

安装 Docker Compose 之前，要先安装 Docker，在前面的课程中我们已经具体的介绍了如何安装和配置Docker，在此不再啰嗦了，如果忘了了如何安装配置Docker 环境，请查看《Docker 基础》文档。

Docker Compose 可以通过 Python 的 pip 工具进行安装，可以直接下载编译好的二进制文件使用，甚至直接运行在 Docker 容器中。我们在接下的操作中介绍最简单的二进制文件安装方式，其他安装方式请自行阅读 [Docker Compose Install ]( https://github.com/docker/docker.github.io/blob/master/compose/install.md) 。

### 下载Docker Compose二进制文件

教学环境在前面的课程中已经给大家介绍过了，我们所需要的代码和软件都存在在materials.example.com服务器上，docker-compose也不例外。首先我们下载docker-compose二进制文件。

```shell
[root@node1-f0 ~]# wget http://materials.example.comdocker-tools/docker-compose-Linux-x86_64 
```

请注意，我们目前在实验环境系统中的第一个虚拟主机node1上，教师演示机是foundation0，学生机是foundationN，请自行替换你的试验机编号。

### Docker Compose 文件就位

下载好docker-compose二进制文件后，我们需要将其改名并放置到`/usr/local/bin`目录下，你也可以将其放置到其它你认为合适的目录下，比如`/usr/bin`目录下。

```shell
[root@node1-f0 ~]# cp docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
```

### 设置Docker Compose可执行

将docker-compose二进制文件放置到位后，还需要设置其可执行权限，没有可执行权限将无法运行。

```shell
[root@node1-f0 ~]# chmod +x /usr/local/bin/docker-compose
```

### 检验Docker Compose状态

在docker-compose程序可执行的情况下，我们可以通过`-v`参数查看当前docker-compose的版本来验证其执行状态。

```shell
[root@node1-f0 ~]# docker-compose -v
docker-compose version 1.9.0, build 2585387
```

## Docker Compose 命令说明

我们可以通过`—help` 参数查看docker-compose的命令行说明：

```shell
[root@node1-f0 ~]# docker-compose --help
Define and run multi-container applications with Docker.

Usage:
  docker-compose [-f <arg>...] [options] [COMMAND] [ARGS...]
  docker-compose -h|--help

Options:
  -f, --file FILE             Specify an alternate compose file (default: docker-compose.yml)
  -p, --project-name NAME     Specify an alternate project name (default: directory name)
  --verbose                   Show more output
  -v, --version               Print version and exit
  -H, --host HOST             Daemon socket to connect to

  --tls                       Use TLS; implied by --tlsverify
  --tlscacert CA_PATH         Trust certs signed only by this CA
  --tlscert CLIENT_CERT_PATH  Path to TLS certificate file
  --tlskey TLS_KEY_PATH       Path to TLS key file
  --tlsverify                 Use TLS and verify the remote
  --skip-hostname-check       Don't check the daemon's hostname against the name specified
                              in the client certificate (for example if your docker host
                              is an IP address)

Commands:
  build              Build or rebuild services
  config             Validate and view the compose file
  create             Create services
  down               Stop and remove containers, networks, images, and volumes
  events             Receive real time events from containers
  exec               Execute a command in a running container
  help               Get help on a command
  kill               Kill containers
  logs               View output from containers
  pause              Pause services
  port               Print the public port for a port binding
  ps                 List containers
  pull               Pulls service images
  restart            Restart services
  rm                 Remove stopped containers
  run                Run a one-off command
  scale              Set number of containers for a service
  start              Start services
  stop               Stop services
  unpause            Unpause services
  up                 Create and start containers
  version            Show the Docker-Compose version information
```

### 命令选项

- `-f, --file FILE` 指定使用的 Compose 模板文件，默认为 `docker-compose.yml`，可以多次指定。
- `-p, --project-name NAME` 指定项目名称，默认将使用所在目录名称作为项目名。
- `--verbose` 输出更多调试信息。
- `-v, --version` 打印版本并退出。
- `-H, --host HOST` 指定链接的Docker服务器

### 子命令说明

#### `build`

构建或重新构建项目中的服务容器。

服务容器一旦构建后，将会带上一个标记名，例如对于 web 项目中的一个 db 容器，可能是 web_db。如果修改了服务目录中的`Dockerfile`文件，你就可以使用`doker-compose build`命令重建它。可以随时在项目目录下运行 `docker-compose build` 来重新构建服务。

格式为 `docker-compose build [options] [SERVICE...]`

可选参数包括：

- `--force-rm` 删除构建过程中的临时容器。
- `--no-cache` 构建镜像过程中不使用 cache（这将加长构建过程）。
- `--pull` 始终尝试通过 pull 来获取更新版本的镜像。

#### `config`

验证和显示Docker Compose 配置文件。

格式为 `docker-compose config [options]`

可选参数包括：

* `-q , --quiet` 仅仅检测配置文件语法，不显示文件内容
* `--servicec` 打印服务名，一行一个

#### `create`

为服务创建容器。

格式为 `docker-compose create [options] [SERVICE...]`

可选参数包括：

* `--force-recreate` 重建服务内的所有容器，即使它们未做修改，不能与`--no-recreate`参数同时使用。
* `--no-recreate` 如果服务内容器已就绪，不去重建它们，不能与`--force-recreate`参数同时使用。
* `--no-build` 不重建镜像，即使镜像丢失。
* `--build` 在创建容器前重建镜像。

#### `down`

停止容器并删除容器、网络、创建的卷和镜像。

默认情况下，只有删除: 

* Docker-compose当前配置文件中`service`定义的容器 　　
* Docker-compose当前配置文件中`network`定义的网络　
* 默认的网络，如果仅仅只有它自己使用
* 网络和卷定义为`external（外部）`是永远不会被删除。

格式为 `docker-compose down [options]`

可选参数包括：

- `--rmi type` 删除镜像，type 为`all` ，删除所有镜像，type为`local`，仅删除配置文件中`image`字段定义的镜像
- `-v, --volumes` 删除数据卷
- `--remove-orphans` 删除没有在配置文件中`service`字段定义的孤儿容器

#### `events`

获取容器的事件流。

格式为 `docker-compose events [options] [SERVICE...]`

可选参数包括：

* `--json` 以json格式输出事件流

#### `exec`

在容器中执行一个命令。

格式为 `docker-compose exec [options][SERVICE...]`

可选参数包括：

* `-d` 独立运行模式，将命令放在后台运行。
* `--privileged` 给这个过程扩展的特权。
* `--user USER` 指定用户运行程序。
* `-T` 关闭伪终端模式，默认为终端模式是打开的。
* `--index=index` 如果同一服务存在多个容器，指定命令对象容器的序号（默认为 1）。

#### `help`

获得一个子命令的帮助。

格式为 `docker-compose help COMMAND`

#### `kill`

通过发送 `SIGKILL` 信号来强制停止服务容器。

格式为 `docker-compose kill [options] [SERVICE...]`。

可选参数包括：

* `-s` 指定发送的信号，例如通过如下指令发送 `SIGINT` 信号。例如：

```
$ docker-compose kill -s SIGINT

```

#### `logs`

查看服务容器的输出。

格式为 `docker-compose logs [options] [SERVICE...]`。

可选参数包括：

* `--no-color` 关闭颜色输出。
* `-f, --follow` 连续输出，直到你手动终止。
* `-t, —timestamps` 输出时间戳。
* `--tail` 从最后一行输出每个容器的日志。

默认情况下，docker-compose 将对不同的服务输出使用不同的颜色来区分。可以通过 `--no-color` 来关闭颜色。

该命令在调试问题的时候十分有用。

#### `pause`

暂停一个服务的所有容器。

格式为 `docker-compose pause [SERVICE...]`。

继续运行一个服务的所有容器命令是`docker-compose unpause `

#### `port`

打印某个容器端口所映射的公共端口。

格式为 `docker-compose port [options] SERVICE PRIVATE_PORT`。

可选参数包括：

- `--protocol=proto` 指定端口协议，tcp（默认值）或者 udp。
- `--index=index` 如果同一服务存在多个容器，指定命令对象容器的序号（默认为 1）。

#### `ps`

列出项目中目前的所有容器。

格式为 `docker-compose ps [options] [SERVICE...]`。

可选参数包括：

- `-q` 只打印容器的 ID 信息。

#### `pull`

拉取服务依赖的镜像。

格式为 `docker-compose pull [options] [SERVICE...]`。

可选参数包括：

- `--ignore-pull-failures` 忽略拉取镜像过程中的错误。

#### `restart`

重启项目中的服务。

格式为 `docker-compose restart [options] [SERVICE...]`。

可选参数包括：

- `-t, --timeout TIMEOUT` 指定重启前停止容器的超时（默认为 10 秒）。

#### `rm`

删除所有停止状态的服务容器。

格式为 `docker-compose rm [options] [SERVICE...]`。

可选参数包括：

- `-f, --force` 强制直接删除，包括非停止状态的容器。一般尽量不要使用该选项。
- `-v` 删除容器所挂载的数据卷。默认情况下，附加到容器的匿名卷不会被删除，如果你想删除它们，请加`-v`参数。
- `-a, --all`  删除由`docker-compse run`命令创建的所有一次性容器 

推荐先执行 `docker-compose stop` 命令来停止容器。

#### `run`

在指定服务上执行一个命令。

格式为 `docker-compose run [options] [-p PORT...] [-e KEY=VAL...] SERVICE [COMMAND] [ARGS...]`。

例如：

```
$ docker-compose run web bash
```

将会启动一个 web 服务容器，并执行 `bash` 命令。

默认情况下，如果存在关联，则所有关联的服务将会自动被启动，除非这些服务已经在运行中。

该命令类似启动容器后运行指定的命令，相关卷、链接等等都将会按照配置自动创建。

需要注意的是：

- 给定命令将会覆盖原有的自动运行命令；比如原有web服务默认执行`python python.py`，现在就执行`bash`了。
- 不会自动创建端口，以避免冲突。

如果不希望自动启动关联的容器，可以使用 `--no-deps` 选项，例如

```
$ docker-compose run --no-deps web python manage.py shell

```

将不会启动 web 容器所关联的其它容器。

可选参数包括：

- `-d` 后台运行容器并打印出容器名。
- `--name NAME` 为容器指定一个名字。
- `--entrypoint CMD` 覆盖默认的容器启动指令。
- `-e KEY=VAL` 设置环境变量值，可多次使用选项来设置多个环境变量。
- `-u, --user=""` 指定运行容器的用户名或者 uid。
- `--no-deps` 不自动启动关联的服务容器。
- `--rm` 运行命令后自动删除容器，`d` 模式下将忽略。
- `-p, --publish=[]` 映射容器端口到本地主机。
- `--service-ports` 配置服务端口并映射到本地主机。
- `-T` 不分配伪终端，意味着依赖 tty 的指令将无法运行。
- `-w，--workdir=""` 定义容器中的工作目录位置

#### `scale`

设置指定服务运行的容器个数。

格式为 `docker-compose scale [options] [SERVICE=NUM...]`。

通过 `service=num` 的参数来设置数量。例如：

```
$ docker-compose scale web=3 db=2

```

将启动 3 个容器运行 web 服务，2 个容器运行 db 服务。

一般的，当指定数目多于该服务当前实际运行容器，将新创建并启动容器；反之，将停止容器。

可选参数包括：

- `-t, --timeout TIMEOUT` 停止容器时候的超时（默认为 10 秒）。

#### `start`

启动已经存在的服务容器。

格式为 `docker-compose start [SERVICE...]`。

#### `stop`

停止已经处于运行状态的容器，但不删除它。

格式为 `docker-compose stop [options] [SERVICE...]`。

可选参数包括：

- `-t, --timeout TIMEOUT` 停止容器时候的超时（默认为 10 秒）。

通过 `docker-compose start` 可以再次启动这些容器。

#### `unpause`

恢复处于暂停状态中的服务。

格式为 `docker-compose unpause [SERVICE...]`。

#### `up`

构建，(重新)创建、启动服务中的容器及关联操作。

格式为 `docker-compose up [options] [SERVICE...]`。

可选参数包括：

- `-d` 在后台运行服务容器。
- `--no-color` 不使用颜色来区分不同的服务的控制台输出。
- `--no-deps` 不启动服务所链接的容器。
- `--force-recreate` 强制重新创建容器，不能与 `--no-recreate` 同时使用。
- `--no-recreate` 如果容器已经存在了，则不重新创建，不能与 `--force-recreate` 同时使用。
- `--no-build` 不自动构建缺失的服务镜像。
- `-t, --timeout TIMEOUT` 停止容器时候的超时（默认为 10 秒）。
- `--remove-orphans` 删除没有在配置文件中`service`字段定义的孤儿容器

该命令十分强大，它将尝试自动完成包括构建镜像，重新创建服务，启动服务，并关联服务相关容器的一系列操作。链接的服务都将会被自动启动，除非已经处于运行状态。可以说，大部分时候都可以直接通过该命令来启动一个项目。

默认情况，`docker-compose up` 启动的容器都在前台，控制台将会同时打印所有容器的输出信息，可以很方便进行调试。当通过 `Ctrl-C` 停止命令时，所有容器将会停止。如果使用 `docker-compose up -d`，将会在后台启动并运行所有的容器。一般推荐生产环境下使用该选项。

默认情况，如果服务容器已经存在，`docker-compose up` 将会尝试停止容器，然后重新创建（保持使用 `volumes-from` 挂载的卷），以保证新启动的服务匹配 `docker-compose.yml` 文件的最新内容。如果用户不希望容器被停止并重新创建，可以使用 `docker-compose up --no-recreate`。这样将只会启动处于停止状态的容器，而忽略已经运行的服务。如果用户只想重新部署某个服务，可以使用 `docker-compose up --no-deps -d ` 来重新创建服务并后台停止旧服务，启动新服务，并不会影响到其所依赖的服务。

#### `version`

打印版本信息。

格式为 `docker-compose version`。

