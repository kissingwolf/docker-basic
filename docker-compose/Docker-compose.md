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

## Docker Compose 配置文件说明

Docker Compose 配置文件格式为YAML，用以定义`services`、`networks`和`volumes`。默认文件名和路径为`./docker-compose.yml`。配置文件的扩展名可以是`yml`也可以是`yaml`，两者都能够正常识别。

Docker Compose配置文件中定义的`services`字段将传递给`docker`命令执行容器的创建，同时`network`和`volume`字段定义的部分也会调用相应的`docker network create`和`docker volume create`命令创建。

Docker Compose配置文件中可以使用系统Shell中定义的环境变量，引用方式类似Shell Script中的`${VAR}`。

### Service 字段配置

Docker Compose 配置文件目前有两种版本格式：

* `version 1`:  已经被废弃， 其配置内不支持`volumes` 和 `networks`字段，默认`version` 关键字省略。
* `version 2`：目前支持的最新版本是2.1，普遍使用版本是2，需要在配置文件开始处声明`version: "2"`。

在`version 1`中，每个顶级元素为服务名称，次级元素为服务容器的配置信息，例如:

```
webapp:
  image: examples/web
  ports:
    - "80:80"
  volumes:
    - "/data"
```

在`version 2`中，扩展了语法关键字，除了可以声明`networks`和`volumes`外，与`version 1`最大的区别是添加了版本信息，并且需要将说有服务定义放置在`services`字段下，例如：

```yaml
version: "2"
services:
  webapp:
    image: examples/web
    ports:
      - "80:80"
    volumes:
      - "/data"
```

#### build 关键字

在构建时应用的配置选项。

