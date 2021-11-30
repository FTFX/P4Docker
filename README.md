# P4Docker
Perforce Helix Core server in a Docker container.  

## Usage
This image requires 2 persistent volumes:  
1. One is for P4ROOT, defaulte location is ```/srv/p4d/```.   
2. Another one is for ```p4dctl``` configuration files, located in ```/etc/perforce/```.   
