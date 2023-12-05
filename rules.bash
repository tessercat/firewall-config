# Commands to load iptables rules from file.
if [ "$1" = "v4" ]; then
    BIN=/sbin/iptables
elif [ "$1" = "v6" ]; then
    BIN=/sbin/ip6tables
else
    echo "v4 or v6"
    exit 1
fi
BASE=/opt/firewall/config
RULES=("$BASE/rules/$1/*")
echo $RULES

for file in ${RULES[@]}; do
    while read -r line; do
        $BIN $line
    done < $file
    echo "Restored $1 rules $(basename $file)"
done
