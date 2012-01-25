Technical details
=================

Layout
------
Standard Layout for a level, from bottom to top
	
* Black stage
* Level Background
* Player and zombie sprite
* Light mask of the player (and deflagration)
* Blood rush
* Moviemonitor

Debug layout for a level, from bottom to top :

* Black stage
* Influence map
* Player and zombie sprite
* Moviemonitor

Achievements
------------

### Default values
```
	handgunCapacity = 3
	handgunRange = 50
	handgunCooldown = 30
	handgunReload = 60
	handgunAutomatic = false
	shotgunCapacity = 1
	shotgunRange = 50
	shotgunCooldown = 40
	shotgunReload = 60
	shotgunAutomatic = false
	railgunCapacity = 50
	railgunRange = 50
	railgunCooldown = 45
	railgunAutomatic = false
	uziCapacity = 15
	uziRange = 30
	uziCooldown = 4
	uziReload = 30
	uziAutomatic = false
```

### Final values
```
	handgunCapacity = 16
	handgunRange = ∞
	handgunCooldown = 15
	handgunReload = 30
	handgunAutomatic = true
	shotgunCapacity = 6
	shotgunRange = ∞
	shotgunCooldown = 20
	shotgunReload = 40
	shotgunAutomatic = true
	railgunCapacity = 50
	railgunRange = ∞
	railgunCooldown = 20
	railgunAutomatic =
	uziCapacity = 30
	uziRange = 200
	uziCooldown = 2
	uziReload = 15
	uziAutomatic = true
```

### Weapon achievement typical list
* Weapon unlocked
* Weapon: increased range (200)
* Weapon: increased magazine capacity
* Weapon: jungle style magazines
* Weapon: infinite range
* Weapon: faster cooldown (/2)
* Weapon: increased magazine capacity
* Weapon: faster reload (/2)
* Weapon: automatic reload


### Global Achievements

1. **Handgun unlocked**
1. Handgun: increased range (200)
1. Handgun: increased magazine capacity (6)
2. **Shotgun unlocked**
1. Handgun: jungle style magazines
2. Shotgun: increased range (100)
1. Handgun: infinite range
2. Shotgun: increased range (200)
1. Handgun: faster cooldown (20)
1. Handgun: increased magazine capacity (10)
1. Handgun: faster cooldown (15)
3. **Railgun unlocked**
2. Shotgun: increased magazine capacity (2)
1. Handgun: increased magazine capacity (16)
1. Handgun: faster reload (30)
2. Shotgun: infinite range
1. Handgun: automatic reload
3. Railgun: infinite range
2. Shotgun: faster cooldown (30)
2. Shotgun: increased magazine capacity (6)
3. Railgun: faster cooldown (30)
4. **Uzi unlocked**
2. Shotgun: faster reload (40)
2. Shotgun: faster cooldown (20)
4. Uzi: increased range (100)
3. Railgun: faster cooldown (20)
4. Uzi: increased magazine capacity (25)
2. Shotgun: automatic reload
4. Uzi: increased range (200)
4. Uzi: jungle style magazine
4. Uzi: increased magazine capacity (30)
4. Uzi: faster cooldown (2)
4. Uzi: faster reload (15)
4. Uzi: automatic reload