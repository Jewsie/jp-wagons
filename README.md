# jp-wagons
 A wagon script for RSGCore

**This a wagon script for RSGCore for RedM. I thought it was about time there was one specifically created for RSGCore, not just converted.**

**_Features;_**
- Buy Multiple wagons
- Trade wagons with other players
- Sell your wagon for buyprice
- Store your wagons if you don't need it out
- Inventory/Storage system on the wagons that can be modified easily in config
- Easy to modify config file


**_Keybinds_**
- [J] To call the Wagon
- [B] To open the stash


**_Depencies_**
- rsg-core

 
 ```CONFIG = {}

CONFIG.DealerPos = vector4(-1811.048, -556.9874, 155.98309, 253.00506)

CONFIG.wagonid = {
    {
        hash = -824257932, -- The hash id of the model
        model = 'cart01', -- The model itself
        name = 'Cart 1', Whichever name you would like it to be called
        price = 10, -- The price of the wagon
        wagonSpawn = vector4(-1802.889, -603.457, 154.11616, 313.62756), -- Ignore this, just add 0 to it or smt
        storage = 150, -- How many slots the wagon has
        weight = 500000 -- How much weight there can be in the wagon
    },
    {
        hash = -2053881888, 
        model = 'cart02', 
        name = 'Cart 2', 
        price = 20,
        wagonSpawn = vector4(-1798.418, -605.6962, 153.54212, 312.56396),
        storage = 225,
        weight = 500000
    },
    {
        hash = -1347283941, 
        model = 'cart03', 
        name = 'Cart 3', 
        price = 25,
        wagonSpawn = vector4(-1794.986, -608.3958, 152.83732, 313.71353),
        storage = 275,
        weight = 500000
    },
    {
        hash = -570691410, 
        model = 'cart04', 
        name = 'Cart 4', 
        price = 40,
        wagonSpawn = vector4(-1791.018, -611.6496, 151.76203, 320.38354),
        storage = 350,
        weight = 500000
    },
    {
        hash = 374792535, 
        model = 'cart05', 
        name = 'Cart 5', 
        price = 50,
        wagonSpawn = vector4(-1782.282, -602.8549, 151.64329, 141.97291),
        storage = 450,
        weight = 500000
    },
    {
        hash = 219205323, 
        model = 'cart06', 
        name = 'Cart 6', 
        price = 60,
        wagonSpawn = vector4(-1788.279, -601.3692, 153.14079, 147.14958),
        storage = 525,
        weight = 500000
    },
    {
        hash = 47200842, 
        model = 'cart07', 
        name = 'Cart 7', 
        price = 80,
        wagonSpawn = vector4(-1793.684, -597.9241, 154.24227, 147.7151),
        storage = 650,
        weight = 500000
    },
    {
        hash = -377157708, 
        model = 'cart08', 
        name = 'Cart 8', 
        price = 150,
        wagonSpawn = vector4(-1800.343, -593.3711, 155.12245, 146.94023),
        storage = 1000,
        weight = 1000000
    },
}```
