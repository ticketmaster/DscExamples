Summary
=======
This example shows how configurations can be nested. Nesting configurations in this way, along with utilizing node configuration data, can allow you to build a group of configurations that selectively adds certain components, based on the configuration data.

How To Run 
==========
This example can be run by cloning this repository, and then executing `RootConfiguration.ps1`. MOF files will be created in `\NestedConfigs\Output`.

How It Works
============
The `RootConfiguration.ps1` is the primary entry-point configuration. Executing this configuration will look for all `.ps1` files in the _Configurations_ folder, and will dynamically import them and execute the sub-configurations. It is required that sub-configurations have the same file name as their configuration name. This is used as a convention so that `RootConfiguration.ps1` knows which configuration to call.

Since each sub-configuration has access to the `$Node` variable, you can selectively skip configuration blocks (or return from the entire sub-configuration to return back to the root configuration) to change the resulting MOF file on a per-node basis.

Each node is processed consecutively, and the set of sub-configurations is processed for each node.