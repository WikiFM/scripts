How to use the scripts
----------------------

Then, proceed to the update (will backup mysql):

    ./update.sh

If everything went well, you can move the directories into production (with a brief downtime)

    ./deploy-to-production.sh
    
Special cases
-------------

If you never used this tool, remember to configure your paths in `dirs_conf.sh`

For the first usage, you can setup the needed git repos with the command:

    ./first-launch.sh

PANIC! If nothing works, restore MySQL to the previous state

    mysql database_name < database_name.sql