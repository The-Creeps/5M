# vdk_truck

Edit VERSION By : **Ze-Creeps**
Original Autor : **Vodkhard**
Original Link : ** https://github.com/vodkhard/vdk_truck **

> Resources for FiveM allowing the user to access to a car inventory and for developpers to add and remove items from this inventory.

## Requirements

- **es_freeroam**
- **vdk_inventory** last version : https://forum.fivem.net/t/release-inventory-system-v2-personal-menu/
- **ply_garage** (to add **personal vehicles**) : https://forum.fivem.net/t/release-en-fr-async-garages-v4-2-06-06-17-updated/
- **MySQL-Async** : https://forum.fivem.net/t/beta-mysql-async-library-v0-2-2/

## Compatibility "La_Life"
please add this line into the "inventory_client.lua" of your "fivemenu" folder
- **RegisterNetEvent("player:receiveItem")**

## Installation

- Place the folder `vdk_truck` to resources folder of FiveM
- Execute **dump.sql** file in your database (will create the tables and the constraints)

## Usage

- For users : Press your  INPUT CELLPHONE CAMERA FOCUS LOCK (usually '**L**') to show the menu in front a vehicle
- For developers : Use "**car:receiveItem**" and "**car:looseItem**" server events
- You can change the **max capacity** in _server.lua_ with the maxCapacity variable
- You can watch the **PutInCoffre** function of `vdk_inventory` to see an example

Add in this edit version
- Compatibility with "La_Life" 
- You can now select objects to put in the car chest directly from the menu.
- You can put any object into any vehicle, no need to own the vehicle... (But if you loose the vehicle you loose your objects too ..)
- Limit slot by class vehicle
- Not possible to open when the vehicle is closed ( status lock 2 and 7 )
- Some alert ( Full, No more slot, etc )
- Solved a problem with the items list after reboot.
