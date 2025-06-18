# New sensible specification

To structure everything better, and making it efficient for setting up machines or projects, i've come up with a new specification.

You are now able to completely able to define your own structure,

sensible.yml inside a project for folder:

```yaml
packages:
  - rpm: [btop]

require: 
  - .sensible/requirements/postgres17 # Path to the task
  - .sensible/requirements/httpd

tasks:
  - .sensible/tasks/test

options: 
  # Possible future options
```

The nice thing here is, that the order of where you place the packages, require and tasks property matters. It parses the file from top-to-bottom, so in this example, it install packages first, handle requirements, and run tasks at the end. You could do it in complete reverse order if you wanted.

The same thing with the require and tasks property, the list in there, will be handled in that order..

When you add an requirement, it's the relative path from where you execute sensible from.

## Folder structure example

```
.sensible/
  requirements/
    httpd.yml
    postgresql17.yml
  tasks/
    another.yml
    test.yml
sensible.yml
```

You could also structure it like this:

```
services/
  httpd.yml
  postgresql17.yml
tasks/
  another.yml
  test.yml
hosts/
  server1.yml
  server2.yml
```

Then you run the command: `sensible -f check hosts/server1.yml` or `sensible -f install hosts/server1.yml`

If you want to have a hosts folder, I recommend using the `-f` option.

By default sensible will look for a sensible.yml in the folder you are executing sensible from.

## Tasks
Everything is basically a task, it manages packages, and the script to check and install the task.

### Properties

#### name
This is name of the task, should be short and simple

#### description
This a longer description to help explain it in more detail what it does.

#### require
A task can require other things. Lets say you have a task that installs a frontend project, that can then require that you have a apache server installed to run. 

**This property is optional**

#### packages
Here you can definethe packages a task should install. You define which type of package via the property name: `rpm`, `deb` or `aur`

Example:

```
packages:
  rpm: [btop] # RHEL based
  deb: [btop] # Debian based
  aur: [btop] # Arch linux based
```

**This property is optional**

#### check
This is the script you can use to check if the task was installed succesfully.

You will most likely use this, if you are going to use the `script` property.

**This property is optional**

#### script
This the install script for the task. Let's say you need to do a git clone, create a user, switch to that user etc.

If this script exits with 0, it completed successfully

**This property is optional**


### Full example

```yaml
# .sensible/task/test.yml
---
name: Task example
description: This installs an apache httpd server, shellopts gem
require:
  - .sensible/requirements/httpd # Remember, it's relative from execution path
packages: # Optional if task does not require packages
  deb: # Debian packages
  aur: # Aur packages (Arch linux)
  rpm: [httpd]
check: |
  # This is for a more complex check, like if you need to check a service is running, files exist, etc... 
script: |
  # Script is optional, as it's intended for tasks that require more than just installing various packages.
  # Maybe you require things being installed in a certain order
```







### Future ideas

#### Allow for ruby files
I'm planning on allowing .rb-files too, for even more flexibility.

#### Include other files
It might be a nice feature to be able to include other files.
