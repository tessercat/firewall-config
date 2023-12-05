# Commands to restore, flush and reload ipsets.
BIN=/sbin/ipset
BASE=/opt/firewall/config
MEMORY=($($BIN list -name)) # IP sets in memory.
shopt -s nullglob
SETS=("$BASE/sets/*")

contains() {
    local elem match="$1"
    shift
    for elem; do
        [[ "$elem" == "$match" ]] && return 0
    done
    return 1
}

for file in ${SETS[@]}; do

    # Restore the set if it's not in memory.
    ipset=$(basename $file)
    contains $ipset ${MEMORY[@]}
    if [ $? -ne 0 ]; then
        $BIN restore -file $file
        echo "Restored ipset $ipset"
    fi

    # Flush and reload the set.
    $BIN flush $ipset
    file=$BASE/lists/$ipset
    if [ -f $file ]; then
        while read -r line; do
            addr=$(echo $line | cut -d ' ' -f 1)
            $BIN add $ipset $addr
        done < $file
    fi
    echo "Flushed and reloaded ipset $ipset"
done
