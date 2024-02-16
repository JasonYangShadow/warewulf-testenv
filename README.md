# warewulf-testenv
Terraform template for setting up a virtual warewulf test cluster. It pull an
OS appliance and install `warewulf` on it.  You can login to the nodes as
`root` with the password `linux`.

[!WARNING]
This is only for testing purpose as weak passwords are set and ssh keys are
handled not securely. Also the `warewulf` rpm package is installed without
gpg check.

## Prerequisites
Terraform must be installed, the user must be part of the `libvirt` group and
`terraform init` has to run.

## Usage
Simply run
```
terraform apply
```
what will create the instance `ww4-host (172.16.?.250)` and per default 4 nodes
called `n[01-04]` on the the `172.16.?.0` virtual network, where '?' is a
random number, what allows to have several workspaces at the same time. The
keys of the file `~/.ssh/authorized_keys` are exported to the `root` account on
`ww4-host`. The root account has the password `linux`.  Also the according
warewulf package is installed, but not further configured.  The default base OS
is a `openSUSE Leap 15.5`, but following other base OS for `ww4-host` can be
selected by setting the command line variable `distribution`:
* leap (openSUSE Leap 15.5)
* tw (openSUSE Tumbleweed)
* local-zypp (use local.qcow2 and zypper for installation)

Now you can login to the `ww4-host` and check if `warewulf.conf` got the right
network configuration.  After that configure warewulf with following command
```
systemctl enable --now warewulfd
wwctl configure -a
```
and add the nodes with
```
wwctl node add n[01-04] -I 172.16.?.101
```
From this point on you should check the warewulf documentation on how to set up
the cluster.

After the test you have to remove the virtual machines with
```
terraform destroy
```

### Img Download
`http://ftp.halifax.rwth-aachen.de/rockylinux/9.3/images/x86_64/Rocky-9-GenericCloud-Base.latest.x86_64.qcow2`

### Configure number of nodes
```
terraform apply -var="nr-nodes=2"
```

### Don't install warewulf
```
terraform apply -var="packages=fortune"
```

## known errors
The key in `~/.ssh/authorized_keys` are copied over to `ww4-host`. If there is
more than one key, cloud-init fails.

## Attention
If wanting compute nodes to run via EFI.
Following firmware should be added to `ww4-nodes` in `warewulf-testenv.tf`

For openSuse:

```
  machine = "pc-q35-6.1"
  firmware = "/usr/share/qemu/ovmf-x86_64-smm-ms-code.bin"
  nvram {
    file     = "/var/tmp/efi${count.index}_EFIVARS.fd"
    template = "/usr/share/qemu/ovmf-x86_64-smm-ms-vars.bin"
  }
```

For ubuntu:
```
firmware = "/usr/share/ovmf/OVMF.fd"                                                                                                                                                                                                         
  nvram {                                                                                                                                                                                                                                      
    file     = "/var/tmp/efi${count.index}_EFIVARS.fd"                                                                                                                                                                                         
    template = "/usr/share/ovmf/OVMF.fd"                                                                                                                                                                                                       
  } 
```