可以直接使用路径传入构建容器的目录，也可以通过传入[context](https://docs.docker.com/compose/compose-file/#context)、[dockerfile](https://docs.docker.com/compose/compose-file/#dockerfile)和[args](https://docs.docker.com/compose/compose-file/#args)对象进一步配置，  `dockerfile`和`args`两个对象是可选配置。

直接传入路径：

```yaml
build： ./dir
```

传入配置对象：

```yaml
build:
  context: ./dir
  dockerfile: Dockerfile-alternate
  args:
    buildno: 1
```

如果指定`image`关键字, 那么`Docker Compose`会基于镜像名`imagename`和可选的版本标签`tag`来构建镜像。

```yaml
build: ./dir
image: imagename:tag
```

上面的指令会生成一个基于`./dir`镜像名称为`imagename`，版本标签为`tag`的镜像。

> 在 `version 1` 格式的文件里，两种方式是不同的 1. 仅支持字符串形式： `build: .`， 不支持对象形式。 2. 不能同时使用`build`和`image`, 如果尝试这么做的话会导致错误。

##### context 关键字

> 只支持`version 2` , `version 1` 只能使用`build：.`

`context` 值可以是一个目录路径，也可以是一个git 网络地址`git repository url`。
当所提供的值是相对路径的时候，它被解释为docker-compose文件位置的相对路径。目录里的信息会被当做构建内容发送到Docker daemon。

```yaml
build:
  context: ./dir
```

##### dockerfile 关键字

指定dockerfile文件名称。

Docker Compose 将会使用此文件去构建镜像，但必须指定`build`路径。如：

```yaml
build:
  context: .
  dockerfile: Dockerfile-alternate
```

##### args 关键字

> 仅支持 `version 2`

其目的是与Dockerfile文件联用，添加构建环境变量的参数，但此环境变量仅构建过程期间可以使用。如在Dockerfile中配置如下：

```Dockerfile
ARG buildno
ARG password

RUN echo "Build number: $buildno"
RUN script-requiring-password.sh "$password"
```

`args`关键字可以使用 mapping 或 list两种数据结构定义:

mapping数据方式：
```yaml
build:
  context: .
  args:
    buildno: 1
    password: secret
```

list 数据方式：
```yaml
build:
  context: .
  args:
    - buildno=1
    - password=secret
```
> YAML 格式的Boolean值（true、false、yes、no、on和off）必须用双引号修饰，否则程序无法识别。

#### cap_add 和 cap_drop 关键字

指定容器的内核能力（capacity）分配。具体看参见`man 7 capabilities`。

例如，让容器拥有所有能力可以指定为：

```yaml
cap_add:
  - ALL
```

去掉 NET_ADMIN 能力可以指定为：

```yaml
cap_drop:
  - NET_ADMIN
```

Capabilities是Linux 2.2 内核引入的，它将root用户的权限细分为不同的领域，可以分别启用或禁用。从而在实际进行特权操作时，如果euid不是root，便会检查是否具有该特权操作所对应的capabilities，并以此为依据决定是否可以执行特权操作。

#### command 关键字

覆盖容器启动后默认执行的命令。

有两种写法：

```yaml
command: bundle exec thin -p 3000
```

和

```yaml
command: [bundle, exec, thin, -p, 3000]
```

#### cgroup_parent 关键字

指定父 cgroup 组，意味着将继承该组的资源限制。

例如，有一个已知 cgroup 组名称为 `all_cgroups`，此处继承其配置。

```yaml
cgroup_parent: all_cgroups
```

#### container_name 关键字

指定容器名称。默认使用 `项目名称_服务名称_序号` 这样的格式。

例如：

```yaml
container_name: my-web-container
```

注意，指定容器名称后，该服务将无法进行扩展（scale），因为 Docker 不允许多个容器具有相同的名称。

#### devices 关键字

指定设备映射关系。

例如：

```yaml
devices:
  - "/dev/ttyUSB1:/dev/ttyUSB0"
```

#### depends_on 关键字

表示服务之间的依赖关系， 有两个影响：

- `docker-compose up` 将会根据依赖关系的顺序开启所有服务，下面的例子中, `db`和`redis`会早于`web`服务先启动。
- `docker-compose up SERVICE` 会自动包含`SERVICE`的依赖，下面的例子中，`docker-compose up web`将会创建，同时也会启动`db`和`redis`服务。

```yaml
version: '2'
services:
  web:
    build: .
    depends_on:
      - db
      - redis
  redis:
    image: redis
  db:
    image: mysql
```

> web 服务启动前并不会等待db和redis到ready状态才启动。如果需要等待其他服务到ready状态，可以参考[Controlling startup order](https://docs.docker.com/compose/startup-order/) ，配置其内部脚本判断依赖服务是否正常可连接，然后在启动本地进程。

#### dns 关键字

自定义 DNS 服务器。可以是一个值，也可以是一个列表。

```yaml
dns: 8.8.8.8
```

```yaml
dns:
  - 8.8.8.8
  - 114.114.114.114
```

#### dns_search 关键字

配置 DNS 搜索域。可以是一个值，也可以是一个列表。

```yaml
dns_search: example.com
```

```yaml
dns_search:
  - domain1.example.com
  - domain2.example.com
```

#### tmpfs 关键字

> 仅在`version 2`版本以上有效。

在容器内挂接tmpfs文件系统，可以是一个值，也可以是一个列表。

```yaml
tmpfs: /run
```

```yaml
tmpfs:
  - /run
  - /tmp
```

#### entrypoint 关键字

覆盖默认的entrypoint（容器执行进程或脚本）。可以是一个值，也可以是一个列表。

```yaml
entrypoint: /code/entrypoint.sh
```

```yaml
entrypoint:
    - php
    - -d
    - zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20100525/xdebug.so
    - -d
    - memory_limit=-1
    - vendor/bin/phpunit
```

> 在Docker Compose配置文件中定义的`entrypoint`将覆盖原服务中容器`Dockerfile`配置文件中的`ENTERYPOINT`关键字的定义，同时也将使容器中`CMD`定义的内容被忽略。

#### env_file 关键字

从文件中获取环境变量，可以是单独的文件路径或者是一个文件路径列表。

如果通过 `docker-compose -f FILE` 方式来指定 Compose 模板文件，则 `env_file` 中变量的路径会基于模板文件路径。

如果有变量名称与 `environment` 指令冲突，则按照惯例，以后者为准。

```yaml
env_file: .env
```

```yaml
env_file:
  - ./common.env
  - ./apps/web.env
  - /opt/secrets.env
```

环境变量文件中每一行必须符合格式，支持 `#` 开头的注释行，`.env`文件类似如下内容。

```shell
# Set Rails/Rack environment
PROG_ENV=development
```
设置环境变量。你可以使用数组或字典两种格式。

只给定名称的变量会自动获取运行 Docker Compose 主机上对应变量的值，可以用来防止泄露不必要的数据。

可以使用mapping方式，例如:

```yaml
environment:
  RACK_ENV: development
  SESSION_SECRET:
```

或者使用list方式，例如:

```yaml
environment:
  - RACK_ENV=development
  - SESSION_SECRET
```

注意，如果变量名称或者值中用到 `true|false，yes|no` 等表达布尔含义的词汇，最好放到引号里，避免 YAML 自动解析某些内容为对应的布尔语义。

`http://yaml.org/type/bool.html` 中给出了这些特定词汇，包括:

```yaml
 y|Y|yes|Yes|YES|n|N|no|No|NO
|true|True|TRUE|false|False|FALSE
|on|On|ON|off|Off|OFF
```

#### expose 关键字

对外暴露端口，但不是暴露给host机器的，而是对已经 linked 的service可访问。

```yaml
expose:
 - "3000"
 - "8000"
```

#### extends 关键字

基于其它模板文件进行扩展。

例如我们已经有了一个 webapp 服务，定义一个基础模板文件为 `common.yml`。

```
# common.yml
webapp:
  build: ./webapp
  environment:
    - DEBUG=false
    - SEND_EMAILS=false

```

再编写一个新的 `development.yml` 文件，使用 `common.yml` 中的 webapp 服务进行扩展。

```
# development.yml
web:
  extends:
    file: common.yml
    service: webapp
  ports:
    - "8000:8000"
  links:
    - db
  environment:
    - DEBUG=true
db:
  image: mysql
```

后者会自动继承 common.yml 中的 webapp 服务及环境变量定义。

使用 extends 需要注意：

- 要避免出现循环依赖，例如 `A 依赖 B，B 依赖 C，C 反过来依赖 A` 的情况。
- extends 不会继承 `links` 和 `volumes_from` 中定义的容器和数据卷资源。

一般的，推荐在基础模板中只定义一些可以共享的镜像和环境变量，在扩展模板中具体指定应用变量、链接、数据卷等信息。

#### external_links 关键字

链接到 docker-compose.yml 外部的容器，甚至并非 `Docker Compose` 管理的外部容器。参数格式跟 `links` 类似。格式为`[CONTAINER:ALIAS](容器名：别名)`

```
external_links:
 - redis_1
 - project_db_1:mysql
 - project_db_1:postgresql
```

#### extra_hosts 关键字

类似 Docker 中的 `--add-host` 参数，指定额外的 host 名称映射信息。

例如：

```
extra_hosts:
 - "somehost:162.242.195.82"
 - "kissingwolf.com:118.193.241.38"
```

会在启动后的服务容器中 `/etc/hosts` 文件中添加如下两条条目。

```
162.242.195.82  somehost
118.193.241.38  kissingwolf.com
```

#### group_add 关键字

为容器添加指定的用户组，可以是组名，也可以是组id，其目的是为了保证多个容器在使用不同用户运行容器内进程时，可以读写同一寄主系统文件。实现方法是调用`Docker`的`--group-add`参数完成。

例如：

```yaml
version: '2'
services:
    image: alpine
    group_add:
      - mail
```

#### image 关键字

指定要启动容器的镜像，可以是`repository/tag`或`image ID`

```
image: redis
image: ubuntu:14.04
image: kissingwolf/busybox
image: registry.example.com:4000/nginx
image: a4bc65fd
```

镜像文件不存在，Docker Compose会尝试去远端拉取。

#### isolation 关键字

> 仅`version 2.1`版本支持。

指定容器的隔离技术。Linux 仅支持参数`default`，Windows支持参数`default`、`process`和`hyperv`。具体可以查看[Docker Engine docs](https://docs.docker.com/engine/reference/commandline/run/#specify-isolation-technology-for-container---isolation) 文档。

#### labels 关键字

为容器添加 Docker 元数据（metadata）信息。例如可以为容器添加辅助说明信息。

可以使用mapping方式，例如：

```yaml
labels:
  com.example.description: "Accounting webapp"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""
```

也可以使用list方式，例如：

```yaml
labels:
  - "com.example.description=Accounting webapp"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

#### links 关键字

链接到其它服务中的容器。使用服务名称或服务名称：服务别名 `（SERVICE:ALIAS）` 格式。

```yaml
web:
  links:
   - db
   - db:database
   - redis
```

`links`也表达`depends_on`一样的依赖关系，他们决定服务的启动顺序。

使用的服务名（别名）将会自动在服务容器中的 `/etc/hosts` 里创建ip和服务名（别名）的对用关系。例如：

```bash
172.17.4.123  db
172.17.4.123  database
172.17.4.124  redis
```

被链接容器中相应的环境变量也将被创建。

> 链接的多个服务之间必须有共同的网络。

#### logging 关键字

> `logging`关键字只支持`version 2`，在`version 1`中使用`log_driver`和`log_opt`

服务的日志配置。

```yaml
logging:
  driver: syslog
  options:
    syslog-address: "tcp://192.168.0.42:123"
```

有两个子关键字`driver`和`options`，不同的`driver`会有不同的`options`。此关键字是`Docker`的`—log-driver`和`--log-opt`的实现。具体参考[Docker 官方文档](https://docs.docker.com/engine/reference/logging/overview/)。

>`driver`为`json-file`和`journald`时通过`docker-compose logs`能够查看到日志，其他`driver`设置是无法查看的。

#### log_driver 关键字

> 仅在`version 1`中支持。

类似 Docker 中的 `--log-driver` 参数，指定日志驱动类型，默认是`json-file`。

```yaml
log_driver: "syslog"
```

#### log_opt 关键字

> 仅在`version 1`中支持。

日志驱动的相关参数。

例如

```yaml
log_driver: "syslog"
log_opt:
  syslog-address: "tcp://192.168.0.42:123"
```

#### net 关键字

> 仅在`version 1`中支持。`version 2`中使用`network_mode`关键字。

设置网络模式。使用和 `Docker`命令 的 `--net` 参数一样的值。如果是容器网络格式为`container:[service name or container name/id]`

```yaml
net: "bridge"
net: "none"
net: "container:[service name or container name/id]"
net: "host"
```

#### network_mode 关键字

> 仅在`version 2`中支持。`version 1`中使用`net`关键字。

设置网络模式。使用和 `Docker`命令 的 `--net` 参数一样的值。增加了对服务网络的支持: `service:[service name]`

```yaml
network_mode: "bridge"
network_mode: "host"
network_mode: "none"
network_mode: "container:[container name/id]"
network_mode: "service:[service name]"
```

#### networks 关键字

> 仅在`version 2`中支持。`version 1`中使用`net`关键字。

加入网络，支持全局`networks`关键字设置的网络。

```yaml
services:
  some-service:
    networks:
     - some-network
     - other-network
```

##### aliases 关键字

`network`下的子关键字`aliases`用来设置服务中容器别名。其他容器可以在相同的网络中通过设置的别名来连接到此容器。

`aliases`设置的生效范围是基于网络的，也就是说同一服务在不同的网络中可以使用不同的别名。

例如：

```yaml
services:
  some-service:
    networks:
      some-network:
        aliases:
         - alias1
         - alias3
      other-network:
        aliases:
         - alias2
```

具体实现可以参看如下的例子，在此docker-compose.yml配置文件中，设置了两个网络`new`和`legacy`，三个服务`web`、`worker`和`db`。在`new`网络中`db`服务被识别为`database`别名，在`legacy`网络中`db`服务被识别为`mysql`。

```yaml
version: '2'

services:
  web:
    build: ./web
    networks:
      - new

  worker:
    build: ./worker
    networks:
    - legacy

  db:
    image: mysql
    networks:
      new:
        aliases:
          - database
      legacy:
        aliases:
          - mysql

networks:
  new:
  legacy:
```

##### ipv4\_address和ipv6\_address 关键字

指定为这个服务容器加入网络时设置一个静态IPv4和IPv6地址。

```yaml
version: '2'

services:
  app:
    image: busybox
    command: ifconfig
    networks:
      app_net:
        ipv4_address: 172.16.238.10
        ipv6_address: 2001:3984:3989::10

networks:
  app_net:
    driver: bridge
    driver_opts:
      com.docker.network.enable_ipv6: "true"
    ipam:
      driver: default
      config:
      - subnet: 172.16.238.0/24
        gateway: 172.16.238.1
      - subnet: 2001:3984:3989::/64
        gateway: 2001:3984:3989::1
```

设置服务中容器的静态网络需要全局`networks`支持。要设置IPv6地址，需要全局`networks`中`com.docker.network.enable_ipv6`设置为`true`。同时需要设置`ipam`包括子网和网关信息。

##### link\_local\_ips 关键字

> 在`version 2.1`中添加。

设置服务容器直接连接到寄主机网桥上的静态IP组，通常依赖于你现实中的架构部署。

例如：

```yaml
version: '2.1'
services:
  app:
    image: busybox
    command: top
    networks:
      app_net:
        link_local_ips:
          - 57.123.22.11
          - 57.123.22.13
networks:
  app_net:
    driver: bridge
```

#### pid 关键字

跟主机系统共享进程命名空间。打开该选项的容器之间，以及容器和宿主机系统之间可以通过进程 ID 来相互访问和操作。

```yaml
pid: "host"
```

#### port 关键字

暴露端口。既可以是`HOST:CONTAINER`，也可以只写容器端口，host端口会随机选取。

> 当以`HOST:CONTAINER`的形式映射端口的时候，当容器的端口低于60的时候可能会遇到错误，因为YAML会解析`xx:yy`为60进制的数字。 基于这个原因，我们推荐明确指定端口映射用字符串的形式。

```
ports:
 - "3000"
 - "3000-3005"
 - "8000:8000"
 - "9090-9091:8080-8081"
 - "49100:22"
 - "127.0.0.1:8001:8001"
 - "127.0.0.1:5000-5010:5000-5010"
```

#### security\_opt 关键字

指定容器模板标签（label）机制的默认属性（用户、角色、类型、级别等）。

例如配置标签的用户名和角色名。

```
security_opt:
    - label:user:USER
    - label:role:ROLE
```

#### stop\_signal 关键字

设置另一个进程信号用以停止容器。在默认情况下Docker使用SIGTERM信号停止容器。

````yaml
stop_signal: SIGUSR1
````

#### ulimits 关键字

指定容器的 ulimits 限制值。

例如，指定最大进程数为 65535，指定文件句柄数为 20000（软限制，应用可以随时修改，不能超过硬限制） 和 40000（系统硬限制，只能 root 用户提高）。

```yaml
  ulimits:
    nproc: 65535
    nofile:
      soft: 20000
      hard: 40000
```

#### volumes 关键字

数据卷所挂载路径设置。可以设置宿主机路径 （`HOST:CONTAINER`） 或加上访问模式 （`HOST:CONTAINER:ro`）。

> `version 2 `中可以调用上级`volumes`关键字定义的外部卷，`version 1`中只能使用本地卷

该指令中路径支持相对路径。例如：

```yaml
volumes:
  # Just specify a path and let the Engine create a volume
  - /var/lib/mysql

  # Specify an absolute path mapping
  - /opt/data:/var/lib/mysql

  # Path on the host, relative to the Compose file
  - ./cache:/tmp/cache

  # User-relative path
  - ~/configs:/etc/configs/:ro

  # Named volume
  - datavolume:/var/lib/mysql
```

#### volumes_driver 关键字

> `version 2` 中支持数据卷的插件驱动。

用户可以先使用第三方驱动创建一个数据卷，然后使用名称来访问它。

此时，可以通过 `volumes_driver` 来指定驱动。

```yaml
volume_driver: mydriver
```

#### volumes\_from 关键字

从另一个服务或容器挂载它的数据卷。

例如：

```yaml
volumes_from:
 - service_name
 - service_name:ro
 - container:container_name
 - container:container_name:rw
```

可以指定挂接方式，`ro`为只读方式，`rw`为读写方式，默认没有指定方式时为`rw`方式。

#### 其它关键字

此外，还有包括 `cpu_shares, cpuset, domainname, hostname, ipc, mac_address, mem_limit, memswap_limit, privileged, read_only, restart, stdin_open, tty, user, working_dir` 等指令，基本跟 docker-run 中对应参数的功能一致。

例如，指定使用 cpu 核 0 和 核 1，只用 50% 的 CPU 资源：

```Yaml
cpu_quota: 50000
cpuset: 0,1
```

指定容器中运行应用的用户名。

```yaml
user: nginx
```

指定容器中工作目录。

```yaml
working_dir: /code
```

指定容器中搜索域名、主机名、mac 地址等。

```yaml
domainname: your_website.com
hostname: test
mac_address: 08-00-27-00-0C-0A
```

指定容器中进程通讯

```yaml
ipc: host
```

指定容器中内存和内存交换区限制都为 1G。

```yaml
mem_limit: 1g
memswap_limit: 1g
```

允许容器中运行一些特权命令。

```yaml
privileged: true
```

指定容器退出后的重启策略为始终重启。该命令对保持服务始终运行十分有效，在生产环境中推荐配置为 `always` 或者 `unless-stopped`。

```yaml
restart: always
```

以只读模式挂载容器的 root 文件系统，意味着不能对容器内容进行修改。

```yaml
read_only: true
```

打开标准输入，可以接受外部输入。

```yaml
stdin_open: true
```

模拟一个假的远程控制台。

```yaml
tty: true
```

### volumes 字段配置

虽然动态卷声明可以作为服务声明的一部分出现，这`version 2`的全局`volumes`字段配置允许你创建独立卷名，并跨多个服务可重用的的公共卷，并可以借助`Docker`命令行或API很容易检索和检查。具体进一步的配置可以参看[docker volume](https://docs.docker.com/engine/reference/commandline/volume_create/)文档获得更多信息。

#### driver 关键字

指定用于驱动本卷的卷驱动类型。默认为`local`。如果驱动是不可用，`Docker`引擎将返回一个错误。`Docker`第三方`volumes plugin`很多，具体可以参见[Volume plugins](https://docs.docker.com/engine/extend/legacy_plugins/) 。

例如：

```yaml
driver: local
```

#### driver\_opts  关键字

指定一个选项键值对列表为参数传递给`driver`用于设置并驱动卷。为可选的配置，根据不同的`driver`会有所不同。

```yaml
 driver_opts:
   foo: "bar"
   baz: 1
```

#### external 关键字

如果设置为`true`，指定卷在`Docker Compose`之外创建。`docker-compose up `命令在执行时不会试图创建它，但如果访问时无法连接，将会抛出一个错误。

例如：

```yaml
version: '2'

services:
  db:
    image: postgres
    volumes:
      - data:/var/lib/postgresql/data

volumes:
  data:
    external: true
```

`data`卷就是一个外部使用`docker volume create` 命令或`Docker API`创建的卷，在执行`docker-compose up`命令时，将在服务`db`中挂接在`postrges`镜像创建的容器中`/var/lib/postgresql/data`目录位置上。

#### labels 关键字

> `version 2.1` 新增关键字

为容器元数据添加[`Docker labels`标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)，可以是数组也可以是字典。

建议使用反向dns符号来阻止你的标签和其他软件有冲突。

例如：

```yaml
labels:
  com.example.description: "Database volume"
  com.example.department: "IT/Ops"
  com.example.label-with-empty-value: ""

labels:
  - "com.example.description=Database volume"
  - "com.example.department=IT/Ops"
  - "com.example.label-with-empty-value"
```

### networks 字段配置

顶级网络关键允许你指定要创建网络。完整的解释可以参考`Docker`网络功能部分，具体参看[Networking guide](https://docs.docker.com/compose/networking/)。

#### driver 关键字

指定使用何种驱动生成网络。默认驱动程序决于本地`Docker`引擎配置，大多数情况下，单机的`Docker`环境默认为`bridge`，`Swarm`多机环境下默认为`overlay`。

如果指定的driver不可用，`Docker`将返回一个错误。

例如：

```yaml
driver: overlay
```

#### driver\_opts 关键字

一个可选参数关键字，主要是为了将`driver`定义的驱动相关参数传递到`Docker`。根据不同的`driver`会有所不同。

例如：

```yaml
  driver_opts:
    foo: "bar"
    baz: 1
```

#### enable\_ipv6 关键字

> `version 2.1`新增关键字。

在网络中打开IPv6。

#### ipam 关键字

IPAM（IP address mangement) 网络地址管理，此关键字指定自定义网络配置。

这个对象关键字包含几个属性关键字，每一个属性关键字都是可选的：

* `driver`：自定义IPAM驱动，默认为default。
* `config`：配置列表，包含一个或多个配置块，包含如下自配置项
  * `subnet`：CIDR格式的子网,代表一个网段
  * `ip_range`：分配给容器的地址范围
  * `gateway`：分配给容器的默认网关，可以是IPv4也可以是IPv6
  * `aux_addresses`：辅助网络驱动程序所使用的IPv4和IPv6地址，ß从主机名映射到IP

例如：

```yaml
ipam:
  driver: default
  config:
    - subnet: 172.28.0.0/16
      ip_range: 172.28.5.0/24
      gateway: 172.28.5.254
      aux_addresses:
        host1: 172.28.1.5
        host2: 172.28.1.6
        host3: 172.28.1.7ß
```

#### internal 关键字

> `version 2`新增关键字

默认情况下，`Docker`中的容器是通过一个寄主机桥接提供的网络连接外部网络。如果你想创建一个孤立的`overlay`网络，你可以设置该选项为true。

#### labels 关键字

> `version 2.1` 新增关键字

为容器元数据添加[`Docker labels`标签](https://docs.docker.com/engine/userguide/labels-custom-metadata/)，可以是数组也可以是字典。

建议使用反向dns符号来阻止你的标签和其他软件有冲突。

例如：

```yaml
labels:
  com.example.description: "Financial transaction network"
  com.example.department: "Finance"
  com.example.label-with-empty-value: ""

labels:
  - "com.example.description=Financial transaction network"
  - "com.example.department=Finance"
  - "com.example.label-with-empty-value"
```

#### external 关键字

如果设置为`true`，则指定这个网络为`docker-compose up`命令控制范围之外的网络。docker-compose不会试图创建它，如果在容器使用它的时候发现其并不存在则会报错。

`external` 关键字不能与其它网络关键字混用，包括`driver`、 `driver_opts`、 `group_add`、 `ipam`和 `internal`。

例如：

```yaml
version: '2'

services:
  proxy:
    build: ./proxy
    networks:
      - outside
      - default
  app:
    build: ./app
    networks:
      - default

networks:
  outside:
    external: true
```

## Docker Compose 工作原理

在近些年的商业技术发展中，微服务架构潜移默化的改变着应用的部署方式，其提倡将应用分割成一系列细小的服务，每个服务专注于单一业务功能，服务之间采用轻量级通信机制相互沟通。对应的数据库解决方案也在发生着变化，多种持久化混合方案提倡将数据存放在最适合的数据库类型中（关系型、非关系型和对象型等），而传统的数据库解决方案将数据存在在同一个数据库类型中，并且不同类型的数据以单独的服务为运行单位。服务数量的增加也就意味着运行节点的增加，对应到容器领域，就是容器数量的增多，逐渐增加的容器数量也带来了容器部署、运行及管理带来了挑战。`Docker Compose`的出现解决多个容器部署的问题并提高了多个容器解决方案的可移植性。

`Docker Compose`将所管理的对象分为三层：工程（project）、服务（service）以及容器（container），这三个对象概念我们在前面介绍过。

### 工程（Project）

`Docker Compose`运行目录下的所有文件组成一个工程，若无特殊指定工程名即为当前目录名。

工程(Porject)目录下包含docker-compose.yml、extends文件或环境变量文件等，最主要的就是`docker-compose.yml`配置文件。前面我们已经详细介绍了其配置项目。

### 服务（Service）

一个工程（Project）当中可包含多个服务（Service），每个服务（Service）中定义了容器运行的镜像、参数和依赖关系。

### 容器（Container）

一个服务（Service）当中可包括多个容器（Container）实例，`Docker Compose`并没有解决负载均衡的问题，因此需要借助其他工具实现服务发现及负载均衡。

### 编配文件（`docker-compose.yml`）

`Docker Compose`的工程配置文件默认为`docker-compose.yml`(具体配置内容在前面有详细讲解），可通过环境变量`COMPOSE_FILE`或`-f`参数自定义配置文件名称和路径，其定义了多个有依赖关系的服务及每个服务运行的容器。以下是一个简单的配置文件：

```yaml
version: '2'
services:
  web:
    image: kissingwolf/hello-world-nginx
    volumes:
      - ./html:/website_files
  lb:
    image: kissingwolf/haproxy
    links:
      - web
    ports:
      - "80:80"
      - "1936:1936"
    environment:
      - SERVICE_NAMES=web
```

