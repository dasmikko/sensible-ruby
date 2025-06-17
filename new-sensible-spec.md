# New sensible specification

To structure everything better, and making it efficient for setting up machines or projects, i've come up with a new specification.

sensible.yml inside a project for folder:

```yaml
requirements: 
  - postgres # Name of the requirement file
  - httpd # Name of the requirement file

options: 
  # Possible future options
  package_install_command: sudo dnf install -y $0 # Global command for package installation
  package_check_command: rpm -q -y $0 # Global check command for packages
```
Now you can just place the requirements in the order you need things to be installed at. No more pre/post tasks.

If a project just requires a few packages, just make a requirement that installs them and you're done.

## Tasks
Tasks remain the same. It's just now ment for one off actions, like starting a dev server, updating the project. Stuff that you may need to do once in a while.

## Requirement files
These are new, and it explains a single requirement for the project or machine. It explains which packages it needs, and has a `check` and `install` property for the more complex scenarios.

`check` and `install` works by that the exit code has to return either 1 (failed) or 0 (success). They are optional if you just need system packages installed.

`sensible.yml` also has a global `install` and `check` command now, if you know that you will install them all the same way, and make it easier to change for all of them, in case you switch distro.

### Future ideas

#### Allow for ruby files
I'm planning on allowing .rb-files too, for even more flexibility.

#### Include other files
It might be a nice feature to be able to include other files.

### Example 
A requirement-file in .sensible/requirements

```yaml
---
name: Apache server
description: This installs an apache httpd server
packages:
  - name: httpd
    check: rpm -q httpd # If omitted, it used the one from sensible.yml
    install: sudo dnf install -y httpd # If omitted, it used the one from sensible.yml
check: |
  # This is for a more complex check, like if you need to check a service is running, files exist, etc... 
install: |
  # Install is now optional, as it's intended for tasks that require more than just installing system packages.
  # Maybe you require things being installed in a certain order
```

  