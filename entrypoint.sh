#!/bin/sh

# Copyright 2004-2020 L2J Server
# L2J Server is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.
# L2J Server is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
# You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

DATABASE_USER=${DATABASE_USER:-"root"}
DATABASE_PASS=${DATABASE_PASS:-"root"}
DATABASE_ADDRESS=${DATABASE_ADDRESS:-"mariadb"}
DATABASE_PORT=${DATABASE_PORT:-"3306"}
SERVER_DEBUG=${SERVER_DEBUG:-"False"}

AUTO_CREATE_ACCOUNTS=${AUTO_CREATE_ACCOUNTS:-"True"}
MAX_ONLINE_USERS=${MAX_ONLINE_USERS:-"300"}

RATE_XP=${RATE_XP:-"1"}
RATE_SP=${RATE_SP:-"1"}
RATE_PARTY_XP=${RATE_PARTY_XP:-"1"}
RATE_PARTY_SP=${RATE_PARTY_SP:-"1"}

RATE_DROP_ADENA=${RATE_DROP_ADENA:-"1"}
RATE_DROP_QUEST=${RATE_DROP_QUEST:-"1"}
RATE_QUESTS_REWARD=${RATE_QUESTS_REWARD:-"1"}
RATE_KARMA_EXP_LOST=${RATE_KARMA_EXP_LOST:-"1"}

PLAYER_DROP_LIMIT=${PLAYER_DROP_LIMIT:-"0"}
PLAYER_RATE_DROP=${PLAYER_RATE_DROP:-"0"}
PLAYER_RATE_DROP_ITEM=${PLAYER_RATE_DROP_ITEM:-"0"}
PLAYER_RATE_DROP_EQUIP=${PLAYER_RATE_DROP_EQUIP:-"0"}
PLAYER_RATE_DROP_EQUIP_WEAPON=${PLAYER_RATE_DROP_EQUIP_WEAPON:-"0"}
MINIMUM_PKS_BEFORE_DROP=${MINIMUM_PKS_BEFORE_DROP:-"1"}

PET_XP_RATE=${PET_XP_RATE:-"1"}
PET_FOOD_RATE=${PET_FOOD_RATE:-"1"}

echo "Using environment configuration:"
printenv | sort

echo "Waiting mariadb service in $DATABASE_ADDRESS:$DATABASE_PORT"
sleep 5s

STATUS=$(nc -z $DATABASE_ADDRESS $DATABASE_PORT; echo $?)
while [ "$STATUS" != 0 ]
do
    sleep 3s
    STATUS=$(nc -z $DATABASE_ADDRESS $DATABASE_PORT; echo $?)
done

# ---------------------------------------------------------------------------
# Database Installation
# ---------------------------------------------------------------------------

DATABASE=$(mysql -h "$DATABASE_ADDRESS" -P "$DATABASE_PORT" -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "SHOW DATABASES" | grep l2jdb)
if [ "$DATABASE" != "l2jdb" ]; then
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "DROP DATABASE IF EXISTS l2jdb";
    
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "CREATE OR REPLACE USER 'l2j'@'%' IDENTIFIED BY 'l2jserver2020';";
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "GRANT ALL PRIVILEGES ON *.* TO 'l2j'@'%' IDENTIFIED BY 'l2jserver2020';";
    mysql -h $DATABASE_ADDRESS -P $DATABASE_PORT -u "$DATABASE_USER" -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES;";
    
    chmod +x /opt/l2j/cli/l2jcli.sh
    echo "Y" | java -jar /opt/l2j/cli/l2jcli.jar db install -sql /opt/l2j/server/login/sql -u l2j -p l2jserver2020 -m FULL -t LOGIN -c -mods -url jdbc:mariadb://$DATABASE_ADDRESS:$DATABASE_PORT
    echo "Y" | java -jar /opt/l2j/cli/l2jcli.jar db install -sql /opt/l2j/server/game/sql -u l2j -p l2jserver2020 -m FULL -t GAME -c -mods -url jdbc:mariadb://$DATABASE_ADDRESS:$DATABASE_PORT
    #java -jar /opt/l2j/server/cli/l2jcli.jar account create -u l2j -p l2j -a 8 -url jdbc:mariadb://mariadb:3306
