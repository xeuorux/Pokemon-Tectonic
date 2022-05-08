Script threads:
https://reliccastle.com/resources/640/
https://www.pokecommunity.com/showthread.php?t=449364

Since the original script is abandonware, and I've been updating it, guess it's time to make my own thread for it.
Original Thread: https://www.pokecommunity.com/showthread.php?t=447015

Credits to mGriffin for the original script, Khaikaa for commissioning it, and Vendily for updating it to v18 and v19.

There's two parts:
    - a plug and play script for Essentials in cable_club.rb (It's a plugin in v19). You need to edit the HOST and PORT constants at the top to be the address and port of your server.
    - a Python3 server in cable_club.py. It needs your PBS files to run, by default it looks in the directory you run it from, but you can pass --pbs_dir to change that. You can also pass --host and --port or alter the HOST and PORT constants at the top. You also need to set EBDX_INSTALLED to true if you have it, so the script can handle the extra data EBDX requires.

Connections are established via Trainer IDs, which can be found on the trainer card screen. Think of them as a bit like friend codes.

The v19 version of the script requires at least mkxpz 2.2.3. You do not need the std folder, just the included files.

For hosting the server you could try free-tier on Google Cloud. It shouldn't use much processing power (but I'd recommend setting up some sensible limits, because there's nothing in the protocol to stop somebody DDOSing it).

Newly added in v2.1, a online trainer type that is used in online battles, kind of like how you can appear as different sprites in the Union Room. Call pbChangeOnlineTrainerType to have an easy preset event that allows the player to change using the contents of ONLINE_TRAINER_TYPE_LIST.
ONLINE_TRAINER_TYPE_LIST is an array containing either length 2 arrays (for gender locked trainer types) or a single Trainer Type ID.

Also new in v2.1, an optional serverinfo.ini file, for if you want to let your players set up their own servers. Of course, they will still need the PBS files, same as any server. The ini file contains up to 2 lines, a "HOST = X.X.X.X" line, and a "PORT = XXXX" line. Technically you can have more, but only the last HOST and PORT will work. These override the settings in the script. You don't need to define both in the file either.
Makes testing easier too.

Google Cloud instructions:
    0) Set up the desired port in the python script, and set the host to "0.0.0.0"
    1) Sign up for Google Cloud (this requires a credit card, even for the free trial).
    2) In the side bar, hover "Compute Engine" and select "VM Instances".
    3) Select "Create Instance".
    4) Under Machine Configuration, select E2-micro (one of the options supported by Google's free tier).
    5) Under Boot Disk, select Change, and make it a Ubuntu 18.04 (this comes with python 3.6).
    6) Click Create.
    7) In the side bar, hover "VPC Networks" and select "External IP Addresses".
    8) The IP address for the VM we just created should show here. Select CHANGE to reserve it as a static address and give it a name. Copy this address and put it in the ruby script file as the HOST.
    9) In the side bar, select "Firewall" and create a new Firewall rule, an Ingress rule for all ips (0.0.0.0/0) on TCP port 9999 (or whatever you have it in  the script).
    10) Return to the VM Instances, and press the SSH button to enter the terminal for the VM.
    11) You are now in the home folder of the VM. You can use the gear to manually upload files one at a time. You need to upload the python script, and the PBS files it requires. (You can also use git to clone the files into the VM.)
    12) To test, you can run "python3 cable_club.py"
    13) The server auto shuts down when the ssh session is closed but at that point you have to set up boot scripts for the VM.
    
Boot Scripts for Google Cloud VMs
    0) You need to change the python script's PBS property to "./home/YOUR_USERNAME_HERE". YOUR_USERNAME_HERE is the green part of the name before the @. This sets it to the home folder that you log into, adjust further if the PBS files are in a sub folder.
    1) In "VM Instances", click the name of your VM instance, and select Edit.
    2) Scroll down to the Custom Metadata section.
    3) Set the key to "startup-script" (no quotes), and the value to
        #! /bin/bash
        nohup python3 /home/YOUR_USERNAME_HERE/cable_club.py &
       If your server is in a sub folder, adjust the second line to it's proper location.
    4) Save the edits, and stop and reboot the VM.
    