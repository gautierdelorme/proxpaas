# Proxpaas

## Developer setup

### Requirements

#### macOS requirements

##### Install Xcode command line tools

    xcode-select --install

##### Install Homebrew

    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    brew doctor

##### Install rbenv

    brew install rbenv
    rbenv init
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bash_profile


#### Linux requirements

##### Install rbenv

    sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    mkdir -p ~/.rbenv/plugins
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi' >> ~/.bashrc
    source ~/.bashrc

### Project setup

#### Go to the project directory

    git clone git@github.com:gautierdelorme/proxpaas.git
    cd proxpaas

#### Install the required version of Ruby

    rbenv install
    rbenv rehash

#### Install Bundler

    gem install bundler
    rbenv rehash

#### Install required gems

    bundle install
    rbenv rehash

#### Initial setup and start

    rake db:setup
    ruby app.rb


## Project Overview

### Technologies

- Web app built in Ruby (using Sinatra to define the API)
- CLI tool written in pure bash
- SQLite3 was chosen as a simple database
- Git as versioning system

### Architecture

- `cli/`: contains the CLI tool
  - `proxpaas-cli` used to create and push an app to the cloud infrastructure
- `db/`: contains database related files (schema, migrations...)
- `lib/`:
  - `prox_client`: Proxpaas client used to manage the cloud infrastructure
  - `proxmox_config`: Proxpaas client configuration file
  - `proxmox`: Promox API ruby client (based on [Nicolas Ledez's work](https://github.com/nledez/proxmox))
- `models/`: contains only the `ProxApp` class modeling a proxmox hosted app
- `app.rb`: The main part of Proxpass where is defined the API.

## How it works

**Important:**

- You need to have an instance of Proxpaas running
- To connect to Proxmox you need to set `PROXMOX_LOGIN` and `PROXMOX_PASSWORD` environment variables or edit the `lib/proxmox_config.rb` file.
  - This project supports `.env` configuration strategy (more info: https://github.com/bkeepers/dotenv#usage)
- CLI tool default Proxpaas host is `http://localhost:4567`. You can set the `PROXPAAS_HOST` environment variable to use another one.
- You need to add the Proxpaas CLI directory to your PATH: `export PATH=/path/to/proxpaas/cli/:$PATH`
- You can check if it works with `proxpaas-cli -h`

E.g.

    Usage: proxpaas-cli [-h] [-c] [-p] [-u]

      -h  Help. Display this message and quit.
      -c  Create the app.
      -p  Push the app.
      -u  Print the app URL.


#### Create your project directory

Go inside and create the `index.html` file inside

    mkdir awesome_project
    cd awesome_project
    echo "Hello world" > index.html

#### Init Proxpaas in your project directory

    proxpaas-cli -c

You should see `Proxpaas initialization...`.

During the setup Proxpaas will
- Create a container in Proxmox to host your app
- Install two utilities in the container (and all dependencies like `curl` and `nodejs`):
  - `http-server`: To serve your application
  - `forever`: To keep your application alive


Once it's done  you should see a `.proxpaas_config` (used to identify your app) in your project directory and this message in the console:

    Proxpaas is setup!
    Use proxpaas-cli -p to deploy your app.
    Use proxpaas-cli -u to print your app URL.

You are now ready to deploy your app.

#### Deploy your project

Go back to your project directory and deploy it using Proxpaas.

    proxpaas-cli -p

You should see `Deploying app...` it means Proxpaas is deploying your app to the cloud.
During the deployment Proxpaas will:


1. Create an archive of your app.
1. Upload it to the container using SCP.
1. Stop the server on the container.
1. Replace (if it exists) the previous app (likely a previous version of the same app) hosted in the container with the new one.
1. Start again the server.

Once the deployment is done you should see:

    Your app has been deployed!
    Your app is accessible from here: X.X.X.X

#### Watch your app alive on the Internet

From your web browser go to the given IP to see your awesome application alive!

#### Deploy a new version

In your project directory update your index.html:

    echo "NEW CRAZY V2" >> index.html

Then deploy your app again

    proxpaas-cli -p

Once it's deployed, from your web browser you can see the new version alive.


Of course you can create and deploy more complex web applications using HTML/CSS/JS.


## Improvements to do

- ✅ ~~Remove manual intervention to setup a Proxpaas application (find the container IP programmatically)~~ (fixed by [PR#1](https://github.com/gautierdelorme/proxpaas/pull/1))
- Move from SCP archived project directory to another system for deployment (rsync, git...)
- Remove downtime during deployment (using side A / side B or other strategies...)
- Support more technologies (servers, languages, build processes...)
- Build a UI to manage apps
- ...

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