fi

# ---------------------------------------------------------------------------
# Log folders
# ---------------------------------------------------------------------------

LF="/opt/l2j/server/login/log"
if test -d "$LF"; then
    echo "Login log folder server exists"
else
    mkdir $LF
fi

GF="/opt/l2j/server/game/log"
if test -d "$GF"; then
    echo "Game log folder server exists"
else
    mkdir $GF
fi

# ---------------------------------------------------------------------------
# General
# ---------------------------------------------------------------------------

sed -i "s#Debug = False#Debug = $SERVER_DEBUG#g" /opt/l2j/server/game/config/options.properties

# ---------------------------------------------------------------------------
# Rates
# ---------------------------------------------------------------------------

sed -i "s#RateXp = 1#RateXp = $RATE_XP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateSp = 1#RateSp = $RATE_SP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RatePartyXp = 1#RatePartyXp = $RATE_PARTY_XP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RatePartySp = 1#RatePartySp = $RATE_PARTY_SP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateDropAdena = 1#RateDropAdena = $RATE_DROP_ADENA#g" /opt/l2j/server/game/config/rates.properties

sed -i "s#RateDropQuest = 1#RateDropQuest = $RATE_DROP_QUEST#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateQuestsReward = 1#RateQuestsReward = $RATE_QUESTS_REWARD#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#RateKarmaExpLost = 1#RateKarmaExpLost = $RATE_KARMA_EXP_LOST#g" /opt/l2j/server/game/config/rates.properties

sed -i "s#PlayerDropLimit = 0#PlayerDropLimit = $PLAYER_DROP_LIMIT#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#PlayerRateDrop = 0#PlayerRateDrop = $PLAYER_RATE_DROP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#PlayerRateDropItem = 0#PlayerRateDropItem = $PLAYER_RATE_DROP_ITEM#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#PlayerRateDropEquip = 0#PlayerRateDropEquip = $PLAYER_RATE_DROP_EQUIP#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#PlayerRateDropEquipWeapon = 0#PlayerRateDropEquipWeapon = $PLAYER_RATE_DROP_EQUIP_WEAPON#g" /opt/l2j/server/game/config/rates.properties

sed -i "s#PetXpRate = 1#PetXpRate = $PET_XP_RATE#g" /opt/l2j/server/game/config/rates.properties
sed -i "s#PetFoodRate = 1#PetFoodRate = $PET_FOOD_RATE#g" /opt/l2j/server/game/config/rates.properties

sed -i "s#MinimumPKRequiredToDrop = 5,1#MinimumPKRequiredToDrop = $MINIMUM_PKS_BEFORE_DROP#g" /opt/l2j/server/game/config/pvp.properties

# ---------------------------------------------------------------------------
# Server
# ---------------------------------------------------------------------------

sed -i "s#MaximumOnlineUsers = 300#MaximumOnlineUsers = $MAX_ONLINE_USERS#g" /opt/l2j/server/game/config/server.properties
sed -i "s#AutoCreateAccounts = True#AutoCreateAccounts = $AUTO_CREATE_ACCOUNTS#g" /opt/l2j/server/login/config/server.properties

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

sed -i "s#jdbc:mariadb://localhost/l2jdb#jdbc:mariadb://mariadb:3306/l2jdb#g" /opt/l2j/server/login/config/database.properties
sed -i "s#jdbc:mariadb://localhost/l2jdb#jdbc:mariadb://mariadb:3306/l2jdb#g" /opt/l2j/server/game/config/server.properties

# ---------------------------------------------------------------------------
# Login and Gameserver start
# ---------------------------------------------------------------------------

echo "Starting login server"

cd /opt/l2j/server/login/
bash ./startLoginServer.sh
tail -f log/stdout.log

echo "Starting game server"

cd /opt/l2j/server/game/
bash ./startGameServer.sh
tail -f log/stdout.log