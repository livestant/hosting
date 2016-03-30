# Hosting utility
Utility for managing virtual servers on clusters with Virtualmin

This utility is console based tool for making mass operations with virtual servers. 
It allows to handle virtual servers placed on different clusters in such a way as they are all on a one machine. 
Though it's not required to use clusters. You just may keep this possibility in mind for future scaling.

# Installation

The utility now is in early version. It's mainly works, but possibly not in any environment. Now, to install it just clone the repository somewhere with git and make symbolic links:
```
git clone https://github.com/livestant/hosting.git
ln -s `pwd`/hosting.git/hosting /usr/bin/hosting
ln -s `pwd`/hosting.git/common.sh /usr/bin/common.sh
```

Later, normal DEB packages will be available.

# Examples
Create a new virtual server:

```
hosting create -d test.com -m mymail@somewhere.com
```

Register a new cluster:

```
hosting -r other.cluster.com
```

List virtual servers from both clusters:
```
hosting list
```
More detailed list:
```
hosting list -c "cluster owner status"
```

List with filtering:
```
hosting list -c "cluster owner status" -f "status~enabled"
```

The same, but shorter:
```
hosting list -C cOs -F senabled
```

See help for this command:
```
hosting help list
```

Move virtual servers to other cluster:
```
hosting move -d "test.com test2.com" -t other.cluster.com
```
